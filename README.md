# podaac-airflow


# Developing for podaac-Airflow

An kubernetes cluster is required to develop for Airflow if you intend to use kubernetesPodOperators. Minikube is a good option for this.

## install an airflow on your k8s cluster
using helm, it's easy to install Airflow locally.

```
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow --namespace airflow --create-namespace
```

to delete it from your k8s cluster:

```
helm delete airflow --namespace airflow
```

## Accessing the UI
you'll need to tunnel into your running pods to view the web service:
```
kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow
```

Then go to `localhost:8080` in your browser.

## Adding or updating a dag

to add a locally developed dag to your airflow instance, you can use kubectl to copy it in.

```
kubectl cp  eddy-process-dag.py airflow-scheduler-66867df4fc-2jrtn:/opt/airflow/dags/. -n airflow
kubectl cp  eddy-process-dag.py airflow-worker-0:/opt/airflow/dags/. -n airflow
```

***Note you must copy it to both the scheduler AND the worker*** 
