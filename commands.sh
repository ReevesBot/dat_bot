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

if has "$allmsg" "^$BOTNAME:? !?help$" ; then 
    say $chan "I'm bored: Random wikipedia article" 
    say $chan "!google fubar: Returns first google result" 
    say $chan "oh shit: whaddup?"
fi

if has "$allmsg" "^$BOTNAME:? !?source$" ; then 
    say $chan "Check me out at https://github.com/ReevesBot/dat_bot"
fi
