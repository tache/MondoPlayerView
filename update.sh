#!/bin/bash

RED="\033[1;31m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"
COLOR_RESET="\033[0m"

printf "\n${GREEN}Updating project ...\n${COLOR_RESET}"

printf "\n${BLUE}Using Xcode: ${COLOR_RESET}"
xcode-select --print-path
printf "\n"

bundle update
printf "\n"

sleep 1
open MondoPlayerView.xcodeproj

printf "${GREEN}\nProject Updated!${COLOR_RESET}"
printf "${BLUE}\n\n-------------------------------------------------------------\n\n${COLOR_RESET}"