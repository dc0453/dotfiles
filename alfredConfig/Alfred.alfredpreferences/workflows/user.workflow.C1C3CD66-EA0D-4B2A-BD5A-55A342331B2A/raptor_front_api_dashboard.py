#!/usr/bin/python
# encoding: utf-8
import json
import sys

import raptorAction
from utils import get_args, wf


def key_for_record(record):
    return u'{} {}'.format(record[raptorAction.FIELD_NAME_NAME], record[raptorAction.FIELD_NAME_TITLE])


def main(workflow):
    query, mis, cache_seconds = get_args()
    current_selected_front_project = wf().stored_data('current_selected_front_project')
    if not current_selected_front_project:
        raise RuntimeError(u'请先运行cfp指令，选择前端项目')
    raptor_front_project = json.loads(current_selected_front_project)
    project_id = raptor_front_project[raptorAction.FIELD_NAME_ID]
    project_domain = raptor_front_project[raptorAction.FIELD_NAME_DOMAIN]
    api_list = wf().cached_data('raptor_front_project_{}'.format(project_id),
                                lambda: raptorAction.get_api_by_project(project_id),
                                max_age=int(cache_seconds))
    api_list = wf().filter(query, api_list, key_for_record)
    if api_list:
        for record in api_list:
            wf().add_item(
                record[raptorAction.FIELD_NAME_NAME],
                u'[{}] {}'.format(project_domain, record[raptorAction.FIELD_NAME_TITLE]),
                'projectId={}&apiId={}'.format(project_id, record[raptorAction.FIELD_NAME_ID]),
                valid=True)
    else:
        wf().add_item('no result')
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
