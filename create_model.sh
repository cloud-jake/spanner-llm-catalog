#!/bin/bash

LOCATION="us-central1"
PROJECT_ID=$(gcloud config get-value project)


gcloud spanner databases ddl update productdb --instance=productcatalog \
--ddl="CREATE MODEL TextBison \
INPUT (prompt STRING(MAX)) \
OUTPUT (content STRING(MAX)) \
REMOTE \
OPTIONS ( \
endpoint = '//aiplatform.googleapis.com/projects/'${PROJECT_ID}'/locations/'${LOCATION}'/publishers/google/models/text-bison'
);"
