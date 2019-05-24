#!/bin/bash
#coding=utf-8

original_path=$1/.
target_path=/Users/$USER/Library/Developer/Xcode/UserData/CodeSnippets

function createFileNoExist()
{
    if [ ! -d "$target_path" ]; then
        mkdir -p $target_path
    fi
}

function cpOriginalToTarget()
{
    cp -R $original_path $target_path
}

createFileNoExist
cpOriginalToTarget
