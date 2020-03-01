# coding:utf-8  
#功能: 将 TingpaiLogic 里头 带 str_headcombi 且不带 str_TingpaiLogic , str_return , str_hulue 的行数全部注释 
#参数: t 为注释 f 为反注释
#说明: 如果想手动忽略掉某一行 请在行尾加上 --python_hulue
import itertools
import sys

str_headcombi = "headcombi"
str_TingpaiLogic = "TingpaiLogic"
str_return = "return"
str_hulue = "python_hulue"

def annotation (file):
    #加注释
    import os
    data = ""
    #         传入文件                                  修改后得文件
    with open(file, 'r+', encoding='utf-8') as f1:
        f1.seek(0)  # 指针移到顶部
        for line in f1:  # 逐行修改，并写入a1.bak
            #带 str_headcombi  并且 不带 str_TingpaiLogic str_return str_hulue --python_zhushi 就注释
            if line.find(str_headcombi) != -1 and line.find(str_TingpaiLogic) == -1 and line.find(str_return) == -1 \
                and line.find(str_hulue) == -1 and line.find("--python_zhushi") == -1:
                new_line = '--python_zhushi' + line
                data += new_line
            else:
               data += line
    wopen = open(file, 'w', encoding='utf-8')
    wopen.write(data)
    wopen.close()
    f1.close()

def de_annotation (file):
    #解注释 
    import os
    data = ""
    #         传入文件                                  修改后得文件
    with open(file, 'r+', encoding='utf-8') as f1:
        f1.seek(0)  # 指针移到顶部
        for line in f1:  # 逐行修改，并写入a1.bak
            #带 str_headcombi  并且 不带 str_TingpaiLogic str_return str_hulue 就注释
            if line.find(str_headcombi) != -1 and line.find(str_TingpaiLogic) == -1 and line.find(str_return) == -1 \
                and line.find(str_hulue) == -1 and line.find('--python_zhushi') != -1:
                new_line = line.replace("--python_zhushi", '')
                data += new_line
            else:
               data += line
    wopen = open(file, 'w', encoding='utf-8')
    wopen.write(data)
    wopen.close()
    f1.close()

def python_hulue(file, is_annotation):
    if is_annotation:#加注释
        return annotation(file)
    return de_annotation(file)#解注释

if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1] == "t":
            print("进行注释")
            python_hulue('TingpaiLogic.lua', True)
        if sys.argv[1] == "f":
            print("进行解注释")
            python_hulue('TingpaiLogic.lua', False)
    if len(sys.argv) <= 1:
        print("需要参数 t : 注释 ; f : 反注释")
    # true 是加注释 false 是解注释
#    python_hulue('TingpaiLogic.lua', True)
#    python_hulue('TingpaiLogic.lua', False)
