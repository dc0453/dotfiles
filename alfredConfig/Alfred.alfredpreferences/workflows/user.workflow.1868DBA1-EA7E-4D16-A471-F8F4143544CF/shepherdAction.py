# -*- coding: utf-8 -*-
# @Time     : 2024/3/24 16:40
# @Author   : liuyulong06
# @File     : shepherdAction.py
from LoginEnvAwareManager import LoginEnvAwareManager
from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
import webUtils

LOGIN_URL = 'https://shepherd.mws.sankuai.com'
LOGIN_URL_TEST = 'https://shepherd.mws-test.sankuai.com'
WAIT_ELEMENT = EC.presence_of_element_located((By.ID, "app"))
COOKIE_NAME = 'shepherd_cookies'

login_manager_prod = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)
login_manager_test = LoginManager(LOGIN_URL_TEST, WAIT_ELEMENT, COOKIE_NAME + "_TEST")
login_manager = LoginEnvAwareManager(login_manager_prod, login_manager_test)

SHEPHERD_GROUP_ID = 'id'
SHEPHERD_GROUP_NAME = 'name'
SHEPHERD_GROUP_DESC = 'description'
SHEPHERD_GROUP_PREFIX = 'commonPrefix'

SHEPHERD_API_ID = 'id'
SHEPHERD_API_NAME = 'name'
SHEPHERD_API_PATH = 'path'
SHEPHERD_API_GROUP_ID = 'apiGroupId'
SHEPHERD_API_GROUP_NAME = 'apiGroupName'
SHEPHERD_API_DESC = 'description'


def key_for_group_record(record):
    return u'{} {} {}'.format(
        record[SHEPHERD_GROUP_NAME],
        record[SHEPHERD_GROUP_DESC],
        record[SHEPHERD_GROUP_PREFIX]
    )


def key_for_api_record(record):
    return u'{} {} {} {}'.format(
        record[SHEPHERD_API_NAME],
        record[SHEPHERD_API_PATH],
        record[SHEPHERD_API_DESC],
        record[SHEPHERD_API_GROUP_NAME]
    )


def search_shepherd(keyword='', env='prod'):
    """
    api response example：{"code":0,"data":{"apiGroups":[],"apis":[{"apiGroupId":7242,"apiGroupName":"apaas-applicaion-platform","apiId":126366,"apiName":"role_apply"}]},"message":"成功"}
    api group response example：{"code":0,"data":{"apiGroups":[{"apiGroupId":7242,"apiGroupName":"apaas-applicaion-platform"}],"apis":[]},"message":"成功"}
    """
    url = login_manager.get_url('/spapi/v1/search', env)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    params = {'query': keyword}
    result = webUtils.get(url, login_manager, params=params, headers=headers)
    if result['code'] == 0:
        return result['data']['apiGroups'], result['data']['apis']
    return [], []


def api_by_group(group_id, env='prod'):
    relative_url = '/spapi/v1/apis/{}'.format(group_id)
    url = login_manager.get_url(relative_url, env)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str, 'Accept': 'application/json'}
    return extract_api_result(webUtils.get(url, login_manager, headers=headers))


def extract_group_result(resp_json):
    if 'data' in resp_json:
        items = resp_json['data']
        if items:
            return [{
                SHEPHERD_GROUP_ID: item[SHEPHERD_GROUP_ID],
                SHEPHERD_GROUP_NAME: item[SHEPHERD_GROUP_NAME],
                SHEPHERD_GROUP_DESC: item[SHEPHERD_GROUP_DESC] if SHEPHERD_GROUP_DESC in item else '',
                SHEPHERD_GROUP_PREFIX: item[SHEPHERD_GROUP_PREFIX] if SHEPHERD_GROUP_PREFIX in item else '',
            } for item in items]
    return []


def extract_api_result(resp_json):
    if 'data' in resp_json:
        items = resp_json['data']
        if items:
            return [{
                SHEPHERD_API_ID: item[SHEPHERD_API_ID],
                SHEPHERD_API_NAME: item[SHEPHERD_API_NAME],
                SHEPHERD_API_PATH: item[SHEPHERD_API_PATH],
                SHEPHERD_API_GROUP_ID: item[SHEPHERD_API_GROUP_ID],
                SHEPHERD_API_GROUP_NAME: item[SHEPHERD_API_GROUP_NAME],
                SHEPHERD_API_DESC: item[SHEPHERD_API_DESC] if SHEPHERD_API_DESC in item else '',
            } for item in items]
    return []


def groups_list(env='prod'):
    relative_url = '/spapi/v1/groups/list'
    url = login_manager.get_url(relative_url, env)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str, 'Accept': 'application/json'}
    resp_json = webUtils.get(url, login_manager, headers=headers)
    return extract_group_result(resp_json)


def all_my_api_list(env='prod'):
    api_groups = groups_list(env)
    all_my_apis = []
    for g in api_groups:
        apis = api_by_group(g[SHEPHERD_GROUP_ID], env)
        if apis:
            all_my_apis.extend(apis)
    return all_my_apis


def build_api_detail_url(api):
    """
    example: https://shepherd.mws.sankuai.com/api-detail?api_group_name=apaas-applicaion-platform&api_group_id=7242&api_name=role_apply&api_id=126366&group_tab=api-manage
    """
    return 'api-detail?api_group_name={}&api_group_id={}&api_name={}&api_id={}&group_tab=api-manage' \
        .format(api['apiGroupName'], api['apiGroupId'], api['apiName'], api['apiId'])


def build_api_group_url(api_group):
    """
    example: https://shepherd.mws.sankuai.com/api-group-detail?api_group_name=apaas-applicaion-platform&api_group_id=7242
    """
    return 'api-group-detail?api_group_name={}&api_group_id={}'.format(
        api_group['apiGroupName'], api_group['apiGroupId'])


if __name__ == '__main__':
    # print(api_by_group(24551, 'test'))
    # print(groups_list('test'))
    print(all_my_api_list('test'))
    # print(search_shepherd('phf', 'test'))
