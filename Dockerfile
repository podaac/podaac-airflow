FROM apache/airflow:2.10.5-python3.11

#RUN pip install boto3==1.34.89
RUN pip install -U aiobotocore[awscli,boto3]>=2.21.1
RUN pip install apache-airflow-providers-amazon==9.10.0
RUN pip install earthaccess==0.14.0
RUN pip install asf-search==9.0.9

# Only use this if we end up needed some common tooling (e.g. token_generator)
# code common to all DAGs
COPY plugins /opt/airflow/plugins
