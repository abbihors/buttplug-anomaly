# B.U.T.T.P.L.U.G.

Adds buttplug support to STALKER: Anomaly.

## Features

- Buzzes your vibrator based on in-game events in STALKER: Anomaly
    - e.g. firing your gun (based on caliber used), equipping certain items, *receiving damage*
- Works with any toy supported by [buttplug.io](https://buttplug.io/) (check [here](https://iostindex.com/?filtersChanged=1&filter0Availability=Available,DIY) to see if your toy is supported)
- Devices are automatically discovered and reconnected in case of a disconnect
- Shouldn't have any compatibility problems with other addons
- Zero or close to zero impact on game performance
- TODO: Multiple profiles

## How Do I Use This?

1. Install and launch [Intiface Desktop](https://intiface.com/desktop/) and click "Server Status". Make sure "Regular Websockets" is checked (*not* secure), then click "Start Server"
2. Install [STALKER: Anomaly](https://www.moddb.com/mods/stalker-anomaly) and copy the `bin` and `gamedata` folders from this folder to your game folder
3. Launch the game and load up a save or start a new game
4. Turn on your device, it should automatically be detected
5. If you want to confirm that your device was found, you can check the console by pressing \` (tilde) and making sure it says "`[buttplug] found device`"

## Known Issues

- If you are using the **Lovense USB Bluetooth Adapter** (not recommended), the game won't be able to find your toy if it takes more than 30 seconds to find. If this happens, just reload your save and make sure the device is on so that it can be discovered right away.

- Vibration gets stuck on death, just press ESC.

- No customization, this may be added in a future version.

## Frequently Asked Questions

### *What is "pollnet.dll"?*

[pollnet](https://github.com/probable-basilisk/pollnet) is a library that lets Lua scripts use WebSockets. B.U.T.T.P.L.U.G. uses this to talk to the buttplug server.

### *Why?*

Because its fun and because I can.