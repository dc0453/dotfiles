import getpass
from datetime import datetime

from workflow import Workflow3

_workflow = None
_default_cache_seconds = 14400
log = None


def wf():
    global _workflow
    global log
    if _workflow is None:
        _workflow = Workflow3()
        log = _workflow.logger
    return _workflow


def get_args():
    mis = None
    cache_seconds = _default_cache_seconds
    if len(wf().args):
        query = wf().args[0]
        if len(wf().args) > 1:
            mis = wf().args[1]
            if len(wf().args) > 2:
                cache_seconds = wf().args[2]
    else:
        query = None
    if not mis:
        mis = getpass.getuser()
    return query, mis, cache_seconds


def from_time_stamp(time_stamp):
    return datetime.fromtimestamp(time_stamp).strftime("%Y-%m-%d %H:%M:%S")
