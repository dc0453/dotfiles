#!/usr/local/bin/python
# encoding: utf-8
import json
from utils import url_encode

from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from workflow import web

LOGIN_URL = 'https://avatar.mws.sankuai.com/'
WAIT_ELEMENT = EC.presence_of_element_located((By.ID, "app"))
COOKIE_NAME = 'avatar_cookies'

login_manager = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)


def query_services(keyword):
    url = 'https://avatar.mws.sankuai.com/api/v1/avatar/srv?query={}&page=1&pageSize=10'.format(
        url_encode(keyword))
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result and 'items' in result['data']:
        items = result['data']['items']
        return [{'name': item['name'], 'appkey': item['appkey'][0], 'comment': item['comment']} for item in items]
    return None


if __name__ == '__main__':
    print query_services('10.178.27.195')
