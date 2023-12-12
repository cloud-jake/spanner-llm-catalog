#!/bin/bash

echo "Enable Cloud Spanner API"
gcloud services enable spanner.googleapis.com

echo "Create Cloud Spanner Instance"
gcloud spanner instances create productcatalog \
--config=regional-us-central1 \
--description="productcatalog instance" \
--nodes=1

echo "Create Cloud Spanner Database"
gcloud spanner databases create productdb \
  --instance=productcatalog

echo "Create Cloud Storage Bucket"
export PROJECT_ID=$(gcloud config get-value project)
gsutil mb -l us-central1 gs://${PROJECT_ID}

sed 's|'BUCKET'|'"$PROJECT_ID"'|g' data/home_depot_data_1_2021_12.temp  > data/home_depot_data_1_2021_12.json

echo "Copy files to CLoud Storage"
gsutil cp data/home_depot_data_1_2021_12.csv gs://${PROJECT_ID}/
gsutil cp data/home_depot_data_1_2021_12.json gs://${PROJECT_ID}/

echo "Enable Cloud Dataflow API"
gcloud services enable dataflow.googleapis.com

echo "Create the product table in Cloud Spanner"
gcloud spanner databases ddl update productdb --instance=productcatalog \
--ddl="CREATE TABLE homedepot (\
index INT64 NOT NULL,\
url STRING(4096),\
title STRING(4096),\
images STRING(4096),\
description STRING(4096),\
product_id FLOAT64,\
sku FLOAT64,\
gtin13 FLOAT64,\
brand STRING(1024),\
price FLOAT64,\
currency STRING(1024),\
availability STRING(1024),\
uniq_id STRING(1024),\
scraped_at STRING(1024)\
) PRIMARY KEY (index);"

echo "Run the Cloud Dataflow job to load sample data"
gcloud dataflow jobs run loadhomedepot \
    --gcs-location gs://dataflow-templates/latest/GCS_Text_to_Cloud_Spanner \
    --region us-central1 \
    --parameters \
instanceId=productcatalog,\
databaseId=productdb,\
importManifest=gs://${PROJECT_ID}/home_depot_data_1_2021_12.json

echo ""

echo "******************************************************"
echo ""
echo "  Prerequisites Installed - Check for Error Messages  "
echo ""
echo "******************************************************"
 
