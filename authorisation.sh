#!/bin/bash

users=("team-a" "team-b" "team-c")
for user in "${users[@]}"
do
    echo $user
done




# list_a=( 1 2 )
# list_b=( 3 4 )

# for key in "${list_a[@]}" "${list_b[@]}"; do
#   echo "the key is: $key"
# done