#!/bin/sh

RED=$(printf "\033[1;31m")
GREEN=$(printf "\033[1;32m")
COLOR_RESET=$(printf "\033[0m")

echo "Updating app..."
bundle update
pod update
sleep 1
open MondoPlayerView.xcworkspace

echo "${GREEN}It's Updated${COLOR_RESET}"

