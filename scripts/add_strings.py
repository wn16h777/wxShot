#!/usr/bin/env python3
"""Adds wxShot-specific strings to every Resources/<lang>.lproj/Localizable.strings.
Idempotent: existing keys are left untouched. Run from the repo root: python3 scripts/add_strings.py"""
import re, pathlib

LANGS = ["en", "zh-Hans"]

S = {
 "wxSettingsWindowTitle": {"en": "wxShot Settings", "zh-Hans": "wxShot 设置"},
 "wxSectionShortcut": {"en": "Screenshot shortcut", "zh-Hans": "截图快捷键"},
 "wxShortcutDefaultNote": {"en": "The default ⌃⌘A is the same as WeChat's screenshot shortcut, so your habits carry over", "zh-Hans": "默认 ⌃⌘A，与微信截图习惯一致，无需重新适应"},
 "wxSectionWeChat": {"en": "When WeChat is open", "zh-Hans": "微信打开时"},
 "wxWeChatStatusNotRunning": {"en": "WeChat is not running", "zh-Hans": "微信未运行"},
 "wxWeChatStatusLoginScreen": {"en": "WeChat is open but not signed in", "zh-Hans": "微信已打开但未登录"},
 "wxWeChatStatusLoggedIn": {"en": "WeChat is signed in", "zh-Hans": "微信已登录"},
 "wxShortcutOwner": {"en": "Right now the shortcut is handled by %@", "zh-Hans": "当前快捷键由 %@ 响应"},
 "wxOwnerWeChat": {"en": "WeChat", "zh-Hans": "微信"},
 "wxSectionGeneral": {"en": "General", "zh-Hans": "通用"},
 "wxPermissionStatusGranted": {"en": "Screen recording is allowed", "zh-Hans": "已允许屏幕录制"},
 "wxPermissionStatusMissing": {"en": "Screen recording is not allowed yet", "zh-Hans": "尚未允许屏幕录制"},
 "wxOpenSystemSettings": {"en": "Open System Settings", "zh-Hans": "打开系统设置"},
 "wxWelcomeTitle": {"en": "Welcome to wxShot", "zh-Hans": "欢迎使用 wxShot"},
 "wxWelcomeBody": {"en": "The WeChat-style screenshot that works whether or not WeChat is signed in. It runs quietly in the background and answers one shortcut", "zh-Hans": "微信同款截图体验，不用登录微信也能用。静静待在后台，只响应一个快捷键"},
 "wxStepPermission": {"en": "1  Allow screen recording", "zh-Hans": "1  允许屏幕录制"},
 "wxStepPermissionNote": {"en": "macOS requires this for every screenshot app. wxShot only looks at the area you select and never sends it anywhere", "zh-Hans": "这是 macOS 对所有截图软件的要求。wxShot 只处理你框选的区域，不会上传任何画面"},
 "wxStepShortcut": {"en": "2  Press %@ anywhere to capture", "zh-Hans": "2  在任何界面按 %@ 即可截图"},
 "wxStepShortcutNote": {"en": "Drag to select, double-click or press Return to copy, press Esc to cancel. Open wxShot again any time to change settings", "zh-Hans": "拖动框选，双击或回车复制，Esc 取消。随时再次打开 wxShot 即可修改设置"},
 "wxStartButton": {"en": "Start Using wxShot", "zh-Hans": "开始使用"},
 "wxConfirmDiscard": {"en": "Press again to exit — your edits will be lost", "zh-Hans": "再按一次退出，当前标注将丢失"},
 "wxTipSettings": {"en": "Settings", "zh-Hans": "设置"},
 "wxTipShare": {"en": "Share", "zh-Hans": "分享"},
 "wxLensCopyHint": {"en": "Press ⌘+C to copy the color", "zh-Hans": "按 ⌘+C 复制色值"},
}

root = pathlib.Path(__file__).resolve().parent.parent
for lang in LANGS:
    path = root / "Resources" / f"{lang}.lproj" / "Localizable.strings"
    text = path.read_text(encoding="utf-8")
    existing = set(re.findall(r'^"([^"]+)"\s*=', text, flags=re.M))
    add = []
    for key, vals in S.items():
        if key in existing:
            continue
        value = vals[lang].replace('"', '\\"')
        add.append(f'"{key}" = "{value}";')
    if add:
        text = text.rstrip("\n") + "\n\n/* wxShot */\n" + "\n".join(add) + "\n"
    path.write_text(text, encoding="utf-8")
    print(lang, "added", len(add))
