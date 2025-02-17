import sys

import kmAction
from utils import get_args, wf


def main(workflow):
    query, mis, cache_seconds = get_args()
    dx_uid = kmAction.query_dxuid(query)
    print(dx_uid)


if __name__ == '__main__':
    # print(query_all_records())
    sys.exit(wf().run(main))
