#!/usr/local/bin/python
# encoding: utf-8
from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from utils import url_encode
from workflow import web

LOGIN_URL = 'https://raptor.mws.sankuai.com/'
WAIT_ELEMENT = EC.presence_of_element_located((By.ID, "syno-nsc-ext-gen3"))
COOKIE_NAME = 'rpt_cookies'

login_manager = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)


def query_host(keyword):
    url = 'https://raptor.mws.sankuai.com/raptor/s/hosts/endpoint/list?query={}&query2=&mode=endpoint&limit=10'.format(
        url_encode(keyword))
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'result' in result and 'machines' in result['result']:
        return result['result']['machines']
    return None


if __name__ == '__main__':
    print query_host('10.178.27.195')
