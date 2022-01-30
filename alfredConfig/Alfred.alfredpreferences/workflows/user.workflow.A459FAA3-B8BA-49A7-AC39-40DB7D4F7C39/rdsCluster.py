#!/usr/bin/python
# encoding: utf-8
import sys

import rdsAction
from utils import get_args, wf


def key_for_record(record):
    return u'{} {}'.format(record[rdsAction.NAME], record[rdsAction.DESC])


def main(workflow):
    query, mis, cache_seconds = get_args()
    records = wf().cached_data('my_rds_cluster', rdsAction.query_all_clusters, max_age=int(cache_seconds))
    records = wf().filter(query, records, key_for_record)
    if records:
        for record in records:
            wf().add_item(u'集群：{}'.format(record[rdsAction.NAME]), record[rdsAction.DESC], record[rdsAction.ID], valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
