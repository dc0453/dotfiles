#!/usr/bin/python
# encoding: utf-8
import sys

from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from utils import wf, get_args
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


def query_all_logs():
    logs = query_paged_log(
        'http://logcenter.data.sankuai.com/logcenter/rest/logs/?format=json&offset=0&limit=25'
        '&select_dep_name=lc_operators')
    next_url = logs['next']
    logs_result = [{LOG_NAME: log[LOG_NAME], DESC: log[DESC]} for log in logs['results']]
    while next_url:
        logs = query_paged_log(next_url)
        next_url = logs['next']
        logs_result.extend([{LOG_NAME: log[LOG_NAME], DESC: log[DESC]} for log in logs['results']])
    return logs_result


def key_for_log(log):
    return u'{} {}'.format(log[LOG_NAME], log[DESC])


def main(workflow):
    query, mis, cache_seconds = get_args()
    logs = wf().cached_data('my_logs', query_all_logs, max_age=int(cache_seconds))
    logs = wf().filter(query, logs, key_for_log)
    if logs:
        for log in logs:
            wf().add_item(log[LOG_NAME], log[DESC], log[LOG_NAME], valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    sys.exit(wf().run(main))
    # delete_cookies(LOG_CENTER_COOKIE_NAME)
