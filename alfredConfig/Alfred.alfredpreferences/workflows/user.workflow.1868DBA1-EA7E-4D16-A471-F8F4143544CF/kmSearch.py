import sys

import kmAction
from utils import get_args, wf


def main(workflow):
    query, mis, cache_seconds = get_args()
    if query.strip():
        records = kmAction.suggest(query)
    else:
        records = kmAction.search_history()
    if records:
        for record in records:
            wf().add_item(u'{}'.format(record),
                          u'',
                          record,
                          valid=True)
    else:
        wf().add_item(query, '', query, valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
