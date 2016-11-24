#!/bin/sh

echo "Starting..."

echo "Installing bundled dependencies..."
bundle install

echo "Rebuilding Pods and workspace..."
pod install

echo "Open XCode Workspace..."
sleep 1
open MondoPlayerView.xcworkspace

echo "Done."
