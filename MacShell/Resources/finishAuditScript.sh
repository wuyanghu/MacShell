#!/bin/sh

#  finishAuditScript.sh
#  PrivilegedTaskExample
#
#  Created by ruantong on 2018/8/6.
#  Copyright © 2018年 Sveinbjorn Thordarson. All rights reserved.

project_path=$1 #工程路径
sandbox_path=$2 #沙盒路径

cd $project_path

#审核完后手动推送代码
function pushOrigin ()
{
    git status -s > $sandbox_path""/gitdiff.txt
    diff=$(cat $sandbox_path""/gitdiff.txt)

    if [[ "$diff" == "" ]]
    then
        echo "push本地文件没有修改，可以提交"

        git branch > $sandbox_path""/branch.txt

        cat $sandbox_path""/branch.txt | read branch
        git pull --rebase origin $brench
        git push -u origin $brench

        #提交完后移除文件
        rm $sandbox_path/branch.txt
        rm $sandbox_path/output.txt
        rm $sandbox_path/gitdiff.txt
    else
        echo "push本地文件有修改,不能提交"
    fi

}

pushOrigin
