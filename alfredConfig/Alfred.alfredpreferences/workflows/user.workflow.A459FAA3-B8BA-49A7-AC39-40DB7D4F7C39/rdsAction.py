#!/usr/bin/python
# encoding: utf-8

from LoginManager import LoginManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from workflow import web

# cluster field
ID = 'id'
CLUSTER_ID = 'clusterId'
DATABASE_ID = 'databaseId'
DATABASE_NAME = 'databaseName'
NAME = 'name'
DESC = 'description'

# login manager
COOKIE_NAME = 'rds_cookies'
LOGIN_URL = 'https://rds.mws.sankuai.com/dba/db_manage'
WAIT_ELEMENT = EC.presence_of_element_located((By.CLASS_NAME, "rds-db-list"))

login_manager = LoginManager(LOGIN_URL, WAIT_ELEMENT, COOKIE_NAME)


def query_paged_clusters(page_no):
    url = 'https://rds.mws.sankuai.com/api/v1/cluster-manage/clusters'
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    params = {'current': page_no, 'page_size': 10}
    resp = web.get(url, params=params, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    return resp.json()


def query_all_clusters():
    page_no = 1
    resp = query_paged_clusters(page_no)
    data = resp['data']
    result = []
    if data:
        data_list = data['data']
        total = data['total']
        result.extend([filter_cluster_fields(r) for r in data_list])
        while len(result) < total:
            page_no = page_no + 1
            data = query_paged_clusters(page_no)['data']
            total = data['total']
            data_list = data['data']
            if not data_list:
                break
            result.extend([filter_cluster_fields(r) for r in data_list])
    return result


def query_paged_database(cluster_id=None, keyword=None, page_size=20, page_no=None):
    params = {}
    if cluster_id:
        params['cluster_id'] = cluster_id
    if keyword:
        params['database_name'] = keyword
    params['current'] = 1 if not page_no else page_no
    params['page_size'] = 20 if not page_size else page_size
    url = 'https://rds.mws.sankuai.com/api/v2/resource/database'
    cookies_str = login_manager.get_cookies()
    headers = {'Cookie': cookies_str}
    resp = web.get(url, params=params, headers=headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    data = resp.json()['data']
    if data and 'data' in data:
        return [filter_db_fields(r) for r in data['data']]
    return None


def query_databases_by_cluster_id(cluster_id):
    return query_paged_database(cluster_id)


def filter_cluster_fields(record):
    return {ID: record[ID], NAME: record[NAME], DESC: record[DESC]}


def filter_db_fields(record):
    return {DATABASE_ID: record[DATABASE_ID], DATABASE_NAME: record[DATABASE_NAME], DESC: record[DESC],
            CLUSTER_ID: record[CLUSTER_ID]}


if __name__ == '__main__':
    print(query_all_clusters())
