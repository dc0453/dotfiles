#!/usr/bin/python
# encoding: utf-8

import sys
import getpass
# Workflow3 supports Alfred 3's new features. The `Workflow` class
# is also compatible with Alfred 2.
from workflow import Workflow3
import appkeyAction


def main(wf):
    mis = None
    cache_seconds = 3600
    if len(wf.args):
        query = wf.args[0]
        if len(wf.args) > 1:
            mis = wf.args[1]
            if len(wf.args) > 2:
                cache_seconds = wf.args[2]
    else:
        query = None
    if not mis:
        mis = getpass.getuser()

    app_key_list = wf.cached_data(
        'appkeys', lambda: appkeyAction.get_app_key_list(mis), max_age=int(cache_seconds))

    if query:
        app_key_list = wf.filter(query, app_key_list)
        if not app_key_list:
            app_key_list.append(query)

    for app_key in app_key_list:
        wf.add_item(app_key, arg=app_key, largetext=app_key, valid=True)
    wf.send_feedback()


if __name__ == '__main__':
    # Create a global `Workflow3` object
    wf = Workflow3()
    # Call your entry function via `Workflow3.run()` to enable its
    # helper functions, like exception catching, ARGV normalization,
    # magic arguments etc.
    sys.exit(wf.run(main))
