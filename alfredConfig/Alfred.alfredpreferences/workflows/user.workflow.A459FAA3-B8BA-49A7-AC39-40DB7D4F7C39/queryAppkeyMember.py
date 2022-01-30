#!/usr/bin/python
# encoding: utf-8

import sys

import appkeyAction
# Workflow3 supports Alfred 3's new features. The `Workflow` class
# is also compatible with Alfred 2.
from utils import wf


def main(workflow):
    cache_seconds = 14400
    appkey = None
    if len(workflow.args):
        appkey = workflow.args[0]
        if len(workflow.args) > 1:
            cache_seconds = workflow.args[1]

    mis_list = workflow.cached_data('appkeys_member_' + appkey, lambda: appkeyAction.query_mis_by_appkey(appkey),
                                    max_age=int(cache_seconds))
    if mis_list:
        for index, user in enumerate(mis_list):
            if index == 0:
                workflow.add_item(u"{0} - {1}".format(user['mis'], user['name']), 'Owner', arg=user['mis'],
                                  largetext=user['mis'], valid=True)
            else:
                workflow.add_item(u"{0} - {1}".format(user['mis'], user['name']), arg=user['mis'],
                                  largetext=user['mis'], valid=True)
    else:
        workflow.add_item("no result for {}".format(appkey), valid=False)

    workflow.send_feedback()


if __name__ == '__main__':
    # Create a global `Workflow3` object
    # Call your entry function via `Workflow3.run()` to enable its
    # helper functions, like exception catching, ARGV normalization,
    # magic arguments etc.
    sys.exit(wf().run(main))
