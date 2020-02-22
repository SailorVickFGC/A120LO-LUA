# Asuka 120 LimitOver - LUA Training mode
LUA script to help training more efficiently & understand more the game.

If you want to talk, share ideas etc: I advise joining the [Asuka 120% Discord](https://discordapp.com/invite/K4WyTCC), and go in the ddicated #programming-club channel.



## 🔰 How to use this .lua script
I recommend using BizHawk, it's easy to use & pretty robust.  
After loading the rom, just drag the lua file into BizHawk window or in the menu "Tools > LUA console" and open the file.

- BizHawk: https://github.com/TASVideos/BizHawk/releases
- Saturn BIOS: https://mega.nz/#!ddUD3KwK!bWNhUhhAaGKQQzenjtV93HU4754NJL9x7ffZ6dOUhig



## 📦 What's in the training mode right now:
![Bizhawk screenshot of A120LO Lua 1.0](https://media.discordapp.net/attachments/606287985801166878/615225027910041611/EmuHawk_2019-08-24_21.58.08.png?width=720&height=530)
- Combo counter in real time (number of hits in your last combo)
- Damage output (last combo damage)
- Stun / foe's stamina - timer until stun reset
- Training Dummy's state (WIP)

Disclaimer: When you start the training mode, damage is at -1, it will go to zero once you hit the training dummy.



## 🔁 FUTURE UPDATE / IDEAS
Here's some ideas I have for how we could improve the .lua:

**Color code:**  
![#f5645d](https://placehold.it/15/f5645d/000000?text=+) → Would help tremendously — ![#f5cc5d](https://placehold.it/15/f5cc5d/000000?text=+) → Good Quality of life — ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) → Not a high priority feature

__Easy:__
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) Makes the game heal to max health, instead of "max health-1", 
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) Only show / start script once in Deku battle (training mode)

__Intermediate:__ 
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) show when the opponent can tech (true vs fake combo),
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) a ground / wall / throw tech option for the dummy (I kinda have the code for it, but the dummy doesn't accept the inputs >.>),
- ![#f5cc5d](https://placehold.it/15/f5cc5d/000000?text=+) show startup/recovery like Skullgirls would be pretty cool too. (frame data would be awesome in itself)
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) input history (with frame counter? Would make it easier to test the juggle systems limits)
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) Having macro to activate some script (activate enemy teching Wall or ground etc by example)

__Freaking hard:__
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) hitbox viewer: it would help tremendously to understand the game but is the hardest to implement.
