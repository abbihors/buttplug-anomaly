# B.U.T.T.P.L.U.G.

Adds buttplug support to STALKER: Anomaly.

## Features

- Buzzes your vibrator based on in-game events in STALKER: Anomaly
    - e.g. firing your gun, doing damage, *receiving damage*, during blowouts
- Works with any toy supported by [buttplug.io](https://buttplug.io/) (check [here](https://iostindex.com/?filtersChanged=1&filter0Availability=Available,DIY) to see if your toy is supported)
- Devices are automatically discovered and reconnected in case of a disconnect
- TODO: Multiple profiles
- Shouldn't have any compatibility problems with other addons
- No impact on game performance

## How Do I Use This?

1. Install and launch [Intiface Desktop](https://intiface.com/desktop/) and click "Server Status". Make sure "Regular Websockets" is checked (*not* secure), then click "Start Server"
2. Install STALKER: Anomaly and copy the files from this folder to the game folder
3. Launch the game and load up a save or start a new game
4. Turn on your device, it should automatically be detected
5. Your toy will do a small vibration to let you know that it's connected to the game, but you can also check the console by pressing \` (tilde) and making sure it says "`[buttplug] found device`"

## Known Issues

If you are using the **Lovense USB Bluetooth Adapter** (which is generally *not* recommended because of all the problems it has), the game won't be able to find your toy if it takes more than 30 seconds to find. If this happens, just reload your save and make sure the device is on so that it can be discovered right away.

## Frequently Asked Questions

### *What is "pollnet.dll"?*

[pollnet](https://github.com/probable-basilisk/pollnet) is a library that lets Lua scripts use WebSockets. B.U.T.T.P.L.U.G. uses this to talk to the buttplug server.

### *Why?*

Because its fun and because I can.
