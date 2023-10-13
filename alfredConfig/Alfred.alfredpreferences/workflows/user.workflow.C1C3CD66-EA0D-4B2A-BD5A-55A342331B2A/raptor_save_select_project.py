# coding=utf-8
import json
import os
import sys

from utils import get_args, wf


def key_for_record(record):
    return record['name']


def main(workflow):
    query, mis, cache_seconds = get_args()
    current_front_project = os.getenv('current_front_project')
    project = json.loads(current_front_project)
    wf().store_data('current_selected_front_project', current_front_project)
    wf().logger.info("current project %s %s", current_front_project, project)
    wf().add_item(u'raptor前端项目设置为{}'.format(project['domain'], ), valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
