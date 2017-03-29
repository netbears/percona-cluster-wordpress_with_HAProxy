# Wordpress with Percona Cluster
Deploy a Percona cluster behind a Load Balancer to which multiple wordpress containers connect that have a Load Balancer in front of them.

This tutorial has been created in regards to 2 deployment methods : `docker-compose` and `kubernetes`.

Please amend the volumes path according to your OS.

`Docker-Advanced` presentation is available [here](https://github.com/NETBEARS-IT-Outsourcing/percona-cluster-wordpress_with_HAProxy/raw/master/Docker%20-%20Advanced.pdf).

## DOCKER COMPOSE

To create the stack, all you need to do is:
```
cd docker-compose
docker-compose up
```

## KUBERNETES

This tutorial assumes that you have first  performed the following steps:
- Install [Google Cloud SDK](https://cloud.google.com/sdk/downloads)
- Login to your existing project `gcloud init`
- Install kubernetes with `gcloud components install kubectl`

If alerted that you need to remove existing `kubectl` applications, please do and:
- Add `KUBECONFIG` as environment variable with value `<user_home_dir>\.kube\config`
- Run `gcloud auth application-default login`

If everything is working, then the following should connect you to your project and get kubernetes cluster info.

```
gcloud container clusters get-credentials <cluster-name> --zone europe-west1-b --project <project-name>
kubectl cluster-info
```

Then, to create the stack, follow these instructions:

### Connect to cluster
```
cd kubernetes
kubectl create namespace <namespace>
kubectl config set-context $(kubectl config current-context) --namespace=<namespace>
```

### Set persistence
```
kubectl create -f set-persistence.yaml
```

### Create database
```
kubectl create -f replica-set-db-primary.yaml
kubectl expose rs db-primary

# wait around 50 seconds
kubectl create -f replica-set-db-slave.yaml
kubectl create -f service-db-cluster.yaml
kubectl get pods,services
```

### Create web servers
```
kubectl create -f deployment-wordpress.yaml
kubectl expose deployment web --type=LoadBalancer
```


