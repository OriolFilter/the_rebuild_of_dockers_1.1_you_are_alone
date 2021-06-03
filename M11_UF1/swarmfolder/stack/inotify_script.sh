#!/bin/sh
while true; do
  inotifywait -m /data/av/quarantine/ -e create |
  while read path action file; do
printf "
ehlo carter.ofa.itb
mail from: antivirus@clamav.ofa.itb
rcpt to: a@carter.ofa.itb,
data
Subject: A file has been moved to the quarantine folder
The file $file was moved to the quarantine folder at $(date +%H:%M) from $(date +%d-%m-%Y)!

.
quit
" | telnet carter.ofa.itb 25
  done
done



# Stored for record, for some reason the curl version strongly refused to work, getting the response VRFY from the serever

#    curl --ssl-reqd -v \
#        --url "smtp://carter.ofa.itb:25" \
#        --user "a:a" \
#        --mail-from "a@carter.ofa.itb" \
#        --mail-rcpt "profe@carter.ofa.itb" \
#        -H "Content-Type: text/plain; charset=UTF-8" \
#        -H "Subject: A file has been moved to the quarantine folder" \
#        -F "BODY=The file $file was moved to the quarantine folder at $(date +%H:%M) from $(date +%d-%m-%Y)!" \
#        --insecure