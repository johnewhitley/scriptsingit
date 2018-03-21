#!/bin/bash

data_free=$(df -H | grep data | awk '{print $4}')
rsync_free=$(df -H | grep rsync | awk '{print $4}')
boot_free=$(df -H | grep boot | awk '{print $4}')
mem_usage=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
cpu_load=$(top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}')

# Check Media Services
services="plexmediaserver qbittorrent nomad hass sonarr"
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

prometheus="whitleyserver.ddns.net:9090/graph"
grafana="whitleyserver.ddns.net:3000/login"
containers="${prometheus} ${grafana}"

prometheuschk=$(curl -S -i http://whitleyserver.ddns.net:9090/status| grep "OK" | awk {'print $2'})
grafanachk=$(curl -s -I -L ${grafana} | grep "HTTP/1.1" | grep "OK" | awk {'print $2'})

containercheck() {
if [[ ${prometheuschk} == 200 ]]; then
  promchk="good"
elif [[ ${prometheuschk} != 200 ]]; then
  bad_container="Prometheus"
fi
if [[ ${grafanachk} == 200 ]]; then
  grafchk="good"
elif [[ ${grafanachk} != 200 ]]; then
  bad_container="Grafana"
fi
}


containerstat() {
if [[ -n ${bad_container} ]]; then
  container_slack="${bad_container} is not running correctly!"
  container_status="bad"
else
  container_slack="All containers are running correctly! :+1:"
  container_status="good"
fi
}


#Main
containercheck
containerstat

if [[ "${services_status}" == "bad" ]]; then
 services_slack="${bad_service} is not running correctly!"
else
 services_slack="All media server services are running correctly! :+1:"
fi

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
         "text":"Free Space in /data: ${data_free}\nFree Space in /rsync: ${rsync_free}\nFree Space in /boot ${boot_free}",
         "color":"good"
      },
      {
         "title":"Service Checks",
         "text":"${services_slack}",
         "color":"${services_status}"
      },
      {
         "title":"Container Checks",
         "text":"${container_slack}",
         "color":"${container_status}"
      }
   ]
}
EOF
)


curl -X POST --data-urlencode "payload=$foo" https://hooks.slack.com/services/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
