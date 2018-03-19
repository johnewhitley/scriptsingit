#!/bin/bash

data_free=$(df -H | grep data | awk '{print $4}')
rsync_free=$(df -H | grep rsync | awk '{print $4}')
mem_usage=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
cpu_load=$(top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}')

# Check Media Services
services="plexmediaserver qbittorrent"
for i in ${services}; do
 systemctl is-active --quiet ${i}
 service_chk=$?
 if [[ ${service_chk} -eq 0 ]]; then
  services_status="good"
 elif [[ ${service_chk} -ne 0 ]]; then
  bad_service=${i}
  services_status="bad"
  break
 fi
done

#Check for Prometheus and Grafana
prometheus="whitleyserver.ddns.net:9090"
grafana="whitleyserver.ddns.net:3000"
containers="${prometheus} ${grafana}"
for i in ${containers}; do
  curl -s -I -L ${containers} | grep "HTTP/1.1" | awk {'print $2'}
  if [[ ${containers} == 200 ]]; then
    container_status="good"
  elif [[ ${containers} != 200 ]]; then
    bad_container=${containers}
    container_status="bad"
    break
  fi
done

if [[ "${containers}" == "bad" ]]; then
  container_slack="${bad_container} is not running correctly!!!"
else
  container_slack="All containers are running correctly!!! :+1:"
fi

if [[ "${services_status}" == "bad" ]]; then
 services_slack="${bad_service} is not running correctly!!!"
else
 services_slack="All media server services are running correctly! :+1:"
fi

# Set Slack post for /opt being lowf
#opt_trimmed=$(echo ${data_free} | sed 's/[A-Za-z]*//g')
#if [[ ${opt_trimmed} -le 1.3 ]]; then
# storage_status="bad"
#else
storage_status="good"
#fi



#JSON Array for slack post
foo=$(cat <<EOF
{
   "channel":"#server-stats",
   "color":"good",
   "username":"webhookbot",
   "icon_emoji":":ghost:",
   "text":"*Daily Stats*\n*Server Name: $(hostname)*",
   "attachments":[
      {
         "title":"CPU Load",
         "text":"${cpu_load}",
         "color":"good"
      },
      {
         "title":"Memory Usage",
         "text":"${mem_usage}",
         "color":"good"
      },
      {
         "title":"Storage Check",
         "text":"Free Space in /data: ${data_free}\nFree Space in /rsync: ${rsync_free}",
         "color":"${storage_status}"
      },
      {
         "title":"Service Checks",
         "text":"${services_slack}",
         "color":"${services_status}"
      },
      {
         "title":"Container Checks",
         "text":"${container_slack}",
         "color":"good"
      }
   ]
}
EOF
)



curl -X POST --data-urlencode "payload=$foo" https://hooks.slack.com/services/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
