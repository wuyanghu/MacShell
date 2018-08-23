#!/bin/sh

#  startAuditScript.sh
#  PrivilegedTaskExample
#
#  Created by ruantong on 2018/8/6.
#  Copyright © 2018年 Sveinbjorn Thordarson. All rights reserved.

#coding=utf-8

commitParameter=$1 #获取参数
project_path=$2 #工程路径
sandbox_path=$3 #沙盒路径
arccommand_path=$4 #arc命令所在目录

cd $project_path

#缓存文件
arcidffreuslt_file_path=$sandbox_path/output.txt #arc diff 结果文件
settinginfo_file_path=$sandbox_path/settingInfo.txt #审核信息配置文件
gitstatus_s_file_path=$sandbox_path/gitdiff.txt #git status -s文件信息
gitstatus_file_path=$sandbox_path/gitstatus.txt
log_file_path=$sandbox_path/log.txt #运行日志信息

echo "">$log_file_path
#读取url复制到剪切板
function readFileUrl ()
{
    if [ -f $arcidffreuslt_file_path ];then
        cat $arcidffreuslt_file_path | while read url
        do
            result=$(echo $url | grep "http://")
            if [[ "$result" != "" ]]
            then
            echo ${url#*URI:} | pbcopy #分割字符并拷贝到剪切板
            echo $url
            break
            fi

        done

    fi
}
#判断是否有推送
function isPush()
{
    git status > $gitstatus_file_path

    result=$(grep -o 'Your branch is ahead of' $gitstatus_file_path)
    if [ "$result" != "" ];then
        echo yes
    else
        echo no
    fi
}

#判断是否有拉取
function isPull()
{
    git status > $gitstatus_file_path

    result=$(grep -o 'and have [0-9]* and [0-9]* different' $gitstatus_file_path)
    result2=$(grep -o 'Your branch is behind ' $gitstatus_file_path)
    if [ "$result" != "" -o "$result2" != "" ];then
        echo yes
    else
        echo no
    fi
}

#arc diff生成url
function arcdiffUrl ()
{
    result=`readFileUrl`
    #做一个缓存:没有url则--create;有url则--update
    if [[ "$result" == "" ]]
    then
    echo create >>$log_file_path
    $arccommand_path""arc diff --encoding GBK --create --message-file $settinginfo_file_path 2>&1 | tee $arcidffreuslt_file_path  #从文件arcdiff.txt读取配置信息,把arc diff结果写入output.txt
    else
    echo update""${result##*/} >>$log_file_path
    $arccommand_path""arc diff --update ${result##*/} -m $commitParameter 2>&1 | tee $arcidffreuslt_file_path    #把arc diff结果写入output.txt
    fi
}

#提交代码
function commit ()
{
    git status -s > $gitstatus_s_file_path
    diff=$(cat $gitstatus_s_file_path)

#提交代码逻辑:
#1.本地有修改可提交
#2.无推送执行commit,有推送执行commit --amend

    if [[ "$diff" == "" ]]
    then
        echo "本地文件没有修改" >>$log_file_path
    else
        echo "本地文件有修改" >>$log_file_path
        git add .

        isPushResult=$(isPush)
        if [ "$isPushResult" == "yes" ]; then
            git commit --amend -m $commitParameter
            echo amend >>$log_file_path
        else
            git commit -m $commitParameter
            echo commit >>$log_file_path
        fi
    fi

#执行arc diff条件
#1.本地文件无修改，否则失败
#2.已有推送可执行arc diff，否则失败

    git status -s > $gitstatus_s_file_path
    diff=$(cat $gitstatus_s_file_path)
    if [[ "$diff" == "" ]]
    then
        isPushResult=$(isPush)
        if [ "$isPushResult" == "yes" ]; then
            echo 'arcdiffurl' >>$log_file_path
            arcdiffUrl
        else
            echo 'no arcdiffurl' >>$log_file_path
        fi
    else
        echo 'commit failure' >>$log_file_path
    fi
}

isPullResult=$(isPull)
if [ "$isPullResult" == "yes" ];then
    echo "有新的拉取消息，请先处理!"
else
    commit
    readFileUrl
fi


