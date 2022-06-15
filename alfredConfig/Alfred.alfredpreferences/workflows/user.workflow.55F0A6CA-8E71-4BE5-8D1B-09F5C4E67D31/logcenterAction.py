#!/usr/bin/python
# encoding: utf-8

from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from workflow import web

LOGIN_URL = 'http://logcenter.data.sankuai.com/index'
WAIT_ELEMENT = EC.presence_of_element_located((By.ID, "fullpage"))
COOKIE_NAME = 'log_center_cookies'

login_manager = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)

LOG_NAME = 'log_name'
DESC = 'description'


def query_paged_log(url):
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    return resp.json()


def query_logs(select_dep_name):
    logs = query_paged_log(
        'http://logcenter.data.sankuai.com/logcenter/rest/logs/?format=json&offset=0&limit=25'
        '&select_dep_name={}'.format(select_dep_name))
    next_url = logs['next']
    logs_result = [{LOG_NAME: log[LOG_NAME], DESC: log[DESC]} for log in logs['results']]
    while next_url:
        logs = query_paged_log(next_url)
        next_url = logs['next']
        logs_result.extend([{LOG_NAME: log[LOG_NAME], DESC: log[DESC]} for log in logs['results']])
    return logs_result


def query_my_logs():
    return query_logs('lc_operators')


def query_all_logs():
    return query_logs('all')


def key_for_log(log):
    return u'{} {}'.format(log[LOG_NAME], log[DESC])
