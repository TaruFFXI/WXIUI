<p align="center">
  <img src="screenshots/Banner.png" alt="WXIUI Banner" width="900">
</p>

# WXIUI

A modular UI for Windower
WXIUI - A modular UI for Final Fantasy XI
-------------------------------------------
Llevo años utilizando Windower para jugar a mi juego favorito, y siempre he querido una interfaz sofisticada como logró hacer el genial equipo de XIUI para Ashita. Hasta el momento habían no demasiadas opciones similares así que me animé a crear mi propia UI basada en el trabajo hecho en XIUI. Sin embargo no soy desarrollador y este es mi primer addon, el cual me ha ayudado la IA y aunque he hecho cientos de pruebas y he corregido todos los errores que he podido, es posible que aparezca alguno.  

English: 
  
I’ve been using Windower for years to play my favorite game, and I’ve always wanted a sophisticated interface like the amazing XIUI team managed to create for Ashita. Until now, there haven’t been many similar options available, so I decided to create my own UI inspired by the work done with XIUI.

However, I’m not a developer, and this is my first addon. AI helped me build it, and although I’ve done hundreds of tests and fixed every issue I could find, it’s possible that some bugs may still appear.

<p align="center">
  <img src="screenshots/FullUI.png" width="900">
</p>

## Features

- Buff Tracker
- Cast Bar
- Distance HUD
- Config Menu
- Trust Support
- Modular Architecture
- Trade request window
- Party request window
- Loot notification
- Scalable HUDs system
- Pet Window
- ZoneMap transition integrated
- InfoBar integrated
- Gil tracker (Gil per hour and Session)
- Inventory tracker
- Dynamic TP color design.

<p align="center">
  <img src="screenshots/InvitePartyHUD.png" width="900">
</p>

## Commands

- //wxiui config
- //wxiui move <hud>
- //wxiui hide <hud>
- //wxiui show <hud>
- //wxiui toggle <hud>

## Usage

Using the `//wxiui config` command, you can access the interface configuration menu. On the first page, you can move all WXIUI components independently anywhere on the screen. On the second page, clicking the percentage value (50% by default) increases the scale in 10% increments, allowing you to resize the desired HUD. The available range goes from 30% to 100%, enabling WXIUI to adapt seamlessly to both Steam Deck and 4K displays.
The `//wxiui move <hud>` command allows you to reposition any interface element without having to open the main configuration menu. The `hide` command hides the selected HUD, for example, `//wxiui hide partyhud` will hide the party HUD. The `show` command makes it visible again, while `hide` acts as a toggle, switching the HUD between hidden and visible states.

<p align="center">
  <img src="screenshots/HUDMenu.png" width="900">
</p>
<p align="center">
  <img src="screenshots/UIResizeHUD.png" width="900">
</p>

## Loot Notification

The notification system created by the XIUI team to alert players when a new item is added to their inventory is something that always fascinated me, so I wanted to bring a similar feature to WXIUI. This system can display notifications for up to 5 items obtained after defeating monsters, with each notification remaining on screen for 5 seconds. Like the rest of the HUD elements, it can be freely moved and resized to suit your preferences.

<p align="center">
  <img src="screenshots/LootHUD.png" width="900">
</p>
