# Space Tonbow

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/tite.gif)

Soar through outerspace as the giant mechanical dragonfly, Tonbow, taking out enemy orbs swarming the stars
in this arcade-style Sega Master System game! 

This repository contains the source code for Space Tonbow. 
You're welcome to compile it yourself, but if you want a direct download of the ROM, that can be found for free
on its itch.io page: https://bofner.itch.io/space-tonbow


For me this feels like a big step up over Triangle Puzzle. I spent a lot of time working on this one,
and yet at the same time, things came together rather quickly when I focused on the project. So what
do we have to show off this time?

Well as always, it of course works on real Sega Master System (or in this case Sega Mark III) hardware!

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/realHardware.gif)

I've also added Mega Drive/Genesis START button support!

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/realHardwareMD.gif)

But the coolest feature is that this is (to my knowledge) the first Sega Master System game to support TATE mode!

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/realHardwareTATE.gif)

Controls are quite simple, the d-pad moves Tonbow around screen and the 1-button causes him to dash forward
in an attack that can take out the enemy orbs. 

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/controls.gif)

You can also hold down the 2-button for easy strafing!

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/strafe.gif)

But watch out! Not only will the orbs kill you, but when they reach the end of the screen, they'll fire off 
a projetile that can't be dashed into!

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/backShot.gif)

This game will require either a flash cartridge to play on real Sega hardware, or an emulator to play on any other device. 

So, what kind of high score can you get?

![](https://github.com/Bofner/Space-Tonbow/blob/main/images/highScore.gif)
 
 
__________________________________________________________________________________________________

 
This repository includes all source code and assets for this project. All code, art and music by me, Cameron "Bofner" Mitchell unless otherwise noted. 
 
## Tools used:
 
### Emulators for testing:

-[Emulicious](https://emulicious.net/) by Calindro for general purpose testing

-[BizHawk](https://tasvideos.org/Bizhawk) by TASVideos for LUA scripting 
 
### Artwork/Assets:

-[Aseprite](https://www.aseprite.org/) by Igara Studio S.A. for graphics design

-[BMP2Tile](https://github.com/maxim-zhao/bmp2tile) by Maxim for conversion to SMS format

### Music Production:

-[Deflemask](https://www.deflemask.com/) by Leonard Demartino

-[Furnace Tracker](https://tildearrow.org/furnace/) by Tile Arrow

-Moon Blaster 1.4 by Moon Soft

-[PSGTool](https://www.smspower.org/forums/16925-PSGToolAVGMToPSGConvertor) by Calindro
 
### Programming and Assembly:

-[Visual Studio Code](https://code.visualstudio.com/) by Microsoft 

-[WLA DX Assembler](https://github.com/vhelin/wla-dx) by Ville Helin

-[PSGLib](https://github.com/sverx/PSGlib) by Sverx 

-[MBMPlayer](https://github.com/HerrSchatten/MBMPlay-SMS) by HerrSchatten
 
Thanks to everyone who made these wonderful tools!

And special thanks to all the dragonflies flying around Osaka for the inspiration to get me
to continue working on this project!
 
__________________________________________________________________________________________________
 
## Updates:

#### v1.1: Update 08/01/2024
-Fixed a bug with the high score not working properly with scores over 100

#### v1.0: Official release! 07/30/2024
It's finally here! After about a year of development and procrastination, Space Tonbow is finally here! It's biggest features being:

-TATE support

-FM Sound Unit Support

-SRAM High Score save feature

Again, if you want to download the ROM, check out the itch.io page: https://bofner.itch.io/space-tonbow

__________________________________________________________________________________________________

Here's everything I've added/fixed since the previous update: 

-Added Splash screen music! Added FM music and sound effects!

-Added a high score mechanic using SRAM to save your high scores. 

-Fixed a bug where if you die on the bottom of screen, no parts go flying.

-Fixed a glitch where the BG star scrolling speed would get messed up. 

-Fixed a glitch where SFX would cut out the music in PSG mode. 

-Enemies no longer spawn on top of each other.

#### v0.9.6.1: 07/16/2024
Fixed a bug that was causing a jump to random memory, leading to odd glitches and the game not 
running on real hardware. 

Still hoping to add and fix the same things as prior update

#### v0.9.6: 07/16/2024

Wow! We're really getting there! Space Tonbow now has MUSIC AND SFX! I didn't think I'd be able to
write muic, so I'm really really happy that I figured it all out!

Hoping to add:

-Maybe one more song

-Splash Screen tune or SFX

Hoping to fix:

-A bug where if you die on the bottom of screen, no parts go flying... still

#### v0.9: 6/18/2024

Space Tonbow is almost near completion! Feel free to call this the beta.

Hoping to add:

-Sound effects

-???

Hoping to fix:

-A bug where if you die on the bottom of screen, no parts go flying
