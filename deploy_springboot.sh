echo "===========开始进入本地git项目============="
cd /developer/git-repository/Project


echo "==========git切换分之到项目需要发布的分支==============="
git checkout branch_need_publish

echo "==================git fetch======================"
git fetch

echo "==================git pull======================"
git pull


echo "===========编译并跳过单元测试===================="
mvn clean package -Dmaven.test.skip=true

echo "===========生成jar包============================="
mvn clean install

echo "===========进入jar包目录============================="
cd target

echo "===========后台运行工程============================="
nohup java -jar target-jar-name.jar &
