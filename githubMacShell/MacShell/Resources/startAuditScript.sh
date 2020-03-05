#!/bin/sh
#coding=utf-8
#固定参数 $1:工程路径;$2:沙盒路径;$3 #获取参数
#        $4:commit参数;$5:arc命令所在目录
basepath=$(cd `dirname $0`; pwd)
source $basepath/commonMethodScript.sh $1 $2
executeCommand=$3 #执行参数
commitParameter=$4 #commit参数
arccommand_path=$5 #arc命令所在目录

#arc diff生成url
function arcdiffUrl ()
{
    result=`readFileUrl`
    #做一个缓存:没有url则--create;有url则--update
    if [[ "$result" == "" ]]
    then
        echo '正在执行arc diff --create'>>$log_file_path
        $arccommand_path""arc diff --encoding GBK --create --message-file $settinginfo_file_path 2>&1 | tee $arcidffreuslt_file_path  #从文件arcdiff.txt读取配置信息,把arc diff结果写入output.txt
    else
        echo '正在更新arc diff --update'""${result##*/}>>$log_file_path
        $arccommand_path""arc diff --update ${result##*/} -m $commitParameter 2>&1 | tee $arcidffreuslt_file_path    #把arc diff结果写入output.txt
    fi

    if [[ $? -eq 0 ]];then
        echo 'arc diff执行完成'>>$log_file_path
    else
        echo 'arc diff执行异常，请检查后重新尝试'>>$log_file_path
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
        echo "本地文件没有提交...">>$log_file_path
    else
        echo "正在提交...">>$log_file_path
        git add .

        isPushResult=$(isPush $gitstatus_file_path)
        if [ "$isPushResult" == "yes" ]; then
            git commit --amend -m $commitParameter >>$log_file_path
            echo "追加提交...">>$log_file_path
        else
            git commit -m $commitParameter >>$log_file_path
            echo "提交...">>$log_file_path
        fi
        if [[ $? -eq 0 ]];then
            echo "提交成功..."
            echo "提交成功...">>$log_file_path
        else
            echo "提交失败，请检查后再尝试"
            echo "提交失败，请检查后再尝试">>$log_file_path
        fi

    fi

}

function arcdiff()
{
#执行arc diff条件
#1.本地文件无修改，否则失败
#2.已有推送可执行arc diff，否则失败

    git status -s > $gitstatus_s_file_path
    diff=$(cat $gitstatus_s_file_path)
    if [[ "$diff" == "" ]]
    then
        isPushResult=$(isPush $gitstatus_file_path)
        if [ "$isPushResult" == "yes" ]; then
            echo '开始执行arc diff'>>$log_file_path
            arcdiffUrl
        else
            echo '请先推送代码再执行arc diff'>>$log_file_path
        fi
    else
        echo '还有代码未提交'>>$log_file_path
    fi
}

function execresult()
{
    isPullResult=$(isPull $gitstatus_file_path)
    if [ "$isPullResult" == "yes" ];then
        echo "有新的拉取消息，请先处理!">>$log_file_path
    else
        #$executeCommand:1.提交代码 2.
        if [ $executeCommand == "1" ];then
            commit
        elif [ $executeCommand == "2" ];then
            arcdiff
            readFileUrl
        else
            echo '1'
        fi
    fi

}
execresult $executeCommand
