#!/usr/bin/env bash

#Config Color
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#const
source1=https://github.com/CocoaPods/Specs.git
commitText=""
tag=""
result=`find ./ -maxdepth 1 -type f -name "*.podspec"`
SpecName=${result}


#pull代码
pull() {
    echo -e "${GREEN}\n第一步：准备拉取代码${NC}⏰⏰⏰"
    #先拉代码
    if git pull; then
        echo -e "${GREEN}拉取代码成功${NC}🚀🚀🚀"
    else
        echo -e "${RED}拉取代码失败，请手动解决冲突${NC}🌧🌧🌧"
        exit 1
    fi
}

#替换podspec的Tag
updatePodspec() {
    echo -e "${GREEN}\n第二步：修改 s.version = ${tag} ${NC}⏰⏰⏰"
    sed -i '' s/"s.version[[:space:]]*=[[:space:]]*\'[0-9a-zA-Z.]*\'"/"s.version = \'${tag}\'"/g ${SpecName}
}

#本地验证Lib
localVerifyLib(){
    echo -e "${GREEN}\n第三步：开始本地验证：pod lib lint ${NC}⏰⏰⏰"
    if ! pod lib lint --skip-import-validation --allow-warnings --use-libraries --sources="${source1}"; then echo -e "${RED}验证失败${NC}🌧🌧🌧"; exit 1; fi
    echo -e "${GREEN}验证成功${NC}🚀🚀🚀"
}

#push代码，tag
pushAndTag(){
    echo -e "${GREEN}\n第四步：准备提交代码${NC}⏰⏰⏰"
    git add .
    if ! git commit -m ${commitText}
    then
        echo -e "${RED}git commit失败${NC}🌧🌧🌧"
        exit 1
    fi
    if ! git push
    then
        echo -e "${RED}git push失败${NC}🌧🌧🌧"
        exit 1
    fi
    echo -e "${GREEN}提交代码成功${NC}🚀🚀🚀"

    echo -e "${GREEN}\n第五步：准备打Tag${NC}⏰⏰⏰"
    if git tag ${tag}
    then
        git push --tags
        echo -e "${GREEN}打Tag成功${NC}🚀🚀🚀"
    else
        echo -e "${RED}打Tag失败,本地可能已经存在 ${tag}${NC}🌧🌧🌧"
        echo -e "输入命令【git tag】查看本地tag列表"
        echo -e "单击【Q】返回继续操作终端"
        echo -e "输入命令【git tag -d ${tag}】删除本地tag"
        echo -e "输入命令【git push origin :refs/tags/${tag}】删除远程tag"
        exit 1
    fi
}

#远程验证
remoteVerifyLib(){
    echo -e "${GREEN}\n可省步：开始远程验证：pod spec lint ${NC}⏰⏰⏰"
    if ! pod spec lint --skip-import-validation --allow-warnings --use-libraries --sources="${source1}"; then echo -e "${RED}验证失败${NC}🌧🌧🌧"; exit 1; fi
    echo -e "${GREEN}验证成功${NC}🚀🚀🚀"
}

#发布库
publishLib(){
    echo -e "${GREEN}\n第六步：准备发布${tag}版本${NC}⏰⏰⏰"
    if ! pod trunk push ${SpecName} --allow-warnings; then echo -e "${RED}发布${tag}版本失败${NC}🌧🌧🌧"; exit 1; fi
    echo -e "${GREEN}发布${tag}版本成功${NC}🚀🚀🚀"
}

#发布二进制
publishBinary(){
    echo -e "${GREEN}\n第七步：准备发布${tag}二进制版本${NC}⏰⏰⏰"

    echo -e "${GREEN}发布${tag}二进制版本成功${NC}🚀🚀🚀"
}

# 循环输入直到有值为止
inputValue(){
    read -p "请输入【$1】: " word
    if [[ -z $word ]]; then
        inputValue "$1"
    fi
}
publish(){

    #拉取代码
    pull
    
    # 是否带入参数
    if [[ ! -z $1 ]];then
       commitText=$1
    fi
    
    if [[ -z $commitText ]];then
       #执行循环输入
       inputValue "提交内容"
       #赋值操作
       commitText=${word}
    fi
    read -p "是否仅提交代码（输入回车、空格或者y确认）" res
    if [ -z ${res} ]||[ ${res} == "y" ]||[ ${res} == "Y" ];then
        git add .
        if ! git commit -m ${commitText}
        then
            echo -e "${RED}git commit失败${NC}🌧🌧🌧"
            exit 1
        fi
        if ! git push
        then
            echo -e "${RED}git push失败${NC}🌧🌧🌧"
            exit 1
        fi
        echo -e "${GREEN}提交代码成功${NC}🚀🚀🚀"
        return
    fi
    #
    echo -e "${GREEN}请输入tag:${NC}"
    read b
    tag=${b}
    
    #
    if [ -z "$commitText" ]; then
        echo -e "${RED}提交内容不能为空${NC}🌧🌧🌧"
        exit 1
    fi

    if [ -z "$tag" ]; then
        echo -e "${RED}提交Tag不能为空${NC}🌧🌧🌧"
        exit 1
    fi

    if [ -z "$SpecName" ]; then
        echo -e "${RED}请配置podspec的名称${NC}🌧🌧🌧"
        exit 1
    fi

    #
    updatePodspec
    
    #
    localVerifyLib

    #
    pushAndTag

    #
    remoteVerifyLib

    #
    publishLib

    #
    publishBinary

}

publish $1
