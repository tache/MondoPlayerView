#!/bin/sh

echo "Starting..."

echo "Installing bundled dependencies..."
bundle install

echo "Open XCode Workspace..."
sleep 1
open MondoPlayerView.xcworkproj

echo "Done."
