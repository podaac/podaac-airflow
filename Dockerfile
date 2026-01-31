FROM apache/airflow:2.10.5-python3.12

# Copy requirements first for better caching
COPY requirements.txt .

# Install all dependencies in one layer
RUN pip install --no-cache-dir -r requirements.txt

# Copy plugins
COPY plugins /opt/airflow/plugins