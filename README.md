# uidaho-spr26-gamejam

## Godot 4.6.1
https://godotengine.org/download/windows/

## Git Structure

`origin/master` is a protected branch
* You will not be able to push directly into it
* You must create a feature branch and PR into master
  * Yes, this slows things down
  * Yes, this reduces problems we will have


## Folder Structure
Please follow the folder structure below.

- `addons/`: Third-party or custom Godot plugins and editor extensions.
- `assets/`: Shared game assets root.
- `assets/art/`: Sprites, textures, tilesets, animations, and other visual assets.
- `assets/audio/`: Sound effects, music, and voice assets.
- `assets/fonts/`: Font files and font resources.
- `scenes/`: Main scene files (`.tscn`) for gameplay and systems.
- `scenes/levels/`: Level scenes and map-specific scene setups.
- `scenes/ui/`: UI scenes such as menus, HUD, and overlays.
- `scripts/`: Game logic scripts (`.gd`).
- `scripts/autoload/`: Global singleton scripts for systems like save data, audio, or game state.
- `scripts/towers/`: tower-specific logic and components.
- `scripts/enemies/`: Enemy AI, behavior, and combat scripts.
- `scripts/ui/`: UI behavior scripts.
- `shaders/`: Shader files and related shader resources.



# Game Overview

"Bloons" style tower defense.

Buyable dinosaurs
2 player co-op
Each player has 3 buyable dinos

Enemies on the track consist of "cavemen"
Each enemy killed gives "money" "bones" "meat"



## Things we need
2 levels
* track for enemies to follow

gamemode
* enemy spawning
* rounds

enemies
* health (also amount of damage dealt)

6 dinos total
* attack damage
* range
* cooldown
* cost
* "upgrade"

UI
* main menu
* level select
* decision menu
* buy menu
* HUD
  * health
  * money
  * round
  * time

coop
* 2 controllers

Building system
* buy towers
* place towers
* collision blocking

sounds
* main menu bgm
* in game bgm
* enemy death / money gain sfx


