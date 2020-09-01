#!/bin/bash
# 
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Enable Cloud Build, Cloud Run, and Cloud Scheduler
gcloud services enable --project "${PROJECT_ID}" cloudbuild.googleapis.com run.googleapis.com cloudscheduler.googleapis.com

# Create Service Accounts for Cloud Run Service and Cloud Schedule Job
gcloud iam service-accounts create openfwusingdomain --description="Run 'gcloud compute firewall-rules create/update' commands inside open-fw-using-domain Cloud Run Service" 
gcloud iam service-accounts create openfwusingdomain2 --description="Run Cloud Run Service onhalf of Cloud Scheduler"

# Create a key for the Cloud Run Service Account for initiliazing the Cloud SDK 
gcloud iam service-accounts keys create --iam-account openfwusingdomain@${PROJECT_ID}.iam.gserviceaccount.com key.json

# Create a custom role for the Cloud Run Service 
gcloud iam roles create openfwusingdomainrole --project=${PROJECT_ID} --title="Firewall Admin" --description="Custom Role for openFWUsingDomainName Cloud Run Service" --permissions=compute.firewalls.create,compute.firewalls.delete,compute.firewalls.get,compute.firewalls.list,compute.firewalls.update,compute.networks.updatePolicy,compute.globalOperations.get,compute.globalOperations.list --stage=GA

# Bind the custom role to the Service Account 
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:openfwusingdomain@${PROJECT_ID}.iam.gserviceaccount.com --role=projects/${PROJECT_ID}/roles/openfwusingdomainrole

