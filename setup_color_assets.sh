#!/bin/bash

# Setup Color Assets for Socoto Design System
# This script creates the Asset Catalog color sets

ASSETS_DIR="Socoto/Assets.xcassets"

# Create Colors directory
mkdir -p "$ASSETS_DIR/Colors.xcassets"

# Function to create a color set
create_color_set() {
    local name=$1
    local light_hex=$2
    local dark_hex=$3
    local category=$4

    local dir="$ASSETS_DIR/$category.colorset"
    mkdir -p "$dir"

    # Convert hex to RGB components
    local light_r=$(printf "%d" 0x${light_hex:0:2})
    local light_g=$(printf "%d" 0x${light_hex:2:2})
    local light_b=$(printf "%d" 0x${light_hex:4:2})

    local dark_r=$(printf "%d" 0x${dark_hex:0:2})
    local dark_g=$(printf "%d" 0x${dark_hex:2:2})
    local dark_b=$(printf "%d" 0x${dark_hex:4:2})

    # Create Contents.json
    cat > "$dir/Contents.json" <<EOF
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "$(awk "BEGIN {printf \"%.3f\", $light_b/255}")",
          "green" : "$(awk "BEGIN {printf \"%.3f\", $light_g/255}")",
          "red" : "$(awk "BEGIN {printf \"%.3f\", $light_r/255}")"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "$(awk "BEGIN {printf \"%.3f\", $dark_b/255}")",
          "green" : "$(awk "BEGIN {printf \"%.3f\", $dark_g/255}")",
          "red" : "$(awk "BEGIN {printf \"%.3f\", $dark_r/255}")"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
}

echo "Creating color assets..."

# Surface Colors
create_color_set "Surface" "FFFFFF" "0A0A0A" "Surface/Surface"
create_color_set "SurfacePage" "F8F9FA" "121212" "Surface/SurfacePage"
create_color_set "SurfaceElevated" "FFFFFF" "1E1E1E" "Surface/SurfaceElevated"
create_color_set "SurfaceOverlay" "000000" "000000" "Surface/SurfaceOverlay"

# Ink (Text) Colors
create_color_set "InkPrimary" "0A0A0A" "F8F9FA" "Ink/Primary"
create_color_set "InkSecondary" "4A5568" "A0AEC0" "Ink/Secondary"
create_color_set "InkTertiary" "718096" "718096" "Ink/Tertiary"
create_color_set "InkMuted" "A0AEC0" "4A5568" "Ink/Muted"
create_color_set "InkContrast" "FFFFFF" "FFFFFF" "Ink/Contrast"

# Border Colors
create_color_set "BorderDefault" "E2E8F0" "2D3748" "Border/Default"
create_color_set "BorderSubtle" "F7FAFC" "1A202C" "Border/Subtle"
create_color_set "BorderFocus" "4F46E5" "818CF8" "Border/Focus"

# Brand Colors
create_color_set "BrandPrimary" "4F46E5" "818CF8" "Brand/Primary"
create_color_set "BrandSecondary" "7C3AED" "A78BFA" "Brand/Secondary"
create_color_set "BrandAccent" "EC4899" "F472B6" "Brand/Accent"

# Status Colors - Success
create_color_set "StatusSuccessBackground" "D1FAE5" "064E3B" "Status/SuccessBackground"
create_color_set "StatusSuccessForeground" "059669" "34D399" "Status/SuccessForeground"

# Status Colors - Warning
create_color_set "StatusWarningBackground" "FEF3C7" "78350F" "Status/WarningBackground"
create_color_set "StatusWarningForeground" "D97706" "FBBF24" "Status/WarningForeground"

# Status Colors - Error
create_color_set "StatusErrorBackground" "FEE2E2" "7F1D1D" "Status/ErrorBackground"
create_color_set "StatusErrorForeground" "DC2626" "F87171" "Status/ErrorForeground"

# Status Colors - Info
create_color_set "StatusInfoBackground" "DBEAFE" "1E3A8A" "Status/InfoBackground"
create_color_set "StatusInfoForeground" "2563EB" "60A5FA" "Status/InfoForeground"

# Status Colors - Pending
create_color_set "StatusPendingBackground" "E0E7FF" "312E81" "Status/PendingBackground"
create_color_set "StatusPendingForeground" "6366F1" "A5B4FC" "Status/PendingForeground"

echo "✅ Color assets created successfully!"
echo "📝 Note: Open the project in Xcode to verify the colors"
