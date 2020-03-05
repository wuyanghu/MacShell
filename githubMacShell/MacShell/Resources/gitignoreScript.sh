#!/bin/sh
#固定参数 $1:工程路径;$2:沙盒路径;$3 #获取参数

cd $1
ls -a>$2/ls_a.txt
result=$(grep -o ".*.xcodeproj" $2/ls_a.txt)

if [ $3 == "1" ] ;then
    git update-index --no-assume-unchanged $result/project.pbxproj
else
    git update-index --assume-unchanged $result/project.pbxproj
fi

