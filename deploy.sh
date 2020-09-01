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


# Modify the ENV variables below to customize 
PRIORITY='1000'
RULES='tcp:80,tcp:8080,udp:8000'
DOMAIN='naver.com'
TARGETTAGS='tags1'
NETWORK='default'
FREQUENCY='0 */1 * * *'

gcloud run deploy "${DOMAIN_FW_NAME}" \
  --project "${PROJECT_ID}" \
  --platform "managed" \
  --region "us-central1" \
  --image "gcr.io/${PROJECT_ID}/openfwusingdomain" \
  --service-account "openfwusingdomain@${PROJECT_ID}.iam.gserviceaccount.com" \
  --update-env-vars "^;^project=${PROJECT_ID};fwrulename=${DOMAIN_FW_NAME};priority=${PRIORITY};rules=${RULES};domain=${DOMAIN};targettags=${TARGETTAGS};network=${NETWORK}" \
  --no-allow-unauthenticated

# Scheduler Job Creation
# Setup the Cloud Scheduler to invoke the deployed Cloud Run Service periodically to refresh the f/w rule with changes in the A record of the domain name.

## Grant the Cloud Run Invoker (roles/run.invoker) role to the calling service identity on the receiving service.
gcloud run services add-iam-policy-binding ${DOMAIN_FW_NAME} --member=serviceAccount:openfwusingdomain2@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/run.invoker --platform=managed --region=us-central1

## Retrieve the Service URL
SERVICE_URL=$(gcloud run services describe ${DOMAIN_FW_NAME} --platform=managed --region=us-central1 | grep Traffic: | cut -d' ' -f2-)

## Create the Cloud Scheduler Job 
## Modify the schedule frequency, default is every 1 hour.
## Supported Time Zones - https://cloud.google.com/dataprep/docs/html/Supported-Time-Zone-Values_66194188
gcloud beta scheduler jobs create http ${DOMAIN_FW_NAME}-job --schedule "${FREQUENCY}" --time-zone "Asia/Seoul" --http-method=POST --uri=${SERVICE_URL} --oidc-service-account-email=openfwusingdomain2@${PROJECT_ID}.iam.gserviceaccount.com --oidc-token-audience=${SERVICE_URL}
