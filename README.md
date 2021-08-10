# Asuka 120 LimitOver - LUA Training mode
LUA script to help training more efficiently & understand more the game.

If you want to talk, share ideas etc, please join the [Asuka 120% Discord](https://discordapp.com/invite/K4WyTCC), and go in the dedicated #wiki-dev channel.

You can also contact me on discord, Vick#9262, or on twitter [@thesailorvick](https://twitter.com/TheSailorVick).



## 🔰 How to use it
I recommend using BizHawk, it's easy to use & pretty robust _(I also only tested it in Bizhawk)_.  
After loading the rom, just drag the lua file into BizHawk window or in the menu "Tools > LUA console" and open the file.

- BizHawk: https://github.com/TASVideos/BizHawk/releases
- Saturn BIOS: https://mega.nz/#!ddUD3KwK!bWNhUhhAaGKQQzenjtV93HU4754NJL9x7ffZ6dOUhig



## 📦 The Features
![Bizhawk screenshot of A120LO Lua 1.0](https://media.discordapp.net/attachments/606287985801166878/615225027910041611/EmuHawk_2019-08-24_21.58.08.png?width=720&height=530)
- Hibox Viewer!
- Combo counter in real time (number of hits in your last combo)
- Damage output (last combo damage)
- Stun / foe's stamina - timer until stun reset
- Training Dummy's state (WIP)

> **Disclaimer**: When you start the training mode, damage is at -1, it will go to zero once you hit the training dummy.



## 🔁 To DO & Ideas
**Color code:**  
🔴 Hard  |  🟡 Intermediate  |  🟢 Easy  |  🔵 Unsure


**Important**
1. 🟡 Show when the opponent can tech (true vs fake combo)
1. 🔴 Ground / wall / throw tech option for the dummy (I kinda have the code for it, but the dummy doesn't accept the inputs >.>)
1. 🟡 show startup/recovery like Skullgirls would be pretty cool too (frame data would be awesome in itself)
1. 🔴 Somehow make the hitboxes white when invincible (eg. on Torami's j22 or when you hit the juggle system limit & drop out).

**Good Quality of life**
1. 🟢 Input history (with frame counter? Would make it easier to test the juggle systems limits)
1. 🟢 Having macro to activate X part of the script (eg. activate enemy wall/ground teching)
1. 🔵 Make the text scale with window (imo avoid textPixel)

**Not a Priority**
1. 🟢 Make the game heal to max health, instead of "max health1.1"
1. 🟢 Only show / start script once in Deku battle (training mode)
