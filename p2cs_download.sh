#!/bin/bash

echo "# Go into http://www.p2cs.org/, click 'browse' and Paste your PHPSESSID from url."

read session_id

echo "# Paste your searched url, examply: http://www.p2cs.org/page.php?section=genelist&type=hc&PHPSESSID= without value of PHPSESSID=."

read searching_url

echo "# Paste path to result file."

read save_file

echo "# Script is running. Watch out your RAM!"

phantomjs ./p2cs_download.js $searching_url$session_id > "./p2cs.html"

echo "# Completed downloading genes id. For next step you will need coffee."

res=$(cat p2cs.html | grep -Po 'gene=.*&amp'|sed 's/gene=//g'| sed 's/&amp//g')
counter=0
char=" "
all_genes=$(awk -F"${char}" '{print NF-1}' <<< "${res}"| wc -l)
counter_curl=0
collector=''
for tmp in $res;
do
    collector=$collector'&gene%5B%5D='$tmp
    counter=$((counter+1))
    if (( counter > 1000 ))
    then
        data_post='PHPSESSID='$session_id'&section=p2cscart&action=add'$collector
        #echo $data_post
        curl -d $data_post -X POST "http://www.p2cs.org/page.php" > /dev/null
        collector=''
        counter=0
        counter_curl=$((counter_curl+1))
        echo 'completed requests: '$counter_curl "from: "$((all_genes/1000 +1))' requests.'

    fi
done

data_post='PHPSESSID='$session_id'&section=p2cscart&action=add'$collector
#echo $data_post
curl -d $data_post -X POST "http://www.p2cs.org/page.php" > /dev/null
counter_curl=$((counter_curl+1))
echo 'completed requests: '$counter_curl "from: "$((all_genes/1000 +1))' requests.'

rm "./p2cs.html"

echo "# Completed sending genes id."

curl "http://www.p2cs.org/exportCartInTextFile.php?fasta=p&PHPSESSID="$session_id >$save_file

echo "# Completed downloading fasta."
