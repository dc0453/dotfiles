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

CONTENT_KEY = 'contentKey'
CONTENT_TYPE = 'contentType'
CONTENT_TITLE = 'title'
CONTENT_CREATOR = 'contentCreator'
CONTENT_MODTIME = 'contentModTime'

UNIT_PAGE_ID = 'pageId'
UNIT_TITLE = 'title'
UNIT_CREATOR = 'creator'
UNIT_MODIFY_TIME = 'modifyTime'
UNIT_OPERATOR_TIME = 'operatorTime'

PAGE_CONTENT_ID = 'contentId'
PAGE_CHILD_COUNT = 'childCount'
PAGE_MODIFY_TIME = 'modifyTime'
PAGE_MODIFIER = 'modifier'
PAGE_PATH = 'pagePath'


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
    # cookies_str = 'login_manager.get_cookies()'
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


def operation_history(operationTypes=3, page_no=1, page_size=50):
    url = 'https://km.sankuai.com/api/operationHistory?pageNo={}&pageSize={}&operationTypes={}'.format(
        page_no, page_size, operationTypes)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result and 'units' in result['data']:
        units = result['data']['units']
        return [{
            UNIT_PAGE_ID: u[UNIT_PAGE_ID],
            UNIT_TITLE: u[UNIT_TITLE],
            UNIT_CREATOR: u[UNIT_CREATOR],
            UNIT_MODIFY_TIME: u[UNIT_MODIFY_TIME],
            UNIT_OPERATOR_TIME: u[UNIT_OPERATOR_TIME]
        } for u in units]
    return None


def query_limit_operation_history(km_history_limit=300):
    page_no = 1
    page_size = 50
    result_limit = []
    history_record = operation_history(page_no=page_no, page_size=page_size)
    result_limit.extend(history_record)
    while len(result_limit) < km_history_limit:
        page_no = page_no + 1
        history_record = operation_history(page_no=page_no, page_size=page_size)
        if history_record:
            result_limit.extend(history_record)
        else:
            break
    return result_limit


def last_edit(offset=0, limit=300):
    url = 'https://km.sankuai.com/api/pages/latestEdit?offSet={}&limit={}'.format(offset, limit)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result and 'units' in result['data']:
        units = result['data']['units']
        return [{
            UNIT_PAGE_ID: u[UNIT_PAGE_ID],
            UNIT_TITLE: u[UNIT_TITLE],
            UNIT_CREATOR: u[UNIT_CREATOR],
            UNIT_MODIFY_TIME: u[UNIT_MODIFY_TIME],
        } for u in units]
    return None


# content_types : 0-其他收藏  1-常用收藏
def query_collections(collection_type, content_types="0,2"):
    url = 'https://km.sankuai.com/api/collection/collection?collectionType={}&contentTypes={}'.format(
        collection_type, content_types)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result and 'contentVOList' in result['data']:
        content_list = result['data']['contentVOList']
        return [{
            CONTENT_KEY: c[CONTENT_KEY],
            CONTENT_TYPE: c[CONTENT_TYPE],
            CONTENT_TITLE: c[CONTENT_TITLE],
            CONTENT_CREATOR: c[CONTENT_CREATOR],
            CONTENT_MODTIME: c[CONTENT_MODTIME],
        } for c in content_list]
    return None


def get_space_id_by_mis(mis):
    url = 'https://km.sankuai.com/api/spaces/person?mis={}'.format(mis)
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    if 'data' in result:
        return result['data']


def get_pages_by_space_id(space_id):
    url = 'https://km.sankuai.com/api/spaces/child/{}'.format(space_id)
    result = invoke_km_api_get(url)
    return get_space_page_list(result)


def get_child_pages_by_id(space_id, page_id):
    url = 'https://km.sankuai.com/api/pages/child/{}/{}'.format(space_id, page_id)
    result = invoke_km_api_get(url)
    return get_space_page_list(result)


def get_space_page_list(result):
    if 'data' in result and 'list' in result['data']:
        page_list = result['data']['list']
        return [{
            PAGE_CONTENT_ID: p[PAGE_CONTENT_ID],
            CONTENT_TITLE: p[CONTENT_TITLE],
            PAGE_CHILD_COUNT: p[PAGE_CHILD_COUNT],
            PAGE_MODIFY_TIME: p[PAGE_MODIFY_TIME],
            PAGE_MODIFIER: p[PAGE_MODIFIER],
        } for p in page_list]


def get_space_pages(space_id):
    pages = get_pages_by_space_id(space_id)
    all_pages = []
    current_path = ''
    return get_all_pages(all_pages, space_id, current_path, pages)


def get_all_pages(all_pages, space_id, current_path, pages):
    for p in pages:
        page_id = p[PAGE_CONTENT_ID]
        if p[PAGE_CHILD_COUNT]:
            sub_pages = get_child_pages_by_id(space_id, page_id)
            if sub_pages:
                get_all_pages(all_pages, space_id, current_path + '/' + p[CONTENT_TITLE], sub_pages)
        all_pages.append({
            PAGE_CONTENT_ID: p[PAGE_CONTENT_ID],
            CONTENT_TITLE: p[CONTENT_TITLE],
            PAGE_CHILD_COUNT: p[PAGE_CHILD_COUNT],
            PAGE_MODIFY_TIME: p[PAGE_MODIFY_TIME],
            PAGE_MODIFIER: p[PAGE_MODIFIER],
            PAGE_PATH: current_path,
        })
    return all_pages


def invoke_km_api_get(url):
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    result = resp.json()
    return result


if __name__ == '__main__':
    print(search_history())
    # print get_space_pages()
