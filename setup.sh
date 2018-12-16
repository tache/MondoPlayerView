#!/bin/sh

# COMMAND LINE PARSING
################################################
# REF: http://misc.flogisoft.com/bash/tip_colors_and_formatting
RED=$(printf "\033[1;31m")
GREEN=$(printf "\033[1;32m")
COLOR_RESET=$(printf "\033[0m")
getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "${RED}I’m sorry, `getopt --test` failed in this environment - command line args WON'T WORK!${COLOR_RESET}"
    echo "If you're on a mac you need to:"
    echo "> brew install gnu-getopt"
    echo "> brew link --force gnu-getopt"
fi
# list short args here
SHORT_ARGS=hqv
# list long forms here
LONG_ARGS=help,quick,verbose
# -temporarily store output to be able to check for errors
# -activate advanced mode getopt quoting e.g. via “--options”
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--help)
            echo "Usage:"
            echo "    -h,--help                      Display this help message."
            echo "    -q,--quick                     Quick execution (no repo updates)"
            echo "    -v,--verbose                   Print verbose messages"
            exit 0
            ;;
        -q|--quick) opt_quick=true; shift;;
        -v|--verbose) opt_verbose=true; shift;;
        --) shift; break;;
        *) echo "UNKNOWN ERROR!"; exit 3;;
    esac
done
################################################
# GNISRAP ENIL DNAMMOC


export COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=YES

echo "Setting up your development environment and starting xcode..."

# note: this will upgrade to the latest, maybe need to stay at a fixed bundler version?
# if ! gem list -i bundler > /dev/null 2>&1; then
# echo "Installing Bundler"
# gem install bundler
# fi

# note: This installs whatever is defined in the Gemfile and Gemfile.lock
# ensuring that our env is the same versions as desired for all of our environments
if [ "$opt_verbose" == true ]; then
    echo "Installing bundled dependencies..."
fi
bundle install

echo "Rebuilding Pods and workspace..."
if [ "$opt_quick" != true ]; then
    if [ "$opt_verbose" == true ]; then
        echo "Updating pod repository"
    fi
    pod repo update
fi

if [ "$opt_verbose" == true ]; then
    echo "Open XCode Workspace..."
fi
sleep 1
open MondoPlayerView.xcodeproj

echo "${GREEN}It's Setup${COLOR_RESET}"

echo "Done."
