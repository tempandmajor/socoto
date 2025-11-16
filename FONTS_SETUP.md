# Custom Fonts Setup

This project uses **Space Grotesk** and **Inter** fonts for a modern, professional typography system.

## Required Font Files

### Space Grotesk
Download from: https://fonts.google.com/specimen/Space+Grotesk

Required weights:
- `SpaceGrotesk-Medium.ttf` (500)
- `SpaceGrotesk-SemiBold.ttf` (600)
- `SpaceGrotesk-Bold.ttf` (700)

### Inter
Download from: https://fonts.google.com/specimen/Inter

Required weights:
- `Inter-Regular.ttf` (400)
- `Inter-Medium.ttf` (500)
- `Inter-SemiBold.ttf` (600)

## Installation Steps

### 1. Add Font Files to Project

1. Download the font files from the links above
2. In Xcode, drag the `.ttf` files into the project navigator
3. Make sure "Copy items if needed" is checked
4. Add to target: **Socoto**

### 2. Register Fonts in Info.plist

Add the following to `Info.plist`:

```xml
<key>UIAppFonts</key>
<array>
    <string>SpaceGrotesk-Medium.ttf</string>
    <string>SpaceGrotesk-SemiBold.ttf</string>
    <string>SpaceGrotesk-Bold.ttf</string>
    <string>Inter-Regular.ttf</string>
    <string>Inter-Medium.ttf</string>
    <string>Inter-SemiBold.ttf</string>
</array>
```

### 3. Verify Installation

Run this code in a preview or at app launch:

```swift
// Print all available fonts
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) Font names: \(names)")
}
```

Look for:
- Family: **Space Grotesk**
- Family: **Inter**

## Usage

The fonts are already configured in `DesignTokens.swift`:

```swift
// Headlines use Space Grotesk
Text("Headline")
    .headlineLarge() // Space Grotesk SemiBold, 32pt

// Body text uses Inter
Text("Body text")
    .bodyMedium() // Inter Regular, 16pt

// Buttons use Space Grotesk uppercase
Text("Button Text")
    .buttonLarge() // Space Grotesk SemiBold, 16pt, UPPERCASE
```

## Typography Scale

| Style | Font | Size | Weight | Tracking | Use Case |
|-------|------|------|--------|----------|----------|
| Display Large | Space Grotesk | 56pt | SemiBold | -0.04 | Hero headlines |
| Display Medium | Space Grotesk | 48pt | SemiBold | -0.04 | Page titles |
| Display Small | Space Grotesk | 40pt | SemiBold | -0.04 | Section headers |
| Headline Large | Space Grotesk | 32pt | SemiBold | -0.04 | Main headings |
| Headline Medium | Space Grotesk | 28pt | SemiBold | -0.04 | Sub-headings |
| Headline Small | Space Grotesk | 24pt | SemiBold | -0.04 | Card titles |
| Title Large | Space Grotesk | 20pt | SemiBold | -0.02 | List headers |
| Title Medium | Space Grotesk | 18pt | Medium | -0.02 | Sub-sections |
| Title Small | Space Grotesk | 16pt | Medium | -0.02 | Labels |
| Body Large | Inter | 18pt | Regular | 0 | Long-form content |
| Body Medium | Inter | 16pt | Regular | 0 | Default body text |
| Body Small | Inter | 14pt | Regular | 0 | Secondary text |
| Label Large | Inter | 14pt | Medium | 0.01 | Form labels |
| Label Medium | Inter | 12pt | Medium | 0.01 | Metadata |
| Label Small | Inter | 11pt | Medium | 0.02 | Captions |
| Button Large | Space Grotesk | 16pt | SemiBold | 0.05 | Primary actions |
| Button Medium | Space Grotesk | 14pt | SemiBold | 0.05 | Secondary actions |
| Button Small | Space Grotesk | 12pt | SemiBold | 0.05 | Tertiary actions |

## Fallback Fonts

If custom fonts are not installed, the system falls back to:
- **Space Grotesk** → SF Pro Rounded
- **Inter** → SF Pro

This ensures the app works even without custom fonts, though with reduced visual fidelity.

## Dynamic Type Support

For accessibility, consider implementing dynamic type scaling:

```swift
extension Font {
    static func spaceGrotesk(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("SpaceGrotesk-\(weight.name)", size: size, relativeTo: .body)
    }

    static func inter(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("Inter-\(weight.name)", size: size, relativeTo: .body)
    }
}
```

## Troubleshooting

### Font not displaying
1. Check that font files are in **Copy Bundle Resources** (Build Phases)
2. Verify font names in Info.plist match the actual file names exactly
3. Font family names may differ from file names - use the code above to verify

### Wrong font weight
Ensure you're using the correct postscript name:
- `SpaceGrotesk-Medium` (not `SpaceGroteskMedium`)
- `Inter-Regular` (not `InterRegular`)

## License

- **Space Grotesk**: Open Font License (OFL)
- **Inter**: Open Font License (OFL)

Both fonts are free for commercial use.
