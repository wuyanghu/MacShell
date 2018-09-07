#!/bin/sh
#coding=utf-8
#固定参数 $1:工程路径;$2:沙盒路径;$3:获取参数;$4:arc命令所在目录
basepath=$(cd `dirname $0`; pwd)
source $basepath/commonMethodScript.sh $1 $2

project_path=$1 #工程路径
sandbox_path=$2 #沙盒路径
executeCommand=$3
arccommand_path=$4 #arc命令所在目录
#审核完后手动推送代码
function pushOrigin ()
{
    git status -s > $sandbox_path""/gitdiff.txt
    diff=$(cat $sandbox_path""/gitdiff.txt)

    if [[ "$diff" == "" ]]
    then
        git branch > $sandbox_path""/branch.txt
        cat $sandbox_path""/branch.txt | read branch

        #$executeCommand:1.拉取代码 2.推送代码
        if [ $executeCommand == "1" ];then
            isPullResult=$(isPull $gitstatus_file_path)
            if [ "$isPullResult" == "yes" ];then
                echo "有新的拉取消息，正在拉取代码...">>$log_file_path
                git pull --rebase origin $branch>>$log_file_path
                if [[ $? -eq 0 ]];then
                    echo "代码拉取成功。"
                    echo "代码拉取成功。">>$log_file_path
                else
                    echo "代码拉取失败，请重试...">>$log_file_path
                fi
            else
                echo "无新的拉取消息...">>$log_file_path
            fi
        elif [ $executeCommand == "2" ];then
            isPushResult=$(isPush $gitstatus_file_path)
            if [ "$isPushResult" == "yes" ];then
                echo "正在推送代码...">>$log_file_path
                git push -u origin $branch>>$log_file_path
                if [[ $? -eq 0 ]];then
                    echo "推送代码成功..."
                    echo "推送代码成功...">>$log_file_path
                    result=`readFileUrl`
                    $arccommand_path/arc close-revision ${result##*/}
                    #提交完后移除文件
                    delFile $sandbox_path/branch.txt
                    delFile $arcidffreuslt_file_path
                    delFile $gitstatus_s_file_path
                else
                    echo "推送代码失败,请重试..."
                    echo "推送代码失败,请重试...">>$log_file_path
                fi
            else
                echo "请先commit代码再推送代码">>$log_file_path
            fi
        else
            echo "other">>$log_file_path
        fi

    else
        echo "本地文件有修改,请先commit..."
    fi

}

pushOrigin

