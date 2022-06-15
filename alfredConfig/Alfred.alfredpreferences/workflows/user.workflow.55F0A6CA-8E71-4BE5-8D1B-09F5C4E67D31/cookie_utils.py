# coding=utf-8
import logging
import re
import urlparse
import webbrowser
from datetime import datetime

from pycookiecheat import chrome_cookies

url = 'http://logcenter.data.sankuai.com/index'
cookies = chrome_cookies(url)
chrome_path = 'open -a /Applications/Google\\ Chrome.app %s'
webbrowser.get(chrome_path).open(url)
print cookies['sessionid']
for k, v in cookies.items():
    print k, '=', v
