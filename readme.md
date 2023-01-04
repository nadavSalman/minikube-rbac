



## Train Kubernetes RBAC
The `dev-rbac` create the follwing workflow :


![ScreenShot](screenshots/k8s-rbac-demo.png.jpg)






```bash
 $ kubectl get ns | grep team
team-a            Active   5m44s
team-b            Active   5m44s
team-c            Active   5m44s
 $ kubectl get all  -A  | grep team | awk '{ print $2 }'
pod/team-a-nginx-59c5849978-v8k4v
pod/team-b-nginx-59c5849978-74fzb
pod/team-c-nginx-59c5849978-h8qkd
deployment.apps/team-a-nginx
deployment.apps/team-b-nginx
deployment.apps/team-c-nginx
replicaset.apps/team-a-nginx-59c5849978
replicaset.apps/team-b-nginx-59c5849978
replicaset.apps/team-c-nginx-59c5849978
```




