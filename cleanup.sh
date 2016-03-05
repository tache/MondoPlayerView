#!/bin/sh

echo "Cleaning up..."
sleep 1
/bin/rm -Rf docs
/bin/rm -Rf Pods
/bin/rm -Rf Podfile.lock
/bin/rm -Rf MondoPlayerView.xcworkspace
# /bin/rm -Rf MondoPlayerView.xcodeproj/xcuserdata

# Clean up the custom attributes
find . -name '*.DS_Store' -print -type f -delete

# Clean up the extended attributes
xattr -vcr ./MondoPlayerView ./MondoPlayerTest  ./MondoPlayerTestTests  ./MondoPlayerViewTests Gemfile* *.xcodeproj Podfile* *.md *.sh 

echo "Done."
