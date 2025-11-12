# Spark Image - Using Jupyter PySpark notebook which includes Spark
FROM jupyter/pyspark-notebook:spark-3.3.0

# Fix permissions for Spark work directory
USER root
RUN mkdir -p /usr/local/spark/work && chmod 777 /usr/local/spark/work
USER jovyan

# Install python libraries that you need
# RUN pip install ...
