#!/usr/bin/python
# encoding: utf-8
import sys

from edAction import query_all_test_apply_list
from utils import wf, get_args


def key_for_test_apply(test_apply_item):
    return test_apply_item['name']


def main(workflow):
    query, mis, cache_seconds = get_args()
    test_apply_list = query_all_test_apply_list()
    test_apply_list = wf().filter(query, test_apply_list, key_for_test_apply)
    if test_apply_list:
        for test_apply in test_apply_list:
            wf().add_item(test_apply['name'], test_apply['id'], test_apply['id'], valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    sys.exit(wf().run(main))
    # delete_cookies(LOG_CENTER_COOKIE_NAME)
