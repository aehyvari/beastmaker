#!/bin/bash

SCRIPTDIR=$(cd $(dirname $0); pwd)

START_SAMPLE=$SCRIPTDIR/data/F7.mp3
END_SAMPLE=$SCRIPTDIR/data/B.mp3

if [ ! -z $BEASTMAKER_OPENAI_API ]; then
    echo "Downloading your motivational quote from openai"

    quote=$(curl -s https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $BEASTMAKER_OPENAI_API" \
      -d '{
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a sports coach from Switzerland."
          },
          {
            "role": "user",
            "content": "10 word motivational quote for training for climbing"
          }
        ],
        "temperature": 2
        }' |jq '.choices.[].message.content' |sed 's!"\\"\(.*\)\\""!\1!g')
else
    echo "Set BEASTMAKER_OPENAI_API to enable your virtual coach!"
    quote="For what is climbing but an intimate dance between you and the rock"
fi

# Take a random voice
for name in $(say -v '?'  |grep 'en_' |awk '{print $1}'); do
    voices+=("$name");
done
numVoices=${#voices[@]}
randomIdx=$(($RANDOM % $numVoices))

voice=${voices[$randomIdx]}

function s () {
    if [ ! -z $2 ]; then
        say -r $2 -v $voice $1;
    else
        say -v $voice $1
    fi
}

function getMinutesFromSeconds () {
    echo $(($1/60))
}

function getSeconds () {
    echo $(($1%60))
}

holds=(big big medium medium big big)
repetitions=6
sets=7
rest=60
smallRest=3

quickRate=360

echo "$quote"
s "$quote"
sleep 3

for ((j=5; j > 0; j--)) do
    s $j $quickRate &
    sleep 1 &
    wait
done;

for ((k=0; k < ${#holds[@]}; k++)); do
    hold=${holds[$k]}
    s $hold
    echo -n "$hold: "
    s Start
    for ((i=0; i < $repetitions; i++)); do
        echo -n "$i "
        afplay $START_SAMPLE &
        sleep $sets
        afplay $END_SAMPLE &
        if [ $i != $(($repetitions-1)) ]; then
            sleep $smallRest
        fi
    done
    echo
    if [ $k == $((${#holds[@]}-1)) ]; then
        break
    fi
    echo -n "Rest: "
    s "Rest $rest seconds"
    for ((i=$rest; i > 5; i--)); do
        echo -n "$i "
        sleep 1;
    done
    for ((i=5; i > 0; i--)); do
        echo -n "$i ";
        s $i $quickRate &
        sleep 1 &
        wait
    done
    echo
done

totalHangTime=$((${#holds[@]} * $repetitions * $sets))
totalHangMinutes=$(getMinutesFromSeconds $totalHangTime)
totalHangSeconds=$(getSeconds $totalHangTime)

echo Total hang time $totalHangMinutes mins $totalHangSeconds seconds

s "End of exercise.  Total hang time $totalHangMinutes minutes and $totalHangSeconds seconds"
