FROM apache/airflow:2.10.5-python3.12

# Install Python deps in one layer
RUN pip install --no-cache-dir -U \
    "aiobotocore[awscli,boto3]>=3.1.1" \
    apache-airflow-providers-amazon==9.20.0 \
    earthaccess==0.15.1 \
    asf-search==11.0.2

# Common tooling / plugins
COPY plugins /opt/airflow/plugins
