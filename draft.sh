#!/bin/bash

####
# 草稿 
####


####
# 优化 IP6 
####
# 查看 IP6 是否被启动
lsmod | grep ipv6

# 停止 IP6
echo "install ipv6 /bin/true" 
    > /etc/modprobe.d/disable-ipv6.conf #使用 /bin/true 代替 ipv6 模块的加载
echo "IPV6INIT=no" 
    >> /etc/sysconfig/network-scripts/ifcfg-eth0 #禁用基于 IP6 的网络

####
# 【ch01】 优化文件打开数 
####
# 【/etc/security/limit.conf】 系统安全限制配置
* soft nofile 65535 #所有用户软打开文件上限
* hard nofile 65535 #所有用户硬打开文件上限
# 【/etc/rc.local】 运行时本地配置文件
ulimit -SHn 65535 #使得生效

####
# 查看系统最大文件打开数 
####
#!/bin/bash
for pid in `ps aux | grep nginx | grep  -v grep | awk '{print $2}'` #遍历每个ngix进程
do
    cat /proc/${pid}/limits | grep 'Max open files'   #查看进程的最大打开限制
done 

