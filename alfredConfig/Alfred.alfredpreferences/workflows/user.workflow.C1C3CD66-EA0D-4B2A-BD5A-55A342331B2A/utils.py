import getpass
import urllib
from datetime import datetime, timedelta
import time
from dateutil.parser import parse
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
    return query, mis.strip(), cache_seconds


def from_time_stamp(time_stamp):
    return datetime.fromtimestamp(time_stamp).strftime("%Y-%m-%d %H:%M:%S")


def url_encode(query):
    return urllib.quote(encode_value_to_bytes(query))


def encode_value_to_bytes(value):
    if not isinstance(value, unicode):
        return str(value)
    return value.encode('utf8')


def to_unix_timestamp(date_str):
    date = parse(date_str)
    return int(time.mktime(date.timetuple()))


def today_YYHHMM():
    return datetime.today().strftime('%Y-%m-%d')


def days_ago_YYHHMM(days):
    today = datetime.now()
    n_days_ago = today - timedelta(days=days)
    return n_days_ago.strftime('%Y-%m-%d')


def from_unix_timestamp(timestamp):
    return datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M:%S")


if __name__ == '__main__':
    print
    to_unix_timestamp('2022-05-17 18')
    print
    from_unix_timestamp(1652716800)
    print
    datetime.now()
    print
    to_unix_timestamp(datetime.today().strftime("%Y-%m-%d"))
    print
    to_unix_timestamp(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

    print today_YYHHMM()
    print days_ago_YYHHMM(30)
