#!/bin/sh

echo "Cleaning up..."
sleep 1
/bin/rm -Rf docs
/bin/rm -Rf Pods
/bin/rm -Rf Podfile.lock
/bin/rm -Rf MondoPlayer.xcworkspace
# /bin/rm -Rf MondoPlayer.xcodeproj/xcuserdata

# Clean up the custom attributes
find ./ -name '*.DS_Store' -print -type f -delete

# Clean up the extended attributes
xattr -vcr ./MondoPlayerView ./MondoPlayerView Gemfile* setup.sh cleanup.sh *.xcodeproj *md Podfile*

echo "Done."
