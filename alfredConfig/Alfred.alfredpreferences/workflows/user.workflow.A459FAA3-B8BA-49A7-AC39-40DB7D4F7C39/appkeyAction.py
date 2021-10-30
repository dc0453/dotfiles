#!/usr/bin/python
# encoding: utf-8

import json
import sys

# Workflow3 supports Alfred 3's new features. The `Workflow` class
# is also compatible with Alfred 2.
from workflow import web

def get_app_key_list(mis):
    params = dict(mis=mis)
    resp = web.post('https://b-admain-apigw.waimai.sankuai.com/api/open/appkeysByMis', data=params)
    resp.raise_for_status()
    return resp.json()



def get_git_repositoy(app_key_list):
    params = dict(appkeys=','.join(app_key_list))
    resp = web.post('https://b-admain-apigw.waimai.sankuai.com/api/open/appkeys/git', data=params)
    resp.raise_for_status()
    return resp.json()


if __name__ == '__main__':
    json_data = get_git_repositoy(['waimai_e_api'])
    print(json_data)

    json_data = get_app_key_list("pingxumeng")
    print(json_data)
