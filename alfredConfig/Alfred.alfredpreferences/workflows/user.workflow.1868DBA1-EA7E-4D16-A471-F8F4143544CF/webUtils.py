import json

from workflow import web


def get(url, login_manager, params=None, headers=None):
    cookies_str = login_manager.get_cookies()
    req_headers = {'Cookie': cookies_str, 'Content-Type': 'application/json; charset=utf-8'}
    if headers:
        req_headers.update(headers)
    resp = web.get(url, params, headers=req_headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    return resp.json()


def post_json(url, login_manager, json_payload, params=None, headers=None):
    cookies_str = login_manager.get_cookies()
    req_headers = {'Cookie': cookies_str, 'Content-Type': 'application/json; charset=utf-8'}
    if headers:
        req_headers.update(headers)
    resp = web.post(url, params, data=json.dumps(json_payload), headers=req_headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    return resp.json()


def post_form(url, login_manager, data=None, params=None, headers=None):
    cookies_str = login_manager.get_cookies()
    req_headers = {'Cookie': cookies_str, 'Content-Type': 'application/json; charset=utf-8'}
    if headers:
        req_headers.update(headers)
    resp = web.post(url, params, data=data, headers=req_headers, allow_redirects=False)
    login_manager.check_login_status(resp)
    resp.raise_for_status()
    return resp.json()
