## Jenkins deployment using docker 


Official Jeknins documentation: [https://www.jenkins.io/](https://www.jenkins.io/)
<br>

## Requirements

* Ubuntu 16.04+ [https://www.ubuntu.com/download/server](https://www.ubuntu.com/download/server)
* Docker-compose 1.16.1+ [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
* Docker-ce 18.3.1+ [https://docs.docker.com/install/linux/docker-ce/ubuntu/](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

<br>

## 1. SSL Certificate creation for nginx

a. Local testing (non-production) on laptop or VM
 
```
bash ./src/infrastructure/nginx/init-ssl.sh # creates ssl cert
bash ./src/infrastructure/nginx/init-localhost.sh <yourUrlDomainGoesHere> #creates local routing

```

b. Production (not needed if terminating SSL at Load Balancer):

https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

## 2. Deploy Jenkins master


```
$ cd jenkins_ci/
$ docker-compose up -d

```

## 3. Directory structure details


/src/infrastructure

* contains nginx config and created certs

/src/backup

* Jenkinsfile used to create S3 backup and AMI backup 

/src/update

* Automation script for safely updating Jenkins plugins 

/src/upgrade

* Automation script for upgrading to latest Jenkins docker image


## Release Notes

### 1.0.1

* Initial creation of deploy and maintenance scripting for test & production Jenkins


