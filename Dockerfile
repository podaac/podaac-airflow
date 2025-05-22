FROM apache/airflow:2.10.3-python3.11

RUN pip install boto3==1.34.89

# Only use this if we end up needed some common tooling (e.g. token_generator)
# code common to all DAGs
#COPY plugins /opt/airflow/plugins
