import os
import sys

import kmAction
import utils
from utils import get_args, wf


def key_for_record(record):
    return u'{} {} {}'.format(record[kmAction.UNIT_TITLE], record[kmAction.PAGE_MODIFIER], record[kmAction.PAGE_PATH])


def main(workflow):
    query, mis, cache_seconds = get_args()
    space_id = kmAction.get_space_id_by_mis(mis)
    km_page_cache_seconds = os.getenv('my_space_pages_cache_seconds')
    if not km_page_cache_seconds:
        km_page_cache_seconds = 28800
    records = workflow.cached_data('my_km_space_pages', lambda: kmAction.get_space_pages(space_id),
                                   max_age=int(km_page_cache_seconds))
    all_my_pages = wf().filter(query, records, key_for_record)
    if all_my_pages:
        for page in all_my_pages:
            modify_time = utils.from_unix_timestamp_HHMM(page[kmAction.PAGE_MODIFY_TIME] / 1000)
            wf().add_item(u'{}'.format(page[kmAction.UNIT_TITLE]),
                          u'{} - {}'.format(page[kmAction.PAGE_PATH], modify_time),
                          page[kmAction.PAGE_CONTENT_ID],
                          valid=True)
    else:
        wf().add_item('no result', '', query, valid=True)
    wf().send_feedback()


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
