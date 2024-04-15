#!/usr/bin/python
# encoding: utf-8
import sys
import shepherdAction

from utils import wf, get_args


def main(workflow):
    query, mis, cache_seconds = get_args()
    all_my_api_list = wf().cached_data('my_all_shepherd_apis_test',
                                       lambda: shepherdAction.all_my_api_list('test'),
                                       max_age=int(cache_seconds))
    all_my_api_list = wf().filter(query, all_my_api_list, shepherdAction.key_for_api_record)
    if all_my_api_list:
        for group in all_my_api_list:
            api_query = u'api_group_name={}&api_group_id={}&group_tab=api-manage&api_name={}&api_id={}'.format(
                group[shepherdAction.SHEPHERD_API_GROUP_NAME],
                group[shepherdAction.SHEPHERD_API_GROUP_ID],
                group[shepherdAction.SHEPHERD_API_NAME],
                group[shepherdAction.SHEPHERD_API_ID],
            )
            wf().add_item(u'{}'.format(group[shepherdAction.SHEPHERD_API_PATH]),
                          u'{} - {}'.format(group[shepherdAction.SHEPHERD_API_NAME],
                                            group[shepherdAction.SHEPHERD_API_DESC]),
                          arg=api_query,
                          valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    sys.exit(wf().run(main))
    # delete_cookies(LOG_CENTER_COOKIE_NAME)
