美团内部链接快捷方式：支持octo，mcc、rhino、raptor、avatar、trace、devops、trace、redis、cellar、mafka、git等
appkey根据计算机名为misid自动获取，检查计算机名（shell命令：whoami）是否跟mis一致，不一致需要在alfred中修改环境变量mis，修改后为正确mis后，alfred运行cc命令后重试。特性：
1. appkey自动根据mis id获取
2. appkey支持模糊匹配，如不存在，默认搜索关键字为appkey
指令列表：
- ak - 复制appkey
- sak（[s]earch [a]pp[k]ey） - 根据关键字搜索appkey，回车复制appkey
- akm ([a]pp[k]ey [m]embers) - 根据appkey搜索负责人，回车复制mis
- option +[M]embers - 根据剪贴板内的appkey搜索负责人，快捷键可自定义，回车复制mis

- oc - octo线上环境，按住cmd到线下环境
- rh - rhino线上环境，按住cmd到线下环境
- lion - lion线上环境，按住cmd到线下环境
	- lk - [L]ion [K]ey 先输入lion key，再选择appkey，lion中查看制定key
- git - code线上环境
- plus - new devops的发布
- pl - 现有的plus
- rpt - raptor 线上环境，按住cmd到测试环境
- avt - avatar
- trace - mtrace


- db - rds集群列表
    - 直接回车后查看集群下的db列表
        - 按住cmd后回车到db详情页
        - 回车后到sql执行页面
    - 按住cmd跳转到rds集群信息页面
- sdb ([S]earch db) 根据关键字搜索db
- rds - rds集群列表，直接到监控页

- cl - [C]ellar [L]ist集群组列表
    - 回车查看集群组下集群，再回车查看集群
- tl - [T]air cluster [L]ist 列表，跳转集群详情页

- sq - squirrel集群列表，跳转集群详情页
- ssq - [S]earch [Sq]uirrel 搜索集群
- sqg - [sq]uirrel  [g]roup 集群组
    - 直接回车后查看集群组下集群列表
        - 按住cmd后回车到集群组详情页
        - 回车后直接到集群详情页

- mf - [Ma]fka topic列表，回车跳转详情页
- smf - [S]earch [M]a[f]ka topic，回车跳转详情页
- mfc - [M]a[f]ka [C]onsumer group ,消费组列表，跳转详情页
- smfc - [S]earch  [m]a[f]ka [c]onsumer 搜索消费组，跳转详情页


- cg - cargo 个人泳道列表
- scg  -  [s]earch [c]ar[g]o 根据编排名称或泳道搜索，跳转泳道详情。

- rp - git [r]e[p]ository  我的仓库列表，跳转代码仓库详情。
    - 按住cmd创建PR
- dp - [d]e[p]loy 跳转发布页
- prl - [p]ull [r]equest [l]ist  代码评审列表



- lc - logcenter我的日志列表
- lca - logcenter所有日志列表

- km -学城搜索，默认显示搜索历史，输入关键字会自动提示。
- mykm -打开我的学城空间

【其他 - 需SSO登录】
- ou - oceanus站点
- mis - 查询mis，回车后打开大象聊天框
- srv - 查询avatar服务，可以根据ip或主机名查询
- host - 根据ip或主机，查询主机名和ip
- jp - jumper免密登录，需wiki配置：https://km.sankuai.com/page/545430795

到家digger【需登录SSO - 需安装chrome】
- dg - 查询收藏的监控大盘
- sdg - 关键字搜索大盘

实用工具
- ts -日期转为时间戳，并复制到剪贴板
- tsnow -当前时间的时间戳，并复制到剪贴板
- tstoday - 当天的时间戳，并复制到剪贴板
- fts  -时间戳转为日期，并复制到剪贴板


到家持续交付系统【需登录SSO - 需安装chrome】
- ed
    - 1、新建迭代申请
    - 2、迭代申请列表
    - 3、新建上线计划
    - 4、上线计划列表
- edlist - 我的迭代列表
- edplan - 我的上线列表

系统指令：
- cc - clear cache 清除缓存：如发现数据不是最新，可尝试清除缓存。