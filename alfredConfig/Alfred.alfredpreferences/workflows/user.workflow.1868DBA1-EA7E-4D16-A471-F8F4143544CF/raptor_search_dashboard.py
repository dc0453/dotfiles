#!/usr/bin/python
# encoding: utf-8
import sys

import raptorAction
from utils import get_args, wf


def key_for_record(record):
    return u'{}'.format(record[raptorAction.FIELD_NAME_NAME])


def main(workflow):
    query, mis, cache_seconds = get_args()
    dashboard_rows = []
    result = raptorAction.search_dashboard(query, True)
    if result:
        dashboard_rows.extend(result)
    result = raptorAction.search_dashboard(query, False)
    if result:
        dashboard_rows.extend(result)

    if dashboard_rows:
        for d in dashboard_rows:
            is_core = str(d[raptorAction.DASH_BOARD_IS_CORE]).lower()
            wf().add_item(
                d[raptorAction.FIELD_NAME_NAME],
                d[raptorAction.DASH_BOARD_ORG],
                'dashboard={}&isCore={}'.format(d[raptorAction.FIELD_NAME_ID], is_core),
                valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
