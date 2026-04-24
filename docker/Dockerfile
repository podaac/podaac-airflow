FROM apache/airflow:3.2.1-python3.12

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# COPY plugins /opt/airflow/plugins

# Copy your local dags folder to the airflow dags folder
#COPY --chown=airflow:root ./dags/ /opt/airflow/dags/