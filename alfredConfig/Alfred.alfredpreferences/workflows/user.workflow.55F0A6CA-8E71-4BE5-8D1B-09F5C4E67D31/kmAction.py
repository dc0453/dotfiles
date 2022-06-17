#!/usr/local/bin/python
# encoding: utf-8
import json
from utils import url_encode

from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from workflow import web

LOGIN_URL = 'https://km.sankuai.com/'
WAIT_ELEMENT = EC.presence_of_element_located((By.ID, "app"))
COOKIE_NAME = 'km_cookies'

login_manager = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)


def query_users(keyword):
    url = 'https://km.sankuai.com/api/users/neixin/search?input={}&pageSize=10&pageNo=0'.format(url_encode(keyword))
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result and 'users' in result['data']:
        users = result['data']['users']
        return [v
                for user in users
                for (k, v) in user.items()
                ]
    return None


def search_history():
    url = 'https://km.sankuai.com/api/citadelsearch/content/history'
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False, )
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    return result['data']


def query_dxuid(mis):
    url = 'https://km.sankuai.com/dxuid'
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str, 'Content-Type': 'application/json; charset=utf-8'}
    pay_load = [mis]
    resp = web.post(url, data=json.dumps(pay_load), headers=headers, allow_redirects=False, )
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    return result['data'][0]


if __name__ == '__main__':
    print query_dxuid()


def suggest(query):
    url = 'https://km.sankuai.com/api/citadelsearch/content/sug?keyword={}'.format(url_encode(query))
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str, 'Content-Type': 'application/json; charset=utf-8'}
    resp = web.get(url, headers=headers, allow_redirects=False, )
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result and 'sugList' in result['data']:
        sug_list = result['data']['sugList']
        return [sug['sug'] for sug in sug_list]
