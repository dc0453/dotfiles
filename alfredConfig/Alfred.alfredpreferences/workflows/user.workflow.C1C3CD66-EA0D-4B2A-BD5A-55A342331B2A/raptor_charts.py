#!/usr/bin/python
# encoding: utf-8
import sys

import raptorAction
from utils import get_args, wf


def key_for_record(record):
    return u'{}'.format(record[raptorAction.FIELD_NAME_NAME])


def main(workflow):
    import os
    # rpt_dashboard_id_iscore : dashboard=234&isCore=false
    dashboard_info = os.getenv('rpt_dashboard_id_iscore')
    dashboard_id_query, is_core_query = dashboard_info.split('&')
    dashboard_id = dashboard_id_query.split('=')[1]
    is_core = is_core_query.split('=')[1]
    wf().logger.info('dashboard_id:%s', dashboard_id)
    query, mis, cache_seconds = get_args()
    records = wf().cached_data('raptor_dashboard_{}_{}'.format(is_core, dashboard_id),
                               lambda: raptorAction.get_charts_by_dashboard(dashboard_id, 'true' == is_core),
                               max_age=int(cache_seconds))
    records = wf().filter(query, records, key_for_record)
    if records:
        for record in records:
            wf().add_item(record[raptorAction.FIELD_NAME_NAME], arg=record[raptorAction.FIELD_NAME_ID], valid=True)
    else:
        wf().add_item('no result')
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
