#工程代码更新
echo "\n============ 开始执行脚本 ============"

# 读取plist文件
function read_plist(){
  if [ ! -z $1 ];then
      echo `/usr/libexec/PlistBuddy -c "Print :${1}" ${INFOPLIST_FILE}`
  fi
}
# 查看工程文件中的参数
function check_project_pbxproj(){
  if [ ! -z $1 ];then
    # 工程文件查询结果
    result=`sed -n '/'${1}'/{s/'${1}' = //;s/;//;s/^[[:space:]]*//;p;q;}' ./${project_name}.xcodeproj/project.pbxproj`
    # 输出返回值去除双引号
    echo ${result} | sed 's/\"//g'
  fi
}

# 删除特殊符号"{"、"}"、"("、")"、"$"
function delete(){
    if [ ! -z $1 ];then
        echo "$1" | sed 's/{//g' | sed 's/}//g' | sed 's/(//g' | sed 's/)//g'| sed 's/\$//g'
    fi
}
# 判断文件是否存在
function hasfile(){
    # -f 参数判断 $1 是否存在
    if [ -f "$1" ]; then
      echo "YES"
    fi
      #touch "$1"
}
# 判断文件中是否包含某内容
function filehasword(){

    if [[ -z $2 ]]; then
        echo "$2值不能为空"
        return
    fi
    if [[ -n $(hasfile "$1") ]]; then

        if cat "$1" | grep "$2" > /dev/null
        then
            echo "$1中已存在$2"
            continue
        fi
    else
        echo "$1文件不存在"
    fi
}

# 脚本入口函数
function init(){


    #工程路径读取
    if [ ! -z $1 ];then
        workspace_path=$1
    else
        workspace_path="$(cd "$(dirname $0)" && pwd)"
    fi
    #echo -e "${GREEN}当前路径: ${workspace_path}${NC}"
    cd ${workspace_path}
    workspace_name=$(ls | grep xcworkspace)
    #echo -e "${GREEN}工程名称: ${workspace_name}${NC}"
    project_name=$(ls ${workspace_path} | grep xcodeproj | awk -F.xcodeproj '{print $1}')
    #echo -e "${GREEN}项目名称: ${project_name}${NC}"
    # 读取工程文件的info.plist文件路径
    INFOPLIST_FILE=${workspace_path}/$(check_project_pbxproj "INFOPLIST_FILE")
    #echo -e "${GREEN}plist文件路径: ${INFOPLIST_FILE}${NC}"

    # 处理遍历plist文件
    LINES=`/usr/libexec/PlistBuddy ${INFOPLIST_FILE} -c print | grep = | tr -d ' '`
    for PLIST_ITEMS in ${LINES};
    do
        # 截取“=”第一段作为KEY值
        KEY=`echo $PLIST_ITEMS | cut -d= -f1`
        VALUE=$(read_plist "${KEY}")
        # 查找到Bundle ID的值
        if [ $KEY == "CFBundleIdentifier" ];then
            BundleId=$(read_plist "${KEY}")
            if [[ "${BundleId}" == '$'* ]]; then
                # 处理删除特殊字符后读取工程文件
                BundleId=$(check_project_pbxproj "$(delete "$BundleId")")
            fi
            break
        fi
        
    done
    
    #================================ 项目白名单集合 ================================
    BundleIDS=("com.njxingong.qycloud" "org.ay.demo.module" "pod 'JAConfigBase'")
    
    IS_WHITE=false
    # 遍历筛选结果
    for(( i=0;i<${#BundleIDS[@]};i++)) do
        # 读取数组元素
        item=${BundleIDS[i]}
        if [ $item == "$BundleId" ];then
            IS_WHITE=true
            break
        fi
    done
    
    #================================ 项目白名单集合 ================================
    WHITE_PODS=(
    "QYCQChat# pod 'QYCQChat', :git => 'http://git.qpaas.com/PaasPods/QYCQChat.git', :branch => 'feature/LXFeb_UserInfo'"
    "QYCMonitor# pod 'QYCMonitor', :git => 'http://git.qpaas.com/PaasPods/QYCMonitor.git', :branch => 'project/Project_Base'"
    )
    # 遍历筛选结果
    for(( i=0;i<${#WHITE_PODS[@]};i++)) do
        # 判断是否存在于白名单中
        change_podfile "${WHITE_PODS[i]}" "$IS_WHITE"
    done

   
}
# 修改Podfile文件
function change_podfile(){
    if [[ -z $1 ]];then
        return
    fi
    # 匹配库
    check_key=`echo $1 | cut -d "#" -f 1`
    check_value=`echo $1 | cut -d "#" -f 2`

    # 描述文件位置
    Podfile_Path="${workspace_path}/Podfile"
    cd $workspace_path
    # 判断文件中是否存在
    if [[ -z $(filehasword "${Podfile_Path}" "${check_key}") ]]; then
        if [ $2 == true ];then
                # 读取指定行
            addline=`grep -n "target '$project_name'"  ${Podfile_Path} | cut -d ":" -f 1`
            if [[ -z ${addline} ]]; then
            addline=`grep -n "target '${project_name}_Example'"  ${Podfile_Path} | cut -d ":" -f 1`
            fi
            
            #允许插入
            if [[ -n ${addline} ]]; then
                sed '/pattern/{G;}' ${Podfile_Path}
                result=$(sed -i '' "${addline} a\\
                ${check_value}" ${Podfile_Path})
            fi
        fi

        else
        # 读取指定行
        hangline=`grep -n "$check_key"  ${Podfile_Path} | cut -d ":" -f 1`
        if [ $2 == false ];then
             # 删除指定行内容最为最终结果
            result=$(sed "${hangline}d" ${Podfile_Path})
        fi
    fi
    
    #结果不为空修改覆盖文件
    if [[ -n ${result} ]]; then
    echo "$result"
        cd ${workspace_path}
        echo "${result}">"${Podfile_Path}"
        
#        #回到当前目录，执行pod命令
#        cd ${workspace_path}
#        pod install
    fi
}
# 执行脚本
init $1
