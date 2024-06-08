# Keybind Manager

Keybind Manager is a Garry's Mod addon that provides a convenient way to manage and customize keybinds. It allows players to create, edit, and delete keybinds, as well as organize them into different profiles.

https://github.com/thatrtxdude/KeybindManager/assets/88516241/5e9cceb1-a97b-4025-9a5a-548ff5ba76ed

> [!NOTE]  
> This video is outdated and doesn't reflect current features.
> It only demonstrates basic functionality.

> [!WARNING]  
> This addon is not finished yet! Things can break over different versions, and bugs are (hopefully not) present!

## Features

- Create and manage multiple keybind profiles
- Bind keys to execute console commands or default actions <- (Default actions need some work)
- Intuitive and user-friendly menu interface
- Customizable keybind names, descriptions, and commands
- Ability to save and load keybind profiles
- Profiles are stored as .json files in `garrysmod/data/keybindmanager`

## Installation

1. Download the latest version from the GitHub repository by either cloning or downloading the repo via zip, or get the stable version from the Workshop
2. As stated before, Clone or unzip the repo into your `garrysmod/addon` folder
3. Restart Garry's Mod

## Usage

1. Launch Garry's Mod and join a server or start a new game.
2. Open the Keybind Manager menu using one of the following methods:
   - Open the console and type in `open_keybind_manager`
   - Access the Keybind Manager through the spawnmenu under "Utilities" > "Keybind Manager".
3. Create a new profile or select an existing profile from the dropdown menu.
5. Customize the keybind name, description, command, and key for each keybind.
6. Add the keybind using the dedicated Add Keybind button.
7. The keybinds will now be active and can be used in-game.

## Configuration & File Structure

Keybind Manager does not require any additional configuration. However, you can customize the addon by modifying the following files:

- `lua/autorun/keybind_manager.lua`: The main entry point of the addon, responsible for including the necessary files on both the server and client.
- `lua/keybind_manager/core.lua`: Contains the core functionality of the addon, including keybind registration, saving, and loading.
- `lua/keybind_manager/menu.lua`: Defines the user interface and menu functionality for managing keybinds.
- `lua/keybind_manager/spawnmenu.lua`: Integrates the Keybind Manager with the spawnmenu for easy access.

## Limitations
This addon cannot run blocked console commands, simply due to certain commands being blocked internally.

[List of all blocked console commands](https://wiki.facepunch.com/gmod/Blocked_ConCommands)

However, I have added a bypass for the `toggle` command by utilizing GetConVar. Every other command in the list will still be blocked.

## Contributing

Contributions are welcome! If you encounter any issues, have suggestions for improvements, or would like to contribute new features, please feel free to submit a pull request.

## License

This addon is released under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html). Please review the license terms before using or distributing the addon.
