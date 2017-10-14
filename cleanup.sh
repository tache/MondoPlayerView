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
SHORT_ARGS=htv
# list long forms here
LONG_ARGS=help,tags,verbose
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
            echo "    -t,--tags                      Clean up git tags too"
            echo "    -v,--verbose                   Print verbose messages"
            exit 0
            ;;
        -t|--tags) opt_tags=true; shift;;
        -v|--verbose) opt_verbose=true; shift;;
        --) shift; break;;
        *) echo "UNKNOWN ERROR!"; exit 3;;
    esac
done
################################################
# GNISRAP ENIL DNAMMOC

if [ "$opt_verbose" == true ]; then
	echo "Removing docs, Pods, Podfile.lock, workspace"
fi
sleep 1
/bin/rm -Rf docs
/bin/rm -Rf Pods
/bin/rm -Rf Podfile.lock
/bin/rm -Rf MondoPlayerView.xcworkspace
/bin/rm -rf ./DerivedData

if [ "$opt_verbose" == true ]; then
	echo "Clean up the custom attributes"
fi
find ./ -name '*.DS_Store' -print -type f -delete

if [ "$opt_verbose" == true ]; then
	echo "Clean up the extended attributes"
fi
xattr -vcr ./MondoPlayerViewTests Gemfile* *.xcodeproj Podfile* *.txt *.md *.sh

if [ "$opt_tags" == true ]; then
	if [ "$opt_verbose" == true ]; then
		echo "Cleaning up git tags"
	fi
	git tag -d $(git tag)
	git fetch origin --tags
fi

echo "${GREEN}It's Clean${COLOR_RESET}"