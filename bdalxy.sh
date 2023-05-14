#!/bin/bash
# export LANG=en_US.UTF-8

#下载指定up主的全部video并实时监听更新
#author:lixingyu
#author_site:https://lixingyu.top

#相关信息定义
#lux下载工具
lux=/home/lxy/bdalxy/tools/lux
#上传百度云的工具
BaiduPCSGo=/home/lxy/bdalxy/tools/BaiduPCS-Go
#传入的uid文件
alluid=$(cat /home/lxy/bdalxy/infor/uid.txt)
#rss源
rss=$(cat /home/lxy/bdalxy/infor/rss.txt)
#cookies.txt用来下载大会员清晰度等等
biliCookies="/home/lxy/bdalxy/infor/"
#rss格式
#rssURL="http://123.249.3.63:1200/bilibili/user/video-all/$uid/:disableEmbed?"
#rssURL="http://127.0.0.1:1200/bilibili/user/video-all/$uid/:disableEmbed?"

#uid循环
uid_array=($alluid)
for ((i=0;i<${#uid_array[@]};i++)); do
	uid_num=$(($uid_num+1))
done
for ((j=0;j<${#uid_array[@]};j++)); do
    uid_array_get=${uid_array[j]}
	echo "----$uid_array_get---- $(($j+1)) of $uid_num ----"
    #判断rss是否能用
    rss_array=($rss)
    for ((i=0;i<${#rss_array[@]};i++)); do
        rss_array_get=${rss_array[i]}
        echo "test $rss_array_get ......"
        #下载rss推送
        content=$(wget $rss_array_get/bilibili/user/video-all/$uid_array_get/:disableEmbed? -q -O -)
        #echo "$content"
        #需要获取 作者名字 标题，以作者名字为文件夹名字命名
        author=$(echo -n "$content" | sed -n '/<author>/{s/.*<author>[[:space:]]*<!\[CDATA\[\([^]]*\)\]\]>[[:space:]]*<\/author>.*/\1/p;q}')
        if [ -z "$author" ]; then
            continue
            echo "change rss...."
        else
            break
        fi
    done
    echo "------------------"
    echo "$author"
    echo "------------------"
    #创建author.txt防止作者改名字，存入作者名与uid相匹配的一对
    if [ -f ./infor/author.txt ]; then
        echo "author.txt exist."
    else
        if touch "./downhere/author.txt" 2>/dev/null; then
            echo "author.txt directory make"
        else
            echo "Failed to create author.txt" >&2
            exit 1
        fi
    fi
    #查找author.txt是否存在uid作者名匹配的行，若不存在则新加一行
    authorline="${uid_array}_${author}"
    if grep -q "$authorline" ./infor/author.txt; then
        echo "$authorline exists in author.txt"
    else
        echo "$authorline not exist in file"
        # 写入新内容到文件末尾
        echo "$authorline" >> ./infor/author.txt
        if grep -q "$authorline" ./infor/author.txt; then
            echo "$authorline write success"
        else
            echo "$authorline write fail"
            exit 1
        fi
    fi
    #创建作者文件夹如存在则跳过
    if [ -d ./downhere/$author ]; then
        echo "$author directory exist"
    else
        if mkdir "./downhere/$author" 2>/dev/null; then
            echo "$author directory make success"
        else
            echo "Failed to create $author directory." >&2
            exit 1
        fi
    fi
    #获取视频名字，视频源，封面图（注意多P视频）
    #获取视频标题
    vidtitle1=$(echo "$content" | grep -oP '(?<=<title><!\[CDATA\[).*?(?=]]></title>)' | tr -d ' ' | paste -sd ' ')
    # echo "------vidtitle1--------"
    # echo $vidtitle1
    # echo "---------------"
    vidtitle2=${vidtitle1#$author}
    # echo "------vidtitle2--------"
    # echo $vidtitle2
    # echo "---------------"
    #去除所有符号和控制字符
    vidtitle3=$(echo "$vidtitle2" | sed 's/[[:punct:][:cntrl:]]//g' | tr '\n' ' ' | awk '{$1=$1;print}')
    # echo "------vidtitle3--------"
    # echo "$vidtitle3"
    # echo "---------------"
    #去除空格

    #去除emoji
    vidtitle=$(echo "$vidtitle3" | perl -CSD -pe 's/\p{Emoji}//g')
    # echo "------vidtitle--------"
    # echo "$vidtitle"
    # echo "---------------"
    #获取封面链接
    vidimg=$(echo -n "$content" | sed -n 's/.*<img[[:space:]]*src="\([^"]*\)"[[:space:]]*referrerpolicy.*/\1/p')
    # echo "------vidimg--------"
    # echo "$vidimg"
    # echo "---------------"
    #获取视频链接
    vidlink=$(echo -n "$content" | sed -n 's/.*<link>\([^<]*www\.bilibili\.com[^<]*\)<\/link>.*/\1/p')
    # echo "------vidlink--------"
    # echo "$vidlink"
    # echo "---------------"
    #获取bv号
    vidbv=$(echo "$vidlink" | sed 's/.*\/video\///')
    # echo "-----vidbv------"
    # echo "$vidbv"
    # echo "---------------"
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
    num=0
    for ((i=0;i<${#titles_array[@]};i++)); do
        num=$((num+1))
    done
    for ((i=0;i<${#titles_array[@]};i++)); do
        # 提取数组值
        titlein=${titles_array[i]}
        posterin=${posters_array[i]}
        videoin=${videos_array[i]}
        videobvin=${bv_array[i]}
        echo "----------------------- $(($j+1)) of $uid_num -------- $author -- $(($i+1)) in $num  -----------------------------"
        echo "$titlein"
        #echo "$videos_array"
        #echo "$posters_array"
        echo "$videobvin"
        if grep -q "$videobvin" vidbv.txt; then
            echo "exist"
        else
            # 创建以标题为名的文件夹，并进入该文件夹
            # echo "---"
            mkdir -p "$titlein"
            cd "$titlein" || exit 1
            #下载视频和图片若存在则跳过
            #图片下载
            if [ -e poster.jpg ]; then
                echo "poster exist"
            else
                wget -nv -O "poster.jpg" "$posterin"
                echo "poster download"
            fi
            # 视频下载
            if [ -e "$titlein".mp4 ]; then
                echo "$titlein exists"
            else
                echo "download begin"
                $lux -c "$biliCookies"cookies.txt -O "$titlein" "$videobvin"
            fi
            sleep 1s
            #判断下载
            echo "download check"
            if [ -f "poster.jpg" ] && [ -f "$titlein.mp4" ]; then
                echo "poster and $titlein.mp4 download check success"
                x=1
            else
                echo "poster and $titlein.mp4 download check fail"
                x=0
                echo "next begin skip upload"
                ##exit 1
            fi
            if [ $x == 1 ]; then
		    #上传百度网盘或者rclone
		    $BaiduPCSGo upload "poster.jpg" /bilidown/$author/$titlein/
		    $BaiduPCSGo upload "$titlein.mp4" /bilidown/$author/$titlein/
		    echo "upload done"
		    echo "remove local file"
		    rm $titlein.mp4
		    rm poster.jpg
		    cd ..
		    ##记录下载bv到vidbv.txt
		    if grep -q "$videobvin" vidbv.txt; then
		        echo "$videobvin exists in file"
		    else
		        echo "$videobvin not exist in file"
		        # 写入新内容到文件末尾
		        echo "$videobvin" >> vidbv.txt
		        echo "bv written"
		    fi
	    else
	    	echo "skip upload done"
	    fi
        fi
    done
    cd ../ || exit 1
    cd ../ || exit 1
done
