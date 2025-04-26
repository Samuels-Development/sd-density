# sd-density

sd-density is a zone- and time-based ped density-modifier for FiveM. Using ox_lib poly zones, you define any area on your map and then schedule custom pedestrian, vehicle, parked-vehicle and scenario-ped densities for different times of day.

Example: Make Legion’s Park almost empty from 00:00–06:00, lightly trafficked from 06:00–18:00, and bustling from 18:00–24:00.

Settings are saved in a GlobalState bag (zone_key) on the server and instantly pushed to all clients.
For testing or live tweaks, there’s an admin command to edit any zone’s schedule in runtime.

## 🔔 Contact

Author: Samuel#0008  
Discord: [Join the Discord](https://discord.gg/FzPehMQaBQ)  
Store: [Click Here](https://fivem.samueldev.shop)

## 💾 Installation

1. Download the latest release from the [GitHub repository](https://github.com/Samuels-Development/sd-density/releases).
2. Extract the downloaded file and rename the folder to `sd-density`.
3. Place the `sd-density` folder into your server's `resources` directory.
4. Add `ensure sd-density` to your `server.cfg` to ensure the resource starts with your server.


## 📖 Dependencies
- ox_lib

## 📖 Admin Usage

### Command
/pop:set zoneKey scheduleIndex field value
* zoneKey | The key of the zone in your Config.Zones table (e.g. downtown, hospital, grovestreet).
* scheduleIndex | The 1-based index into that zone’s population array (which entry you’re editing).
* field | Which density to change: peds, vehicles, randomVehicles, parked, or scenario.
* value | A float ≥ 0.0 (0 = none, 1 = “normal”), or higher if you want extra density.
