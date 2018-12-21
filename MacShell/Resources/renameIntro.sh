#!/bin/sh
#coding=utf-8
#如启动页,引导图呢，自动按分辨率命名如:640 × 960.png,750 × 1334.png等
file_path=$1
cd $file_path

for img_path in $file_path/*; do
    img_Width=$(sips -g pixelWidth $img_path | tail -n1 | cut -d" " -f4)
    img_Height=$(sips -g pixelHeight $img_path | tail -n1 | cut -d" " -f4)
    img_newname=$img_Width" × "$img_Height".png"
    mv $img_path $img_newname
done

