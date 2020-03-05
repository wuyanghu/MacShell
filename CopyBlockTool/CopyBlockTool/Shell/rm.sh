#!/bin/bash
#coding=utf-8
original_path=$1

function rmAllFile()
{
    if [ -d "$original_path" ]; then
        echo '移除'
        rm -rf $original_path
    fi
}

rmAllFile

