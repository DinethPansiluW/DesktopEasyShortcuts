# Windows Easy Scripts

A collection of simple scripts for common Windows tasks, designed for ease of use and quick access.

## Features
- **Shutdown**: Shut down the computer in 5 seconds with countdown.
- **Restart**: Restart the computer in 5 seconds with countdown.
- **Sleep**: Put the computer to sleep in 5 seconds with countdown.
- **Wi-Fi On/Off**: Toggle Wi-Fi status. *Edit script to add your Wi-Fi network name.*
- **Black Screen**: Instantly turn off the screen without sleep or shutdown.
- **Sleep & Screen Timer**: Automatically put the device to sleep and turn off the screen after a set time.
- **Restore Time**: Restore default screen and sleep settings.
- **Schedule Shutdown**: Schedule a shutdown at a specific time.
- **Wi-Fi OFF 7AM**: Automatically turn off Wi-Fi at 7 AM.
- **Display Switch**: Toggle between “PC screen only” and “Extend” modes.
- **Graphic Settings**: Open advanced graphics settings panel.

## Installation
1. Download all scripts and icons.
2. Copy the script folder to the `D:` drive (e.g., `D:\EasyScripts`).
3. Copy the shortcuts (with icons) from the `Shortcuts` folder to your desktop.

## Usage

### Basic Power Functions (Shutdown / Restart / Sleep)
- Double-click the shortcut to run.
- To **change the delay time**:  
  - Right-click the script or shortcut and choose **Edit** (opens in Notepad).  
  - Locate `Time=` and update the number of seconds (e.g., `Time=5`).

### Wi-Fi Control
- **To connect to your Wi-Fi**:
  - Right-click the **Wi-Fi ON OFF** icon → choose **Open file location**.
  - Right-click the `WiFi ON` shortcut → **Properties**.
  - In the Target field, replace `"Hemis WiFi"` with your actual Wi-Fi name.

- **To change the scheduled Wi-Fi off time**:
  - Right-click the **Wi-Fi OFF 7AM** icon → choose **Open file location**.
  - Open `add_wifi_disable_task.bat` with Notepad.
  - Find the time setting `07:00` and replace it with your preferred time in 24-hour format (e.g., `23:30`).

### Display / Graphics / Sleep Timer
- Use shortcuts to quickly switch display modes, set screen timers, or access graphics settings.
- You can also edit the scripts to change time durations and behavior.

## Notes
- Some scripts may require administrator privileges.
- Scripts can be customized to suit your system preferences and names.

## License
This project is open-source. Modify and distribute freely.
