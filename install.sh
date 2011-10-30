#!/bin/bash

all_files=(`ls -d .*`);
ignored_files=(. .. .git);

for f in "${all_files[@]}"; do
    ignored=;
    for g in "${ignored_files[@]}"; do
        if [ "$f" == "$g" ]; then
            ignored=1;
            break;
        fi;
    done;

    if [ -z "$ignored" ]; then
        ln -s "$f" "$HOME";
    fi;
done;

