#!/bin/bash
set -x 
users=("team-a" "team-b" "team-c")
for user in "${users[@]}" ; do 
    for ns in "${users[@]}" ; do 
        kubectl get pods --as=$user -n $ns
    done
done
