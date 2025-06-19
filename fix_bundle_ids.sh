#!/bin/bash

# Script to fix bundle IDs in FFmpegKit frameworks
# This script will change all bundle IDs from "com.kintan.ksplayer.libshaderc-combined" 
# to "com.iliasak91.ffmpegkit.[framework-name]"

echo "Fixing bundle IDs in FFmpegKit frameworks..."

# Find all Info.plist files in xcframework directories
find ./Sources -name "Info.plist" -path "*/xcframework/*" | while read -r plist_file; do
    # Extract framework name from path
    framework_name=$(echo "$plist_file" | sed -n 's/.*\/\([^\/]*\)\.framework\/Info\.plist/\1/p')
    
    if [ -n "$framework_name" ]; then
        # Create new bundle ID
        new_bundle_id="com.iliasak91.ffmpegkit.$(echo "$framework_name" | tr '[:upper:]' '[:lower:]')"
        
        echo "Fixing $framework_name: $new_bundle_id"
        
        # Update the bundle ID
        plutil -replace CFBundleIdentifier -string "$new_bundle_id" "$plist_file"
    fi
done

echo "Bundle ID fix completed!" 