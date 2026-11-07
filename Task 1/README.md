# Task 1: Multi-Container Pods (Init Container & Sidecar)

## Description

Deploy an Nginx Hello page on a 3-node Minikube cluster that displays the current timestamp and updates it every 5 seconds.

Each Pod contains three containers:

- **init-done (Init Container):** Prints `done` and exits successfully.
- **nginx (Main Container):** Creates the initial `index.html` with the current timestamp and serves it on port 80.
- **time-updater (Sidecar Container):** Updates `index.html` with the current timestamp every 5 seconds using `/proc/<pid>/root`.

## Pod Architecture

- 3 replicas.
- 1 init container and 2 regular containers per Pod.
- `shareProcessNamespace: true`.
- No volumes.
- Nginx listens on port 80.

## Repository Structure

```text
Kubernetes-Course-Tasks/
└── Task-1/
    ├── deployment.yaml
    ├── README.md
    └── screenshots/
        ├── 01-cluster.png
        ├── 02-running-pods.png
        ├── 03-hello-page.png
        ├── 04-timestamp-updates.png
        ├── 05-init-failure.png
        └── 06-recovery.png
```

## Prerequisites

- Docker
- Minikube
- kubectl
- Git

## 1. Start the Minikube Cluster

```bash
minikube start --nodes=3 --driver=docker
```

Verify the nodes:

```bash
kubectl get nodes
```

All three nodes should be in `Ready` status.

## 2. Deploy the Application

```bash
kubectl apply -f deployment.yaml
```

Check the Deployment:

```bash
kubectl get deployments
```

Check the Pods:

```bash
kubectl get pods -o wide
```

Expected: Three Pods running successfully.

## 3. Verify the Init Container

Get a Pod name:

```bash
kubectl get pods
```

Check init container logs:

```bash
kubectl logs <pod-name> -c init-done
```

Expected output:

```text
done
```

## 4. Verify Nginx

Forward port 80:

```bash
kubectl port-forward deployment/hello 8080:80
```

Open the application:

http://localhost:8080

Expected output:

```text
hello in MLOPS MENA COMMUNITY : YYYY-MM-DD HH:MM:SS
```

## 5. Verify Sidecar Timestamp Updates

Check sidecar logs:

```bash
kubectl logs <pod-name> -c time-updater
```

The timestamp should update every 5 seconds.

## 6. Intentionally Fail the Init Container

Modify the init container command in `deployment.yaml`:

```yaml
command: ["sh", "-c", "echo failed; exit 1"]
```

Apply the changes:

```bash
kubectl apply -f deployment.yaml
```

Check the Pods:

```bash
kubectl get pods
```

Expected behavior:

- The init container fails.
- Kubernetes restarts the init container.
- The Pod eventually enters `Init:CrashLoopBackOff`.
- Previously running Pods remain available during the failed rollout.

Check the failure logs:

```bash
kubectl logs <pod-name> -c init-done
```

Inspect the Pod:

```bash
kubectl describe pod <pod-name>
```

## 7. Recover the Application

Restore the init container command:

```yaml
command: ["sh", "-c", "echo done"]
```

Apply the corrected configuration:

```bash
kubectl apply -f deployment.yaml
```

Check rollout status:

```bash
kubectl rollout status deployment/hello
```

Verify the Pods:

```bash
kubectl get pods
```

All three replicas should return to Running status with two regular containers ready.

## 8. Verification Commands

```bash
kubectl get nodes
kubectl get pods -o wide
kubectl get deployments
kubectl describe pod <pod-name>
kubectl logs <pod-name> -c init-done
kubectl logs <pod-name> -c nginx
kubectl logs <pod-name> -c time-updater
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 9. Screenshots

The following screenshots demonstrate successful completion:

1. Three-node Minikube cluster.
2. Three running Pods.
3. Nginx Hello page displaying the timestamp.
4. Sidecar logs showing timestamp updates every 5 seconds.
5. Init container failure and `Init:CrashLoopBackOff`.
6. Successful recovery after fixing the init container.

## 10. Cleanup

Delete the Deployment:

```bash
kubectl delete -f deployment.yaml
```

Stop Minikube:

```bash
minikube stop
```

## Conclusion

Successfully implemented a Kubernetes multi-container Pod architecture using an init container, Nginx main container, and timestamp-updating sidecar.

Demonstrated init container execution, shared process namespace, timestamp updates, intentional initialization failure, Kubernetes Pod lifecycle management, and recovery.