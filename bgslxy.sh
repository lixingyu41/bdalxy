#!/bin/bash
#获取关注列表所有人的uid，只能获取50条左右，哔哩哔哩限制，也能全获取，比较麻烦，我也用不着，所以没做
#author:lixingyu
#author_site:https://lixingyu.top
#传参方法举例
#./bgslxy.sh "285297152"
#定义传入的uid
uid=$1
#rss负责采集视频信息
rssURL="http://127.0.0.1:1200/bilibili/user/followings/$uid"
#下载rss推送
content=$(wget $rssURL -q -O -)
# echo "$content"
#需要获取 作者名字 标题，以作者名字为文件夹名字命名
author=$(echo -n "$content" | sed -n '/<title>/{s/.*<title>[[:space:]]*<!\[CDATA\[\([^]]*\)\]\]>[[:space:]]*<\/title>.*/\1/p;q}')
echo "$author"
guid=$(echo "$content" | sed -n 's/.*space\.bilibili\.com\/\([0-9]*\).*/\1/p')
echo $guid