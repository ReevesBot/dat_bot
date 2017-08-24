#!/bin/bash

read chan nick allmsg
function has { $(echo "$1" | grep -Pi "$2" > /dev/null) ; }

BOTNAME="dat_bot"

function say {
    echo "PRIVMSG $1 :$2"
}

function wiki {
    curl -Ls -o /dev/null -w %{url_effective} https://en.wikipedia.org/wiki/Special:Random
}

function google {
    local search="$(echo "$allmsg" | cut -d ' ' -f 2-)"
    local insert=${search// /+}
    local link="http://www.google.com/search?q=$insert&btnI&safe=active"
    wget -SU Googlebot "$link" 2>&1 | grep -P '^Location:' | awk '{print $2}'
}

function weather {
    local city="$(echo "$allmsg" | cut -d ' ' -f 2-)"
    local insert=${city// /%20}
    say $chan "$insert"
    wget -O forecast.txt http://api.wunderground.com/api/488ca4f3da14f1c8/conditions/q/$insert.json
}

function sevenday {
    local city="$(echo "$allmsg" | cut -d ' ' -f 2)"
    wget -O sevenforecast.txt http://api.wunderground.com/api/488ca4f3da14f1c8/forecast10day/q/$city.json
}

function stalker {
    message="$(echo "$allmsg")"
    {
    if [ ! -f /u/sultan/bot_stuff/dat_bot/stalker/$nick.txt ] ; then
        echo $message > /u/sultan/bot_stuff/dat_bot/stalker/$nick.txt
    else
        echo $message >> /u/sultan/bot_stuff/dat_bot/stalker/$nick.txt
    fi
    }
}

if has "$nick $allmsg" "Reeves !text" ; then
    message="$(echo "$allmsg" | cut -d ' ' -f 3-)"
    name="$(echo "$allmsg" | cut -d ' ' -f 2)"
    number="$(grep "^$name" contacts.txt | cut -d ' ' -f 2)"
    echo "$message" | ./twilio-sms.sh $number
    say $chan "Message sent boss!"
fi

if has "$nick $allmsg" "Reeves !partysignal" ; then
    partymessage="$(echo "$allmsg" | cut -d ' ' -f 2-)"
    oldIFS="$IFS"
    IFS=$'\n'
    for i in $(cat party.txt); do
        partynumber=$(echo $i | cut -d ' ' -f 2)
        echo "$partymessage" | ./twilio-sms.sh $partynumber
    done
    say $chan "PARTY ALERT!"
    IFS=$oldIFS
fi

if has "$allmsg" "^!weather" ; then
    place="$(weather)"
    temp="$(sed -ne '53p' forecast.txt | cut -d ":" -f 2)"
    tempfix="${temp/,/*F}"
    condition="$(sed -ne '51p' forecast.txt | cut -d ":" -f 2)"
    wind="$(sed -ne '56p' forecast.txt | cut -d ":" -f 2)"
    say $chan "Hey $nick it looks like the current condition out there is $condition the temperature is "$tempfix", and the wind is $wind"
fi

if has "$allmsg" "^!7day" ; then
    location="$(sevenday)"
    dayone="$(sed -ne '20p' sevenforecast.txt | cut -d ":" -f 2)"
    daytwo="$(sed -ne '40p' sevenforecast.txt | cut -d ":" -f 2)"
    daythree="$(sed -ne '60p' sevenforecast.txt | cut -d ":" -f 2)"
    dayfour="$(sed -ne '80p' sevenforecast.txt | cut -d ":" -f 2)"
    dayfive="$(sed -ne '100p' sevenforecast.txt | cut -d ":" -f 2)"
    daysix="$(sed -ne '120p' sevenforecast.txt | cut -d ":" -f 2)"
    dayseven="$(sed -ne '140p' sevenforecast.txt | cut -d ":" -f 2)"
    dayoneday="$(sed -ne '19p' sevenforecast.txt | cut -d ":" -f 2)"
    daytwoday="$(sed -ne '39p' sevenforecast.txt | cut -d ":" -f 2)"
    daythreeday="$(sed -ne '59p' sevenforecast.txt | cut -d ":" -f 2)"
    dayfourday="$(sed -ne '79p' sevenforecast.txt | cut -d ":" -f 2)"
    dayfiveday="$(sed -ne '99p' sevenforecast.txt | cut -d ":" -f 2)"
    daysixday="$(sed -ne '119p' sevenforecast.txt | cut -d ":" -f 2)"
    daysevenday="$(sed -ne '139p' sevenforecast.txt | cut -d ":" -f 2)"
    say $chan "Hey $nick, here's the seven day forecast!"
    say $chan "$dayoneday $dayone"
    say $chan "$daytwoday $daytwo"
    say $chan "$daythreeday $daythree"
    say $chan "$dayfourday $dayfour"
    say $chan "$dayfiveday $dayfive"
    say $chan "$daysixday $daysix"
    say $chan "$daysevenday $dayseven"
fi

if has "$allmsg" "^!google" ; then
    website="$(google)"
    say $chan "$nick $website"    
fi

if has "$allmsg" "i(')m? bored$" ; then
    suggest="$(wiki)"
    say $chan "$nick Why don't you read about $suggest ?"
fi

if has "$allmsg" "^oh shit$" ; then say $chan "$nick whaddup?"
fi

if has "$allmsg" "^i(')?m board$" ; then say $chan "Hi board! I'm dad_bot!"
fi

if has "$allmsg" ; then
    $(stalker)
    words="$(sed -e 's/[^[:alpha:]]/ /g' /u/sultan/bot_stuff/dat_bot/stalker/$nick.txt | tr '\n' " " |  tr -s " " | tr " " '\n'| tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr | nl)" #> /u/sultan/bot_stuff/dat_bot/stalker/count_$nick.txt
    new_words="${words//[0-9]/}"
    echo $new_words > /u/sultan/bot_stuff/dat_bot/stalker/count_$nick.txt
fi

if has "$allmsg" "^!wordcount$" ; then
    number1="$(sed -ne 1p /u/sultan/bot_stuff/dat_bot/stalker/count_$nick.txt | cut -d ' ' -f 1)"
    number2="$(sed -ne 1p  /u/sultan/bot_stuff/dat_bot/stalker/count_$nick.txt | cut -d ' ' -f 2)"
    number3="$(sed -ne 1p /u/sultan/bot_stuff/dat_bot/stalker/count_$nick.txt | cut -d ' ' -f 3)"
    say $chan "Hey $nick, it looks like your most used word is $number1, followed by $number2 and $number3"
fi

if has "$allmsg" "^$BOTNAME:? !?help$" ; then 
    say $chan "I'm bored: Random wikipedia article" 
    say $chan "!google fubar: Returns first google result" 
    say $chan "oh shit: whaddup?"
    say $chan "!weather *zipcode* or *city* *state*: Returns todays weather"
    say $chan "!7day *zipcode* or *city* *state*: Returns seven day forecast"
    say $chan "!wordcount: Shows your most used words from all the channels I sit in"
fi

if has "$allmsg" "^$BOTNAME:? !?source$" ; then 
    say $chan "Check me out at https://github.com/ReevesBot/dat_bot"
fi
