#!/bin/bash
path="/opt/dns-tracker/"
export DB_NAME=`cat "$path"/config.ini | grep db_name | awk -F= '{print $2}'`
export DB_HOST=`cat "$path"/config.ini | grep db_host | awk -F= '{print $2}'`
export DB_USERNAME=`cat "$path"/config.ini | grep db_username | awk -F= '{print $2}'`
export DB_PASSWORD=`cat "$path"/config.ini | grep db_password | awk -F= '{print $2}'`
export DB_NAME_IP=`cat "$path"/config.ini | grep dns_name | awk -F= '{print $2}'`
export DB_SERVER_IP=`cat "$path"/config.ini | grep dns_server_ip | awk -F= '{print $2}'`

TABLE_QUERY='CREATE TABLE IF NOT EXISTS  `domains`(`id` int NOT NULL AUTO_INCREMENT PRIMARY KEY ,`ipsrc` text NULL,`name` text NULL,`count` int NOT NULL DEFAULT '1');'
TABLE_RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$TABLE_QUERY" ` 2>/dev/null

echo "DNS Server anyliss is startring.."

tcpdump -nt  udp port 53 | \
  while true; do
    # read output line by line
    read result

    # only act on non-blank output
    if [ "$result" != "" ]; then
     
     domain="$(echo "$result" | grep -P -o -e '\s\K(\S+(?:)\.(net|com)(.|.,) )')"
      if [ ! -z "$domain" ];
       then
         ipsrc="$(echo "$result" | grep -E -o 'IP ([0-9]{1,3}[\.]){3}[0-9]{1,3}'  | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}'  )"
         set -- junk $domain
         shift
        if [ "$ipsrc" != $DB_SERVER_IP  -a  "$ipsrc" != $DB_NAME_IP  ] ; then
         echo $result
         echo $ipsrc
                   for word; do
           [[ "$word" == *".," ]] && {
                  domain=${word%??}
           }
           [[ "$word" == *"." ]] && {
                   domain=${word%?}
           }
           [[ "$word" == *". " ]] && {
                   domain=${word%??}
           }
           echo "------------"
           echo $domain 
           echo $ipsrc
           echo "------------"
           export QUERY='select count(*) as total_req from `domains` where `name`='"'$domain'"''
           RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$QUERY" ` 2>/dev/null
           N_TOTAL=`echo $RESULT | awk '{print $2}'`
           #echo $N_TOTAL
             if [ "$N_TOTAL" -eq "0" ]; then
                INSERT_QUERY='INSERT INTO `domains` (`ipsrc`,`name`) VALUES ("'$ipsrc'","'$domain'") '
                INSERT_RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$INSERT_QUERY"` 2>/dev/null
                echo $domain >> "$path"/output.txt;
             else
                UPDATE_QUERY='UPDATE `domains` SET `count`= `count` + 1 WHERE `name` = '"'$domain'"' '
                UPDATE_RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$UPDATE_QUERY" ` 2>/dev/null 
                #echo "found";
             fi # end if not exite on DB
         done #end loop for check domain string
         echo "-------------------------------------------------------------------"
        fi # end if not exite on DB

         
     fi #end eles for check not blank 
    fi # end else for check not null
  done # loop for tcpdum
done



tcpdump -nt  udp port 53 | \
  while true; do
    # read output line by line
    read result
    if [ "$result" != "" ]; then
         ipsrc="$(echo "$result" | grep -E -o 'IP ([0-9]{1,3}[\.]){3}[0-9]{1,3}'  | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}'  )"
         #ipsrc="$(echo "$ipsrc" "
         set -- junk $domain
         shift
       echo "-------------------------------------------------------------------"  
       #echo "ip is $ipsrc"    
      if [ "$ipsrc" != $DB_SERVER_IP  -a  "$ipsrc" != $DB_NAME_IP  ] ; then
         echo $result
         echo $ipsrc
         echo "-------------------------------------------------------------------"
      fi # end if not exite on DB

    fi # end if not exite on DB
    done