# mysql5.6_install
mysql5.6.16 install

1.配置文件为:my.cnf
2.通过更改mysql_install_path.txt文件中的路径指定mysql安装的目录路径
3.mysql 初始化root密码为new-password
4.mysql登陆 mysql -uroot -hlocalhost -pnew-password     登陆后自行修改密码
5.mysql管理脚本/etc/init.d/mysqld  start|stop|restart|reload|status
6.一键安装脚本chmod +x mysql_install.sh && ./mysql_install.sh
7.若需要更改安装mysql的版本,修改mysql_install.sh脚本中verison="5.6.16" 为verison="5.需要安装的版本号"

mysql管理
mysql启动: /etc/init.d/mysqld start 
mysql关闭: /etc/init.d/mysqld stop 
mysql重启: /etc/init.d/mysqld restart 
mysql运行状态: /etc/init.d/mysqld status 
