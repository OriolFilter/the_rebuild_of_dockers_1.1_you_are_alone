#!/bin/bash

#########################################
# Script intended for dockerfiles usage #
#########################################


##############
# COLOR VARS #
##############

COLOR_DEFAULT='\e[39m'
COLOR_RED='\e[91m'
COLOR_GREEN='\e[92m'
COLOR_BLUE='\e[34m'
COLOR_YELLOW='\e[93m'

########
# MAIN #
########


# MASTER_FILE VARS
#PASSWD_MASTER_FILE='/etc/passwd'
#GROUP_MASTER_FILE='/etc/group'
#SHADOW_MASTER_FILE='/etc/shadow'
PASSWD_MASTER_FILE='./passwd'
GROUP_MASTER_FILE='./group'
SHADOW_MASTER_FILE='./shadow'

# REGEX_FILE VARS
PASSWD_FILE_REGEX='passwd_file*'
GROUP_FILE_REGEX='group_file*'
SHADOW_FILE_REGEX='shadow_file*'


# Get Files Array
PASSWD_FILE_LIST=$(find -name "$PASSWD_FILE_REGEX")
GROUP_FILE_LIST=$(find -name "$GROUP_FILE_REGEX")
SHADOW_FILE_LIST=$(find -name "$SHADOW_FILE_REGEX")

echo ">$PASSWD_FILE_LIST<"
echo ">$GROUP_FILE_LIST<"
echo ">$SHADOW_FILE_LIST<"

# Append password
if [ -z "$PASSWD_FILE_LIST" ]
then
while IFS= read -r file; do
    echo "${COLOR_BLUE}#${COLOR_DEFAULT} ${COLOR_GREEN}APPEND${COLOR_DEFAULT} ${COLOR_RED}->${COLOR_DEFAULT} ${COLOR_YELLOW}$file${COLOR_DEFAULT}"
    printf "$(cat $file)\n" | tee -a "$PASSWD_MASTER_FILE" # &> /dev/null
    file=''
  done <<< "$PASSWD_FILE_LIST"
fi

# Append group
if [ -z "$GROUP_FILE_LIST" ]
then
  while IFS= read -r file; do
    echo "${COLOR_BLUE}#${COLOR_DEFAULT} ${COLOR_GREEN}APPEND${COLOR_DEFAULT} ${COLOR_RED}->${COLOR_DEFAULT} ${COLOR_YELLOW}$file${COLOR_DEFAULT}"
    printf "$(cat $file)\n" | tee -a "$GROUP_MASTER_FILE" # &> /dev/null
    file=''
  done <<< "$GROUP_FILE_LIST"
fi

# Append shadow
if [ !-z "$PASSWD_FILE_LIST" ]
then
  while IFS= read -r file; do
    echo "${COLOR_BLUE}#${COLOR_DEFAULT} ${COLOR_GREEN}APPEND${COLOR_DEFAULT} ${COLOR_RED}->${COLOR_DEFAULT} ${COLOR_YELLOW}$file${COLOR_DEFAULT}"
    printf "$(cat $file)\n" | tee -a "$SHADOW_MASTER_FILE" # &> /dev/null
  done <<< "$SHADOW_FILE_LIST"
  file=''
fi