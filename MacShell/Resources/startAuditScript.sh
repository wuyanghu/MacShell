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

cd $project_path

#缓存文件
arcidffreuslt_file_path=$sandbox_path/output.txt #arc diff 结果文件
settinginfo_file_path=$sandbox_path/settingInfo.txt #审核信息配置文件
gitstatus_file_path=$sandbox_path/gitdiff.txt #git status文件信息
commitparam_file_path=$sandbox_path/commitParam.txt #提交信息缓存
log_file_path=$sandbox_path/log.txt #运行日志信息

echo "">$log_file_path
#读取url复制到剪切板
function readFileUrl ()
{
    if [ -f $arcidffreuslt_file_path ];then
        cat $arcidffreuslt_file_path | while read url
        do
            echo $url | grep "http://"    #匹配出url的一行

            result=$(echo $url | grep "http://")
            if [[ "$result" != "" ]]
            then
            echo ${url#*URI:} | pbcopy #分割字符并拷贝到剪切板
            return $url
            break
            fi

        done

    fi
}

#提交代码
function commit ()
{
    git status -s 2>&1 | tee $gitstatus_file_path
    diff=$(cat $gitstatus_file_path)

    if [[ "$diff" == "" ]]
    then
        echo "本地文件没有修改" >>$log_file_path
    else
        echo "本地文件有修改" >>$log_file_path
        git add .

        commitParamPath=$commitparam_file_path
        if [ -f $commitParamPath ];then
            echo amend >>$log_file_path
            git commit --amend -m $commitParameter
        else
            echo commit >>$log_file_path
            git commit -m $commitParameter
            echo $commitParameter>$commitParamPath
        fi
    fi

#    result=`readFileUrl`
#    #做一个缓存:没有url则--create;有url则--update
#    if [[ "$result" == "" ]]
#    then
#        echo create >>$log_file_path
#        arc diff --encoding GBK --create --message-file $settinginfo_file_path 2>&1 | tee $arcidffreuslt_file_path  #从文件arcdiff.txt读取配置信息,把arc diff结果写入output.txt
#    else
#        echo update""${result##*/} >>$log_file_path
#        arc diff --encoding GBK --update ${result##*/} --message-file $settinginfo_file_path 2>&1 | tee $arcidffreuslt_file_path  #从文件arcdiff.txt读取配置信息,把arc diff结果写入output.txt
#    fi
}

commit
readFileUrl


