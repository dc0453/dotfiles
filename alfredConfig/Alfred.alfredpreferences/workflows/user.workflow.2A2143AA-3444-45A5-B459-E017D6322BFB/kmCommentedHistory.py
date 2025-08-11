#!/usr/bin/env python
# encoding: utf-8
import sys

from kmAction import latest_commented_list, CommentedItem
from utils import (
    get_args,
    wf,
    get_relative_day_desc,
    from_unix_timestamp_HHMM,
    format_timestamp_to_relative_time,
)


def key_for_record(record: CommentedItem):
    return f"{record.title} {record.titlePinyin}"


def get_modify_time(item: CommentedItem):
    return item.recentCommentTime


def main(workflow):
    query, mis, cache_seconds = get_args()
    units = latest_commented_list()
    units = wf().filter(
        query, units, key_for_record, min_score=1, fold_diacritics=False
    )
    if units:
        units.sort(key=get_modify_time, reverse=True)
        for u in units:
            recent_commented_time = int(u.recentCommentTime / 1000)
            wf().add_item(
                u.title,
                f"【{get_relative_day_desc(recent_commented_time)}】:{u.commentCount}条评论 最近评论时间：{format_timestamp_to_relative_time(recent_commented_time)}",
                u.contentId,
                valid=True,
            )
    else:
        wf().add_item("no result", "", query, valid=True)
    wf().send_feedback()


if __name__ == "__main__":
    sys.exit(wf().run(main))
