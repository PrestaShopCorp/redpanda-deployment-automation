#!/bin/bash

# Get/Set single INI section
GetINISection() {
  local filename="$1"
  local section="$2"

  array_name="configuration_${section}"
  declare -g -A ${array_name}
  eval $(awk -v configuration_array="${array_name}" \
             -v members="$section" \
             -F= '{ 
                    if ($1 ~ /^\[/) 
                      section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)) 
                    else if ($1 !~ /^$/ && $1 !~ /^;/) {
                      gsub(/^[ \t]+|[ \t]+$/, "", $1); 
                      gsub(/[\[\]]/, "", $1);
                      gsub(/^[ \t]+|[ \t]+$/, "", $2);
                      if (section == members) {
                        if (configuration[section][$1] == "")  
                          configuration[section][$1]=$2
                        else
                          configuration[section][$1]=configuration[section][$1]" "$2}
                      }
                    } 
                    END {
                        for (key in configuration[members])  
                          print configuration_array"[\""key"\"]=\""configuration[members][key]"\";"
                    }' ${filename}
        )
}

# if [ "$#" -eq "2" ] && [ -f "$1" ] && [ -n "$2" ]; then
#   filename="$1"
#   section="$2"
#   GetINISection "$filename" "$section"

#   echo "[${section}]"
#   for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
#           echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\}) (access it using $(echo $\{configuration_${section}[$key]\}))"
#   done
# else
#   echo "missing INI file and/or INI section"
# fi



function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


filename=hosts.ini
section=redpanda
ips=()

GetINISection "$filename" "$section"

for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
        # echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\}) (access it using $(echo $\{configuration_${section}[$key]\}))"
        if valid_ip $key; then ips+=($key); fi
done

for ip in "${ips[@]}"
do
   echo "======================================"
   echo "public ip:" $ip
   PRIVATE_IP=$(ssh -o StrictHostKeyChecking=accept-new $ip "bash -c \"hostname -I | awk '{print $1}'\" ;");
   PRIVATE_IP=${PRIVATE_IP//[[:blank:]]/}
   echo "private ip:" $PRIVATE_IP

   echo "+++ INSTALL REDPANDA CONSOLE"
   ssh $ip "bash -c \
        'curl -1sLf https://dl.redpanda.com/nzc4ZYQK3WRGd9sy/redpanda/cfg/setup/bash.deb.sh | \
         sudo -E bash && sudo apt-get install redpanda-console -y' && sudo apt autoremove -y;";
   ssh $ip "bash -c \
        \"sudo sed -i 's/localhost/$PRIVATE_IP/' /etc/redpanda/redpanda-console-config.yaml && sudo systemctl restart redpanda-console\" ;";


done 



# /etc/redpanda/redpanda-console-config.yaml






# REDPANDA_CONF=$(sed -nr "/^\[redpanda\]/ { :l /^\s*[^#].*/ p; n; /^\[/ q; b l; }"  hosts.ini)

# echo $REDPANDA_CONF

# REDPANDA_IPS=`echo $REDPANDA_CONF | grep -o ' [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`


# echo $REDPANDA_IPS
# # REDPANDA_IPS="35.205.233.98 34.22.163.184 34.22.130.206"
# IFS='\n' read -r -a ARRAY_IPS <<< "$REDPANDA_IPS"


# echo "${ARRAY_IPS[0]}"
# echo "${ARRAY_IPS[1]}"
# echo "${ARRAY_IPS[2]}"


# for i in "${ARRAY_IPS[@]}"
# do
#    :
#    echo $i
# done 