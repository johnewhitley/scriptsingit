#!/bin/bash
#Check for Prometheus and Grafana
prometheus="whitleyserver.ddns.net:9090"
grafana="whitleyserver.ddns.net:3000"
containers="whitleyserver.ddns.net:9090"
for i in ${containers}; do
        if [ 'curl -s -I -L ${i} | grep "HTTP/1.1" | grep "OK" | awk {'print $2'}' == 200 ]; then
        echo "test1"
        elif [ 'curl -s -I -L ${i} | grep "HTTP/1.1" | grep "OK" | awk {'print $2'}' != 200 ]; then
        echo "test2"
        break
fi
done

if [[ "${containers}" == bad ]]; then
  container_slack="${bad_container} is not running correctly!"
else
  container_slack="All containers are running correctly :+1:"
fi

#Testing function
  echo "container slack is ${container_slack}"
  echo "contqainer status is ${container_status}"
  echo "containers is ${containers}"
  echo "bad container is ${bad_container}"
  echo "cchk is ${cchk}"
