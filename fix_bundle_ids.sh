#!/bin/bash

# FFmpegKit Bundle ID Fix Script
# This script fixes the bundle identifier collision issue in FFmpegKit

echo "🔧 Starting FFmpegKit Bundle ID Fix..."

# Function to replace bundle ID in a file
replace_bundle_id() {
    local file="$1"
    local old_id="$2"
    local new_id="$3"
    
    if grep -q "$old_id" "$file"; then
        sed -i '' "s/$old_id/$new_id/g" "$file"
        echo "✅ Fixed: $file"
    fi
}

# Define the mappings
declare -A bundle_mappings=(
    ["libshaderc_combined"]="com.iliasak91.ffmpegkit.libshaderc_combined"
    ["libfontconfig"]="com.iliasak91.ffmpegkit.libfontconfig"
    ["gmp"]="com.iliasak91.ffmpegkit.gmp"
    ["gnutls"]="com.iliasak91.ffmpegkit.gnutls"
    ["hogweed"]="com.iliasak91.ffmpegkit.hogweed"
    ["lcms2"]="com.iliasak91.ffmpegkit.lcms2"
    ["libass"]="com.iliasak91.ffmpegkit.libass"
    ["Libavcodec"]="com.iliasak91.ffmpegkit.libavcodec"
    ["Libavdevice"]="com.iliasak91.ffmpegkit.libavdevice"
    ["Libavfilter"]="com.iliasak91.ffmpegkit.libavfilter"
    ["Libavformat"]="com.iliasak91.ffmpegkit.libavformat"
    ["Libavutil"]="com.iliasak91.ffmpegkit.libavutil"
    ["Libswresample"]="com.iliasak91.ffmpegkit.libswresample"
    ["Libswscale"]="com.iliasak91.ffmpegkit.libswscale"
    ["nettle"]="com.iliasak91.ffmpegkit.nettle"
    ["libfribidi"]="com.iliasak91.ffmpegkit.libfribidi"
    ["libfreetype"]="com.iliasak91.ffmpegkit.libfreetype"
    ["libsmbclient"]="com.iliasak91.ffmpegkit.libsmbclient"
    ["libsrt"]="com.iliasak91.ffmpegkit.libsrt"
    ["libbluray"]="com.iliasak91.ffmpegkit.libbluray"
    ["libdav1d"]="com.iliasak91.ffmpegkit.libdav1d"
    ["libplacebo"]="com.iliasak91.ffmpegkit.libplacebo"
    ["libzvbi"]="com.iliasak91.ffmpegkit.libzvbi"
    ["MoltenVK"]="com.iliasak91.ffmpegkit.moltenvk"
    ["libharfbuzz"]="com.iliasak91.ffmpegkit.libharfbuzz"
    ["libmpv"]="com.iliasak91.ffmpegkit.libmpv"
)

old_bundle_id="com.kintan.ksplayer.libshaderc-combined"

# Process each framework
for framework in "${!bundle_mappings[@]}"; do
    new_bundle_id="${bundle_mappings[$framework]}"
    
    echo "🔧 Processing $framework.xcframework..."
    
    # Find all Info.plist files for this framework
    find ./Sources -path "*$framework.xcframework*" -name "Info.plist" | while read -r file; do
        replace_bundle_id "$file" "$old_bundle_id" "$new_bundle_id"
    done
done

echo ""
echo "🎉 Bundle ID fix completed!"
echo "📊 Summary:"
echo "   - Old bundle ID: $old_bundle_id"
echo "   - Frameworks processed: ${#bundle_mappings[@]}"
echo ""
echo "🔍 Verifying changes..."

# Verify no old bundle IDs remain
remaining_old_ids=$(grep -r "$old_bundle_id" ./Sources/ 2>/dev/null | wc -l)
if [ "$remaining_old_ids" -eq 0 ]; then
    echo "✅ No old bundle IDs found - all fixed!"
else
    echo "⚠️  Found $remaining_old_ids remaining old bundle IDs"
    grep -r "$old_bundle_id" ./Sources/ 2>/dev/null
fi

echo ""
echo "🚀 Ready to commit and push changes!" 