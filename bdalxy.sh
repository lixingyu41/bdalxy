#!/bin/bash
#下载指定up主的所有视频并实时监听更新的视频
#author:lixingyu
#author_site:https://lixingyu.top
#传参方法举例
#./bdalxy.sh "285297152"

#使用lux下载
lux=tools/lux
#上传百度云
BaiduPCSGo=tools/BaiduPCS-Go
#定义传入的uid
uid=$1
#rss负责采集视频信息
rssURL="http://127.0.0.1:1200/bilibili/user/video-all/$uid/:disableEmbed?"
#cookies.txt用来下载大会员清晰度等等
biliCookies="/root/bdalxy/infor/"
#下载rss推送
content=$(wget $rssURL -q -O -)
# echo "$content"
#需要获取 作者名字 标题，以作者名字为文件夹名字命名
author=$(echo -n "$content" | sed -n '/<author>/{s/.*<author>[[:space:]]*<!\[CDATA\[\([^]]*\)\]\]>[[:space:]]*<\/author>.*/\1/p;q}')
echo "$author"
#创建作者文件夹如存在则跳过
if [ -d ./downhere/$author ]; then
    echo "author directory exists."
else
    if mkdir "./downhere/$author" 2>/dev/null; then
        echo "author directory make"
    else
        echo "Failed to create author directory." >&2
        exit 1
    fi
fi
#创建author.txt防止作者改名字，存入作者名与uid相匹配的一对
if [ -f ./infor/author.txt ]; then
    echo "author.txt exists."
else
    if touch "./downhere/$author" 2>/dev/null; then
        echo "author.txt directory make"
    else
        echo "Failed to create author.txt" >&2
        exit 1
    fi
fi
#查找author.txt是否存在uid作者名匹配的行，若不存在则新加一行
authorline="${uid}_${author}"
if grep -q "$authorline" ./infor/author.txt; then
    echo "$authorline exists in file"
else
    echo "$authorline not exist in file"
    # 写入新内容到文件末尾
    echo "$authorline" >> ./infor/author.txt
fi
#获取视频名字，视频源，封面图（注意多P视频）
#获取视频标题
vidtitle1=$(echo -n "$content" | sed -n 's/.*<title>[[:space:]]*<!\[CDATA\[\([^"]*\)\]\]>[[:space:]]*<\/title>.*/\1/p')
vidtitle2=${vidtitle1#$author}
# 将标题变量中的所有不允许的字符替换为空字符串
vidtitle3=$(echo "$vidtitle2" | awk '{gsub(/[][\\/:：*?"<>|]/,""); gsub(/[[:blank:]]+/,""); print}')
# echo $vidtitle3
#去除emoji
vidtitle=$(echo "$vidtitle3" | perl -CSD -pe 's/\p{Emoji}//g')
# echo "$vidtitle"
#获取视频封面链接
vidimg=$(echo -n "$content" | sed -n 's/.*<img[[:space:]]*src="\([^"]*\)"[[:space:]]*referrerpolicy.*/\1/p')
# echo "$vidimg"
#获取视频链接
vidlink=$(echo -n "$content" | sed -n 's/.*<link>\([^<]*www\.bilibili\.com[^<]*\)<\/link>.*/\1/p')
# echo "$vidlink"
vidbv=$(echo "$vidlink" | sed 's/.*\/video\///')
# echo "$vidbv"
#下载视频封面命名为poster.png
#下载视频本体命名为视频标题
titles_array=($vidtitle)
videos_array=($vidlink)
posters_array=($vidimg)
bv_array=($vidbv)
cd "./downhere/$author" || exit 1
if [ -f vidbv.txt ]; then
    echo "vidbv.txt exists."
else
    if touch vidbv.txt 2>/dev/null; then
        echo "vidbv.txt directory make"
    else
        echo "Failed to create vidbv.txt" >&2
        exit 1
    fi
fi
for ((i=0;i<${#titles_array[@]};i++)); do
    # 提取数组值
    titlein=${titles_array[i]}
    posterin=${posters_array[i]}
    videoin=${videos_array[i]}
    videobvin=${bv_array[i]}
    if grep -q "$videobvin" vidbv.txt; then
        echo "video already exist"
    else
        # 创建以标题为名的文件夹，并进入该文件夹
        echo "---"
        mkdir -p "$titlein"
        cd "$titlein" || exit 1
        #下载视频和图片若存在则跳过
        #图片下载
        if [ -e poster.jpg ]; then
            echo "poster exist"
        else
            wget -nv -O "poster.jpg" "$posterin"
        fi
        # 视频下载
        if [ -e "$titlein".mp4 ]; then
            echo "video exists"
        else
            echo "download"
            ../../../tools/lux -c "$biliCookies"cookies.txt -O "$titlein" "$videoin"
        fi
        #上传百度网盘
        ../../../tools/BaiduPCS-Go upload "$titlein.mp4" /bilidown/$author/ #这里的bilidown是网盘的目录，可以改，也可以放根目录
        echo "upload done"
        #防止占用服务器空间上传完就删掉封面和视频，但是目录会保存
        echo "remove local file"
        rm $titlein.mp4
        rm poster.jpg
        cd ..
        ##记录下载的视频bv到vidbv.txt
        if grep -q "$videobvin" vidbv.txt; then
            echo ""$videobvin" exists in file"
        else
            echo ""$videobvin" not exist in file"
            # 写入新内容到文件末尾
            echo "$videobvin" >> vidbv.txt
            echo "bv written"
        fi
    fi
done
cd ../ || exit 1
cd ../ || exit 1