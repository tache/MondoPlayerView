#!/bin/sh

export COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=YES

echo "Starting..."

echo "Rebuilding Pods and workspace..."
bundle install

echo "Rebuilding Pods and workspace..."
pod install

echo "Open Workspace..."
sleep 1
open MondoPlayerView.xcworkspace

echo "Done."

