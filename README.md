# Asuka 120 LimitOver - LUA Training mode
LUA script made

## What's in the training mode right now:
![Bizhawk screenshot of A120LO Lua 1.0](https://media.discordapp.net/attachments/606287985801166878/615225027910041611/EmuHawk_2019-08-24_21.58.08.png)
- combo counter in real time (number of hits in your last combo)
- Damage output (last damage)
- Stun / foe's stamina - timer until stun goes back to 0
- Training Dummy's state (WIP)

Disclaimer: When you start the training mode, damage is at -1, it will go to zero once you hit the training dummy.

## FUTURE UPDATE / IDEAS
OK, here's some ideas I have for how we could improve the .lua:
(+ important, ~ semi-important, - less important)

(Should be) Easy:
- Makes the game heal to max health, instead of "max health-1", 
- Only show / start script once in Deku battle (training mode)

Intermediate, important: 
+ show when the opponent can tech (true vs fake combo),
+ a ground / wall / air / throw tech option for the dummy (I kinda have the code for it, but the dummy doesn't accept the inputs >.>),

Intermediate-hard, Quality of Life:
~ show startup/recovery like Skullgirls would be pretty cool too. (frame data would be awesome in itself)
- input history (with frame counter? Would make it easier to test the juggle systems limits)
- Having macro to activate some script (activate enemy teching Wall or ground etc by example)

Freaking hard:
+ hitbox viewer: it would help tremendously to understand the game but is the hardest to implement.
