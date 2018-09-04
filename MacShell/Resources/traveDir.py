#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import re
import json
import sys
import fileinput
import shelve

reload(sys)
sys.setdefaultencoding('utf-8')

result_chinese_dict = {}
localizable_strings_dict = {}

project_path = '/Users/ruantong/Desktop/migu/cmread-tools/MacGitShell/MacShell'
chinese_str_path = '/Users/ruantong/Desktop/chinese_str_json.txt'
localizable_str_path = '/Users/ruantong/Desktop/localizable_str_json.txt'

#匹配@"至少有一个中文"字符
def findFileChineseStr(filename):
    hand = open(filename)
    for line in hand:
        line = line.rstrip()
#        res = re.findall(u'@".*?[\u4E00-\u9FA5]+?.*?"', line.decode('utf8'))
#        if res:
##            print "There are %d parts:\n"% len(res)
#            for r in res:
##                print "\t",r
#                if filename not in result_chinese_dict.keys():
#                    result_chinese_dict[filename] = [r]        #此句话玄机
#                else:
#                    result_chinese_dict[filename].append(r)

        it = re.finditer(u'@"?.*?[\u4E00-\u9FA5]+?.*?"', line.decode('utf-8'))
#        it = re.finditer(u'^(?!NSLog()', line.decode('utf-8'))
        for match in it:
            localizable_strings_dict[match.group().encode('utf-8')]='@""'
            if filename not in result_chinese_dict.keys():
                result_chinese_dict[filename] = [match.group().encode('utf-8')]        #此句话玄机
            else:
                result_chinese_dict[filename].append(match.group().encode('utf-8'))
    hand.close()

#遍历文件夹
def traverse(f):
    fs = os.listdir(f)
    for f1 in fs:
        tmp_path = os.path.join(f,f1)
        if not os.path.isdir(tmp_path):
            match = re.match(r'.*.m$',tmp_path)# 使用Pattern匹配文本，获得匹配结果，无法匹配时将返回None
            if match:
                findFileChineseStr(tmp_path)
        else:
            traverse(tmp_path)

#替换原有字符并保证原格式不变
def replace(file_path, old_str, new_str):
    try:
        f = open(file_path,'r+')
        all_lines = f.readlines()
        f.seek(0)
        f.truncate()
        for line in all_lines:
            searchObj = re.search(r'NSLog\(@".*',line.decode('utf-8'))
            if not searchObj:
                line = line.replace(old_str, new_str)
            f.write(line)
        f.close()
    except Exception,e:
        print e

#把数据写入文件
def write_file(file_path,data):
    file = open(file_path, 'w')
    file.write(data)
    file.close()

#从文件中读取数据
def read_file(file_path):
    file = open(file_path, 'r')
    read_data=file.read()
    file.close()
    return read_data

def encode_utf8(string):
    return string.encode('utf-8')

def decode_utf8(string):
    return unicode(string, encoding='utf-8')

def main():
    while True:
        a = input("输入数字1,匹配工程文件并把结果写入文件;输入数字2，替换文件匹配结果:")
        if a==1:
            
            traverse(project_path)
            
            global result_chinese_dict
            if localizable_strings_dict:
#                print json.dumps(localizable_strings_dict, encoding="UTF-8", ensure_ascii=False)
                result=json.dumps(localizable_strings_dict,ensure_ascii=False,indent=4)
                write_file(localizable_str_path,result)

            if result_chinese_dict:
                result=json.dumps(result_chinese_dict,ensure_ascii=False,indent=4)
                write_file(chinese_str_path,result)
            print '结果已写入'+chinese_str_path
        else:
            localizable_file_dict=json.loads(read_file(localizable_str_path))
            if not result_chinese_dict:
                result_chinese_dict=json.loads(read_file(chinese_str_path))
            for key in result_chinese_dict:
                resultArr=result_chinese_dict[key]
                for i, val in enumerate(resultArr):
                    result=localizable_file_dict[val.decode('utf8')]
                    if result != '@""':
                        replace(key,val,result)
                        print '已成功替换:%s,%s' %(val,result)

            print '字符替换完成'
            break

main()



