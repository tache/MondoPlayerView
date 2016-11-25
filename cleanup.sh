#!/bin/sh

echo "Cleaning up..."
sleep 1
/bin/rm -Rf docs
# /bin/rm -Rf MondoPlayerView.xcodeproj/xcuserdata

# Clean up the custom attributes
find ./ -name '*.DS_Store' -print -type f -delete

# Clean up the extended attributes
xattr -vcr ./MondoPlayerView ./MondoPlayerView Gemfile* setup.sh cleanup.sh *.xcodeproj *md

echo "Done."
