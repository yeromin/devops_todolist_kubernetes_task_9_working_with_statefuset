# Validation Instructions

## 1. Prerequisites

Make sure these tools are installed and running:

- `docker` (Docker Desktop started)
- `kubectl`
- `kind`

## 2. Create cluster from config

From project root:

```bash
kind create cluster --config cluster.yml
kubectl get nodes
```

Expected: 3 nodes (`kind-control-plane`, `kind-worker`, `kind-worker2`) in `Ready` state.

## 3. Deploy all resources

```bash
./bootstrap.sh
```

Expected: script finishes without errors and shows resources in `mysql` and `todoapp` namespaces.

## 4. Validate MySQL StatefulSet requirements

```bash
kubectl get ns mysql
kubectl get statefulset -n mysql
kubectl get pods -n mysql -o wide
kubectl get svc -n mysql
kubectl get pvc -n mysql
```

Check:

- `mysql` namespace exists
- StatefulSet `mysql` has `3` replicas
- Pods `mysql-0`, `mysql-1`, `mysql-2` are `Running`
- Headless service `mysql` exists (`CLUSTER-IP` should be `None`)
- PVCs are created from `volumeClaimTemplates`

## 5. Validate `init.sql` execution and DB availability

```bash
kubectl exec -n mysql mysql-0 -- sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES LIKE \"todoapp\";"'
```

Expected: database `todoapp` is present.

## 6. Validate app deployment requirements

```bash
kubectl get deployment -n todoapp todoapp
kubectl get pods -n todoapp -o wide
kubectl describe pod -n todoapp -l app=todoapp | rg "NAME|USER|PASSWORD|HOST|SECRET_KEY"
```

Check:

- App pods are `Running/Ready`
- Pod env vars include DB keys from Secret: `NAME`, `USER`, `PASSWORD`, `HOST`
- `HOST` points to `mysql-0.mysql.mysql.svc.cluster.local`

## 7. Validate app endpoint

```bash
kubectl get svc -n todoapp
curl -i http://localhost:30007/api/health
```

Expected: HTTP `200` (or healthy response from app).

## 8. Optional cleanup

```bash
kind delete cluster
```
