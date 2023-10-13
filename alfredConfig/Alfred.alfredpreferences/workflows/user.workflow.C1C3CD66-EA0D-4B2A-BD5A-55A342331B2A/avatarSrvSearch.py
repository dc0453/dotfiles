import sys

import avatarAction
from utils import get_args, wf


def main(workflow):
    query, mis, cache_seconds = get_args()
    if query.strip():
        records = avatarAction.query_services(query.strip())
        for record in records:
            wf().add_item(u'{} - {}'.format(record['appkey'], record['name']),
                          u'{}'.format(record['comment']),
                          record['appkey'],
                          valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
