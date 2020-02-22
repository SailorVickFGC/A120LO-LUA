# Asuka 120 LimitOver - LUA Training mode
LUA script made

## What's in the training mode right now:
![Bizhawk screenshot of A120LO Lua 1.0](https://media.discordapp.net/attachments/606287985801166878/615225027910041611/EmuHawk_2019-08-24_21.58.08.png?width=720&height=530)
- combo counter in real time (number of hits in your last combo)
- Damage output (last damage)
- Stun / foe's stamina - timer until stun goes back to 0
- Training Dummy's state (WIP)

Disclaimer: When you start the training mode, damage is at -1, it will go to zero once you hit the training dummy.
## FUTURE UPDATE / IDEAS
OK, here's some ideas I have for how we could improve the .lua:

**Legend:**
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) → This feature Would help tremendously 
- ![#f5cc5d](https://placehold.it/15/f5cc5d/000000?text=+) → Good Quality of life
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) → Not a high priority feature

(Should be) Easy:
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) Makes the game heal to max health, instead of "max health-1", 
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) Only show / start script once in Deku battle (training mode)

Intermediate, important: 
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) show when the opponent can tech (true vs fake combo),
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) a ground / wall / throw tech option for the dummy (I kinda have the code for it, but the dummy doesn't accept the inputs >.>),
- ![#f5cc5d](https://placehold.it/15/f5cc5d/000000?text=+) show startup/recovery like Skullgirls would be pretty cool too. (frame data would be awesome in itself)
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) input history (with frame counter? Would make it easier to test the juggle systems limits)
- ![#f0f55d](https://placehold.it/15/f0f55d/000000?text=+) Having macro to activate some script (activate enemy teching Wall or ground etc by example)

Freaking hard:
- ![#f5645d](https://placehold.it/15/f5645d/000000?text=+) hitbox viewer: it would help tremendously to understand the game but is the hardest to implement.
