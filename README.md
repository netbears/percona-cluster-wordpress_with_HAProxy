# percona-cluster-wordpress
Deploy a Percona cluster behind a HA proxy to which connect 3 wordpress containers that have a HA proxy in front of them.

This tutorial has been created using `Docker under Windows 10 with Hyper-V`.
Please amend the volumes path according to your OS.

## CLEAR WORKSPACE
```
docker rm $(docker ps -a -q) -f
docker rmi $(docker images -a -q) -f
```

### CREATE LOGICAL NETWORKS
```
docker network create backend
docker network create frontend
```

## LAUNCH DATABASE NODES
```
docker run --name db1 -d -p 3306 --net=backend  -e MYSQL_ROOT_PASSWORD=root  -e CLUSTER_NAME=cluster  -e XTRABACKUP_PASSWORD=root percona/percona-xtradb-cluster
docker run --name db2 -d -p 3306 --net=backend --link db1:db1 -e MYSQL_ROOT_PASSWORD=root  -e CLUSTER_NAME=cluster -e CLUSTER_JOIN=db1  -e XTRABACKUP_PASSWORD=root percona/percona-xtradb-cluster
docker run --name db3 -d -p 3306 --net=backend --link db1:db1 -e MYSQL_ROOT_PASSWORD=root  -e CLUSTER_NAME=cluster -e CLUSTER_JOIN=db1  -e XTRABACKUP_PASSWORD=root percona/percona-xtradb-cluster
```

## LAUNCH DB PROXY
```
docker run -d --name proxydb -v C:/Users/mariu/Documents/Training/percona-wordpress/proxydb:/usr/local/etc/haproxy:ro -d -p 3306:3306 --net=backend --link db1:db1 --link db2:db2 --link db3:db3 haproxy:1.7
```

## POPULATE DATABASE
```
docker run --name web1 -d -p 80:80 --net=backend --link db1:db1 -e WORDPRESS_DB_HOST=db1 -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=root -e WORDPRESS_DB_NAME=wordpress -e WORDPRESS_TABLE_PREFIX=wp wordpress
```

-> Complete UI install

-> COPY OUTPUT OF `docker exec -ti web1 cat /var/www/html/wp-config.php` TO  `.\percona-wordpress\wordpress\wp-config.php`

## BUILD WEB DOCKER
```
docker build -t web .\percona-wordpress\wordpress
```

## LAUNCH WEB NODES
```
docker run --name web1 -d -p 80 --net=frontend --link proxydb:db1 -v C:/Users/mariu/Documents/Training/galera-wordpress/wordpress/uploads:/var/www/html/wp-content/uploads:rw  web
docker run --name web2 -d -p 80 --net=frontend --link proxydb:db1 -v C:/Users/mariu/Documents/Training/galera-wordpress/wordpress/uploads:/var/www/html/wp-content/uploads:rw  web
docker run --name web3 -d -p 80 --net=frontend --link proxydb:db1 -v C:/Users/mariu/Documents/Training/galera-wordpress/wordpress/uploads:/var/www/html/wp-content/uploads:rw  web
```

## ATTACH WEB NODES TO BACKEND NETWORK
```
docker network connect backend web1
docker network connect backend web2
docker network connect backend web3
```

## LAUNCH WEB PROXY
```
docker run -d --name proxyweb --net=frontend -v C:/Users/mariu/Documents/Training/percona-wordpress/proxyweb:/usr/local/etc/haproxy:ro -d -p 80:80  --link web1:web1 --link web2:web2 --link web3:web3 haproxy:1.7
```
