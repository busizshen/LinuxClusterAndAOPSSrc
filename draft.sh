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


####
# 【ch01】 开启启动网卡 
####
# 【/etc/sysconfig/network-scripts/ifcfg-eth0】 网卡配置文件
DEVICE=eth0 #网卡名
TYPE=Ethernet  #以太网类型
ONBOOT=yes #【系统启动时候就启动网卡】
BOOTPROTO=static #静态ip
IPADDR=203.93.236.146 #ip地址
HWADDR=00:14:22:1b:71:20 #设备地址
NETMASK=255.255.255.192 #子网掩码
GATEWAY=203.93.236.129 #网关
PEERDNS=yes #允许 DHCP 的 DNS 覆盖本地的 DNS
IPV6INIT=no #禁用 IP6
IPV6_AUTOCONF=yes #自动配置 IP6
USERCTL=no #不允许普通用户修改网卡



####
# 【ch01】 禁止远程root 
####
sed -i 's@PermitRootLogin yes@PermitRootLogin no@' \
    /etc/ssh/sshd_config #禁止远程 root 登录

sed -i 's@PermitEmptyPasswords no@PermitEmptyPasswords no@' \
    /etc/ssh/sshd_config #禁止空密码登录

sed -i 's@UseDNS yes@UseDNS no@' \
    /etc/ssh/sshd_config #关闭 SSH  反向查询，加快 SSH 查询速度

####
# 【ch01】 增加 sudo 权限用户 
####
# 【/etc/sudoers】 sudo 用户注册文件
root ALL=(ALL) ALL #允许 root 用户在任何位置允许任何命令
admin ALL=(ALL) NOPASSWD:ALL #添加具有 root 权限的用户 admin，并且切换时候不需要密码

####
# 【ch01】 优化 TCP 套接字 
####
# 【Squid】 服务器优化方案
# 【/etc/sysctl.conf】
net.ipv4.tcp_fin_timeout=30 # FIN 信号超时时间
net.ipv4.tcp_keepalive_time =1200 # 连接超时时间
net.ipv4.tcp_syncookies =1 # 开启 SYN cookie 溢出cookie功能
net.ipv4.tcp_max_syn_backlog =8192 # 增大 SYN 等待队列
net.ipv4.tcp_tw_reuse =1 # 开启 TIME_WAIT 状态的套接字复用
net.ipv4.tcp_tw_recycle =1 # 开启 TIME_WAIT 状态的套接字快速回收
net.ipv4.tcp_max_tw_buckets =5000 #最大 TIME_WAIT 状态的套接字数量
net.ipv4.ip_local_port_range =10000 65000 #增大端口变动范围

#内核立马生效
/sbin/sysctl -p 

# 【Apache/Nginx】 web服务器
net.ipv4.tcp_syncookies =1 # 开启 SYN cookie 溢出cookie功能
net.ipv4.tcp_tw_reuse =1 # 开启 TIME_WAIT 状态的套接字复用
net.ipv4.tcp_tw_recycle =1 # 开启 TIME_WAIT 状态的套接字快速回收
net.ipv4.ip_local_port_range =10000 65000 #增大端口变动范围

# Postfix 邮件服务器
net.ipv4.tcp_fin_timeout=30 # FIN 信号超时时间
net.ipv4.tcp_keepalive_time =1200 # 连接超时时间
net.ipv4.tcp_tw_reuse =1 # 开启 TIME_WAIT 状态的套接字复用
net.ipv4.tcp_tw_recycle =1 # 开启 TIME_WAIT 状态的套接字快速回收
net.ipv4.ip_local_port_range =10000 65000 #增大端口变动范围
kernel.shmmax=134217728 #单个共享内存大小



####
#  【ch01】 CentOS 6.4 x86_64系统最小化优化脚本
####
####
#		【优化yum】  
####
#【替换网易源】
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo.bak
mv CentOS6-Base-163.repo CentOS-Base.repo
yum clean all #清除yum缓存
yum makecache #重建缓存
yum update  #升级Linux系统
#【添加epel外部yum扩展源】
cd /usr/local/src
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

####
#		【开发环境】 
####
#安装gcc基础库文件及sysstat工具
yum -y install gcc gcc-c++  \ #gcc工具
vim-enhanced \ #vim高级版
unzip unrar \   #压缩工具
sysstat #系统监控

####
#		【ntp时间校准】 
####
#配置ntpdate自动对时
yum -y install ntp
echo "01 01 * * * /usr/sbin/ntpdate ntp.api.bz    >> /dev/null 2>&1" >> /etc/crontab
ntpdate ntp.api.bz
service crond restart

####
#		【增加文件打开数】 
####
#配置文件的ulimit值
ulimit -SHn 65534
echo "ulimit -SHn 65534" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*                     soft     nofile             65534
*                     hard     nofile             65534
EOF

####
#		【基础系统内核优化】 
####
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65535
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_max_orphans = 16384
net.ipv4.route.gc_timeout = 100
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
EOF

/sbin/sysctl -p

####
#		【禁用control-alt-delete组合键】 
####
#禁用control-alt-delete组合键以防止误操作
sed -i 
    's@ca::ctrlaltdel:/sbin/shutdown -t3 -r now@#ca::ctrlaltdel:/sbin/shutdown     -t3 -r now@' \
    /etc/inittab


#【关闭SELinux】
sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config

#【关闭iptables】
service iptables stop
chkconfig iptables off

####
#		【ssh优化】 
####
#ssh服务配置优化,请保持机器中至少存在一个具有sudo权限的用户，下面的配置会禁止root远程登录
sed -i 's@#PermitRootLogin yes@PermitRootLogin no@' /etc/ssh/sshd_config
#禁止空密码登录
sed -i 's@#PermitEmptyPasswords no@PermitEmptyPasswords no@' /etc/ssh/sshd_config
#禁止SSH反向解析
sed -i 's@#UseDNS yes@UseDNS no@' /etc/ssh/sshd_config /etc/ssh/sshd_config

service sshd restart

####
#		【ipv6优化】 
####
#禁用IPv6地址
echo "install ipv6 /bin/true" > /etc/modprobe.d/disable-ipv6.conf
#每当系统需要加载IPv6模块时，强制执行/bin/true来代替实际加载的模块
echo "IPV6INIT=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
#禁用基于IPv6网络，使之不会被触发启动
chkconfig ip6tables off

####
#		【vim基础语法优化】 
####
cat >> /root/.vimrc << EOF
set number
set ruler
set nohlsearch
set shiftwidth=2
set tabstop=4
set expandtab
set cindent
set autoindent
set mouse=v
syntax on
EOF

####
#		【精简服务】 
####
#精简开机自启动服务，安装最小化服务的机器初始可以只保留crond|network|rsyslog|sshd这4个服务
for i in `chkconfig --list|grep 3:on|awk '{print $1}'`;do chkconfig --level 3 $i off;done
for CURSRV  in crond rsyslog sshd network;do chkconfig --level 3 $CURSRV on;done
#重启服务器

reboot
