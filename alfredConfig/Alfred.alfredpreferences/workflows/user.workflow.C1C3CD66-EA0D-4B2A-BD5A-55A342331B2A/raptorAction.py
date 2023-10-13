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

FIELD_NAME_ID = "id"
FIELD_NAME_NAME = "name"
FIELD_NAME_TITLE = "title"
FIELD_NAME_DOMAIN = "domain"
FIELD_NAME_DESC = "desc"
DASH_BOARD_IS_CORE = "isCore"
DASH_BOARD_ORG = "org"

SUCCESS_RESP_CODE = 10000


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


def get_dashboard_org(dashboard_record):
    bg = ''
    if 'bg' in dashboard_record and 'name' in dashboard_record['bg']:
        bg = dashboard_record['bg']['name']
    bu = ''
    if 'bu' in dashboard_record and 'name' in dashboard_record['bu']:
        bu = dashboard_record['bu']['name']
    org = bg
    if bu:
        org = u'{}/{}'.format(bg, bu)
    if 'contents' in dashboard_record:
        contents = dashboard_record['contents']
        if contents:
            org += '/'
            org += '/'.join([c['name'] for c in contents])
    return org


def my_favorate_dashboard():
    url = 'https://raptor.mws.sankuai.com/raptor/dashboard/userFavorite'
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'result' in result:
        result_data = result['result']
        if result_data:
            return [{
                FIELD_NAME_ID: r[FIELD_NAME_ID],
                FIELD_NAME_NAME: r[FIELD_NAME_NAME],
                FIELD_NAME_DESC: r[FIELD_NAME_DESC],
                DASH_BOARD_IS_CORE: r[DASH_BOARD_IS_CORE],
                DASH_BOARD_ORG: get_dashboard_org(r)
            } for r in result_data]
    return None


def get_charts_by_dashboard(dashboard_id, is_core):
    if is_core:
        url = 'https://raptor.mws.sankuai.com/raptor/dashboard/core/chartIds?dashboardId={}'.format(dashboard_id)
    else:
        url = 'https://raptor.mws.sankuai.com/raptor/dashboard/chartIds?dashboardId={}'.format(dashboard_id)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    code = result['code']
    message = result['message']
    if code == SUCCESS_RESP_CODE:
        if 'result' in result:
            result_data = result['result']
            if 'charts' in result_data:
                charts = result_data['charts']
                if charts:
                    return [{
                        FIELD_NAME_ID: chart[FIELD_NAME_ID],
                        FIELD_NAME_NAME: chart[FIELD_NAME_NAME],
                    } for chart in charts]
    else:
        raise RuntimeError(message)
    return None


# 搜索大盘
def search_dashboard(dashboard_name, is_core):
    if is_core:
        url = 'https://raptor.mws.sankuai.com/raptor/dashboard/core/searchDashboard?name={}'.format(
            url_encode(dashboard_name))
    else:
        url = 'https://raptor.mws.sankuai.com/raptor/dashboard/searchDashboard?name={}'.format(
            url_encode(dashboard_name))

    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'result' in result:
        result_data = result['result']
        if result_data:
            return [{
                FIELD_NAME_ID: dashboard[FIELD_NAME_ID],
                FIELD_NAME_NAME: dashboard[FIELD_NAME_NAME],
                DASH_BOARD_IS_CORE: is_core,
                DASH_BOARD_ORG: get_dashboard_org(dashboard)
            } for dashboard in result_data]
    return None


# 获取前端工程id
def get_front_project():
    url = 'https://raptor.mws.sankuai.com/cat/mobile/getProject'
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    code = result['code']
    message = result['message']
    if code == SUCCESS_RESP_CODE:
        if 'result' in result:
            project_list = result['result']
            if project_list:
                return [{
                    FIELD_NAME_ID: p[FIELD_NAME_ID],
                    FIELD_NAME_DOMAIN: p[FIELD_NAME_DOMAIN],
                } for p in project_list]
    else:
        raise RuntimeError(message)
    return None


# 获取前端工程下的api
def get_api_by_project(project_id):
    url = 'https://raptor.mws.sankuai.com/cat/mobile/getApiByProject?projectId={}'.format(project_id)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    code = result['code']
    message = result['message']
    if code == SUCCESS_RESP_CODE:
        if 'result' in result:
            result_data = result['result']
            api_list = []
            if 'group' in result_data:
                group_list = result_data['group']
                if group_list:
                    for g in group_list:
                        group = {
                            FIELD_NAME_ID: g[FIELD_NAME_ID],
                            FIELD_NAME_NAME: u'API组 - {}'.format(g[FIELD_NAME_NAME]),
                            FIELD_NAME_TITLE: g[FIELD_NAME_TITLE],
                        }
                        api_list.append(group)
            if 'single' in result_data:
                single_api_list = result_data['single']
                if single_api_list:
                    api_list.extend([{
                        FIELD_NAME_ID: api[FIELD_NAME_ID],
                        FIELD_NAME_NAME: api[FIELD_NAME_NAME],
                        FIELD_NAME_TITLE: api[FIELD_NAME_TITLE],
                    } for api in single_api_list])
            return api_list
    else:
        raise RuntimeError(message)
    return None


if __name__ == '__main__':
    print(my_favorate_dashboard())
