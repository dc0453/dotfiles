#!/usr/local/bin/python
# encoding: utf-8
import os
import sys

import kmAction
import utils
from utils import get_args, wf


def key_for_record(record):
    return u'{} {}'.format(record[kmAction.UNIT_TITLE], record[kmAction.UNIT_CREATOR])


def get_operation_time(item):
    return item[kmAction.UNIT_OPERATOR_TIME]


def main(workflow):
    query, mis, cache_seconds = get_args()
    km_history_limit = os.getenv('km_history_limit')
    if not km_history_limit:
        km_history_limit = 200
    else:
        km_history_limit = int(os.getenv('km_history_limit'))
    units = kmAction.query_limit_operation_history(km_history_limit)
    units = wf().filter(query, units, key_for_record)
    if units:
        units.sort(key=get_operation_time, reverse=True)
        for u in units:
            operation_time = utils.from_unix_timestamp(u[kmAction.UNIT_OPERATOR_TIME] / 1000)
            wf().add_item(
                u'{}'.format(u[kmAction.UNIT_TITLE]),
                u'创建人:{} - 浏览时间:{}'.format(u[kmAction.UNIT_CREATOR], operation_time),
                u[kmAction.UNIT_PAGE_ID],
                valid=True)
    else:
        wf().add_item('no result', '', query, valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
