#!/usr/bin/python
# encoding: utf-8
import sys
import shepherdAction
import utils

from utils import wf, get_args


def main(workflow):
    query, mis, cache_seconds = get_args()
    group_list = wf().cached_data('my_shepherd_group', lambda: shepherdAction.groups_list(),
                                  max_age=int(cache_seconds))
    group_list = wf().filter(query, group_list, shepherdAction.key_for_group_record)
    if group_list:
        for group in group_list:
            wf().add_item(u'{}'.format(group[shepherdAction.SHEPHERD_GROUP_NAME]),
                          u'{} - {}'.format(group[shepherdAction.SHEPHERD_GROUP_PREFIX],
                                            group[shepherdAction.SHEPHERD_GROUP_DESC]),
                          arg=u'api_group_name={}&api_group_id={}'.format(
                              utils.url_encode(group[shepherdAction.SHEPHERD_GROUP_NAME]),
                              group[shepherdAction.SHEPHERD_GROUP_ID],
                          ),
                          valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    sys.exit(wf().run(main))
    # delete_cookies(LOG_CENTER_COOKIE_NAME)
