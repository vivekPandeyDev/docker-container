## Step 1: Install Docker

Verify Docker is installed:

```bash
docker --version
```

If Docker is not installed on Ubuntu/Debian, run:

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

Reload your shell:

```bash
newgrp docker
```

Verify the installation:

```bash
docker run hello-world
```

---

## Step 2: Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Verify the installation:

```bash
kubectl version --client
```

---

## Step 3: Install k3d

```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Verify the installation:

```bash
k3d version
```

---

## Step 4: Create a Cluster

Create a cluster named **devcluster** with:

- Traefik Ingress enabled (default)
- One server
- Two agents
- LoadBalancer
- HTTP and HTTPS ports mapped

```bash
k3d cluster create devcluster \
  --servers 1 \
  --agents 2 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer"
```

Verify the cluster:

```bash
kubectl cluster-info
```

List nodes:

```bash
kubectl get nodes
```

Expected output:

```text
NAME                        STATUS
k3d-devcluster-server-0     Ready
k3d-devcluster-agent-0      Ready
k3d-devcluster-agent-1      Ready
```

---

## Step 5: Verify Traefik Ingress

```bash
kubectl get pods -A
```

You should see something similar:

```text
kube-system   traefik-xxxxx
```

Verify the service. Wait until the status is RUNNING; this may take some time.

```bash
kubectl get svc -n kube-system
```

Expected output:

```text
traefik   LoadBalancer
```

---

## Step 6: Create a Namespace

```bash
kubectl create namespace dev
```

Verify:

```bash
kubectl get ns
```

Expected output:

```text
default
kube-system
dev
```

---

## Step 7: Set the Default Namespace

Instead of specifying `-n dev` every time:

```bash
kubectl config set-context --current --namespace=dev
```

Verify:

```bash
kubectl config view --minify | grep namespace
```

Expected output:

```text
namespace: dev
```

---

## Step 8: Test Deployment

Deploy nginx:

```bash
kubectl create deployment nginx --image=nginx
```

Expose it:

```bash
kubectl expose deployment nginx \
  --port=80 \
  --target-port=80
```

Verify:

```bash
kubectl get pods
kubectl get svc
```

---

## Step 9: Create an Ingress

Create `ingress.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  namespace: dev
spec:
  ingressClassName: traefik
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

Apply:

```bash
kubectl apply -f ingress.yaml
```

---

# Step 10: Update Hosts File

Add:

```text
127.0.0.1 nginx.local
```

Linux:

```bash
sudo nano /etc/hosts
```

Add:

```
127.0.0.1 nginx.local
```

---

# Step 11: Test

```bash
curl http://nginx.local
```

or open:

```
http://nginx.local
```

You should see the **Welcome to nginx** page.

---

# Useful Commands

List clusters:

```bash
k3d cluster list
```

Start cluster:

```bash
k3d cluster start devcluster
```

Stop cluster:

```bash
k3d cluster stop devcluster
```

Delete cluster:

```bash
k3d cluster delete devcluster
```

View nodes:

```bash
kubectl get nodes -o wide
```

View all pods:

```bash
kubectl get pods -A
```

---

# Verify Everything

```bash
kubectl get nodes

kubectl get ns

kubectl get pods -A

kubectl get ingress -n dev

kubectl get svc -A
```

Expected setup:

* **Cluster name:** `devcluster`
* **Runtime:** k3d (k3s)
* **Ingress controller:** Traefik (enabled by default)
* **Load balancer:** k3d load balancer exposing ports **80** and **443**
* **Namespace:** `dev`
* **Default namespace:** `dev`
* **Ingress host example:** `nginx.local`

# Step 2: Install Kubernetes Dashboard

Install the recommended Dashboard manifests using helm:
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
helm search repo headlamp

kubectl create namespace headlamp

helm install headlamp \
  headlamp/headlamp \
  -n headlamp

kubectl get pods -n headlamp -w  
kubectl get all -n headlamp
```

# Step 5: Login

Adding Service account headlamp-admin 

```bash
kubectl apply -f headlamp-admin.yaml
```

Generate token

```bash
kubectl create token headlamp-admin -n headlamp
```

Note for now port forward

```bash
kubectl port-forward -n headlamp svc/headlamp 8080:80
```

verify headlamp running vai cluster-ip

```bash
kubectl get svc -n headlamp

--output
NAME       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
headlamp   ClusterIP   10.43.97.24   <none>        80/TCP    8m20s
```

# Step 6: Create the Ingress with headlamp

Update ingress to handle headlamp
```bash
kubectl apply -f headlamp-ingress.yaml
```

Verify
```bash
kubectl get ingress -n headlamp

--output
NAME       CLASS     HOSTS            ADDRESS                            PORTS   AGE
headlamp   traefik   headlamp.local   172.19.0.2,172.19.0.3,172.19.0.4   80      7s
```

Update /etc/hosts

```bash
sudo nano /etc/hosts

- Add to host

127.0.0.1 headlamp.local
```

# Step 6: Test

Open:

http://headlamp.local

You should see the Headlamp login page.

# Step 7: Log In

Generate a fresh token if needed:

```bash
kubectl create token headlamp-admin -n headlamp
```
Log in with that token.

# Step 8: Verify Everything

Run:

``` bash
kubectl get ingress -A
kubectl get svc -A
kubectl get pods -A
```

You should have:
```text
✅ k3d cluster (devcluster)
✅ Traefik Ingress
✅ Headlamp
✅ Access via http://headlamp.local
```