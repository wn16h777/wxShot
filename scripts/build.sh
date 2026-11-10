#!/bin/bash
# 构建 wxShot.app（可选通用二进制 / Developer ID 签名 / DMG）。
# 用法: scripts/build.sh [--universal] [--sign "Developer ID Application: …"] [--dmg]
# 默认：当前架构、ad-hoc 签名（本机可运行，不能分发）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"

UNIVERSAL=0; SIGN="-"; DMG=0
while [ $# -gt 0 ]; do
  case "$1" in
    --universal) UNIVERSAL=1;;
    --sign) SIGN="$2"; shift;;
    --dmg) DMG=1;;
    *) echo "未知参数: $1"; exit 2;;
  esac; shift
done

NAME="wxShot"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Sources/wxShot/App/Info.plist)"
BUILD_ARGS=(-c release --product "$NAME")
[ "$UNIVERSAL" = 1 ] && BUILD_ARGS+=(--arch arm64 --arch x86_64)

echo "▶ swift build (${BUILD_ARGS[*]})"
swift build "${BUILD_ARGS[@]}"
BIN="$(swift build "${BUILD_ARGS[@]}" --show-bin-path)"

OUT="dist"
APP="$OUT/$NAME.app"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN/$NAME" "$APP/Contents/MacOS/$NAME"
cp Sources/wxShot/App/Info.plist "$APP/Contents/Info.plist"
[ -n "${BUILD_NUMBER:-}" ] && /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP/Contents/Info.plist"

# 本地化
for lproj in Resources/*.lproj; do cp -R "$lproj" "$APP/Contents/Resources/"; done

echo "▶ 图标"
[ -f dist/AppIcon.icns ] || swift scripts/make_icon.swift "viewfinder" "messages" dist/AppIcon.icns
cp dist/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

echo "▶ 签名 ($SIGN)"
if [ "$SIGN" = "-" ]; then
  codesign --force --deep -s - "$APP"
else
  # Secure timestamps are for Developer ID distribution; Apple Development
  # (local) signing skips them — the timestamp service is often unreachable
  # behind a proxy and a dev cert needs no timestamp.
  TS=""; [[ "$SIGN" == "Developer ID"* ]] && TS="--timestamp"
  codesign --force --deep --options runtime $TS --entitlements scripts/entitlements.plist -s "$SIGN" "$APP"
fi
codesign --verify --deep --strict "$APP"
echo "   架构: $(lipo -archs "$APP/Contents/MacOS/$NAME")"

if [ "$DMG" = 1 ]; then
  STAGE="$OUT/.dmg-stage"; rm -rf "$STAGE"; mkdir -p "$STAGE"; cp -R "$APP" "$STAGE/"; ln -s /Applications "$STAGE/Applications"
  DMG_PATH="$OUT/$NAME.dmg"; rm -f "$DMG_PATH"
  hdiutil create -volname "$NAME" -srcfolder "$STAGE" -ov -format UDZO "$DMG_PATH" >/dev/null
  rm -rf "$STAGE"
  [ "$SIGN" != "-" ] && codesign --force --sign "$SIGN" --timestamp "$DMG_PATH"
  echo "▶ DMG: $DMG_PATH ($(du -h "$DMG_PATH" | cut -f1))   版本 $VERSION"
fi
echo "✅ $APP ($(du -sh "$APP" | cut -f1))"
