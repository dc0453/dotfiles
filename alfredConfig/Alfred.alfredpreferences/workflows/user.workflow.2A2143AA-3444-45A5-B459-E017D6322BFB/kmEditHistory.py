import os
import sys
import init_path
from kmAction import latest_edit_list, UnitItem
from utils import from_unix_timestamp, get_args, wf


def key_for_record(record: UnitItem):
    return f"{record.title} {record.creator} {record.titlePinyin}"


def get_modify_time(item: UnitItem):
    return item.modifyTime


def main(workflow):
    query, mis, cache_seconds = get_args()
    units = latest_edit_list()
    units = wf().filter(
        query, units, key_for_record, min_score=1, fold_diacritics=False
    )
    if units:
        units.sort(key=get_modify_time, reverse=True)
        for u in units:
            modify_time = from_unix_timestamp(int(u.modifyTime) / 1000)
            wf().add_item(
                u.title,
                f"创建人:{u.creator} - 更新时间:{modify_time}",
                u.pageId,
                valid=True,
            )
    else:
        wf().add_item("no result", "", query, valid=True)
    wf().send_feedback()


if __name__ == "__main__":
    sys.exit(wf().run(main))
