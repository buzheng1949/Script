#! /bin/bash
# NowYouSeeMe
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
usage () {
	cat $DIR/sshelp
}

wrong_params() {
    echo "参数输入错误!$1"
}

install() {
	if [[ "$#" -lt 1 ]]
        then
          wrong_params "请输入密码"
	  return 1
	fi
        port="9999"
        if [[ "$#" -ge 2 ]]
        then
          port=$2
        fi
        if [[ $port -le 0 || $port -gt 65535 ]]
        then
          wrong_params "端口号输入格式错误"
          exit 1
        fi
	echo "{
    \"password\":\"$1\",
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
	echo 'shadowsocks-server已经卸载成功'
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
		echo 'successful'
		exit 0;
		;;
esac

if [ "$EUID" -ne 0 ]; then
	echo '请使用sudo命令'
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
