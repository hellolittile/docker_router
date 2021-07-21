# docker_router
## ubuntu中使用docker作为软路由服务 
* 容器基于alpine:3.14支持IPV6编译好的镜像78MB
* wan 使用dhcp方式获取地址
* 使用dnsmasq作为dhcp和dns服务
* 使用radvd广播ipv6地址
* lan使用ipv6私有地址通过nat6转发到wan
* 如果主机无线网卡支持AP可以配置hostapd做wifi

测试的宿主机是ubuntu18.04
1. 第一张enp开头网卡将被用作wan. 其余网卡桥接到lan .可以通过init修改
2. lan默认网络192.168.100.1/24,fd00::/64可以通过Dockerfile修改

需要注意的是:
* 需要docker容器来管理宿主机网络,所以会对宿主机网络产生影响.

使用方法:
安装docker[参见docker官方文档](https://docs.docker.com/engine/install/ubuntu/) 
安装docker-compose
`sudo apt install docker-compose`
启动:
`sudo docker-compose up -d`
停止:
`sudo docker-compose down`
