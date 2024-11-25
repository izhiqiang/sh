#!/bin/bash

# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/jiben.sh | bash
# apt install -y net-tools

function systatus_info() {
    echo -e "\n==================== 服务器基本信息 ==================="
    # 获取操作系统信息
    echo "主机名: $(hostname)"
    echo "操作系统: $(uname -o)"
    echo "内核版本: $(uname -r)"
    echo "操作系统版本: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    echo "系统语言: $LANG"
    echo "系统当前时间: $(date)"
    echo "系统最后重启时间: $(who -b | awk '{print $3,$4}')"
    echo "系统运行时间: $(uptime -p)"
    echo "系统登录用户: $(awk -F: '{if ($NF=="/bin/bash") print $0}' /etc/passwd)"
}

function cpu_info() {
    # 获取 CPU 信息
    echo -e "\n-------------------- CPU 信息 --------------------"
    echo "CPU 型号: $(lscpu | grep 'Model name' | awk -F ':' '{print $2}' | sed 's/^ *//g' | tr -s ' ')"
    echo "CPU 核心数: $(nproc)"
    echo "架构: $(uname -m)"
}

function mem_info() {
    # 获取内存信息
    echo -e "\n-------------------- 内存信息 --------------------"
    echo "总内存: $(free -h | awk '/^Mem:/{print $2}')"
    echo "已用内存: $(free -h | awk '/^Mem:/{print $3}')"
}

function disk_info() {
    # 获取磁盘信息
    echo -e "\n-------------------- 磁盘信息 --------------------"
    df -h --output=source,size,used,avail,pcent,target | grep -v "loop"
}

function net_info() {
    echo -e "\n-------------------- 网络信息 --------------------"
    # 检测防火墙状态 (以 ufw 为例)
    if command -v ufw &>/dev/null; then
        echo "防火墙状态: $(ufw status | head -n 1)"
    else
        echo "防火墙: 未安装 ufw"
    fi
    echo "系统公网地址: $(curl ifconfig.me -s)"
    echo "系统私网地址: $(ip a show dev eth0 | grep -w inet | awk '{print $2}' | awk -F '/' '{print $1}')"
    echo "网关地址: $(ip route | grep default | awk '{print $3}')"
    echo "MAC地址: $(ip link | egrep -v "lo" | grep link | awk '{print $2}')"
    echo "路由信息: $(egrep -v "^$|^#" /etc/resolv.conf)"
    echo "DNS 信息: $(route -n)"

}

function process_top_info() {
    echo -e "\n-------------------- 进程占用TOP10 --------------------"
    ps -eo pid,user,%cpu,%mem,command --sort=-%cpu | head -n 10
}

function service_info() {
    echo -e "\n-------------------- 启动服务 --------------------"
    echo "监听端口: $(netstat -lntup | grep -v "Active Internet")"
    echo "内核参考配置: $(sysctl -p 2>/dev/null)"
}


function main() {
    systatus_info
    cpu_info
    mem_info
    disk_info
    net_info
    process_top_info
    service_info
}

main
