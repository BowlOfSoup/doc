#!/bin/bash

##
# Normal terminal color.
##
readonly colorNormal="\033[0m"

##
# Info terminal color.
##
readonly colorInfo='\033[0;96m'

##
# Success terminal color.
##
readonly colorSuccess='\033[0;92m'

##
# Error terminal color.
##
readonly colorError='\033[0;91m'

##
# Output error text.
#
# @param string
##
function outputError() {
  local text="${1?Missing argument 1 for outputError()}"

  echo -e "${colorError}${text}${colorNormal}"
}

##
# Output success text.
#
# @param string
##
function outputSuccess() {
  local text="${1?Missing argument 1 for outputSuccess()}"

  echo -e "${colorSuccess}${text}${colorNormal}"
}

##
# Output info text.
#
# @param string
##
function outputInfo() {
  local text="${1?Missing argument 1 for outputInfo()}"

  echo -e "${colorInfo}${text}${colorNormal}"
}

##
# Output newline
##
function outputLine() {
  echo -e ""
}

##
# Output affirmation
#
# @param string
##
function outputAffirmation() {
  echo -en "${colorError}${1}${colorNormal} Continue? [y/N]:"
}