# 自动化从git拉取项目并编译发布脚本
echo "===========开始进入本地git项目============="
cd /buzheng/git-repository/yourproject


echo "==========git切换分之到项目需要发布的分支==============="
git checkout feature/test

echo "==================git fetch======================"
git fetch

echo "==================git pull======================"
git pull


echo "===========编译并跳过单元测试===================="
mvn clean package -Dmaven.test.skip=true


echo "============删除旧的ROOT.war==================="
rm /buzheng/apache-tomcat-7.0.73/webapps/ROOT.war


echo "======拷贝编译出来的war包到tomcat下-ROOT.war======="
cp /buzheng/git-repository/yourproject/target/yourproject.war  /buzheng/apache-tomcat-7.0.73/webapps/ROOT.war


echo "============删除tomcat下旧的ROOT文件夹============="
rm -rf /buzheng/apache-tomcat-7.0.73/webapps/ROOT



echo "====================关闭tomcat====================="
/buzheng/apache-tomcat-7.0.73/bin/shutdown.sh


echo "================Tomact休息一会  sleep 20s========================="
for i in {1..20}
do
	echo $i"s Tomact开始休息....."
	sleep 1s
done


echo "====================启动tomcat====================="
/buzheng/apache-tomcat-7.0.73/bin/startup.sh