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


#Refer to the documentation for full list of possible firewall-rules command arguments - https://cloud.google.com/vpc/docs/using-firewalls#example_1_deny_all_ingress_tcp_connections_except_those_to_port_80_from_subnet1
if [[ $(gcloud compute firewall-rules list | grep ^$fwrulename | wc -l) -eq 0 ]];then
  gcloud compute --project=$project firewall-rules create $fwrulename --direction=INGRESS --priority=$priority --network=$network --action=ALLOW --rules $rules --source-ranges=`dig $domain +short | paste -s -d, -` --target-tags $targettags | echo
else
  gcloud compute --project=$project firewall-rules update $fwrulename --rules $rules --source-ranges=`dig $domain +short | paste -s -d, -` | echo
fi
