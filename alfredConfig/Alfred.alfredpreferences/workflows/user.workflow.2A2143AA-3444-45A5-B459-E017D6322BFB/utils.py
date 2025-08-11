#!/usr/bin/env python
# encoding: utf-8

import json
import getpass
import init_path
from urllib.parse import quote
import time
from typing import Optional, Any, Dict, List
import datetime as dt

from enum import Enum
from dateutil.parser import parse as date_parse
from dataclasses import dataclass, field
from pypinyin import lazy_pinyin, Style, load_phrases_dict
from workflow import Workflow3
import requests
import logging

import init_path


# 环境常量


class Environment(Enum):
    PROD = "prod"
    STAGING = "staging"
    TEST = "test"

    @staticmethod
    def get_env(env_str: str) -> "Environment":
        env_str = env_str.lower()
        if env_str == "prod":
            return Environment.PROD
        elif env_str == "staging":
            return Environment.STAGING
        elif env_str == "test":
            return Environment.TEST
        else:
            return Environment.PROD  # 默认返回生产环境


# 全局变量
_workflow: Optional[Workflow3] = None
_default_cache_seconds: int = 14400
log: Optional[logging.Logger] = None


@dataclass
class BaseItem:
    """基础数据项类"""

    def __init__(self, **kwargs):
        fields = [f.name for f in self.__class__.__dataclass_fields__.values()]
        for k, v in kwargs.items():
            if k in fields:
                setattr(self, k, v)
        self.__post_init__()

    def __post_init__(self):
        if hasattr(self, "title"):
            self.titlePinyin = hanzi_to_pinyin(self.title)
        elif hasattr(self, "name"):
            self.titlePinyin = hanzi_to_pinyin(self.name)


class WorkflowManager:
    """Workflow管理类"""

    @staticmethod
    def get_workflow() -> Workflow3:
        global _workflow, log
        if _workflow is None:
            _workflow = Workflow3()
            log = _workflow.logger
        return _workflow

    @staticmethod
    def get_args() -> tuple:
        workflow = WorkflowManager.get_workflow()
        mis = None
        cache_seconds = _default_cache_seconds
        query = ""
        if len(workflow.args):
            query = workflow.args[0].strip() if workflow.args[0] else ""
            if len(workflow.args) > 1:
                mis = workflow.args[1]
                if len(workflow.args) > 2:
                    cache_seconds = workflow.args[2]
        if not mis:
            mis = getpass.getuser()
        return query, mis.strip(), cache_seconds

    @staticmethod
    def get_args_with_env() -> tuple:
        query, mis, cache_seconds = WorkflowManager.get_args()
        wf = WorkflowManager.get_workflow()
        env = wf.args[3] if len(wf.args) > 3 else Environment.PROD
        return query, mis, cache_seconds, env

    @staticmethod
    def get_four_args() -> tuple:
        query, mis, cache_seconds = WorkflowManager.get_args()
        wf = WorkflowManager.get_workflow()
        forth_arg = wf.args[3] if len(wf.args) > 3 else None
        return query, mis, cache_seconds, forth_arg


class DateTimeUtils:
    """日期时间工具类"""

    @staticmethod
    def from_timestamp(timestamp: int) -> str:
        # 将时间戳转换为日期时间字符串
        # 参数:
        #   timestamp: int - Unix时间戳（秒或毫秒）
        # 返回:
        #   str - 格式化的日期时间字符串 (YYYY-MM-DD HH:MM:SS)

        # 检查时间戳长度，判断是否为毫秒级
        if len(str(timestamp)) > 10:
            # 毫秒级时间戳，需要除以1000
            timestamp = timestamp / 1000
        return dt.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M:%S")

    @staticmethod
    def from_timestamp_date(timestamp: int) -> str:
        """
        将时间戳转换为日期字符串
        参数:
            timestamp: int - Unix时间戳（秒或毫秒）
        返回:
            str - 格式化的日期字符串 (YYYY-MM-DD)
        """

        # 检查时间戳长度，判断是否为毫秒级
        if len(str(timestamp)) > 10:
            # 毫秒级时间戳，需要除以1000
            timestamp = timestamp / 1000
        return dt.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d")

    @staticmethod
    def format_timestamp_to_relative_time(timestamp: int) -> str:
        if len(str(timestamp)) > 10:
            timestamp = timestamp / 1000
        dt_obj = dt.datetime.fromtimestamp(timestamp)
        now = dt.datetime.now()
        delta = now.date() - dt_obj.date()

        if delta.days == 0:
            if (now - dt_obj).seconds < 60:
                return "刚刚"
            elif (now - dt_obj).seconds < 3600:
                return f"{(now - dt_obj).seconds // 60}分钟前"
            else:
                hours = (now - dt_obj).seconds // 3600
                minutes = ((now - dt_obj).seconds % 3600) // 60
                return f"{hours}小时前 {dt_obj.strftime('%H:%M')}"
        elif delta.days == 1:
            return f"昨天 {dt_obj.strftime('%H:%M')}"
        elif delta.days == 2:
            return f"前天 {dt_obj.strftime('%H:%M')}"
        elif delta.days < 7:
            return f"{delta.days}天前 {dt_obj.strftime('%H:%M')}"
        elif dt_obj.year == now.year:
            return dt_obj.strftime("%m月%d日 %H:%M")
        else:
            return dt_obj.strftime("%Y年%m月%d日 %H:%M")

    @staticmethod
    def to_unix_timestamp(date_str: str) -> int:
        date = date_parse(date_str)
        return int(time.mktime(date.timetuple()))

    @staticmethod
    def today_ymd() -> str:
        return dt.datetime.today().strftime("%Y-%m-%d")

    @staticmethod
    def days_ago_ymd(days: int) -> str:
        return (dt.datetime.now() - dt.timedelta(days=days)).strftime("%Y-%m-%d")

    @staticmethod
    def from_unix_timestamp_hm(timestamp: float) -> str:
        return dt.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")

    @staticmethod
    def unix_timestamp(date: dt.datetime) -> int:
        return int(time.mktime(date.timetuple()))

    @staticmethod
    def get_relative_day_desc(timestamp: int) -> str:
        now = dt.datetime.today().date()
        target_date = dt.datetime.fromtimestamp(timestamp).date()
        delta = now - target_date

        if delta.days == 0:
            return "今天"
        elif delta.days == 1:
            return "昨天"
        elif delta.days <= 3:
            return "3天内"
        elif delta.days <= 7:
            return "1周内"
        elif delta.days <= 30:
            return "30天内"
        else:
            return "更早"


def hanzi_to_pinyin(text: str) -> str:
    """
    将汉字转换为拼音

    Args:
        text (str): 输入的汉字字符串

    Returns:
        str: 转换后的拼音字符串
    """
    return " ".join(lazy_pinyin(text))


def url_encode(query: str) -> str:
    """URL编码"""
    return quote(query)


# 为了保持向后兼容性，我们保留一些旧的函数名
wf = WorkflowManager.get_workflow
logger = WorkflowManager.get_workflow().logger
get_args = WorkflowManager.get_args
get_args_with_env = WorkflowManager.get_args_with_env
get_four_args = WorkflowManager.get_four_args
from_timestamp = DateTimeUtils.from_timestamp
to_unix_timestamp = DateTimeUtils.to_unix_timestamp
today_YYHHMM = DateTimeUtils.today_ymd
days_ago_YYHHMM = DateTimeUtils.days_ago_ymd
from_unix_timestamp_HHMM = DateTimeUtils.from_unix_timestamp_hm
unix_timestamp = DateTimeUtils.unix_timestamp
get_relative_day_desc = DateTimeUtils.get_relative_day_desc
format_timestamp_to_relative_time = DateTimeUtils.format_timestamp_to_relative_time

if __name__ == "__main__":
    # 测试代码应该移到单独的测试文件中，这里只保留简单的使用示例
    print(f"Today: {DateTimeUtils.today_ymd()}")
    print(f"Today: {get_relative_day_desc(1739886600)}")
    print(f"7 days ago: {DateTimeUtils.days_ago_ymd(7)}")
