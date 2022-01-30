#!/usr/bin/python
# encoding: utf-8
import getpass
from multiprocessing import Process
from os import path

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver import ChromeOptions
from selenium.webdriver.support.ui import WebDriverWait
from utils import wf
from workflow import PasswordNotFound


class LoginManager(object):
    def __init__(self, login_url, wait_element, cookie_name):
        """
        Args:
            login_url : login url
            wait_element: webbrowser wait until wait_element is present
            cookie_name: cookie name
        """
        self.login_url = login_url
        self.wait_element = wait_element
        self.cookie_name = cookie_name

    def login(self):
        server = Process(target=self.__login_in_browser)
        server.start()

    def __login_in_browser(self, chrome_driver_path='/usr/local/bin/chromedriver'):
        cookies = {}
        if path.exists(chrome_driver_path):
            options = ChromeOptions()
            options.add_argument("user-data-dir=~/Library/Application Support/Google/Chrome/Default")
            browser = webdriver.Chrome(executable_path=chrome_driver_path, options=options)
        else:
            browser = webdriver.Safari()
        # options = ChromeOptions()
        # options.add_argument("user-data-dir=/Users/{}/Library/Application Support/Google/Chrome/Default"
        #                      .format(getpass.getuser()))
        # browser = webdriver.Chrome(executable_path='./chromedriver', options=options)
        browser.get(self.login_url)
        delay = 60  # seconds
        try:
            WebDriverWait(browser, delay).until(self.wait_element)
            for c in browser.get_cookies():
                cookies[c['name']] = c['value']
            browser.quit()
            cookie_str = ';'.join(['{0}={1}'.format(k, v) for k, v in cookies.items()])
            wf().logger.info('login success !')
            self.save_cookies(cookie_str)
        except TimeoutException:
            wf().logger.warning('login timeout !')
            raise RuntimeError('login timeout !')
        # except Exception:
        #     raise RuntimeError('login failure !')

    def check_login_status(self, resp):
        if resp.status_code == 301 or resp.status_code == 401 or resp.status_code == 302:
            self.re_login()
            raise RuntimeError('login timeout , please login first , then retry.')

    def get_cookies(self):
        try:
            return wf().get_password(self.cookie_name)
        except PasswordNotFound:
            self.login()
            raise RuntimeError('please login first, then retry')

    def save_cookies(self, value):
        return wf().save_password(self.cookie_name, value)

    def delete_cookies(self):
        try:
            wf().delete_password(self.cookie_name)
        except PasswordNotFound:
            pass

    def re_login(self):
        self.delete_cookies()
        self.login()
