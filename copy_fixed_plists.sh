#!/bin/bash

# Script to copy fixed Info.plist files from DerivedData to FFmpegKit repository
# This script finds all Info.plist files in DerivedData that have been fixed
# and copies them to the corresponding locations in the FFmpegKit repo

echo "🔍 Searching for fixed Info.plist files in DerivedData..."

# Find DerivedData directory
DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"

# Find FFmpegKit in DerivedData
FFMPEGKIT_CACHE_DIR=$(find "$DERIVED_DATA_DIR" -name "ffmpeg-kit*" -type d 2>/dev/null | head -1)

if [ -z "$FFMPEGKIT_CACHE_DIR" ]; then
    echo "❌ Could not find FFmpegKit in DerivedData"
    echo "   Make sure you have built your project with FFmpegKit dependency"
    exit 1
fi

echo "📁 Found FFmpegKit cache at: $FFMPEGKIT_CACHE_DIR"

# Find all Info.plist files in the cache that have the new bundle ID pattern
echo "🔍 Searching for fixed Info.plist files..."

# Find all Info.plist files that contain the new bundle ID pattern
FIXED_PLISTS=$(find "$FFMPEGKIT_CACHE_DIR" -name "Info.plist" -exec grep -l "com.iliasak91.ffmpegkit" {} \; 2>/dev/null)

if [ -z "$FIXED_PLISTS" ]; then
    echo "❌ No fixed Info.plist files found in cache"
    echo "   Make sure you have manually fixed the bundle IDs in DerivedData first"
    exit 1
fi

echo "✅ Found $(echo "$FIXED_PLISTS" | wc -l | tr -d ' ') fixed Info.plist files"

# Counter for copied files
copied_count=0

# Process each fixed plist file
echo "$FIXED_PLISTS" | while read -r cache_plist; do
    # Extract the relative path from the cache
    relative_path=$(echo "$cache_plist" | sed "s|$FFMPEGKIT_CACHE_DIR/||")
    
    # Find the corresponding path in the repository
    # The structure should be similar: Sources/<framework>.xcframework/...
    repo_plist="./Sources/$(echo "$relative_path" | sed -n 's|.*/\([^/]*\.xcframework\)/.*|\1|p')"
    
    if [ -n "$repo_plist" ] && [ -d "$repo_plist" ]; then
        # Find the exact matching file in the repo
        framework_name=$(echo "$relative_path" | sed -n 's|.*/\([^/]*\)\.xcframework/.*|\1|p')
        
        if [ -n "$framework_name" ]; then
            # Construct the target path in the repo
            target_path="./Sources/${framework_name}.xcframework/$(echo "$relative_path" | sed -n "s|.*${framework_name}\.xcframework/||p")"
            
            if [ -f "$target_path" ]; then
                echo "📋 Copying: $cache_plist"
                echo "   To: $target_path"
                
                # Copy the file
                if cp "$cache_plist" "$target_path"; then
                    echo "   ✅ Copied successfully"
                    copied_count=$((copied_count + 1))
                else
                    echo "   ❌ Failed to copy"
                fi
            else
                echo "⚠️  Target file not found: $target_path"
            fi
        fi
    fi
done

echo ""
echo "🎉 Copy operation completed!"
echo "📊 Files copied: $copied_count"

echo ""
echo "🔍 Verifying changes in repository..."
remaining_old_ids=$(grep -r "com.kintan.ksplayer.libshaderc-combined" ./Sources --include="*.plist" | wc -l)
echo "⚠️  Found $remaining_old_ids remaining old bundle IDs"

if [ "$remaining_old_ids" -gt 0 ]; then
    echo "📋 Remaining files with old bundle IDs:"
    grep -r "com.kintan.ksplayer.libshaderc-combined" ./Sources --include="*.plist"
else
    echo "✅ All bundle IDs have been fixed!"
fi

echo ""
echo "🚀 Ready to commit and push changes!" 