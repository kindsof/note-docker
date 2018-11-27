dsfa

华为阿里的
docker stack deploy -c docker-compose.yml hwtest

######################################## selinux

vi /etc/selinux/config


#SELINUX=enforcing #注释掉
 
#SELINUXTYPE=targeted #注释掉
 
SELINUX=disabled #增加
 
:wq! #保存退出
 
setenforce 0 #使配置立即生效


##############################ce版本

wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo && yum install -y docker-ce && systemctl enable docker.service && service docker start



########命令

sysetmctl show docker
docker info
docker network 



####################配置加速
首先配置加速
docker 无法访问hub时候：
systemctl stop docker
 
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://df1e2ed4.m.daocloud.io
systemctl start docker


 使用阿里云我的加速

aliyun d 

您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器：

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://71d9whb7.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker


22222
当你下载安装的Docker Version不低于1.10时，建议直接通过daemon config进行配置。
使用配置文件 /etc/docker/daemon.json（没有时新建该文件）

{
    "registry-mirrors": ["<your accelerate address>"]
}

重启Docker Daemon就可以了。

without sudo 

sudo usermod -aG docker ub

systemctl restart docker



其他用户加入docker组



sudo usermod -G docker jenkins
visudo, add bellow 
jenkins ALL=(ALL:ALL) NOPASSWD: ALL


#install docker-ce

##ubuntu https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
脚本安装：
$ curl -fsSL get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh



download a package to install  is another choice


###########所有的文档，通过docker访问：以后速度会比较快。 docker文档
docker run -ti -p 4000:4000 docs/docker.github.io:latest 


##################源安装
sudo apt-get remove docker docker-engine docker.io

sudo apt-get install     apt-transport-https     ca-certificates     curl     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -s
sudo apt-key fingerprint 0EBFCD88

     sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


docker user as a not root 

sudo usermod -aG docker joe

restart docker

###for linuxmint use a diff

     sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  xenial\
   stable"
 ###########################################
   
    sudo apt-get update
    sudo apt-get install docker-ce


######################

docker inspect -f '{{.HostConfig.NetworkMode}}' d22

root@dev:~#  docker inspect -f '{{.HostConfig.LogConfig.Type}}' 20d
json-file
#####################

  vi  Dockerfile

"
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
"

  vi requirements.txt


"
Flask
Redis

"
  vim app.py

"
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)


"

vi docker-compose.yml

"
version: "3"
services:
  web:
    # replace username/repo:tag with your name and image details
    image: kinds/hellocount:new
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
    networks:
      - webnet
networks:
  webnet:


"

#after three file create 

sudo docker build -t hellocount .

    sudo docker images

    sudo docker run -p 4000:80 hellocount


#login and upload images

sudo docker login

sudo docker tag hellocount kinds/hellocount:new

    sudo docker images
   
    sudo docker push kinds/hellocount:new


##install compose 
    sudo curl -L https://github.com/docker/compose/releases/download/1.17.0-rc1/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
    sudo cp /tmp/docker-compose /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose


new：

curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


#swarm init and deploy

sudo docker swarm init
 sudo docker stack deploy -c docker-compose.yml mycountlab
 sudo docker container ls

 sudo docker service ls

sudo docker stack rm mycountlab

sudo docker service ls
sudo docker container ls
sudo docker swarm leave --force



加入一个worker

[root@k3 ~]# docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-5hl3j9wszrigytlrwecprydbom2ll55zs52s4d8j0ynapx7eby-a8vz1ctffp67rjwm5cvohsbql \
    192.168.31.103:2377

[root@k3 ~]# 
[root@k1 ~]#     docker swarm join \
>     --token SWMTKN-1-5hl3j9wszrigytlrwecprydbom2ll55zs52s4d8j0ynapx7eby-a8vz1ctffp67rjwm5cvohsbql \
>     192.168.31.103:2377
This node joined a swarm as a worker.
[root@k1 ~]# 
[root@k1 ~]# 
加入一个manager

[root@k3 ~]# docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-5hl3j9wszrigytlrwecprydbom2ll55zs52s4d8j0ynapx7eby-2umihzljjkjuest80pmrn3ezo \
    192.168.31.103:2377

[root@k3 ~]# 
[root@k2 ~]#     docker swarm join \
>     --token SWMTKN-1-5hl3j9wszrigytlrwecprydbom2ll55zs52s4d8j0ynapx7eby-2umihzljjkjuest80pmrn3ezo \
>     192.168.31.103:2377
This node joined a swarm as a manager.
[root@k2 ~]# docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
6d5ah6pr2undubgo2r73vzacn *  k2        Ready   Active        Reachable
ocm5s979zzcwbrdcb1gvblclz    k2        Down    Active        
qp8cuulad0kk8y4cbgiih7cjp    k3        Ready   Active        Leader

[root@k2 ~]# docker node rm ocm5s979zzcwbrdcb1gvblclz
ocm5s979zzcwbrdcb1gvblclz
[root@k2 ~]# docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
6d5ah6pr2undubgo2r73vzacn *  k2        Ready   Active        Reachable
qp8cuulad0kk8y4cbgiih7cjp    k3        Ready   Active        Leader
[root@k2 ~]# 


###############这个阶段出现的问题 ，问题出在compose文件中的卷挂载。

invalid mount config for type

[root@hb-2-dev da]# docker stack services hwtest
ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
53awd2rw0ycv        hwtest_web          replicated          3/3                 kinds/hellocount:new              *:80->80/tcp
d59kiil1j152        hwtest_redis        replicated          0/1                 redis:latest                      *:6379->6379/tcp
u3a28cnqwi0e        hwtest_visualizer   replicated          1/1                 dockersamples/visualizer:stable   *:8080->8080/tcp
redis 没有起来，查看情况

[root@hb-2-dev da]# docker stack ps hwtest
ID                  NAME                  IMAGE                             NODE                 DESIRED STATE       CURRENT STATE                ERROR                              PORTS
74tgpeu36j5w        hwtest_redis.1        redis:latest                      hb-2-dev.novalocal   Ready               Rejected 3 seconds ago       "invalid mount config for type…"   
qimiip0ce3i7         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 8 seconds ago       "invalid mount config for type…"   
zfaz74iups5l         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 28 seconds ago      "invalid mount config for type…"   
tirlavnozpqq         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 43 seconds ago      "invalid mount config for type…"   
x3nn3t0cw4w1         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 53 seconds ago      "invalid mount config for type…"   
prz5ge27i1po        hwtest_visualizer.1   dockersamples/visualizer:stable   hb-2-dev.novalocal   Running             Running about a minute ago                                      
np7l73k25cqb        hwtest_web.1          kinds/hellocount:new              hb-2-dev.novalocal   Running             Running about a minute ago                                      
uofj6qrtw4mj        hwtest_web.2          kinds/hellocount:new              hb-2-dev.novalocal   Running             Running about a minute ago                                      
ug6kl7imot3p        hwtest_web.3          kinds/hellocount:new              hb-2-dev.novalocal   Running             Running about a minute ago                                      
[root@hb-2-dev da]# ^C


错误信息显示的不全  "invalid mount config for type…" 
[root@hb-2-dev da]# docker stack ps --help

Usage:  docker stack ps [OPTIONS] STACK

List the tasks in the stack

Options:
  -f, --filter filter   Filter output based on conditions provided
      --format string   Pretty-print tasks using a Go template
      --no-resolve      Do not map IDs to Names
      --no-trunc        Do not truncate output
  -q, --quiet           Only display task IDs
使用  --no-trunc 显示全部信息
[root@hb-2-dev da]# docker stack ps hwtest --no-trunc
ID                          NAME                  IMAGE                                                                                                     NODE                 DESIRED STATE       CURRENT STATE                 ERROR                                                                     PORTS
m9n3kfw7zzbatkykqmflovxpg   hwtest_redis.1        redis:latest@sha256:26c93c5b06eaa323bb1089500f42b0dd158138772348b865e364127f1d554982                      hb-2-dev.novalocal   Ready               Rejected 1 second ago         "invalid mount config for type "bind": bind source path does not exist"   
zilao8nh8pc29q91zvn6k6gd3    \_ hwtest_redis.1    redis:latest@sha256:26c93c5b06eaa323bb1089500f42b0dd158138772348b865e364127f1d554982                      hb-2-dev.novalocal   Shutdown            Rejected about a minute ago   "invalid mount config for type "bind": bind source path does not exist"   
zlnifqn3n7iz502z4uhy0ikkt    \_ hwtest_redis.1    redis:latest@sha256:26c93c5b06eaa323bb1089500f42b0dd158138772348b865e364127f1d554982                      hb-2-dev.novalocal   Shutdown            Rejected 2 minutes ago        "invalid mount config for type "bind": bind source path does not exist"   
zpvm5nkiddha22jkhfyees80e    \_ hwtest_redis.1    redis:latest@sha256:26c93c5b06eaa323bb1089500f42b0dd158138772348b865e364127f1d554982                      hb-2-dev.novalocal   Shutdown            Rejected 2 minutes ago        "invalid mount config for type "bind": bind source path does not exist"   
zfaz74iups5ltz8tqnsgk1f0v    \_ hwtest_redis.1    redis:latest@sha256:26c93c5b06eaa323bb1089500f42b0dd158138772348b865e364127f1d554982                      hb-2-dev.novalocal   Shutdown            Rejected 5 minutes ago        "invalid mount config for type "bind": bind source path does not exist"   
prz5ge27i1poqn2usa5lb1x2c   hwtest_visualizer.1   dockersamples/visualizer:stable@sha256:bc680132f772cb44062795c514570db2f0b6f91063bc3afa2386edaaa0ef0b20   hb-2-dev.novalocal   Running             Running 5 minutes ago                                                                                   
np7l73k25cqb8cf3r6z0c8win   hwtest_web.1          kinds/hellocount:new@sha256:b7af6143ff504efd5609ebf093981d766be8edaf328546b57c10dfca1d2f2221              hb-2-dev.novalocal   Running             Running 5 minutes ago                                                                                   
uofj6qrtw4mjwjo0ddo1w4eu9   hwtest_web.2          kinds/hellocount:new@sha256:b7af6143ff504efd5609ebf093981d766be8edaf328546b57c10dfca1d2f2221              hb-2-dev.novalocal   Running             Running 5 minutes ago                                                                                   
ug6kl7imot3pxlyrriqwdqdh6   hwtest_web.3          kinds/hellocount:new@sha256:b7af6143ff504efd5609ebf093981d766be8edaf328546b57c10dfca1d2f2221              hb-2-dev.novalocal   Running             Running 5 minutes ago                                                                                   
[root@hb-2-dev da]# 


需要查看docker-compose.yml
[root@hb-2-dev da]# more docker-compose.yml 
version: "3"
services:
  web:
    # replace username/repo:tag with your name and image details
    image: kinds/hellocount:new
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
    ports:
      - "80:80"
    networks:
      - webnet
  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]
    networks:
      - webnet
  redis:
    image: redis
    ports:
      - "6379:6379"
    volumes:
      - /home/docker/data:/data
    deploy:
      placement:
        constraints: [node.role == manager]
    command: redis-server --appendonly yes
    networks:
      - webnet
networks:
  webnet:

[root@hb-2-dev da]# 
redis 里面volumes： /home/docker/data  主机里没有这个目录  需要建立一个目录 或者修改docker-compose文件
修改docker-compose文件，指向本地一个新建的目录
 volumes:
      - /root/da/data:/data
然后更新这个服务
[root@hb-2-dev ~]# docker stack deploy --help

Usage:  docker stack deploy [OPTIONS] STACK

Deploy a new stack or update an existing stack

Aliases:
  deploy, up

Options:
  -c, --compose-file string    Path to a Compose file
      --prune                  Prune services that are no longer referenced
      --resolve-image string   Query the registry to resolve image digest and supported platforms ("always"|"changed"|"never") (default "always")
      --with-registry-auth     Send registry authentication details to Swarm agents
[root@hb-2-dev ~]# 
更新
[root@hb-2-dev da]# docker stack up
"docker stack deploy" requires exactly 1 argument.
See 'docker stack deploy --help'.

Usage:  docker stack deploy [OPTIONS] STACK [flags]

Deploy a new stack or update an existing stack
[root@hb-2-dev da]# docker stack up hwtest
Please specify either a bundle file (with --bundle-file) or a Compose file (with --compose-file).

[root@hb-2-dev da]# docker stack up -c docker-compose.yml hwtest
Updating service hwtest_visualizer (id: u3a28cnqwi0ez70bqmfywkor7)
Updating service hwtest_redis (id: d59kiil1j152vhgl3crow9scj)
Updating service hwtest_web (id: 53awd2rw0ycvvbjvtw52cw5v5)
[root@hb-2-dev da]# 

查看服务状态，Redis已经起来了

[root@hb-2-dev ~]# docker stack services hwtest
ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
53awd2rw0ycv        hwtest_web          replicated          3/3                 kinds/hellocount:new              *:80->80/tcp
d59kiil1j152        hwtest_redis        replicated          1/1                 redis:latest                      *:6379->6379/tcp
u3a28cnqwi0e        hwtest_visualizer   replicated          1/1                 dockersamples/visualizer:stable   *:8080->8080/tcp


[root@hb-2-dev ~]# docker ps
CONTAINER ID        IMAGE                             COMMAND                  CREATED             STATUS              PORTS               NAMES
742390a44a5c        redis:latest                      "docker-entrypoint.s…"   6 minutes ago       Up 6 minutes        6379/tcp            hwtest_redis.1.g4h5m18c5m7135o8x1t82iwbd
2c0750761e0f        dockersamples/visualizer:stable   "npm start"              28 minutes ago      Up 28 minutes       8080/tcp            hwtest_visualizer.1.prz5ge27i1poqn2usa5lb1x2c
dafd3a1a3964        kinds/hellocount:new              "python app.py"          29 minutes ago      Up 29 minutes       80/tcp              hwtest_web.2.uofj6qrtw4mjwjo0ddo1w4eu9
303ff8e7f2ec        kinds/hellocount:new              "python app.py"          29 minutes ago      Up 29 minutes       80/tcp              hwtest_web.3.ug6kl7imot3pxlyrriqwdqdh6
e08979b466d5        kinds/hellocount:new              "python app.py"          29 minutes ago      Up 29 minutes       80/tcp              hwtest_web.1.np7l73k25cqb8cf3r6z0c8win
[root@hb-2-dev ~]# 
查看Redis  log
[root@hb-2-dev ~]# docker logs 742
1:C 20 Mar 07:22:54.750 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 20 Mar 07:22:54.751 # Redis version=4.0.8, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 20 Mar 07:22:54.751 # Configuration loaded
1:M 20 Mar 07:22:54.753 * Running mode=standalone, port=6379.
1:M 20 Mar 07:22:54.753 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 20 Mar 07:22:54.753 # Server initialized
1:M 20 Mar 07:22:54.753 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 20 Mar 07:22:54.753 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:M 20 Mar 07:22:54.753 * Ready to accept connections
[root@hb-2-dev ~]# 


[root@hb-2-dev ~]# docker stack ps hwtest
ID                  NAME                  IMAGE                             NODE                 DESIRED STATE       CURRENT STATE             ERROR                              PORTS
g4h5m18c5m71        hwtest_redis.1        redis:latest                      hb-2-dev.novalocal   Running             Running 6 minutes ago                                        
zmsnjus37a26         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 9 minutes ago    "invalid mount config for type…"   
zilao8nh8pc2         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 23 minutes ago   "invalid mount config for type…"   
zlnifqn3n7iz         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 24 minutes ago   "invalid mount config for type…"   
zpvm5nkiddha         \_ hwtest_redis.1    redis:latest                      hb-2-dev.novalocal   Shutdown            Rejected 25 minutes ago   "invalid mount config for type…"   
prz5ge27i1po        hwtest_visualizer.1   dockersamples/visualizer:stable   hb-2-dev.novalocal   Running             Running 28 minutes ago                                       
np7l73k25cqb        hwtest_web.1          kinds/hellocount:new              hb-2-dev.novalocal   Running             Running 28 minutes ago                                       
uofj6qrtw4mj        hwtest_web.2          kinds/hellocount:new              hb-2-dev.novalocal   Running             Running 28 minutes ago                                       
ug6kl7imot3p        hwtest_web.3          kinds/hellocount:new              hb-2-dev.novalocal   Running             Running 28 minutes ago   



##############install docker machine   
"What is Docker Machine?

Docker Machine is a tool that lets you install Docker Engine on virtual hosts, 
and manage the hosts with docker-machine commands. You can use Machine to create Docker hosts
 on your local Mac or Windows box, on your company network, in your data center, 
 or on cloud providers like Azure, AWS, or Digital Ocean.

Using docker-machine commands, you can start, inspect, stop, and restart a managed host, 
upgrade the Docker client and daemon, and configure a Docker client to talk to your host."

base=https://github.com/docker/machine/releases/download/v0.14.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo install /tmp/docker-machine /usr/local/bin/docker-machine

  
#download boot2docker.iso cp it to the foder 
sudo mv boot2docker.iso /home/joe/.docker/machine/cache/
version is  important
https://github.com/boot2docker/boot2docker/releases
https://github.com/boot2docker/boot2docker/releases/download/v18.05.0-ce/boot2docker.iso
sudo docker-machine create --driver virtualbox myvm1
 # docker-machine create --driver virtualbox vm1
Running pre-create checks...
Creating machine...
(vm1) Copying /root/.docker/machine/cache/boot2docker.iso to /root/.docker/machine/machines/vm1/boot2docker.iso...
(vm1) Creating VirtualBox VM...
(vm1) Creating SSH key...
(vm1) Starting the VM...
(vm1) Check network to re-create if needed...
(vm1) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env vm1
 # 


sudo docker-machine ls
sudo docker-machine  ip  myvm1

 sudo docker-machine ssh myvm1 "docker swarm init --advertise-addr 192.168.99.100"
 sudo docker-machine ssh myvm2 "docker swarm join --token SWMTKN-1-2l6dc0la721ympzfkq5lzq5dk4dyqmdvvsybomeych2x09uhr6-4e9xxponme15v4jcsjlrjqcd0 192.168.
99.100:2377"

   sudo docker-machine ssh myvm1 "docker swarm join-token manager"
   sudo docker-machine ssh myvm1 "docker swarm join-token worker"

   sudo docker-machine ssh myvm1 "docker node ls"

从旧版本导入 来管理老的虚拟机
Migrate from Boot2Docker to Machine
Estimated reading time: 1 minute

If you were using Boot2Docker previously, you have a pre-existing Docker boot2docker-vm VM on your local system. To allow Docker Machine to manage this older VM, you must migrate it.

    Open a terminal or the Docker CLI on your system.

    Type the following command.

    $ docker-machine create -d virtualbox --virtualbox-import-boot2docker-vm boot2docker-vm docker-vm

    Use the docker-machine command to interact with the migrated VM.



docker machine 创建swarm集群
This first step creates three machines, and names the machines manager1, manager2, and manager3

#!/bin/bash

# Swarm mode using Docker Machine

#This configures the number of workers and managers in the swarm
managers=3
workers=3

# This creates the manager machines
echo "======> Creating $managers manager machines ...";
for node in $(seq 1 $managers);
do
  echo "======> Creating manager$node machine ...";
  docker-machine create -d virtualbox manager$node;
done

This second step creates three more machines, and names them worker1, worker2, and worker3

# This create worker machines
echo "======> Creating $workers worker machines ...";
for node in $(seq 1 $workers);
do
  echo "======> Creating worker$node machine ...";
  docker-machine create -d virtualbox worker$node;
done

# This lists all machines created
docker-machine ls


Next you create a swarm by initializing it on the first manager. 
You do this by using docker-machine ssh to run docker swarm init

# initialize swarm mode and create a manager
echo "======> Initializing first swarm manager ..."
docker-machine ssh manager1 "docker swarm init --listen-addr $(docker-machine ip manager1) --advertise-addr $(docker-machine ip manager1)"

Next you get join tokens for managers and workers.

# get manager and worker tokens
export manager_token=`docker-machine ssh manager1 "docker swarm join-token manager -q"`
export worker_token=`docker-machine ssh manager1 "docker swarm join-token worker -q"`

Then join the other masters to the Swarm

for node in $(seq 2 $managers);
do
  echo "======> manager$node joining swarm as manager ..."
  docker-machine ssh manager$node \
    "docker swarm join \
    --token $manager_token \
    --listen-addr $(docker-machine ip manager$node) \
    --advertise-addr $(docker-machine ip manager$node) \
    $(docker-machine ip manager1)"
done

Finally, add the worker machines and join them to the swarm.

# workers join swarm
for node in $(seq 1 $workers);
do
  echo "======> worker$node joining swarm as worker ..."
  docker-machine ssh worker$node \
  "docker swarm join \
  --token $worker_token \
  --listen-addr $(docker-machine ip worker$node) \
  --advertise-addr $(docker-machine ip worker$node) \
  $(docker-machine ip manager1):2377"
done

# show members of swarm
docker-machine ssh manager1 "docker node ls"

That last line will show you a list of all the nodes, something like this:

ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
3cq6idpysa53n6a21nqe0924h    manager3  Ready   Active        Reachable
64swze471iu5silg83ls0bdip *  manager1  Ready   Active        Leader
7eljvvg0icxlw20od5f51oq8t    manager2  Ready   Active        Reachable
8awcmkj3sd9nv1pi77i6mdb1i    worker1   Ready   Active        
avu80ol573rzepx8ov80ygzxz    worker2   Ready   Active        
bxn1iivy8w7faeugpep76w50j    worker3   Ready   Active        

You can also find all your machines by running

$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER      ERRORS
manager1   -        virtualbox   Running   tcp://192.168.99.100:2376           v17.03.0-ce   
manager2   -        virtualbox   Running   tcp://192.168.99.101:2376           v17.03.0-ce 
manager3   -        virtualbox   Running   tcp://192.168.99.102:2376           v17.03.0-ce
worker1    -        virtualbox   Running   tcp://192.168.99.103:2376           v17.03.0-ce
worker2    -        virtualbox   Running   tcp://192.168.99.104:2376           v17.03.0-ce
worker3    -        virtualbox   Running   tcp://192.168.99.105:2376           v17.03.0-ce

The next step is to create a service and list out the services. This creates a single service called web that runs the latest nginx:

$ docker-machine ssh manager1 "docker service create -p 80:80 --name web nginx:latest"
$ docker-machine ssh manager1 "docker service ls"
ID            NAME  REPLICAS  IMAGE         COMMAND
2x4jsk6313az  web   1/1       nginx:latest  



############a case 
joe-T da #
 docker-machine ssh vm1 "docker node ls "
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
p8f3lzbb5ps38t0mtbc4ffn5o *   vm1                 Ready               Active              Leader
m0c3bccaza06isapeqwfu5mii     vm2                 Ready               Active              
joe-T da #
 docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
vm1    -        virtualbox   Running   tcp://192.168.99.100:2376           v17.10.0-ce   
vm2    -        virtualbox   Running   tcp://192.168.99.101:2376           v17.10.0-ce   
joe-T da # 



##Run the given command to configure your shell to talk to myvm1.
the better way to deploy a app 

"docker-machine env <machine>:
This method works better for the next step because it allows you to 
use your local docker-compose.yml file to deploy the app “remotely” without 
having to copy it anywhere."

sudo docker-machine env myvm1                                                                                                      [140/1943]
"
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/home/joe/.docker/machine/machines/myvm1"
export DOCKER_MACHINE_NAME="myvm1"
# Run this command to configure your shell: 
# eval $(docker-machine env myvm1)

"
   eval $(docker-machine env myvm1)
  note!! add sudo here
##
 #    Run docker-machine env myvm1 to get the command to configure your shell to talk to myvm1.
##out the enveriement

docker-machine env -u
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME
# Run this command to configure your shell: 
# eval $(docker-machine env -u)


unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME

##release the env

eval $(docker-machine env vm1)
##go into vm1
docker ps
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS               NAMES
3bdb1d0501aa        kinds/hellocount:new   "python app.py"     38 minutes ago      Up 36 minutes       80/tcp              hellosw_web.3.25msz1or4tkepws9k9tkpxtsz

##you can see the docker ps  if not in the vm1  you can see none

"
Keep in mind that in order to use the ingress network in the swarm, you need to have the following ports open between the swarm nodes before you enable swarm mode:

    Port 7946 TCP/UDP for container network discovery.
    Port 4789 UDP for the container ingress network.

"

 docker stack deploy -c docker-compose.yml hellosw


docker stack rm getstartedlab

docker-machine ssh myvm2 "docker swarm leave"
"
Unsetting docker-machine shell variable settings

You can unset the docker-machine environment variables in your current shell with the following command:
"
eval $(docker-machine env -u)



#####stop

docker-machine ls

docker-machine stop vm1

docker-machine ls
"
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
vm1    -        virtualbox   Stopped                                       Unknown       
vm2    -        virtualbox   Running   tcp://192.168.99.101:2376           v17.10.0-
"
docker-machine ssh vm1 "docker node ls"
"
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
uipliob06xsdat3wy6q67ukob     joe-T               Ready               Active              
p8f3lzbb5ps38t0mtbc4ffn5o *   vm1                 Ready               Active              Leader
m0c3bccaza06isapeqwfu5mii     vm2                 Unknown             Active              
"

"
joe-T da # eval $(docker-machine env vm1)
joe-T da # docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
uipliob06xsdat3wy6q67ukob     joe-T               Ready               Active              
p8f3lzbb5ps38t0mtbc4ffn5o *   vm1                 Ready               Active              Leader
m0c3bccaza06isapeqwfu5mii     vm2                 Ready               Active              
joe-T da # docker node ps ui
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE       ERROR               PORTS
joe-T da # docker node ps m0
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE       ERROR               PORTS
joe-T da # docker stack deploy -c docker-compose.yml hellosw2
Creating network hellosw2_webnet
Creating service hellosw2_web
joe-T da # 
joe-T da # 
joe-T da # docker node ps ui
ID                  NAME                IMAGE                  NODE                DESIRED STATE       CURRENT STATE             ERROR               PORTS
g5ktos4wfrtq        hellosw2_web.1      kinds/hellocount:new   joe-T               Running             Preparing 8 seconds ago                       
m1b2gwpltnyq        hellosw2_web.4      kinds/hellocount:new   joe-T               Running             Preparing 8 seconds ago                       
joe-T da # docker node ps m0
ID                  NAME                IMAGE                  NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
4wdxysn1uiml        hellosw2_web.2      kinds/hellocount:new   vm2                 Running             Running 13 seconds ago                       
joe-T da # docker node ps p8
ID                  NAME                IMAGE                  NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
jy1u3i7tjfm4        hellosw2_web.3      kinds/hellocount:new   vm1                 Running             Running 38 seconds ago                       
bs8zkaljef9y        hellosw2_web.5      kinds/hellocount:new   vm1                 Running             Running 38 seconds ago                       
joe-T da # 

joe-T da # docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                  PORTS
h4v9hnafqn1x        hellosw2_web        replicated          3/5                 kinds/hellocount:new   *:80->80/tcp
joe-T da # docker service ps h4
ID                  NAME                IMAGE                  NODE                DESIRED STATE       CURRENT STATE                  ERROR               PORTS
g5ktos4wfrtq        hellosw2_web.1      kinds/hellocount:new   joe-T               Running             Preparing about a minute ago                       
4wdxysn1uiml        hellosw2_web.2      kinds/hellocount:new   vm2                 Running             Running about a minute ago                         
jy1u3i7tjfm4        hellosw2_web.3      kinds/hellocount:new   vm1                 Running             Running about a minute ago                         
m1b2gwpltnyq        hellosw2_web.4      kinds/hellocount:new   joe-T               Running             Preparing about a minute ago                       
bs8zkaljef9y        hellosw2_web.5      kinds/hellocount:new   vm1                 Running             Running about a minute ago                         
joe-T da # 

joe-T da # docker ps 
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS               NAMES
5d10b717d21a        kinds/hellocount:new   "python app.py"     2 minutes ago       Up About a minute   80/tcp              hellosw2_web.3.jy1u3i7tjfm4pniwandhtrfdm
2b169daa6f26        kinds/hellocount:new   "python app.py"     2 minutes ago       Up About a minute   80/tcp              hellosw2_web.5.bs8zkaljef9y9n7f3r3q71ykk
joe-T da # 


"





################## local registry

 
docker pull registry

docker run -d -p 5000:5000 -v /opt/data/registry:/var/lib/registry registry
##默认的目录如上


Storage customization
Customize the storage location

By default, your registry data is persisted as a docker volume on the host filesystem. 
If you want to store your registry contents at a specific location on your host filesystem, 
such as if you have an SSD or SAN mounted into a particular directory, you might decide to use a bind mount instead. 
A bind mount is more dependent on the filesystem layout of the Docker host, but more performant in many situations.
 The following example bind-mounts the host directory /mnt/registry into the registry container at /var/lib/registry/.

$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /mnt/registry:/var/lib/registry \
  registry:2

 ################################

 docker tag busybox 192.168.112.136:5000/busybox

docker push 192.168.112.136:5000/busybox

#Ubuntu下配置文件地址为：/etc/init/docker.conf，在其中增加–insecure-registry 192.168.112.136:5000
# centos
vim /etc/sysconfig/docker
OPTIONS='--insecure-registry 192.168.1.223:5000' (at the last  added)
systemctl restart docker 



curl -XGET http://192.168.1.223:5000/v2/_catalog 




--pod_infra_container_image=192.168.10.12:5000/google_containers/pause-amd64.3.0



 


##################################overlay network learn


swarm service to use

 1、

[root@k1 ~]# docker swarm init --advertise-addr=192.168.56.101 
Swarm initialized: current node (v01egk5rftemakkr44o468px1) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-2zjftb7nlpq82j2fslzde555uzawoazmz0kigxpvsxhgvetdci-8yun4b48pqzija9tsbmt21is5 192.168.56.101:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.


2、

"To create an overlay network for use with SWARM services, use a command like the following:

$ docker network create -d overlay my-overlay

To create an overlay network which can be used by SWARM SERVICES OR STANDALONE containers to communicate with other standalone containers running on other Docker daemons, add the --attachable flag:

$ docker network create -d overlay --attachable my-attachable-overlay

You can specify the IP address range, subnet, gateway, and other options. See docker network create --help for details.

docker-gwbridge 不是一个docker服务。
"

为特定服务创建overlay网络
docker network create -d overlay nginx-net

[root@k1 ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
8a784855b1d6        bridge              bridge              local
7ef3450d54ec        docker_gwbridge     bridge              local
7215b4f08fb4        host                host                local
mfv66tlpuydz        ingress             overlay             swarm
vseyl4ijaz0d        nginx-net           overlay             swarm
fa7d079c46f2        none                null                local
[root@k1 ~]# 

3、创建服务
docker service create --name my-nginx --publish target=80,published=80 --replicas=5 --network nginx-net nginx


4、查看overlay网络

[root@k1 ~]# docker network inspect nginx-net
[
    {
        "Name": "nginx-net",
        "Id": "vseyl4ijaz0dbw0d3uoqj5opz",
        "Created": "2018-06-08T01:24:57.929978824-04:00",
        "Scope": "swarm",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "10.0.0.0/24",
                    "Gateway": "10.0.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "5f7b2a5a1a8bd6eaa0a6a476601b5125f9967961446eff6dd9429293e82c2bd3": {
                "Name": "my-nginx.3.imrx7gdx7cbkmw9ojjmrzmaw6",
                "EndpointID": "21e38117c2b875abb778e6a114c9ab4f80eb193d845784fca4a231c7f1ef9ecc",
                "MacAddress": "02:42:0a:00:00:08",
                "IPv4Address": "10.0.0.8/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "4097"
        },
        "Labels": {},
        "Peers": [
            {
                "Name": "1281c39a85fd",
                "IP": "192.168.56.101"
            },
            {
                "Name": "e3cf6d8dc789",
                "IP": "192.168.56.102"
            },
            {
                "Name": "50b2f9e3aa81",
                "IP": "192.168.56.103"
            }
        ]
    }
]
[root@k1 ~]# 


[root@k1 ~]# docker service inspect my-nginx
[
    {
        "ID": "ome4xqmm1ai67yhmdp2upmalt",
        "Version": {
            "Index": 25
        },
        "CreatedAt": "2018-06-08T05:24:57.46010115Z",
        "UpdatedAt": "2018-06-08T05:24:57.462773511Z",
        "Spec": {
            "Name": "my-nginx",
            "Labels": {},
            "TaskTemplate": {
                "ContainerSpec": {
                    "Image": "nginx:latest@sha256:3e2ffcf0edca2a4e9b24ca442d227baea7b7f0e33ad654ef1eb806fbd9bedcf0",
                    "StopGracePeriod": 10000000000,
                    "DNSConfig": {},
                    "Isolation": "default"
                },
                "Resources": {
                    "Limits": {},
                    "Reservations": {}
                },
                "RestartPolicy": {
                    "Condition": "any",
                    "Delay": 5000000000,
                    "MaxAttempts": 0
                },
                "Placement": {
                    "Platforms": [
                        {
                            "Architecture": "amd64",
                            "OS": "linux"
                        },
                        {
                            "OS": "linux"
                        },
                        {
                            "Architecture": "arm64",
                            "OS": "linux"
                        },
                        {
                            "Architecture": "386",
                            "OS": "linux"
                        },
                        {
                            "Architecture": "ppc64le",
                            "OS": "linux"
                        },
                        {
                            "Architecture": "s390x",
                            "OS": "linux"
                        }
                    ]
                },
                "Networks": [
                    {
                        "Target": "vseyl4ijaz0dbw0d3uoqj5opz"
                    }
                ],
                "ForceUpdate": 0,
                "Runtime": "container"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 5
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 80,
                        "PublishMode": "ingress"
                    }
                ]
            }
        },
        "Endpoint": {
            "Spec": {
                "Mode": "vip",
                "Ports": [
                    {
                        "Protocol": "tcp",
                        "TargetPort": 80,
                        "PublishedPort": 80,
                        "PublishMode": "ingress"
                    }
                ]
            },
            "Ports": [
                {
                    "Protocol": "tcp",
                    "TargetPort": 80,
                    "PublishedPort": 80,
                    "PublishMode": "ingress"
                }
            ],
            "VirtualIPs": [
                {
                    "NetworkID": "mfv66tlpuydzyhlpwul7fabdz",
                    "Addr": "10.255.0.5/16"
                },
                {
                    "NetworkID": "vseyl4ijaz0dbw0d3uoqj5opz",
                    "Addr": "10.0.0.5/24"
                }
            ]
        }
    }
]




服务在其他node上启动后，其他node自动创建nginx-net



[root@k1 ~]# ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
       valid_lft 84369sec preferred_lft 84369sec
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.56.101/24 brd 192.168.56.255 scope global noprefixroute dynamic enp0s8
       valid_lft 763sec preferred_lft 763sec
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
9: docker_gwbridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    inet 172.18.0.1/16 brd 172.18.255.255 scope global docker_gwbridge
       valid_lft forever preferred_lft forever
[root@k1 ~]# 


新建网络，并更新服务使用新的网络

docker service update --network-add nginx-net-2 --network-rm nginx-net my-nginx



查看新的网络：

[root@k1 ~]# docker network inspect nginx-net
[
    {
        "Name": "nginx-net",
        "Id": "vseyl4ijaz0dbw0d3uoqj5opz",
        "Created": "2018-06-08T01:24:57.929978824-04:00",
        "Scope": "swarm",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "10.0.0.0/24",
                    "Gateway": "10.0.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "4097"
        },
        "Labels": {},
        "Peers": [
            {
                "Name": "1281c39a85fd",
                "IP": "192.168.56.101"
            },
            {
                "Name": "e3cf6d8dc789",
                "IP": "192.168.56.102"
            },
            {
                "Name": "50b2f9e3aa81",
                "IP": "192.168.56.103"
            }
        ]
    }
]
[root@k1 ~]# docker network inspect nginx-net-2
[
    {
        "Name": "nginx-net-2",
        "Id": "u7bxn0la91k4n6zapuljd8ni1",
        "Created": "2018-06-08T01:40:58.751483526-04:00",
        "Scope": "swarm",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "10.0.1.0/24",
                    "Gateway": "10.0.1.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "8938d79c81d3f756eb5d438eb2f69bde2b890f8b4583f4737663259cf574e85b": {
                "Name": "my-nginx.3.t31uzodbzwbocnfhipjlvsg6y",
                "EndpointID": "fcaf257df70ca55aa5700e15360f3897ca5af56100299e29835662e50acc1045",
                "MacAddress": "02:42:0a:00:01:08",
                "IPv4Address": "10.0.1.8/24",
                "IPv6Address": ""
            },
            "e34811a51ab8044f48090a69a8ee7028280666d8af6fbca131c4bb91b9f82d25": {
                "Name": "my-nginx.1.vv1hywob05q5sh76b5ctl8ykh",
                "EndpointID": "b90c0de942dee130bc643f6647ffeabc2c0999d135a857f00b9dc9d11a22755a",
                "MacAddress": "02:42:0a:00:01:06",
                "IPv4Address": "10.0.1.6/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "4098"
        },
        "Labels": {},
        "Peers": [
            {
                "Name": "1281c39a85fd",
                "IP": "192.168.56.101"
            },
            {
                "Name": "e3cf6d8dc789",
                "IP": "192.168.56.102"
            },
            {
                "Name": "50b2f9e3aa81",
                "IP": "192.168.56.103"
            }
        ]
    }
]
[root@k1 ~]# 



container已经都到了nginx-net-2上了
overlay网络自动创建了，但是不会自动删除

删除服务：
docker service rm my-nginx

删除网络：

[root@k1 ~]# docker service rm my-nginx
my-nginx
[root@k1 ~]# docker network rm nginx-net nginx-net-2
nginx-net
nginx-net-2
[root@k1 ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
8a784855b1d6        bridge              bridge              local
7ef3450d54ec        docker_gwbridge     bridge              local
7215b4f08fb4        host                host                local
mfv66tlpuydz        ingress             overlay             swarm
fa7d079c46f2        none                null                local
[root@k1 ~]# 
在swarm manager上删除，则集群内的集群均删除了
[root@k3 ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
737f782f0f46        bridge              bridge              local
5ddd3251a6c8        docker_gwbridge     bridge              local
7215b4f08fb4        host                host                local
mfv66tlpuydz        ingress             overlay             swarm
fa7d079c46f2        none                null                local
[root@k3 ~]# 

now！！
Use a user-defined overlay network



Separate control and data traffic

By default, control traffic relating to swarm management and traffic to and from your applications runs over the same network,
though the swarm control traffic is encrypted. You can configure Docker to use separate network interfaces for handling the
 two different types of traffic. When you initialize or join the swarm,
specify --advertise-addr and --datapath-addr separately. You must do this for each node joining the swarm.




macvlan

bridge example

In the simple bridge example, your traffic flows through eth0 and Docker routes traffic to your container 
using its MAC address. To network devices on your network, your container appears to be physically attached to the network.



802.1q trunked bridge example

In the 802.1q trunked bridge example, your traffic flows through a sub-interface of eth0 (called eth0.10) and Docker routes traffic to your container using its MAC address. 
To network devices on your network, your container appears to be physically attached to the network.



Create a macvlan network called my-8021q-macvlan-net. Modify the subnet, gateway,
 and parent values to values that make sense in your environment.

$ docker network create -d macvlan \
  --subnet=172.16.86.0/24 \
  --gateway=172.16.86.1 \
  -o parent=eth0.10 \
  my-8021q-macvlan-net

You can use docker network ls and docker network inspect pub_net commands to verify that the network exists, is a macvlan network, and has parent eth0.10. You can use ip addr show on the Docker host to verify that the interface eth0.10 exists and has a separate IP address




Start an alpine container and attach it to the my-8021q-macvlan-net network. The -dit flags start the container in the background but allow you to attach to it. The --rm flag means the container is removed when it is stopped.

$ docker run --rm -itd \
  --network my-8021q-macvlan-net \
  --name my-second-macvlan-alpine \
  alpine:latest \
  ash

Bridge mode

To create a Macvlan network which bridges with a given physical network interface, use --driver macvlan with the docker network create command. You also need to specify the parent, which is the interface the traffic will physically go through on the Docker host.

$ docker network create -d macvlan \
  --subnet=172.16.86.0/24 \
  --gateway=172.16.86.1  \
  -o parent=eth0 pub_net

If you need to exclude IP addresses from being used in the Macvlan network, such as when a given IP address is already in use, use --aux-addresses:

$ docker network create -d macvlan  \
  --subnet=192.168.32.0/24  \
  --ip-range=192.168.32.128/25 \
  --gateway=192.168.32.254  \
  --aux-address="my-router=192.168.32.129" \
  -o parent=eth0 macnet32

802.1q trunk bridge mode

If you specify a parent interface name with a dot included, such as eth0.50, Docker interprets that as a sub-interface of eth0 and creates the sub-interface automatically.

$ docker network  create  -d macvlan \
    --subnet=192.168.50.0/24 \
    --gateway=192.168.50.1 \
    -o parent=eth0.50 macvlan50

Use an ipvlan instead of macvlan

In the above example, you are still using a L3 bridge. You can use ipvlan instead, and get an L2 bridge. Specify -o ipvlan_mode=l2.

$ docker network create -d ipvlan \
    --subnet=192.168.210.0/24 \
    --subnet=192.168.212.0/24 \
    --gateway=192.168.210.254  \
    --gateway=192.168.212.254  \
     -o ipvlan_mode=l2 ipvlan210


##########################storage

volume (better)

Sharing data among multiple running containers. 
When you want to store your container’s data on a remote host or a cloud provider, rather than locally.
When you need to back up, restore, or migrate data from one Docker host to another, volumes are a better choice. 

 Volumes have several advantages over bind mounts:

    Volumes are easier to back up or migrate than bind mounts.           备份 迁移更方便
    You can manage volumes using Docker CLI commands or the Docker API.  通过cli或API管理
    Volumes work on both Linux and Windows containers.                   支持Linux和Windows模式
    Volumes can be more safely shared among multiple containers.         更安全地在多个容器之间共享
    Volume drivers allow you to store volumes on remote hosts or cloud providers, to encrypt the contents of volumes, or to add other functionality.
    A new volume’s contents can be pre-populated by a container.


bind-mounts  (share config with host)

Sharing configuration files from the host machine to containers. 
This is how Docker provides DNS resolution to containers by default, 
by mounting /etc/resolv.conf from the host machine into each container.

Sharing source code or build artifacts between a development environment on the Docker host and a container


If you use -v or --volume to bind-mount a file or directory that does not yet exist on the Docker host,
 -v creates the endpoint for you.
 It is always created as a directory.

If you use --mount to bind-mount a file or directory that does not yet exist on the Docker host, 
Docker does not automatically create it for you, but generates an error.

If you bind-mount into a non-empty directory on the container, the directory’s existing contents
 are obscured by the bind mount. This can be beneficial, such as when you want to test a 
 new version of your application without building a new image. 
However, it can also be surprising and this behavior differs from that of docker volumes.


Propagation setting   Description
shared  Sub-mounts of the original mount are exposed to replica mounts, and sub-mounts of replica mounts are also propagated to the original mount.
slave   similar to a shared mount, but only in one direction. If the original mount exposes a sub-mount, the replica mount can see it. However, if the replica mount exposes a sub-mount, the original mount cannot see it.
private   The mount is private. Sub-mounts within it are not exposed to replica mounts, and sub-mounts of replica mounts are not exposed to the original mount.
rshared   The same as shared, but the propagation also extends to and from mount points nested within any of the original or replica mount points.
rslave  The same as slave, but the propagation also extends to and from mount points nested within any of the original or replica mount points.
rprivate  The default. The same as private, meaning that no mount points anywhere within the original or replica mount points propagate in either direction.


tmpfs (memory)

Bind mounts and volumes can both mounted into containers using the -v or --volume flag, 
but the syntax for each is slightly different. For tmpfs mounts, you can use the --tmpfs flag. 
However, in Docker 17.06 and higher, we recommend using the --mount flag for both containers and services, 
for bind mounts, volumes, or tmpfs mounts, as the syntax is more clear.



用例：

docker run -d -it --name test --mount type=bind,source="$(pwd)"/test,target=/app alpine


  588  docker swarm init --advertise-addr=192.168.56.101
  589  docker service create -d --replicas=2 --name alpine --mount source=myvol2,target=/appdata alpine
  590  docker service ls


607  docker plugin install --grant-all-permissions vieux/sshfs

docker run -d --name sshfs-container --mount src=sshvolume,target=/app,volume-opt=sshcmd=root@k2:/root/test  alpine
 

docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest





容器使用卷
If you start a container with a volume that does not yet exist, Docker creates the volume for you. 
The following example mounts the volume myvol2 into /app/ in the container.

The -v and --mount examples below produce the same result. 
You can’t run them both unless you remove the devtest container and the myvol2 volume after running the first one.
$ docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest

 
  
$ docker run -d \
  --name devtest \
  -v myvol2:/app \
  nginx:latest


服务使用卷  必须使用mount

Start a service with volumes

When you start a service and define a volume, each service container uses its own local volume. None of the containers can share this data if you use the local volume driver, but some volume drivers do support shared storage. Docker for AWS and Docker for Azure both support persistent storage using the Cloudstor plugin.

The following example starts a nginx service with four replicas, each of which uses a local volume called myvol2.

$ docker service create -d \
  --replicas=4 \
  --name devtest-service \
  --mount source=myvol2,target=/app \
  nginx:latest

Syntax differences for services

The docker service create command does not support the -v or --volume flag.
 When mounting a volume into a service’s containers, you must use the --mount flag.



 例子：
 root@dev:/var/lib/docker/volumes/swarm-1-count/_data/volume-mount# docker volume ls
DRIVER              VOLUME NAME
local               9cdf4db0a81cabf54a0723b4ca057d57ccfd7fa82bab8917e817232f621080f0
local               swarm-1-count

root@dev:~# docker run -itd --name alpine --mount source=swarm-1-count,target=/datause alpine 
docker attach alpine
在里边创建文件夹及文件
volume-mount  然后创建文件volume.txt
在host主机里边查看：
root@dev:/var/lib/docker/volumes/swarm-1-count/_data/volume-mount# pwd
/var/lib/docker/volumes/swarm-1-count/_data/volume-mount
root@dev:/var/lib/docker/volumes/swarm-1-count/_data/volume-mount# more volume.txt



Populate a volume using a container  如果对应volume挂载的容器的目录里边有文件，则文件会拷贝到volume中。其他容器如果使用这个卷，
同样可以访问里边的内容，这称为预挂载？

If you start a container which creates a new volume, as above, and the container has files or directories 
in the directory to be mounted (such as /app/ above), the directory’s contents are copied into the volume. 
The container then mounts and uses the volume, and other containers which use the volume also have access to 
the pre-populated content.

To illustrate this, this example starts an nginx container and 
populates the new volume nginx-vol with the contents of the container’s /usr/share/nginx/html directory, 
which is where Nginx stores its default HTML content.

The --mount and -v examples have the same end result.

    --mount
    -v

$ docker run -d \
  --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html \
  nginx:latest



$ docker run -d \
  --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html \
  nginx:latest


After running either of these examples, run the following commands to clean up the containers and volumes.
 Note volume removal is a separate step.



存储的驱动 ，使用远程的ssh连接的卷


Use a volume driver

When you create a volume using docker volume create, or when you start a container which uses a not-yet-created volume, you can specify a volume driver. The following examples use the vieux/sshfs volume driver, first when creating a standalone volume, and then when starting a container which creates a new volume.
Initial set-up

This example assumes that you have two nodes, the first of which is a Docker host and can connect to the second using SSH.

On the Docker host, install the vieux/sshfs plugin:

$ docker plugin install --grant-all-permissions vieux/sshfs


Create a volume using a volume driver

This example specifies a SSH password, but if the two hosts have shared keys configured,
 you can omit the password. Each volume driver may have zero or more configurable options, 
 each of which is specified using an -o flag.



$ docker volume create --driver vieux/sshfs \
  -o sshcmd=test@node2:/home/test \
  -o password=testpassword \
  sshvolume

Start a container which creates a volume using a volume driver

This example specifies a SSH password, but if the two hosts have shared keys configured,
 you can omit the password. Each volume driver may have zero or more configurable options. 
 If the volume driver requires you to pass options, you must use the --mount flag to mount the volume, rather than -v.

$ docker run -d \
  --name sshfs-container \
  --volume-driver vieux/sshfs \
  --mount src=sshvolume,target=/app,volume-opt=sshcmd=test@node2:/home/test,volume-opt=password=testpassword \
  nginx:latest




备份 迁移  恢复

Backup, restore, or migrate data volumes

Volumes are useful for backups, restores, and migrations. Use the --volumes-from flag to create a new container that 
mounts that volume.
Backup a container

For example, in the next command, we:

    Launch a new container and mount the volume from the dbstore container
    Mount a local host directory as /backup
    Pass a command that tars the contents of the dbdata volume to a backup.tar file inside our /backup directory.

$ docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata

When the command completes and the container stops, we are left with a backup of our dbdata volume.
Restore container from backup

With the backup just created, you can restore it to the same container, or another that you made elsewhere.

For example, create a new container named dbstore2:

$ docker run -v /dbdata --name dbstore2 ubuntu /bin/bash

Then un-tar the backup file in the new container`s data volume:

$ docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"

You can use the techniques above to automate backup, migration and restore testing using your preferred tools.
Remove volumes

A Docker data volume persists after a container is deleted. There are two types of volumes to consider:

    Named volumes have a specific source form outside the container, for example awesome:/bar.
    Anonymous volumes have no specific source so when the container is deleted, instruct the Docker Engine 
    daemon to remove them.

Remove anonymous volumes

To automatically remove anonymous volumes, use the --rm option. For example, this command creates
 an anonymous /foo volume. When the container is removed, the Docker Engine removes the /foo volume but not the awesome volume.

$ docker run --rm -v /foo -v awesome:/bar busybox top

Remove all volumes

To remove all unused volumes and free up space:

$ docker volume prune




案例：
备份上次alpine容器的datause

docker run -itd --name alpine --mount source=swarm-1-count,target=/datause alpine

root@dev:~# docker run --rm --volumes-from alpine -v /root/web/:/backup alpine tar cvf /backup/backup.tar /datause

恢复上次的
先创建一个alpine2
root@dev:~/web# docker run  -v /volumedata  --name alpine2 alpine /bin/ash
root@dev:~/web# docker ps  没有的
CONTAINER ID        IMAGE                             COMMAND                  CREATED             STATUS              PORTS               NAMES
e5b7ae7caa75        dockersamples/visualizer:stable   "npm start"              44 hours ago        Up 44 hours         8080/tcp            alitest_visualizer.1.raas15jbv14vv6opt6jxzpegu
20d6e9988e16        kinds/hellocount:new              "python app.py"          44 hours ago        Up 44 hours         80/tcp              alitest_web.4.8aw544dqh4sx3p3syz2q6o5fp
a77705f80cea        kinds/hellocount:new              "python app.py"          44 hours ago        Up 44 hours         80/tcp              alitest_web.1.wmv0e2l3zzfb673dxz2kq7jll
cfef852ab2c9        redis:latest                      "docker-entrypoint.s…"   44 hours ago        Up 44 hours         6379/tcp            alitest_redis.1.0jb42auav4o9ehaeurgu5gxlj
3cab65982585        kinds/hellocount:new              "python app.py"          44 hours ago        Up 44 hours         80/tcp              alitest_web.3.nk1xxbrd2onvkpjsb6iehcmc6
16848b568c24        kinds/hellocount:new              "python app.py"          44 hours ago        Up 44 hours         80/tcp              alitest_web.2.giqqi9p3nlzpj937kdh6qum1u

接着恢复数据
root@dev:~/web# docker run --rm --volumes-from alpine2 -v /root/web:/volumedata alpine ash -c "cd /volumedata && tar xvf /volumedata/backup.tar --strip 1 "
datause/
datause/volume-mount/
datause/volume-mount/volume.txt
root@dev:~/web# 

If you need to specify volume driver options, you must use --mount.

优先使用mount  但是在17.06以前 --mount flag was used for swarm services.  


bind mount
If you use -v or --volume to bind-mount a file or directory that does not yet exist on the Docker host,
 -v creates the endpoint for you. It is always created as a directory.

If you use --mount to bind-mount a file or directory that does not yet exist on the Docker host, 
Docker does not automatically create it for you, but generates an error.



如果挂载本地文件夹到容器的一个非空目录，则容器的非空目录被遮掩，使用本地文件，不会对容器内的目录文件进行更改。
Mounting into a non-empty directory on the container

If you bind-mount into a non-empty directory on the container, the directory’s existing contents are
 obscured by the bind mount. This can be beneficial, such as when you want to test a new version of your 
 application without building a new image. However, it can also be surprising and this behavior differs from 
 that of docker volumes.

This example is contrived to be extreme, but replaces the contents of the container’s /usr/ directory with 
the /tmp/ directory on the host machine. In most cases, this would result in a non-functioning container.


The --mount and -v examples have the same end result.

比如：将容器的usr目录覆盖掉，容器就挂了（起不来）


$ docker run -d \
  -it \
  --name broken-container \
  --mount type=bind,source=/tmp,target=/usr \
  nginx:latest

docker: Error response from daemon: oci runtime error: container_linux.go:262:
starting container process caused "exec: \"nginx\": executable file not found in $PATH".


####################compose


Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. Then, with a single command, you create and start all the services from your configuration. To learn more about all the features of Compose, see the list of features.

Compose works in all environments: production, staging, development, testing, as well as CI workflows. You can learn more about each case in Common Use Cases.

Using Compose is basically a three-step process:

    Define your app’s environment with a Dockerfile so it can be reproduced anywhere.

    Define the services that make up your app in docker-compose.yml so they can be run together in an isolated environment.

    Run docker-compose up and Compose starts and runs your entire app.


################################## registry
Requirements

The Registry is compatible with Docker engine version 1.6.0 or higher.
Basic commands

Start your registry

docker run -d -p 5000:5000 --name registry registry:2

Pull (or build) some image from the hub

docker pull ubuntu

Tag the image so that it points to your registry

docker image tag ubuntu localhost:5000/myfirstimage

Push it

docker push localhost:5000/myfirstimage

Pull it back

docker pull localhost:5000/myfirstimage

Now stop your registry and remove all data

docker container stop registry && docker container rm -v registry


改变镜像的存储  本地挂载

$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /mnt/registry:/var/lib/registry \
  registry:2



改变端口：

If you want to change the port the registry listens on within the container, you can use the environment variable REGISTRY_HTTP_ADDR to change it. This command causes the registry to listen on port 5001 within the container:

$ docker run -d \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5001 \
  -p 5001:5001 \
  --name registry-test \
  registry:2

配置文件：

使用一个yml文件部署：
  Deploy your registry using a Compose file

If your registry invocation is advanced, it may be easier to use a Docker compose file to deploy it, 
rather than relying on a specific docker run invocation. Use the following example docker-compose.yml as a template.

registry:
  restart: always
  image: registry:2
  ports:
    - 5000:5000
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
    REGISTRY_HTTP_TLS_KEY: /certs/domain.key
    REGISTRY_AUTH: htpasswd
    REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
  volumes:
    - /path/data:/var/lib/registry
    - /path/certs:/certs
    - /path/auth:/auth

Replace /path with the directory which contains the certs/ and auth/ directories.

Start your registry by issuing the following command in the directory containing the docker-compose.yml file:

$ docker-compose up -d



#################################docker 迁移 registry

docker/migrator

Tool to migrate Docker images from Docker Hub or v1 registry to a v2 registry including Amazon EC2 Container Registry (ECR)

https://hub.docker.com/r/docker/migrator/
Usage

docker run -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e V1_REGISTRY=v1.registry.fqdn \
    -e V2_REGISTRY=v2.registry.fqdn \
    docker/migrator

Environment Variables

The following environment variables can be set:
Required

    V1_REGISTRY - DNS hostname of your v1 registry or Docker Hub (Do not include https://)
        If migrating images from Docker Hub, use docker.io
    V2_REGISTRY - DNS hostname of your v2 registry (Do not include https://)

Optional

    AWS_ACCESS_KEY - AWS Access Key supplied as either an environment variable or as a part of your credentials file.
    AWS_REGION - AWS Region, must be specified if using ECR
    AWS_SECRET_ACCESS_KEY - AWS Secret Access Key supplied as either an environment variable or as a part of your credentials file.
    ERROR_ACTION - Sets the default action on error for pushes and pulls
        prompt - (Default) Prompt for user input as to what action to take on error
        retry - Retry the failed action on error (may cause infinite loop of failure)
        skip - Log the error and continue migration on error
        abort - Abort the migration on error
    MIGRATION_INCREMENT - Breaks up migration in chunks of n images
        Defaults to migrating all images at once if not specified
        Must be a positive integer
        Only works if source and destination are not the same FQDN
    USER_PROMPT - Sets the default action for user prompts (non-error)
        true - (Default) Prompts user for input/validation
        false - Skips user prompt and automatically proceeds
    NO_LOGIN
        true - Skips docker login for both the v1 and v2 registries
        false - (Default) Prompts user to login to the v1 and v2 registries
    V1_NO_LOGIN
        true - Skips docker login for the v1 registry
        false - (Default) Prompts user to login to the v1 registry
    V2_NO_LOGIN
        true - Skips docker login for the v2 registry
        false - (Default) Prompts user to login to the v2 registry
    USE_INSECURE_CURL
        true - Allows curl to perform insecure SSL connections for querying APIs
        false - (Default) Require curl to perform secure SSL connections for querying APIs
    USE_HTTP
        true - Allows curl to connect to both the v1 and v2 registries over HTTP
            Note: daemon must also have --insecure-registry option set
        false - (Default) Requires curl to connect to v1 and v2 registries over HTTPS
    V1_USE_HTTP
        true - Allows curl to connect to v1 registry running over HTTP
            Note: daemon must also have --insecure-registry option set
        false - (Default) Requires curl to connect to v1 registry over HTTPS
    V2_USE_HTTP
        true - Allows curl to connect to v2 registry running over HTTP
            Note: daemon must also have --insecure-registry option set
        false - (Default) Requires curl to connect to v2 registry over HTTPS
    DOCKER_HUB_ORG - Docker Hub organization name to migrate images from
        Defaults to the username used to login to Docker Hub if not provided
    V1_FULL_REPO_LIST
        If provided, this allows the user to provide a whitespace separated list of repos for migration. This allows skipping the V1 call to _search (some setups might have search disabled)
    V1_REPO_FILTER - Search filter to limit the scope of the repositories to migrate (uses grep basic regular expression interpretation)
        Note: This only filters the repositories returned from the source registry search API, not the individual tags
    V1_TAG_FILTER - Search filter to limit the scope of the tags to migrate (Plain text matching).
    LIBRARY_NAMESPACE - Sets option to migrate official namespaces (images where there is no namespace provided) to the library/ namespace (Note: must be set to true for DTR 1.4 or greater)
        true - (Default) Adds library namespace to image names
        false - Keeps images as they are without a namespace
    SKIP_EXISTING_TAGS - Option to skip tags that exist at the target repository
        true - Do not migrate tags that exist at the target repository
        false - (Default) Do not skip any tags
    Custom CA certificate and Client certificate support - for custom CA and/or client certificate support to your v1 and/or v2 registries, you should utilize a volume to share them into the container by adding the following to your run command:
        -v /etc/docker/certs.d:/etc/docker/certs.d:ro
    V1_USERNAME - Username used for docker login to the v1 registry
    V1_PASSWORD - Password used for docker login to the v1 registry
    V1_EMAIL - Email used for docker login to the v1 registry
    V2_USERNAME - Username used for docker login to the v2 registry
    V2_PASSWORD - Password used for docker login to the v2 registry
    V2_EMAIL - Email used for docker login to the v2 registry

Note: You must use all three variables (V1_USERNAME, V1_PASSWORD, and V1_EMAIL or V2_USERNAME, V2_PASSWORD, and V2_EMAIL) for the given automated docker login to function properly. Omitting one will prompt the user for input of all three.
Prerequisites

This migration tool assumes the following:

    You have a v1 registry (or Docker Hub) and you are planning on migrating to a v2 registry
    The new v2 registry can either be running using a different DNS name or the same DNS name as the v1 registry - both scenarios work in this case. If you are utilizing the same DNS name for your new v2 registry, set both V1_REGISTRY and V2_REGISTRY to the same value.

It is suggested that you run this container on a Docker engine that is located near your registry as you will need to pull down every image from your v1 registry (or Docker Hub) and push them to the v2 registry to complete the migration. This also means that you will need enough disk space on your local Docker engine to temporarily store all of the images. If you have limited disk space, it is suggested that you use the MIGRATION_INCREMENT option to migrate n number of images at a time.

If you're interested in migrating to an Amazon EC2 Container Registry (ECR) you will additionally need to supply your AWS API keys to the migrator tool. This can be accomplished in one of the two following ways:

docker run -it \
    -v ~/.aws:/root/.aws:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e V1_REGISTRY=v1.registry.fqdn \
    -e V2_REGISTRY=v2.registry.fqdn \
docker/migrator

docker run -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e AWS_ACCESS_KEY_ID=<key> \
    -e AWS_SECRET_ACCESS_KEY=<secret> \
    -e V1_REGISTRY=v1.registry.fqdn \
    -e V2_REGISTRY=v2.registry.fqdn \
docker/migrator

How Migration Works

The migration occurs using an automated script inside of the Docker container. Running using the above usage will work as expected.

    Login to the v1 registry or Docker Hub (Optional)

    If you do not have authentication enabled, leave the username blank when prompted

    Query the v1 registry or Docker Hub for a list of all repositories
    With the list of images, query the v1 registry or Docker Hub for all tags for each repository. This becomes the list of all images with tags that you need to migrate
    Using a Docker engine, pull all images (including each tag)
    Once all images are pulled, there are a few options for next steps:
    If the same DNS record will be used for the v1 and v2 registries:

    Have user switch the DNS record over to the new server's IP or if same box to be used, stop the v1 registry and start the v2 registry

    If a different DNS record will be used for the v1 and v2 registries:

    Re-tag all images to change the tagging from the old DNS record to the new one

    Login to the v2 registry (Optional)

    If you do not have authentication enabled, leave the username blank when prompted

    Push all images and tags to the v2 registry
    Verify v1 to v2 image migration was successful (not yet implemented)
    Cleanup local docker engine to remove images



#################################  日志的记录  日志驱动

centos的 版本 1.13
[root@k1 ~]# ps aux |grep  journald
root        473  0.0  0.2  39076  5512 ?        Ss   Jun19   0:09 /usr/lib/systemd/systemd-journald
root       1840  1.9  2.7 958504 51364 ?        Ssl  Jun19  29:26 /usr/bin/dockerd-current --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current --default-runtime=docker-runc --exec-opt native.cgroupdriver=systemd --userland-proxy-path=/usr/libexec/docker/docker-proxy-current --init-path=/usr/libexec/docker/docker-init-current --seccomp-profile=/etc/docker/seccomp.json --selinux-enabled --log-driver=journald --signature-verification=false --storage-driver overlay2
root      14306  0.0  0.0 112708   960 pts/0    S+   13:41   0:00 grep --color=auto journald
[root@k1 ~]# 

阿里的Ubuntu  18.03
root@dev:~# ps aux |grep journald
root      7675  0.0  0.1  14224  1052 pts/0    S+   14:59   0:00 grep --color=auto journald
root     18846  0.0  0.8  43464  8400 ?        Ss   Jun20   0:04 /lib/systemd/systemd-journald
root@dev:~# 


###################docker 安全
与Docker安全相关的项目
1. Notary

Docker对安全模块进行了重构，剥离出了名为Notary的独立项目。Notary的目标是保证server和client之间的交互使用可信任的连接，用于解决互联网的内容发布的安全性。该项目并未局限于容器应用，在容器场景下可以对镜像源认证、镜像完整性等安全需求提供更好的支持。
2. docker-bench-security

docker-bench-security提供一个脚本，它可以检测用户的生产环境是否符合Docker的安全实践。




clair ：

Clair的目标是能够从一个更加透明的维度去看待基于容器化基础框架的安全性，Clair是由CoreOS所推出的这样一款针对容器镜像的安全扫描工具。 
Clair主要模块分为Detector、Fetcher、Notifier和Webhook，Clair首先对镜像进行特征的提取，然后再将这些特征匹配CVE漏洞库，
若发现漏洞则进行提示，其功能侧重于扫描容器中的OS及APP的CVE漏洞。

Clair是扫描引擎，启动后暴露API等待调用。在这里笔者使用clairctl（一个第三方调用工具）来对Clair发出调用请求，从而完成扫描。

Dockerscan：

Dockerscan是一个分析、攻击工具。它可以在网络中找出镜像仓库所在的主机，可以在镜像中插入木马，查看镜像中的敏感信息等等。

下图为Dockerscan基本命令，以及一次对 223.****.210/28 这个小网段进行一次探测容器仓库扫描。探测发现两台网易的容器仓库。

Anchore：

Clair能扫描出一个镜像中的所有CVE漏洞，但现在有一种情况，黑客使用最新版无漏洞的OS镜像，然后在其之上安装后门木马，或执行恶意命令，这样Clair就不能检测其安全性了。
这时就要介绍一个分析工具Anchorele，与Clair不同，Anchore侧重于对镜像的审计，其有强大的对镜像的解析能力。在分析之后可以对镜像进行多种操作，内置了许多脚本，用途广泛。



clair：
Cluster
Kubernetes (Helm)

If you don't have a local Kubernetes cluster already, check out minikube. This assumes you've already ran helm init, 
you have access to a currently running instance of Tiller and that you are running the latest version of helm.

git clone https://github.com/coreos/clair
cd clair/contrib/helm
cp clair/values.yaml ~/my_custom_values.yaml
vi ~/my_custom_values.yaml
helm dependency update clair
helm install clair -f ~/my_custom_values.yaml

Local
Docker Compose

$ curl -L https://raw.githubusercontent.com/coreos/clair/master/contrib/compose/docker-compose.yml -o $HOME/docker-compose.yml
$ mkdir $HOME/clair_config
$ curl -L https://raw.githubusercontent.com/coreos/clair/master/config.yaml.sample -o $HOME/clair_config/config.yaml
$ $EDITOR $HOME/clair_config/config.yaml # Edit database source to be postgresql://postgres:password@postgres:5432?sslmode=disable
$ docker-compose -f $HOME/docker-compose.yml up -d

Docker Compose may start Clair before Postgres which will raise an error. If this error is raised, 
manually execute docker-compose start clair.



Docker (this is good)

$ mkdir $PWD/clair_config
$ curl -L https://raw.githubusercontent.com/coreos/clair/master/config.yaml.sample -o $PWD/clair_config/config.yaml
$ docker run -d -e POSTGRES_PASSWORD="" -p 5432:5432 postgres:9.6
$ docker run --net=host -d -p 6060-6061:6060-6061 -v $PWD/clair_config:/config quay.io/coreos/clair-git:latest -config=/config/config.yaml

Source

To build Clair, you need to latest stable version of Go and a working Go environment. 
In addition, Clair requires some additional binaries be installed on the system $PATH as runtime dependencies:



#############################周边的 
VMware harbor   vs registry  vs quay

Harbor 的所有组件都在 Dcoker 中部署，所以 Harbor 可使用 Docker Compose 快速部署。

 Harbor 是基于 Docker Registry V2 版本，所以 docker 版本必须 > = 1.10.0 docker-compose >= 1.6.0 



openshift vs cloudfoundry


cd harbor  
修改配置文件 harbor.cfg
调整主机上的目录  调整IP地址 密码  等

./install.sh

会解压并生成docker image

docker login https://192.168.31.104

docker tag nginx 192.168.31.104/library/nginx
docker push 192.168.31.104/library/nginx 



#################### flannel  calico  CNI

calico
1）calico目前只支持TCP、UDP、ICMP、ICMPv6协议，如果使用其他四层协议（例如NetBIOS协议），建议使用weave、原生overlay等其他overlay网络实现。
2）基于三层实现通信，在二层上没有任何加密包装，因此只能在私有的可靠网络上使用。
3）流量隔离基于iptables实现，并且从etcd中获取需要生成的隔离规则，有一些性能上的隐患。


flanner:
Flannel is focused on networking. For network policy, other projects such as Calico can be used.
flannel 没有网络策略功能 

Flannel runs a small, single binary agent called flanneld on each host, and is responsible for allocating a subnet 
lease to each host out of a larger, preconfigured address space.
Flannel uses either the Kubernetes API or etcd directly to store the network configuration,
the allocated subnets, and any auxiliary data (such as the host s public IP).
Packets are forwarded using one of several backend mechanisms including VXLAN and various cloud integrations.


部署：
Deploying flannel manually

Flannel can be added to any existing Kubernetes cluster though its simplest to add flannel before any pods using the pod network have been started.

For Kubernetes v1.7+ 
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml





################### man
EXAMPLES
Running container in read-only mode
       During container image development, containers often need to write to the image content.  Installing packages into /usr, for example.  In production, applications seldom need to write to
       the image.  Container applications write to volumes if they need to write to file systems at all.  Applications can be made more secure by running them in read-only mode using the
       --read-only switch.  This protects the containers image from modification. Read only containers may still need to write temporary data.  The best way to handle this is to mount tmpfs
       directories on /run and /tmp.

              # docker run --read-only --tmpfs /run --tmpfs /tmp -i -t fedora /bin/bash

Exposing log messages from the container to the host's log
       If you want messages that are logged in your container to show up in the host's syslog/journal then you should bind mount the /dev/log directory as follows.

              # docker run -v /dev/log:/dev/log -i -t fedora /bin/bash

       From inside the container you can test this by sending a message to the log.

              (bash)# logger "Hello from my container"

       Then exit and check the journal.

              # exit

              # journalctl -b | grep Hello

       This should list the message sent to logger.

Attaching to one or more from STDIN, STDOUT, STDERR
       If you do not specify -a then Docker will attach everything (stdin,stdout,stderr) you d like to connect instead, as in:

              # docker run -a stdin -a stdout -i -t fedora /bin/bash

Sharing IPC between containers
       Using shm_server.c available here: ⟨https://www.cs.cf.ac.uk/Dave/C/node27.html⟩

       Testing --ipc=host mode:

       Host shows a shared memory segment with 7 pids attached, happens to be from httpd:

               $ sudo ipcs -m

               ------ Shared Memory Segments --------
               key        shmid      owner      perms      bytes      nattch     status
               0x01128e25 0          root       600        1000       7

       Now run a regular container, and it correctly does NOT see the shared memory segment from the host:

               $ docker run -it shm ipcs -m

               ------ Shared Memory Segments --------
               key        shmid      owner      perms      bytes      nattch     status

       Run a container with the new --ipc=host option, and it now sees the shared memory segment from the host httpd:

               $ docker run -it --ipc=host shm ipcs -m

               ------ Shared Memory Segments --------
               key        shmid      owner      perms      bytes      nattch     status
               0x01128e25 0          root       600        1000       7

       Testing --ipc=container:CONTAINERID mode:

       Start a container with a program to create a shared memory segment:

               $ docker run -it shm bash
               $ sudo shm/shm_server
               $ sudo ipcs -m

               ------ Shared Memory Segments --------
               key        shmid      owner      perms      bytes      nattch     status
               0x0000162e 0          root       666        27         1

       Create a 2nd container correctly shows no shared memory segment from 1st container:

               $ docker run shm ipcs -m

               ------ Shared Memory Segments --------
               key        shmid      owner      perms      bytes      nattch     status

       Create a 3rd container using the new --ipc=container:CONTAINERID option, now it shows the shared memory segment from the first:

               $ docker run -it --ipc=container:ed735b2264ac shm ipcs -m
               $ sudo ipcs -m

               ------ Shared Memory Segments --------
               key        shmid      owner      perms      bytes      nattch     status
               0x0000162e 0          root       666        27         1

Linking Containers
              Note: This section describes linking between containers on the default (bridge) network, also known as "legacy links". Using --link on user-defined networks uses the DNS-based
              discovery, which does not add entries to /etc/hosts, and does not set environment variables for discovery.

       The link feature allows multiple containers to communicate with each other. For example, a container whose Dockerfile has exposed port 80 can be run and named as follows:

              # docker run --name=link-test -d -i -t fedora/httpd

       A second container, in this case called linker, can communicate with the httpd container, named link-test, by running with the --link=<name>:<alias>

              # docker run -t -i --link=link-test:lt --name=linker fedora /bin/bash

       Now the container linker is linked to container link-test with the alias lt.  Running the env command in the linker container shows environment variables
        with the LT (alias) context (LT_)

              # env
              HOSTNAME=668231cb0978
              TERM=xterm
              LT_PORT_80_TCP=tcp://172.17.0.3:80
              LT_PORT_80_TCP_PORT=80
              LT_PORT_80_TCP_PROTO=tcp
              LT_PORT=tcp://172.17.0.3:80
              PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
              PWD=/
              LT_NAME=/linker/lt
              SHLVL=1
              HOME=/
              LT_PORT_80_TCP_ADDR=172.17.0.3
              _=/usr/bin/env

       When linking two containers Docker will use the exposed ports of the container to create a secure tunnel for the parent to access.

       If a container is connected to the default bridge network and linked with other containers, then the container's /etc/hosts file is updated with the linked container's name.

              Note Since Docker may live update the container's /etc/hosts file, there may be situations when processes inside the container can end up reading an empty or incomplete /etc/hosts
              file. In most cases, retrying the read again should fix the problem.

Mapping Ports for External Usage
       The exposed port of an application can be mapped to a host port using the -p flag. For example, an httpd port 80 can be mapped to the host port 8080 using the following:

              # docker run -p 8080:80 -d -i -t fedora/httpd

Creating and Mounting a Data Volume Container
       Many applications require the sharing of persistent data across several containers. Docker allows you to create a Data Volume Container that other containers can mount from. For example,
       create a named container that contains directories /var/volume1 and /tmp/volume2. The image will need to contain these directories so a couple of RUN mkdir instructions might be required
       for you fedora-data image:

              # docker run --name=data -v /var/volume1 -v /tmp/volume2 -i -t fedora-data true
              # docker run --volumes-from=data --name=fedora-container1 -i -t fedora bash

       Multiple --volumes-from parameters will bring together multiple data volumes from multiple containers. And it's possible to mount the volumes that came from the DATA container in yet
       another container via the fedora-container1 intermediary container, allowing to abstract the actual data source from users of that data:

              # docker run --volumes-from=fedora-container1 --name=fedora-container2 -i -t fedora bash

Mounting External Volumes
       To mount a host directory as a container volume, specify the absolute path to the directory and the absolute path for the container directory separated by a colon:

              # docker run -v /var/db:/data1 -i -t fedora bash

       When using SELinux, be aware that the host has no knowledge of container SELinux policy. Therefore, in the above example, if SELinux policy is enforced, the /var/db directory is not
       writable to the container. A "Permission Denied" message will occur and an avc: message in the host's syslog.

       To work around this, at time of writing this man page, the following command needs to be run in order for the proper SELinux policy type label to be attached to the host directory:

              # chcon -Rt svirt_sandbox_file_t /var/db

       Now, writing to the /data1 volume in the container will be allowed and the changes will also be reflected on the host in /var/db.

Using alternative security labeling
       You can override the default labeling scheme for each container by specifying the --security-opt flag. For example, you can specify the MCS/MLS level, a requirement for MLS systems.
       Specifying the level in the following command allows you to share the same content between containers.

              # docker run --security-opt label=level:s0:c100,c200 -i -t fedora bash

       An MLS example might be:

              # docker run --security-opt label=level:TopSecret -i -t rhel7 bash

       To disable the security labeling for this container versus running with the --permissive flag, use the following command:

              # docker run --security-opt label=disable -i -t fedora bash

       If you want a tighter security policy on the processes within a container, you can specify an alternate type for the container. You could run a container that is only allowed to listen on
       Apache ports by executing the following command:

              # docker run --security-opt label=type:svirt_apache_t -i -t centos bash

       Note:

       You would have to write policy defining a svirt_apache_t type.

Setting device weight
       If you want to set /dev/sda device weight to 200, you can specify the device weight by --blkio-weight-device flag. Use the following command:

              # docker run -it --blkio-weight-device "/dev/sda:200" ubuntu

Specify isolation technology for container (--isolation)
       This option is useful in situations where you are running Docker containers on Microsoft Windows. The --isolation <value> option sets a container's isolation technology. On Linux, the only
       supported is the default option which uses Linux namespaces. These two commands are equivalent on Linux:

              $ docker run -d busybox top
              $ docker run -d --isolation default busybox top

       On Microsoft Windows, can take any of these values:

              · default: Use the value specified by the Docker daemon's --exec-opt . If the daemon does not specify an isolation technology, Microsoft Windows uses process as its default value.

              · process: Namespace isolation only.

              · hyperv: Hyper-V hypervisor partition-based isolation.

       In practice, when running on Microsoft Windows without a daemon option set,  these two commands are equivalent:

              $ docker run -d --isolation default busybox top
              $ docker run -d --isolation process busybox top

       If you have set the --exec-opt isolation=hyperv option on the Docker daemon, any of these commands also result in hyperv isolation:

              $ docker run -d --isolation default busybox top
              $ docker run -d --isolation hyperv busybox top

Setting Namespaced Kernel Parameters (Sysctls)
       The --sysctl sets namespaced kernel parameters (sysctls) in the container. For example, to turn on IP forwarding in the containers network namespace, run this command:

              $ docker run --sysctl net.ipv4.ip_forward=1 someimage

       Note:

       Not all sysctls are namespaced. Docker does not support changing sysctls inside of a container that also modify the host system. As the kernel evolves we expect to see more sysctls become
       namespaced.

       See the definition of the --sysctl option above for the current list of supported sysctls.

HISTORY
       April 2014, Originally compiled by William Henry (whenry at redhat dot com) based on docker.com source material and internal work.  June 2014, updated by Sven Dowideit
       ⟨SvenDowideit@home.org.au⟩ July 2014, updated by Sven Dowideit ⟨SvenDowideit@home.org.au⟩ November 2015, updated by Sally O'Malley ⟨somalley@redhat.com⟩

Docker Community                                                                         Docker User Manuals  




##################查看docker容器日志
ls -lh $(find /var/lib/docker/containers/ -name *-json.log)

如何清理日志

如果docker容器正在运行，那么使用rm -rf 方式删除日志后，通过df -h会发现磁盘空间并没有释放

原因：在Linux或者Unix系统中，通过rm或者文件管理器删除文件将会从文件系统的目录结构上解除链接(unlink).然而如果文件是被打开的（
有一个进程正在使用），那么进程将仍然可以读取该文件，磁盘空间也一直被占用

正确姿势是cat /dev/null > *-json.log，当然你也可以通过rm删除后重启docker

脚本安装：
#!/bin/sh 

echo "======== start clean docker containers logs ========"  

logs=$(find /var/lib/docker/containers/ -type f  -mtime +10 -name *-json.log*)  

for log in $logs
        do  
                echo "clean logs : $log"  
                cat /dev/null > $log  
        done  
find /var/lib/docker/containers/ -type f  -size 0 -name *-json.log* |xargs rm -f

echo "======== end clean docker containers logs ========"  



如果深究其日志位置，每个容器的日志默认都会以 json-file 的格式存储于 /var/lib/docker/containers/<容器id>/<容器id>-json.log 下，
不过并不建议去这里直接读取内容，因为 Docker 提供了更完善地日志收集方式 - Docker 日志收集驱动。



关于日志收集，Docker 内置了很多日志驱动，可以通过类似于 fluentd, syslog 这类服务收集日志。无论是 Docker 引擎，还是容器，
都可以使用日志驱动。比如，如果打算用 fluentd 收集某个容器日志，可以这样启动容器：
$ docker run -d \
--log-driver=fluentd \
--log-opt fluentd-address=10.2.3.4:24224 \
--log-opt tag="docker.{{.Name}}" \
nginx

其中 10.2.3.4:24224 是 fluentd 服务地址，实际环境中应该换成真实的地址。

/usr/bin/dockerd-current --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current --default-runtime=docker-runc --exec-opt native.cgroupdriver=systemd --userland-proxy-path=/usr/libexec/docker/docker-proxy-current --init-path=/usr/libexec/docker/docker-init-current --seccomp-profile=/etc/docker/seccomp.json --selinux-enabled --log-driver=journald --signature-verification=false --storage-driver overlay2



在研究设计要素之前，先了解 Docker 日志记录的基本知识很重要。


Docker 支持不同的日志记录驱动，用于存储和/或流式传输主容器进程 (pid 1) 的容器 stdout 和 stderr 日志。默认情况下，
Docker 使用 json-file 日志记录驱动，但也可以配置它使用许多其他驱动，方法是在 /etc/docker/daemon.json 中设置 log-driver 的值，
然后重启 Docker 守护进程以重新加载其配置。


日志记录驱动设置会应用于重新配置守护进程之后启动的所有容器（在重新配置日志记录驱动之后重启现有容器并不会导致容器使用更新过的配置）。
要覆盖默认的容器日志记录驱动，应使用 --log-driver 和 --log-opt 选项运行容器。另一方面，可以使用 docker service update --log-driver--log-opt 对 swarm mode 服务进行运行中更新，使其改用不同的日志记录驱动。

docker引擎日志

那么 Docker 引擎日志呢？这些日志通常由默认的系统管理节点日志记录器处理。现代的大多数发行版（CentOS 7、RHEL 7、Ubuntu 16 等）都使用 systemd，
者使用 journald 记录日志，使用 journalctl 访问日志。要访问引擎日志，可使用 journalctl -u docker.service。

journalctl -u docker.service


 
############################# 预留资源的办法

Docker EE 支持对容器和服务任务应用资源限制。Docker 建议在创建服务时使用 --reserve-memory=<value> 和 --limit-memory=<value> 参数。
这些参数让 Docker EE 可以根据预期的内存消耗，更好地在工作节点上打包任务。

 

此外，分配一个全局（每节点 1 个实例）“幽灵”服务也许是个好主意，它可以在每个节点上保留一部分（例如 2GB）内存，
供非 Docker 系统服务使用。因为 Docker Swarm 当前不会考虑非 Docker 管理的工作负载所消耗的工作节点内存，所以这个方法很有意义：

 

docker service create --name system-reservation --reserve-memory 2G --limit-memory 2G --reserve-cpu 1 --mode global nginx:latest


(nginx 在此服务中实际上不执行任何工作。)（可以使用任何不会消耗大量内存或 CPU 的小镜像取代 nginx）。

#########################删除所有  危险
危险命令：

docker rm $(docker ps -aq)

docker stop $(docker ps -q) & docker rm $(docker ps -aq)

docker image rm  $(docker images -aq)
