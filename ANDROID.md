## Android Development in WSL2

### Environment Layout
- **Source code, JDK 17, Gradle**: Run inside WSL2
- **Android SDK, emulator, ADB server**: Run on Windows
- **Android SDK location**: `F:\_android-sdk` (WSL path: `/mnt/f/_android-sdk`)
- **ANDROID_HOME**: `/mnt/f/_android-sdk` (set in `~/.bashrc`)
- **ADB**: Available in WSL PATH via `/mnt/f/_android-sdk/platform-tools` (configured in `~/.bashrc`)
- **Available AVDs**: `Medium_Phone_API_36.1`, `Pixel_8a`
- **SDK versions**: API 36, Build-Tools 35.0.0 and 36.1.0

### Networking (NAT Mode)
WSL2 on Windows 10 uses NAT networking (`networkingMode=mirrored` requires Windows 11 22H2+). This means:
- WSL2 gets its own IP on a virtual subnet (e.g. `172.19.x.x`)
- Windows and WSL2 cannot share `localhost`
- Get the WSL2 IP with: `hostname -I | awk '{print $1}'`
- ADB works without any networking workarounds — `adb.exe` runs on the Windows side and talks to the emulator directly

### Running the Emulator
The Android emulator runs on **Windows**, not inside WSL2. Launch it from:
- Android Studio on Windows, or
- Command line: `cmd.exe /c "start F:\_android-sdk\emulator\emulator.exe -avd <avd_name>"`
- List AVDs: `cmd.exe /c "F:\_android-sdk\emulator\emulator.exe -list-avds"`

### ADB Usage from WSL2
ADB commands run from WSL2 talk to the Windows ADB server:
- `adb.exe devices` — list connected devices/emulators
- `adb.exe install app.apk` — install an APK
- `adb.exe shell am start -n <package>/<activity>` — launch an app
- `adb.exe logcat` — view device logs

The Windows ADB server manages the actual device connections. WSL2 calls `adb.exe` transparently via the PATH entry.

### Build & Deploy Workflow (Verified Working)
1. Start emulator: `cmd.exe /c "start F:\_android-sdk\emulator\emulator.exe -avd Pixel_8a"`
2. Confirm emulator visible: `adb.exe devices` (should show `emulator-5554 device`)
3. Build: `./gradlew assembleDebug`
4. Install: `adb.exe install app/build/outputs/apk/debug/app-debug.apk`
5. Launch: `adb.exe shell am start -n com.playground.hello/.MainActivity`

### Dev Server Access (WSL2 → Emulator)
When running a dev server in WSL2 that the emulator needs to reach:
1. Bind the server to `0.0.0.0` (not `localhost`)
2. From the Android emulator, use `10.0.2.2` to reach the Windows host
3. Set up port forwarding from Windows to WSL2:
   ```
   # Run in PowerShell as Admin on Windows:
   netsh interface portproxy add v4tov4 listenport=<PORT> listenaddress=0.0.0.0 connectport=<PORT> connectaddress=<WSL_IP>
   ```
4. The emulator can then reach your WSL2 dev server at `10.0.2.2:<PORT>`

To remove a port forward:
```
netsh interface portproxy delete v4tov4 listenport=<PORT> listenaddress=0.0.0.0
```

### ADB Touch Input & Screenshot Coordinate Scaling

**Screenshots are scaled down from device resolution.** The emulator runs at 1080x2400 but `adb exec-out screencap` images displayed in this context are scaled (e.g. to 900x2000). **Do NOT estimate tap coordinates from screenshot pixel positions** — they will be wrong.

**Always use `uiautomator dump` to get real element bounds:**
```bash
adb.exe shell uiautomator dump /sdcard/ui.xml
adb.exe shell cat /sdcard/ui.xml | grep -o 'text="[^"]*"[^/]*bounds="[^"]*"' | head -20
```
This gives exact device-coordinate bounds like `bounds=[42,1748][285,1811]`. Tap the center of those bounds.

**Touch input commands:**
- `adb.exe shell input tap X Y` — tap at device coordinates
- `adb.exe shell input swipe X Y X Y 150` — long press (zero-distance swipe over 150ms)
- `adb.exe exec-out screencap -p > file.png` — screenshot

**Common pitfall with ModalBottomSheet:** Sheet content renders at device coordinates far below what the scaled screenshot suggests. A list item that appears at y=500 in a screenshot may actually be at y=1500+ in device coordinates. Always use `uiautomator dump`.

### Gradle Builds from WSL2
- `ANDROID_HOME=/mnt/f/_android-sdk` is set in `~/.bashrc`
- Gradle wrapper (`./gradlew`) is in the project root
- Gradle will auto-download missing SDK components (build-tools, platforms) as needed
- Kotlin/Compose project uses AGP 8.9.1, Kotlin 2.1.10, Compose BOM 2025.01.01
