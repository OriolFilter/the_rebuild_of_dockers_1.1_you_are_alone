#!/bin/sh
while true; do
  inotifywait -m /data/av/quarantine/ -e create |
  while read path action file; do
    curl --ssl-reqd -v -F \
         "SUBJECT=A file has been moved to the quarantine folder" \
        --url "smtp:/carter.ofa.itb:25" \
        --user "a:a" \
        --mail-from "a@carter.ofa.itb" \
        --mail-rcpt "a@carter.ofa.itb" \
        --"BODY=The file $file was moved to the quarantine folder at $(date +%H:%M) from $(date +%d-%m-%Y)!"
        --insecure
  done
done

