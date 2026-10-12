# Disk Inventory X

Disk usage utility for macOS: shows the sizes of files and folders as a graphical
treemap, with statistics by file kind.

Original application © 2003-2022 Tjark Derlien — https://gitlab.com/tderlien/disk-inventory-x

This fork ports Disk Inventory X to current macOS:

  * Native **Apple Silicon** build; the DMG is universal (arm64 + x86_64), macOS 12 or later.
  * No more dependency on the (2018) OmniGroup frameworks: the few classes used
    (toolbar from a `.toolbar` plist, preferences window, split view, Foundation helpers)
    are replaced by small native implementations.
  * 64-bit clean data source methods (`int` return values are unsafe on arm64).
  * Builds with current Xcode; ad-hoc signed.

## Building

Both repositories must be checked out side by side:

```sh
git clone <this repository> disk-inventory-x
git clone <treemapview-framework fork> treemapview-framework   # https://gitlab.com/tderlien/treemapview-framework
cd disk-inventory-x
./make-dmg.sh           # universal Disk Inventory X.app + dist/DiskInventoryX-<version>-macos-arm64-x86_64.dmg
```

Or open `Disk Inventory X.xcworkspace` in Xcode (it builds TreeMapView.framework first).
`ARCHS=arm64 ./make-dmg.sh` builds Apple Silicon only, `SIGN_ID="Developer ID Application: …"` signs with a real identity.

The app is ad-hoc signed: on first launch macOS may refuse to open it; use right click → Open,
or `xattr -dr com.apple.quarantine "/Applications/Disk Inventory X.app"`.

## Credits & License

  * Disk Inventory X and TreeMapView: © Tjark Derlien
  * Apple Silicon / macOS 12+ port: © 2026 letzzar and Claude (Anthropic)
  * Contains code derived from CocoaTech (Path Finder) and the OmniGroup frameworks API.

Disk Inventory X is free software, distributed under the terms of the GNU General Public License
version 3 or later (see `COPYING`).
