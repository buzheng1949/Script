#! /bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
usage () {
	cat $DIR/sshelp
}

wrong_para_prompt() {
    echo "参数输入错误!$1"
}

install() {
	if [[ "$#" -lt 1 ]]
        then
          wrong_para_prompt "请输入至少一个参数作为密码"
	  return 1
	fi
        port="1024"
        if [[ "$#" -ge 2 ]]
        then
          port=$2
        fi
        if [[ $port -le 0 || $port -gt 65535 ]]
        then
          wrong_para_prompt "端口号输入格式错误，请输入1到65535"
          exit 1
        fi
	echo "{
    \"server\":\"0.0.0.0\",
    \"server_port\":$port,
    \"local_address\": \"127.0.0.1\",
    \"local_port\":1080,
    \"password\":\"$1\",
    \"timeout\":300,
    \"method\":\"aes-256-cfb\"
}" > /etc/shadowsocks.json
	apt-get update
	apt-get install -y python-pip
	pip install --upgrade pip
	pip install setuptools
	pip install shadowsocks
	chmod 755 /etc/shadowsocks.json
	apt-get install python-m2crypto
	ps -fe|grep ssserver |grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
          ssserver -c /etc/shadowsocks.json -d start
        else
          ssserver -c /etc/shadowsocks.json -d restart
        fi
	rclocal=`cat /etc/rc.local`
        if [[ $rclocal != *'ssserver -c /etc/shadowsocks.json -d start'* ]]
        then
          sed -i '$i\ssserver -c /etc/shadowsocks.json -d start'  /etc/rc.local
        fi
	echo "install shadowshocks sucess,please enjoy it"
	cat /etc/shadowsocks.json
}


install_ssr() {
	wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh
	chmod +x shadowsocksR.sh
	./shadowsocksR.sh 2>&1 | tee shadowsocksR.log
}

uninstall_ss() {
	ps -fe|grep ssserver |grep -v grep > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
          ssserver -c /etc/shadowsocks.json -d stop
        fi
	pip uninstall -y shadowsocks
	rm /etc/shadowsocks.json
	rm /var/log/shadowsocks.log
	echo 'shadowsocks卸载成功'
}

if [ "$#" -eq 0 ]; then
	usage
	exit 0
fi

case $1 in
	-h|h|help )
		usage
		exit 0;
		;;
	-v|v|version )
		echo 'ss-fly Version 1.0, 2018-01-20, Copyright (c) 2018 flyzy2005'
		exit 0;
		;;
esac

if [ "$EUID" -ne 0 ]; then
	echo '必需以root身份运行，请使用sudo命令'
	exit 1;
fi

case $1 in
	-i|i|install )
        install $2 $3
		;;
        -bbr )
        install_bbr
                ;;
        -ssr )
        install_ssr
                ;;
	-uninstall )
	uninstall_ss
		;;
	* )
		usage
		;;
esac
