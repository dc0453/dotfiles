import json
import os
import sys

import raptorAction
from utils import get_args, wf


def key_for_record(record):
    return record[raptorAction.FIELD_NAME_DOMAIN]


def main(workflow):
    query, mis, cache_seconds = get_args()
    raptor_front_projects = wf().cached_data('raptor_front_projects', raptorAction.get_front_project,
                                             max_age=int(cache_seconds))
    raptor_front_projects = wf().filter(query, raptor_front_projects, key_for_record)
    if raptor_front_projects:
        for p in raptor_front_projects:
            wf().add_item(
                p[raptorAction.FIELD_NAME_DOMAIN],
                '',
                json.dumps(p),
                valid=True)
    else:
        wf().add_item('no result', valid=False)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
