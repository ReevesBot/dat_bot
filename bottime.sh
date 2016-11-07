#!/bin/bash

function send {

    echo "-> $1"
    echo "$1" >> .botfile

} 

function has { $(echo "$1" | grep -Pi "$2" > /dev/null) ; }

botname="dat_bot"
source ../secrets

started=""
rm .botfile
mkfifo .botfile
tail -f .botfile | openssl s_client -connect irc.cat.pdx.edu:6697 | while true ; do
    if [ -z $started ] ; then
        send "USER $botname 0 0 :$botname"
        send "NICK $botname"
        send "JOIN #robots $cat_chankey"
        send "JOIN #necromancers $cat_chankey"
        send "JOIN #meow $cat_chankey"
        send "JOIN #Reeves $my_chankey"    
        started="yes"
    fi

    read irc
    echo "<- $irc"
    if [[ "$(echo $irc | cut -d ' ' -f 1)" = "PING" ]] ; then
        send "PONG"
    fi
    
    cmd="$(echo $irc | cut -d ' ' -f 2)" # PRIVMSG

    if [[ "$cmd" == "PRIVMSG" ]] ; then

        chan="$(echo $irc | cut -d ' ' -f 3)"
        barf="$(echo $irc | cut -d ' ' -f 1-3)"
        allmsg="$(echo $irc | cut -d ' ' -f 4- | cut -c 2- | tr -d "\r\n")"
        saying="$(echo ${irc##$barf :}|tr -d "\r\n")"
        nick="${irc%%!*}"
        nick="${nick#:}"
        var="$(echo "$chan" "$nick" "$allmsg" | ./commands.sh)"
            if [[ ! -z $var ]] ; then
            send "$var"
            fi
    
    
    fi





done
