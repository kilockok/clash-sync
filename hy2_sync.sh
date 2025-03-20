#!/bin/bash
# 隐藏用户输入
stty erase ^H

while getopts "a:" opt; do
  case $opt in
    a) REMOTE_API="$OPTARG";;
    \?)
      echo "用法: $0 [-a API地址]"
      echo "示例: $0 -a 'http://example.com/config'"
      exit 1
      ;;
  esac
done

# 检测当前用户是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 用户执行此脚本！"
  echo "你可以使用 'sudo -i' 进入 root 用户模式。"
  exit 1
fi

# 远程 API 地址
if [ -z "$REMOTE_API" ]; then
    echo -e "\e[32m请输入您的api地址\e[0m"
    read -r REMOTE_API
fi

# 检查是否存在 /root/hy3 文件夹
if [ ! -d "/root/hy3" ]; then
    echo -e "\e[31m错误: /root/hy3 文件夹不存在!请先使用kilock提供的脚本安装hy2!!。\e[0m"
    echo curl -s -O https://raw.githubusercontent.com/kilockok/clash-/refs/heads/main/hy2_install.sh && chmod +x hy2_install./sh && ./hy2-install.sh
    exit 1
fi

# 输入节点名称
echo -e "\e[32m给节点取个名字吧~\e[0m"
echo -e "\e[32m格式: 地区缩写|服务器所有者|协议 例如: Ningbo|qqqqqf|CMCC\e[0m"
read -r NODE_NAME

# 本地文件中提取节点
config_file="/root/hy3/clash-mate.yaml"

echo "提取 proxies 部分的信息..."
server=$(grep -A 10 "proxies:" "$config_file" | grep "server:" | awk '{print $2}')
port=$(grep -A 10 "proxies:" "$config_file" | grep "port: " | awk '{print $2}')
password=$(grep -A 10 "proxies:" "$config_file" | grep "password: " | awk '{print $2}')

# 核验信息
echo -e "\n=== 核验信息 ==="
echo "节点名称: $NODE_NAME"
echo "服务器地址: $server" 
echo "端口号: $port"
echo "密码: $password"
echo "=================="
echo ""

# 询问是否继续上传
read -p "以上信息是否正确？[Y/n] " confirm
case $confirm in
    [nN][oO]|[nN])
        echo "已取消上传"
        exit 1
        ;;
    *)
        echo "继续上传..."
        ;;
esac

# 添加配置到远程服务器
response=$(curl -X POST "$REMOTE_API" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$NODE_NAME\",\"server\":\"$server\",\"port\":\"$port\",\"password\":\"$password\"}")

# 检查返回值
if [[ $response == *"Config updated successfully!"* ]]; then
    echo -e "\e[32m配置已成功追加到远程服务器!\e[0m"
else
    echo -e "\e[31m错误: 配置上传失败！服务器返回: $response\e[0m"
    exit 1
fi
