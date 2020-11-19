# pfUI for V+ Private Server (v.05)

This is a modification for the popular pfUI addon for Vanilla WoW made by Shagu. For information on the excellent original mod visit [shagu/pfUI](https://github.com/shagu/pfUI).

As the [V+ Server](https://vanillaplus.org/) adds lots of new skills and alters a lot of baseline skills along with their cast times, cooldowns, duration and adds talents
to change those, by default this mod unfortunately doesn't show the right info ingame.

With this modification extension I aim to make the ingame information display correctly. Please note that I'm an amateur programer and mostly
modified code by simply reading into it and with lots of help and advice from [Thirinena (hawaiisa)](https://github.com/hawaiisa) from the V+ server (thx a lot) and [Shagu](https://github.com/shagu) (thx too).
Not all the listed changes have been tested yet.

## Installation:

Use the Green Code Button to the top right and download the zip file. Extrace the file into your `wow/Interface/AddOns` folder and rename it to `pfUI` (remove the -master). If you already have pfUI installed overwrite the existing folder, saved configuations wont be affected by this.
Note: at the moment the mod extension only works with the English Game Client.

## Changelog (v 0.51)

- cleaned up the code a bit
- resolved issue with Mighty Roots talent not working
- corrected some Shaman totem timers

## Changelog (v 0.5)

- first upload with cast time and debuff time corrections


## Changelog (Summary)

**Hunter:**
- Aimed and Multi Shot show the correct cast times and are affected by the Snap Shot talent
- Hunters Mark shows correct debuff time and is correctly affected by Improved Hunters Mark talent
- Concussive and Scatter Shot show correct (new) duration
- Scorpid Sting and improved Scorpid Sting show correct duratin

**Rogue:**
- Duration altering talents affecting debuffs should work correctly (Total Control, Improved Gouge, Exhaustion, Serrated Blades)

**Warrior:**
- Hamstring duration corrected, talent interaction with Improved Hamstring added
- Booming Voice should correctly affect debuff times for Shouts

**Warlock:**
- Prolonged Misery and Jinx should correctly increase the associated Curses duration, base Curse duration corrected

**Priest:**
- Mindflay debuff time corrected
- Shadow Word Pain should display correct in relation to Improved Shadow Word Pain talent

**Paladin:**
- Improved Hammer of Justice should affect Hammers shown debuff time

**Druid:**
- Mighty Roots and Power of Nature should affect the associated spells shown debuff timers

**Mage:**
- Permafrost should correctly increase Frostbolts debuff duration, Frostbolt baseline debuff times corrected

**Shaman:**
- corrected a few totem durations

## Plans (to-do):
- adding the custom V+ spells into the library that then show the correct times 

## Known Issues:
- for some reason Frostbolts first cast always shows the wrong duration (e.g. 6s debuff although it should be 7 seconds, subsequent casts show correctly), sometimes the debuff doesnt register at all
