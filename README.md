# 🚀 NOVA Player Panel for Roblox Islands

**NOVA Player Panel** is a modern, fully‑featured player monitor UI designed specifically for **Roblox Islands**. It displays a live list of online players with avatars, supports search, shows detailed player info (Country Code, Device Type, Join Code, User ID), and includes a draggable floating circle for quick hide/show.

---

## ⚠️ Important Notice

This script is **obfuscated** – the source code has been compressed and encoded to protect its functionality and prevent casual editing.  
- **You cannot modify the script directly.**  
- **All features are locked as‑is.**  
- If you need custom functionality, contact the developer (do not attempt to deobfuscate – it's against the terms of use).

The obfuscation ensures:
- Stable performance across executors.
- Protection against unauthorized modifications.
- Consistent updates delivered via the official loader.

---

## ✨ Features

- **Live Player List** – Automatically updates when players join/leave.
- **Rich Player Cards** – Display avatar, display name, username, and online status.
- **Search** – Filter players by username or display name.
- **Detailed Profile Panel** – Click any player to view:
  - Large avatar
  - Display name & username
  - Country Code (if available)
  - Device Type (if available)
  - Join Code (if available)
  - User ID
- **Join / Leave Notifications** – Beautiful animated toasts.
- **Hide / Minimize** – Click `−` to hide the main panel; a floating `N` circle remains, draggable and clickable to restore.
- **Drag & Drop** – Drag the main window by its header, and drag the floating circle independently.
- **Mobile‑Friendly** – Adaptive sizing for small screens (touch gestures supported).
- **Sleek Dark Theme** – Gradient accents, glass‑morphism cards, and smooth animations.

---

## 🖥️ How to Use

### Load via `loadstring` (Recommended)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/qyroxoo/NOVA/refs/heads/main/nova_V1.lua"))()
```

Paste this into your executor and run it while in **Roblox Islands**. The UI will appear immediately.

> **Note:** Do not attempt to modify or re‑upload the script – only the official loader URL will work.

---

## 🧠 How Data is Fetched in Roblox Islands

The script automatically retrieves **Country Code**, **Device Type**, and **Join Code** from each player using multiple fallbacks:

| Data | Fetch Methods |
|------|---------------|
| **Country Code** | Tries `player.CountryCode`, `player:GetAttribute("CountryCode")`, checks inside a `Data` folder, and falls back to `LocalizationService:GetCountryRegionForPlayerAsync()` |
| **Device Type** | Tries `player.DeviceType`, `player:GetAttribute("DeviceType")`, and checks inside a `Data` folder |
| **Join Code** | Tries `player.JoinCode`, `player:GetAttribute("JoinCode")`, and checks inside a `Data` folder |

If nothing is found, the fields will display `"N/A"`. Debug information is printed to the executor's console to help you identify exactly where the data is stored.

---

## 🎮 Commands & Controls

| Action | How To |
|--------|--------|
| **Open / Close** | The UI opens automatically on load. Close it by clicking the `−` button (minimizes to circle) or the `×` button (hides to circle). |
| **Restore from circle** | Tap / click the floating `N` circle. |
| **Drag main window** | Click and drag the top header (works with mouse or touch). |
| **Drag circle** | Click and drag the floating `N` circle (works with mouse or touch). |
| **Search** | Type in the search box – list filters in real time. |
| **View player details** | Click any player card; a detailed profile panel slides in. |
| **Close details panel** | Click the `‹` back arrow. |

---

## 🧪 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Script doesn't load** | Ensure your executor supports `game:HttpGet`. Check your internet connection and that the raw URL is accessible. |
| **Country / Device / Join Code show "N/A"** | The game may store these values in a different location. Open your executor’s console, click a player, and look for debug output – then contact the developer with the property names found. |
| **UI doesn't appear** | Make sure the script runs after the game loads (add a `wait(1)` at the top if needed). Also verify that `CoreGui` is accessible. |
| **Dragging not working on mobile** | Ensure you’re using the latest version (touch events are supported). If the issue persists, try updating your executor. |

---

## 📝 Credits

- **Script by** – [qyroxoo](https://github.com/qyroxoo)
- **Game** – [Roblox Islands](https://www.roblox.com/games/4872321990/Islands) by Easy.gg

---

## 📄 License

This project is licensed under the MIT License – you may use it freely, but **do not modify or redistribute** the obfuscated code without permission.

---

## ⭐ Show Your Support

If you find this script useful, give the repository a ⭐ and share it with your friends!

---

Happy monitoring in **Roblox Islands**! 🏝️🚀
