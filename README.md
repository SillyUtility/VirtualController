![iPhone running virtual controller app controlling game on iMac](./Assets/HeroImage.png)

# Virtual Controller

This project is an iPhone app that emulates retro game controllers and
a device driver. The device driver makes the controller appear to
macOS as a physical devices and can be used by any app or game that
supports HID game controllers on a Mac (and in the future, an iPad
with an M-series chip).

## Project Goals

- Open source
- Emulates real-world retro devices
- Emulated device indistinguishable from a physical device
- iPhone app distributed on the iOS App Store
- Driver distributed on the Mac App Store from the host app
- iPhone app, driver, and devices require NO setup or configuration

See the wiki for more [Project Goals…](https://github.com/SillyUtility/VirtualController/wiki/Project-Goals)

### Minimum Requirements

- **Controller App**: iOS 12+
- **Mac Driver**: macOS 10.15+
- **iPad (with M series chip) Driver**: iOS 16+

See the wiki for complete [minimum requirements and minimum supported Apple devices…](https://github.com/SillyUtility/VirtualController/wiki/Minimum-Requirements)

## Progress

- Device driver
- Driver’s host app (installs and manages the driver)
- Virtual NES controller (usable from the host app)
- iPhone app that emulates an NES controller and connects to the driver
- iPhone app sends button state to the driver
- Works with OpenEmu and other apps that recognize HID game controllers

See the wiki for a [complete run down of progress…](https://github.com/SillyUtility/VirtualController/wiki/Progress)

## Emulated Devices

This list is a preview of some game controllers that will be supported
and their progress.

| Device Name                  | Progress | Virtual Device Name<sup>*</sup> |
|:-----------------------------|:---------|:--------------------------------|
| NES Controller               | 75%      | 9ES Controller                  |
| Apple Pippin                 | Planned  | Pip                             |
| Atari 2600 CX40 Joystick     | Planned  | Alfa 2600 Joystick              |
| Atari 2600 CX30 Paddle       | Planned  | Alfa 2600 Paddle                |
| ColecoVision Hand Controller | Planned  | CharlieVictor Hand Controller   |
| GameBoy                      | Planned  | GolfBravo                       |
| GameBoy Advance              | Planned  | GolfBravo Advance               |
| GameGear                     | Planned  | GolfGear                        |
| Intellivision                | Planned  | Indiavision                     |
| Nintendo DS                  | Likely   | Nine DS                         |
| Sega Genesis                 | Planned  | Sierra Golf                     |
| Sega Master System           | Planned  | Sierra Mike System              |
| Sega Saturn                  | Planned  | Sierra Jupiter                  |
| SNES                         | Planned  | S9ES                            |
| TurboGrafx-16                | Planned  | TangoGolf-16                    |
| Vectrex                      | Planned  | Victrex                         |
| Virtual Boy                  | Planned  | Victor Bravo                    |

<sup>\*</sup> _names likely to change_

Don’t see your favorite game controller? See the wiki for [more devices…](https://github.com/SillyUtility/VirtualController/wiki/Emulated-Devices)

## How can you help?

See the wiki for [ways you can help Virtual Controller.](https://github.com/SillyUtility/VirtualController/wiki/How-you-can-help)
