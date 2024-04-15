#!/usr/bin/python
# encoding: utf-8
from LoginEnvAwareManager import LoginEnvAwareManager
from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from workflow import web

# cluster field
ID = 'id'
CLUSTER_ID = 'clusterId'
LEVEL = 'level'
NODE_NUM = 'node_num'
DATABASE_ID = 'id'
DATABASE_NAME = 'dbName'
NAME = 'name'
DESC = 'description'
APPKEY = 'appKey'
DBAUSER = 'dbaUser'

# login manager
COOKIE_NAME = 'rds_cookies'
LOGIN_URL = 'https://rds.mws.sankuai.com'
LOGIN_URL_TEST = 'https://rds.mws-test.sankuai.com'
WAIT_ELEMENT = EC.presence_of_element_located((By.CLASS_NAME, "rds-db-list"))

login_manager_prod = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)
login_manager_test = LoginManager(LOGIN_URL_TEST, WAIT_ELEMENT, COOKIE_NAME + "_TEST")
login_manager = LoginEnvAwareManager(login_manager_prod, login_manager_test)


def query_paged_clusters(page_no, env='prod'):
    cookies_str = login_manager.get_cookies(env)
    url = login_manager.get_url('/api/v3/resource/clusters', env)
    headers = {'Cookie': cookies_str}
    params = {'current': page_no, 'page_size': 10, 'with_node_num': 'true'}
    resp = web.get(url, params=params, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp, env)
    resp.raise_for_status()
    return resp.json()


def query_all_clusters(env='prod'):
    page_no = 1
    resp = query_paged_clusters(page_no, env)
    data = resp['data']
    result = []
    if data:
        data_list = data['data']
        total = data['total']
        result.extend([filter_cluster_fields(r) for r in data_list])
        while len(result) < total:
            page_no = page_no + 1
            data = query_paged_clusters(page_no, env)['data']
            total = data['total']
            data_list = data['data']
            if not data_list:
                break
            result.extend([filter_cluster_fields(r) for r in data_list])
    return result


def query_paged_database(cluster_id=None, keyword=None, page_size=20, page_no=None, env='prod'):
    params = {"access_only": "false"}
    if cluster_id:
        params['cluster_id'] = cluster_id
    if keyword:
        params['keyword'] = keyword
    params['current'] = 1 if not page_no else page_no
    params['page_size'] = 20 if not page_size else page_size
    url = login_manager.get_url('/api/v3/resource/databases', env)
    cookies_str = login_manager.get_cookies(env)
    headers = {'Cookie': cookies_str}
    resp = web.get(url, params=params, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp, env)
    resp.raise_for_status()
    data = resp.json()['data']
    if data and 'data' in data:
        return [filter_db_fields(r) for r in data['data']]
    return []


def query_databases_by_cluster_id(cluster_id, env='prod'):
    return query_paged_database(cluster_id, env=env)


def filter_cluster_fields(record):
    return {ID: record[ID], NAME: record[NAME], DESC: record[DESC], APPKEY: record[APPKEY], DBAUSER: record[DBAUSER],
            LEVEL: record[LEVEL], NODE_NUM: record[NODE_NUM]}


def filter_db_fields(record):
    return {DATABASE_ID: record[DATABASE_ID], DATABASE_NAME: record[DATABASE_NAME] if DATABASE_NAME in record else '',
            DESC: record[DESC],
            CLUSTER_ID: record['serviceGroupId']}


if __name__ == '__main__':
    # print(query_all_clusters())
    print(query_paged_database(11789))
