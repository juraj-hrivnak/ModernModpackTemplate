#!/bin/bash

cd ../
manifest="pax/modpack/manifest.json"

branch=$(git rev-parse --abbrev-ref HEAD)
previous_commit=$(git log -n 1 --skip 1 --pretty=format:"%h" -- $manifest)
latest_commit=$(git log -n 1 --pretty=format:"%h" $branch -- $manifest)
latest_tagged_commit=$(git rev-list --tags --max-count=1)
latest_tag=$(git describe --tags --abbrev=0)

echo "branch: $branch"
echo "previous commit: $previous_commit"
echo "latest commit: $latest_commit"
echo "latest tagged commit: $latest_tagged_commit"
echo "latest tag: $latest_tag"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function mods_added {
    local var1=$(git diff -W $previous_commit $latest_commit -- $manifest)
    local var2=$(echo "$var1" | grep -P -o -z '"files":[\s]*\[\K((?!.)[\s\S]*\}[\s]*\])*' | tr -d '\0')
    local var3=$(echo "$var2" | grep '^+' | grep -P -o '"name":[\s]*"\K[^"]*' | sed -e 's/^/- /')
    if [[ ! -z ""$var3"" ]]; then
        echo -e "${GREEN}Added:"
        echo "$var3"
    fi
}

function mods_removed {
    local var1=$(git diff -W $previous_commit $latest_commit -- $manifest)
    local var2=$(echo "$var1" | grep -P -o -z '"files":[\s]*\[\K((?!.)[\s\S]*\}[\s]*\])*' | tr -d '\0')
    local var3=$(echo "$var2" | grep '^-' | grep -P -o '"name":[\s]*"\K[^"]*' | sed -e 's/^/- /')
    if [[ ! -z ""$var3"" ]]; then
        echo -e "${RED}Removed:"
        echo "$var3"
    fi
}

# | grep -P -o '"files":[\s]*\[\K[^\]]*'
# | grep -P -o '((?<!"files".)[\s\S])*$'
# | grep -P -o '((?<!"files"(.|\s)(.|\s))[\s\S])*\]'
# ((?<!"files"(.|\s)(.|\s))[\s\S])*\]*"name":[\s]*"\K[^"]*.*
# ((?<="files"(.|\s)(.|\s))[\s\S])*
# (?<="files"(.|\s)(.|\s).)[\s\S]*\]
# "files":[\s]*\[\K((?!.)[\s\S]*\}[\s]*\])*

echo -e "x---------------x"
echo -e "|  Mod Changes  |"
mods_added
mods_removed
echo -e "${NC}x---------------x"

# Wait for user response
read -p "Done! Press any key to continue" x
