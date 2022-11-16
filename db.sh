#!/bin/bash
export DB_NAME=`cat config.ini | grep db_name | awk -F= '{print $2}'`
export DB_HOST=`cat config.ini | grep db_host | awk -F= '{print $2}'`
export DB_USERNAME=`cat config.ini | grep db_username | awk -F= '{print $2}'`
export DB_PASSWORD=`cat config.ini | grep db_password | awk -F= '{print $2}'`



TABLE_QUERY='CREATE TABLE IF NOT EXISTS  `domains`(`id` int NOT NULL AUTO_INCREMENT PRIMARY KEY ,`name` text NULL,`count` int NOT NULL DEFAULT '1');'
TABLE_RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$TABLE_QUERY" ` 2>/dev/null


echo "DNS Server anyliss is startring"

tcpdump -nt  udp port 53 | \
  while true; do
    # read output line by line
    read result
    # only act on non-blank output
    if [ "$result" != "" ]; then
     domain="$(echo "$result" | grep -P -o -e '\s\K(\S+(?:)\.(net|com)(.|.,) )')"
      if [ ! -z "$domain" ];
       then  
         set -- junk $domain
         shift
         for word; do
           [[ "$word" == *".," ]] && {
                  domain=${word%?}
           }
           [[ "$word" == *"." ]] && {
                   domain=${word%?}
           }
           [[ "$word" == *". " ]] && {
                   domain=${word%??}
           }
           echo $domain
           export QUERY='select count(*) as total_req from `domains` where `name`='"'$domain'"''
           RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$QUERY" ` 2>/dev/null
           N_TOTAL=`echo $RESULT | awk '{print $2}'`
           #echo $N_TOTAL
             if [ "$N_TOTAL" -eq "0" ]; then
                INSERT_QUERY='INSERT INTO `domains` (`name`) VALUES ("'$domain'") '
                INSERT_RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$INSERT_QUERY"` 2>/dev/null
                echo $domain >> output.txt;
             else
                UPDATE_QUERY='UPDATE `domains` SET `count`= `count` + 1 WHERE `name` = '"'$domain'"' '
                UPDATE_RESULT=`mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e "$UPDATE_QUERY" ` 2>/dev/null 
                #echo "found";
             fi # end if not exite on DB
         done #end loop for check domain string
         
     fi #end eles for check not blank 
    fi # end else for check not null
  done # loop for tcpdum
done