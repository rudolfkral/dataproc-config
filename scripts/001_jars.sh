#!/bin/bash
set -e

gsutil cp gs://ai-bucket/dataproc/jars/elasticsearch-hadoop-2.3.0.BUILD-20160303.040409-29.jar /usr/lib/hadoop/lib/
wget https://jdbc.postgresql.org/download/postgresql-9.4.1208.jar -P /usr/lib/hadoop/lib/
wget http://central.maven.org/maven2/org/apache/avro/avro/1.7.7/avro-1.7.7.jar -P /usr/lib/hadoop/lib/
wget https://dl.bintray.com/spark-packages/maven/spotify/spark-bigquery/0.1.2-s_2.10/spark-bigquery-0.1.2-s_2.10.jar -P /usr/lib/hadoop/lib/
wget https://dl.bintray.com/spark-packages/maven/databricks/spark-avro/3.0.1-s_2.10/spark-avro-3.0.1-s_2.10.jar -P /usr/lib/hadoop/lib/
