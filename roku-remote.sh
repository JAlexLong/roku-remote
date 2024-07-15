#!/usr/bin/env bash
# roku-remote
# An app to control your roku tv from the command line
# © 2024 by JAlexLong
# Version 0.2.2

# manual roku device network enumeration required
# auto-enumeration coming later
read -p "Enter Roku device IP Address. [192.168.1.72] " IP_ADDR
# validate ip address in future versions
if [[ "$IP_ADDR" == '' ]]; then
    IP_ADDR='192.168.1.72'
fi

DEVICE='Roku TV'
PORT='8060'

read -p "Query $DEVICE? [y/N] " QUERY
while [[ "$QUERY" == [Yy]* ]]; do
    # get query
    read -p "$IP_ADDR:$PORT/query/" ENDPOINT
    # send tcp payload
	curl "http://$IP_ADDR:$PORT/query/$ENDPOINT" | less
    # ask for another query or break loop
    read -p "Query $DEVICE agian? [Y/n] " QUERY
    case $QUERY in
        "")     QUERY='y';;
        [Nn]*)  break;;
        *)      echo 'Invalid option. Exiting...' && exit 1;;
    esac
done

# roku remote mainloop
while : ; do
    read -p "$USER@$DEVICE:~$ " KEY
    case $KEY in
        'exit') 
            break
            ;;
        '') 
            # repeat last command
            curl -d '' "http://$IP_ADDR:$PORT/keypress/$LAST_KEY"
            ;;
        *)
            # execute payload
            curl -d '' "http://$IP_ADDR:$PORT/keypress/$KEY"
            # save the most recent keypress
            LAST_KEY="$KEY"
            ;;
    esac
done

