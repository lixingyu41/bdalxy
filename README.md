# bdalxy
批量下载哔哩哔哩up主视频的shell脚本
# 准备工作
## rss源
一个rss源，文档请看https://docs.rsshub.app
填写rss地址到脚本里，建议自己搭，用别人的也行，但是肯定不稳定。
## cookies设定
使用一些拓展工具如EditThisCookie，保存哔哩哔哩网站cookies到infor里的cookies.txt里，导出格式设置为Netscape HTTP Cookie File
## 特点
会记录下载过的视频，运行多次脚本不会重复下载视频，
使用各种工具，方便升级
自动上传百度云，你会改也能上传基本所有网盘
## 使用
给文件提权
在目录外使用以下命令
chmod 777 -R bdalxy/*
要不然是没办法执行的，
使用类似./bdalxy.sh uid
会自动开始下载，批量的话，就新建一个shell脚本，填一堆
./bdalxy.sh uid1
./bdalxy.sh uid2
./bdalxy.sh uid3
./bdalxy.sh uid4
就可以了
想一直循环下载的话，找个定时跑脚本的挂着就行，
有什么问题可以联系我，我网站有联系方式
