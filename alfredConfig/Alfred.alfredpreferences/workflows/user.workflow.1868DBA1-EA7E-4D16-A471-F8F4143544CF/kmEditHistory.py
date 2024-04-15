#!/usr/local/bin/python
# encoding: utf-8
import sys

import kmAction
import utils
from utils import get_args, wf


def key_for_record(record):
    return u'{} {}'.format(record[kmAction.UNIT_TITLE], record[kmAction.UNIT_CREATOR])


def get_modify_time(item):
    return item[kmAction.UNIT_MODIFY_TIME]


def main(workflow):
    query, mis, cache_seconds = get_args()
    units = kmAction.last_edit()
    units = wf().filter(query, units, key_for_record, True)
    if units:
        units.sort(key=get_modify_time, reverse=True)
        for u in units:
            modify_time = utils.from_unix_timestamp(u[kmAction.UNIT_MODIFY_TIME] / 1000)
            wf().add_item(
                u'{}'.format(u[kmAction.UNIT_TITLE]),
                u'创建人:{} - 更新时间:{}'.format(u[kmAction.UNIT_CREATOR], modify_time),
                u[kmAction.UNIT_PAGE_ID],
                valid=True)
    else:
        wf().add_item('no result', '', query, valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
