美团内部链接快捷方式：支持octo，mcc、rhino、raptor、avatar、trace、devops、trace
appkey根据计算机名为misid自动获取，请确保计算机名跟mis一致,如不一致，需要在环境变量中指定mis。
特性：
1. appkey自动根据mis id获取
2. appkey支持模糊匹配，如不存在，默认搜索关键字为appkey

- ak - 复制appkey
- sak（search appkey） - 根据关键字搜索appkey，搜索后回车复制
- akm (appkey members) - 根据appkey搜索负责人
- fn+[M]embers - 根据剪贴板内的appkey搜索负责人，快捷键可自定义

- oc - octo线上环境，按住cmd到测试环境
- rh - rhino线上环境，按住cmd到测试环境
- mcc - mcc线上环境，按住cmd到测试环境
- git - code线上环境
- plus - new devops的发布
- pl - 现有的plus
- rpt - raptor 线上环境，按住cmd到测试环境
- avt - avatar
- trace - mtrace

【需登录SSO】
- lc - logcenter日志列表
- rds - rds集群列表，直接到监控页
- ou - oceanus站点
- db - rds集群列表
    - 按住cmd后回车到集群监控页面
    - 直接回车后查看集群下的db列表
        - 按住cmd后回车到db详情页
        - 回车后到sql执行页面
- sdb - 根据关键字搜索db



到家持续交付系统【需登录】
- ed
    - 1、新建迭代申请
    - 2、迭代申请列表
    - 3、新建上线计划
    - 4、上线计划列表
edlist - 我的迭代列表
edplan - 我的上线列表


- octest - octo 测试环境
- rhtest - rhino test 测试环境
- mcctest - mcc test 测试环境
- rpttest - raptor test 测试环境
- tracetest - trace test 测试环境

系统指令：
- cc - clear cache 清除缓存