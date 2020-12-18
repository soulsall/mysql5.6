#! /bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/bin:/usr/sbin
installdir=$(cd `dirname $0`; pwd)
cd $installdir


function set_system()
{
  echo '设置环境变量'
}

function install_environment_package()
{
     date_cur=`date "+%Y%m%d_%H%M%S"`
     echo "${date_cur} 正在开始安装环境依赖包...." 
     yum -y install gcc gcc-devel gcc-c++ gcc-c++-devel autoconf* automake* zlib* libxml* ncurses-devel ncurses libgcrypt* libtool* cmake openssl openssl-devel bison bison-devel

}


function install_mysql()
{  verison="5.6.16" 
   mysql_package="mysql-$verison.tar.gz"
   download_url="http://dev.mysql.com/get/Downloads/MySQL-5.6/$mysql_package"
   cd ${installdir}
   if [ ! -f "$mysql_package" ];then
      echo "开始下载$mysql_package软件包"
      /usr/bin/wget $download_url
   fi
   echo "$mysql_package软件包已存在"
   groupadd mysql 
   useradd -g mysql -s /sbin/nologin mysql
   mysql_install_dir=$(cat mysql_install_path.txt|grep -v '#')
   echo "mysql安装路径为 $mysql_install_dir"
   mkdir -p $mysql_install_dir/{data,log,sockets}
   touch $mysql_install_dir/mysqld.err
   process_num=$(cat /proc/cpuinfo | grep -c "processo") #获取cpu线程数
   if [ ! -d "$installdir/mysql-$verison" ];then
      /usr/bin/tar -xvf $mysql_package
   fi
   cd mysql-$verison
   cmake  -DCMAKE_INSTALL_PREFIX=$mysql_install_dir -DMYSQL_DATADIR=$mysql_install_dir/data/ -DDEFAULT_CHARSET=utf8 -DMYSQL_USER=mysql -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_UNIX_ADDR=$mysql_install_dir/sockets/mysql.sock -DMYSQL_TCP_PORT=3306  -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1
   make -j${process_num} && make install
   yes| cp $mysql_install_dir/support-files/mysql.server /etc/init.d/mysqld
   chmod +x /etc/init.d/mysqld
   sed -i "1,60s#basedir\=#basedir\=$mysql_install_dir#" /etc/init.d/mysqld
   sed -i "1,60s#datadir\=#datadir\=$mysql_install_dir/data#"  /etc/init.d/mysqld
   if [ -f "/etc/my.cnf" ];then    
      mv /etc/my.cnf /etc/my_back.cnf
   fi
   yes | cp -i $installdir/my.cnf /etc/
   sed -i -e "s#\/data\/software\/mysql#$mysql_install_dir#" /etc/my.cnf
   chown -R mysql:mysql $mysql_install_dir
   ln -s $mysql_install_dir/bin/mysql /usr/bin/mysql
   bash_mysql=`cat /etc/profile|grep mysql`
   echo $bash_mysql
   if [[ "$bash_mysql" != "" ]]
   then
      echo ''
   else
      echo "PATH=$mysql_install_dir/bin:$PATH" >>/etc/profile
      echo "export PATH" >>/etc/profile
      source /etc/profile
   fi   
   echo "数据库初始化......"
   $mysql_install_dir/scripts/mysql_install_db --user=mysql --basedir=$mysql_install_dir --datadir=$mysql_install_dir/data
   chown -R mysql:mysql $mysql_install_dir 
   
   mysql_status=`ps -aux|grep -vE 'grep|vim|tail|vi|sh|cat'|grep mysql|grep mysql.pid`
   if [[ "$mysql_status" != "" ]]
   then
      echo "mysql is running ......"
   else
      /etc/init.d/mysqld start
   
   fi
   
   mysql_status_check=`ps -aux|grep -vE 'grep|vim|tail|vi|.sh|cat'|grep mysql|grep mysql.pid` 
   if [[ "$mysql_status_check" != "" ]]
   then
      $mysql_install_dir/bin/mysqladmin -u root password 'new-password'
      echo "数据库安装完成,初始化的root密码为  new-password"
      echo "mysql登陆 mysql -uroot -hlocalhost -pnew-password     登陆后自行修改密码"
   else
      echo "mysql 启动失败,请排查原因......."
   fi
}

install_environment_package
install_mysql
