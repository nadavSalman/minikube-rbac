



## Train Kubernetes RBAC
The `dev-rbac` Helm Chart create the follwing workflow :


![ScreenShot](screenshots/k8s-rbac-demo.png.jpg)


Installl the chart : 
```bash
$ helm install  dev-rbac . --debug
```



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
Check authorization with kubectl --as[USER]
```bash
 ../authorisation.sh  
+ users=("team-a" "team-b" "team-c")
+ for user in '"${users[@]}"'
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-a -n team-a
NAME                            READY   STATUS    RESTARTS   AGE
team-a-nginx-59c5849978-d8l28   1/1     Running   0          12h
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-a -n team-b
Error from server (Forbidden): pods is forbidden: User "team-a" cannot list resource "pods" in API group "" in the namespace "team-b"
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-a -n team-c
Error from server (Forbidden): pods is forbidden: User "team-a" cannot list resource "pods" in API group "" in the namespace "team-c"
+ for user in '"${users[@]}"'
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-b -n team-a
Error from server (Forbidden): pods is forbidden: User "team-b" cannot list resource "pods" in API group "" in the namespace "team-a"
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-b -n team-b
NAME                            READY   STATUS    RESTARTS   AGE
team-b-nginx-59c5849978-zqckj   1/1     Running   0          12h
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-b -n team-c
Error from server (Forbidden): pods is forbidden: User "team-b" cannot list resource "pods" in API group "" in the namespace "team-c"
+ for user in '"${users[@]}"'
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-c -n team-a
Error from server (Forbidden): pods is forbidden: User "team-c" cannot list resource "pods" in API group "" in the namespace "team-a"
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-c -n team-b
Error from server (Forbidden): pods is forbidden: User "team-c" cannot list resource "pods" in API group "" in the namespace "team-b"
+ for ns in '"${users[@]}"'
+ kubectl get pods --as=team-c -n team-c
NAME                            READY   STATUS    RESTARTS   AGE
team-c-nginx-59c5849978-nzv6b   1/1     Running   0          12h
```





exsersice :

A new user michelle joined the team. She will be focusing on the nodes in the cluster. Create the required ClusterRoles and ClusterRoleBindings so she gets access to the nodes.



`ClusterRole`
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: null
  name: michelle-role
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch

```

`ClusterRoleBinding`
```yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: michelle-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: michelle

```

```
controlplane ~ ➜  kubectl get nodes --as=michelle
NAME           STATUS   ROLES                  AGE   VERSION
controlplane   Ready    control-plane,master   44m   v1.24.1+k3s1

controlplane ~ ➜  kubectl get nodes --as=michellew
Error from server (Forbidden): nodes is forbidden: User "michellew" cannot list resource "nodes" in API group "" at the cluster scope

```

michelle's responsibilities are growing and now she will be responsible for storage as well. Create the required ClusterRoles and ClusterRoleBindings to allow her access to Storage.

Get the API groups and resource names from command kubectl `api-resources`.

```
kubectl api-resources | grep storage
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver
csinodes                                       storage.k8s.io/v1                      false        CSINode
csistoragecapacities                           storage.k8s.io/v1                      true         CSIStorageCapacity
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
```



```yaml
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: storage-admin
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["get", "watch", "list", "create", "delete"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "watch", "list", "create", "delete"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: michelle-storage-admin
subjects:
- kind: User
  name: michelle
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: storage-admin
  apiGroup: rbac.authorization.k8s.io
```



RBAC with Service Account : 
```yaml
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: dashboard-sa # Name is case sensitive
  namespace: default
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups:
  - ''
  resources:
  - pods
  verbs:
  - get
  - watch
  - list
  ```