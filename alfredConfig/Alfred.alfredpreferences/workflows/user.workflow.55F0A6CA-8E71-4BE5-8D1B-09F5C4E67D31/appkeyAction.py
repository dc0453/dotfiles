#!/usr/bin/python
# encoding: utf-8

import json
import sys

# Workflow3 supports Alfred 3's new features. The `Workflow` class
# is also compatible with Alfred 2.
from workflow import web


def get_app_key_list(mis):
    params = dict(mis=mis)
    resp = web.post('http://b.gateway.waimai.st.sankuai.com/api/open/appkeysByMis', data=params)
    resp.raise_for_status()
    return resp.json()


def get_git_repositoy(app_key_list):
    params = dict(appkeys=','.join(app_key_list))
    resp = web.post('http://b.gateway.waimai.st.sankuai.com//api/open/appkeys/git', data=params)
    resp.raise_for_status()
    return resp.json()


def search_appkey(keyword):
    params = dict(keyword=keyword)
    resp = web.post(
        'http://b.gateway.waimai.st.sankuai.com/api/open/searchAppkeys', data=params)
    resp.raise_for_status()
    return resp.json()


def query_mis_by_appkey(appkey):
    params = dict(appkey=appkey)
    resp = web.post(
        'http://b.gateway.waimai.st.sankuai.com/api/open/queryMisByAppkey', data=params)
    resp.raise_for_status()
    return resp.json()


def query_plus_by_mis(mis):
    result = {}
    resp = web.get('http://plus.sankuai.com/release/list/{mis}'.format(mis=mis))
    resp.raise_for_status()
    release_names = resp.json().keys()
    for release_name in release_names:
        resp = web.get('http://plus.sankuai.com//release_id/{0}'.format(release_name))
        result[release_name] =  resp.json()['Id']
    return result


if __name__ == '__main__':
    json_data = query_plus_by_mis("pingxumeng")
    print(json_data)

