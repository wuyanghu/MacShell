#!/bin/sh

#  commonMethodScript.sh
#  MacShell
#
#  Created by ruantong on 2018/9/3.
#  Copyright © 2018年 ruantong. All rights reserved.
cd $1
sandbox_path=$2
#缓存文件
arcidffreuslt_file_path=$sandbox_path/output.txt #arc diff 结果文件
settinginfo_file_path=$sandbox_path/settingInfo.txt #审核信息配置文件
gitstatus_s_file_path=$sandbox_path/gitdiff.txt #git status -s文件信息
gitstatus_file_path=$sandbox_path/gitstatus.txt
log_file_path=$sandbox_path/log.txt #运行日志信息

#判断是否有推送
function isPush()
{
    git status > $1

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
    git status > $1

    result=$(grep -o 'and have [0-9]* and [0-9]* different' $gitstatus_file_path)
    result2=$(grep -o 'Your branch is behind ' $gitstatus_file_path)
    if [ "$result" != "" -o "$result2" != "" ];then
        echo yes
    else
        echo no
    fi
}

#判断文件是否存在
function isFileExist()
{
    if [ -f $1 ];then
        echo yes
    else
        echo no
    fi
}

#删除文件
function delFile()
{
    result=$(isFileExist $1)
    if [ "$result" == "yes" ];then
        rm $1
    fi
}

#读取url复制到剪切板
function readFileUrl ()
{
    if [ -f $arcidffreuslt_file_path ];then
        result=$(grep -o "http://.*" $arcidffreuslt_file_path)
        if [ $? -eq 0 ];then
            echo $result | pbcopy
            echo $result
        fi
    fi
}


