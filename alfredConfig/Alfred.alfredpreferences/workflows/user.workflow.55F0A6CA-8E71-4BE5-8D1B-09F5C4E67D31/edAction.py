#!/usr/bin/python
# encoding: utf-8

from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from workflow import web
import socket

# login manager
LOGIN_URL = 'http://ed.sankuai.com/#/metrics/dashboard/homePage'
WAIT_ELEMENT = EC.presence_of_element_located((By.ID, "app-page-body_9AAE"))
login_manager = LoginManager(LOGIN_URL, WAIT_ELEMENT, "ed_cookies")
TIMEOUT = 5

def query_release_plan_paged_list(url, page_no, page_size):
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    params = {'pageNo': page_no, 'pageSize': page_size}
    try:
        resp = web.get(url, params=params, headers=headers, allow_redirects=False, timeout=TIMEOUT)
        login_manager.check_login_status(resp)
        resp.raise_for_status()
        return resp.json()
    except socket.timeout:
        login_manager.re_login()
        # ed token过期后，接口会超时。。
        raise RuntimeError('ed timeout，please login again')


def query_all_release_plan_list():
    page_no = 1
    resp = query_release_plan_paged_list(
        'http://ed.sankuai.com/plugin/ed/api/onlineprogram/getListByUserName', page_no=page_no, page_size=15)
    online_plan_data = resp['data']
    result_online_list = []
    if online_plan_data:
        test_apply_list = online_plan_data['list']
        count = online_plan_data['count']
        result_online_list.extend(
            [{'id': record['id'], 'name': record['name'], 'projectOnlineTime': record['projectOnlineTime']} for record
             in test_apply_list])
        # while len(result_online_list) < count:
        #     page_no = page_no + 1
        #     resp = query_release_plan_paged_list('http://ed.sankuai.com/plugin/ed/api/onlineprogram/getListByUserName',
        #                                          page_no=page_no, page_size=15)
        #     online_plan_data = resp['data']
        #     count = online_plan_data['count']
        #     test_apply_list = online_plan_data['list']
        #     if not test_apply_list:
        #         break
        #     result_online_list.extend(
        #         [{'id': record['id'], 'name': record['name'], 'projectOnlineTime': record['projectOnlineTime']} for
        #          record in test_apply_list])
    return result_online_list


def query_test_apply_paged_list(url, page_no, page_size):
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    params = {'pageNo': page_no, 'pageSize': page_size}
    try:
        resp = web.get(url, params=params, headers=headers, allow_redirects=False, timeout=TIMEOUT)
        login_manager.check_login_status(resp)
        resp.raise_for_status()
        return resp.json()
    except socket.timeout:
        login_manager.re_login()
        # ed token过期后，接口会超时。。。
        raise RuntimeError('ed timeout，please login again')


def query_all_test_apply_list():
    page_no = 1
    resp = query_test_apply_paged_list(
        'http://ed.sankuai.com/plugin/metrics/api/testapply/getListByUserName?type=2'
        '&isMainPage=true&status=0,1,2,3,4,6,7,22,23,24,25,26,27,28&lifeCycleStage=', page_no=page_no, page_size=5)
    test_apply_data = resp['data']
    result_apply_list = []
    if test_apply_data:
        test_apply_list = test_apply_data['list']
        count = test_apply_data['count']
        result_apply_list.extend([{'id': log['id'], 'name': log['name']} for log in test_apply_list])
        while len(result_apply_list) < count:
            page_no = page_no + 1
            resp = query_test_apply_paged_list('http://ed.sankuai.com/plugin/metrics/api/testapply/getListByUserName?'
                                               'type=2&isMainPage=true&status=0,1,2,3,4,6,7,22,23,24,25,26,27,28',
                                               page_no=page_no, page_size=5)
            test_apply_data = resp['data']
            count = test_apply_data['count']
            test_apply_list = test_apply_data['list']
            if not test_apply_list:
                break
            result_apply_list.extend([{'id': log['id'], 'name': log['name']} for log in test_apply_list])
    return result_apply_list


if __name__ == '__main__':
    print(query_all_test_apply_list())
