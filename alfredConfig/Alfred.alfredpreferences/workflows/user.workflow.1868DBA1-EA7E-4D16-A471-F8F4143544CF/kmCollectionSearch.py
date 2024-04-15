#!/usr/local/bin/python
# encoding: utf-8
import sys

import kmAction
import utils
from utils import get_args, wf


def key_for_record(record):
    return u'{} {}'.format(record[kmAction.CONTENT_TITLE], record[kmAction.CONTENT_CREATOR])


def main(workflow):
    query, mis, cache_seconds = get_args()
    collection_type = wf().args[3]
    units = kmAction.query_collections(collection_type)
    units = wf().filter(query, units, key_for_record)
    if units:
        for u in units:
            modify_time = utils.from_unix_timestamp(u[kmAction.CONTENT_MODTIME] / 1000)
            wf().add_item(
                u'{}'.format(u[kmAction.CONTENT_TITLE]),
                u'创建人:{} - 更新时间:{}'.format(u[kmAction.CONTENT_CREATOR], modify_time),
                u[kmAction.CONTENT_KEY],
                valid=True)
    else:
        wf().add_item('no result', '', query, valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
