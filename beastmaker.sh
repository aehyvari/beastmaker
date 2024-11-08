#!/bin/bash

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

for ((j=5; j > 0; j--)) do
    s $j 360 &
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
        for ((j=0; j < $sets; j++)); do
            echo -ne '\007';
            sleep 1;
        done;
        if [ $i != $(($repetitions-1)) ]; then
            s "Rest $smallRest seconds" &
            sleep $smallRest &
            wait
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
        s $i 360 &
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
