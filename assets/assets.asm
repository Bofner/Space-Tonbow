
;============================================================================================
; Constant Data
;============================================================================================
;BANK defines for easy switching around and readability
.define     SFSBank                 $0002
.define     DemoLevelBank           $0003
.define     TitleScreenYokoBank     $0004
.define     TitleScreenTateBank     $0005
.define     TonbowTilesBank         $0006
.define     Audio                   $0007

;Data for an all black palette
FadedPalette:
    .db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
FadedPaletteEnd:

; There are 11 registers, so 11 data
VDPInitData:
              .db %00010100             ; reg. 0

              .db %10100000             ; reg. 1

              .db $ff                   ; reg. 2, Name table at $3800

              .db $ff                   ; reg. 3 Always set to $ff

              .db $ff                   ; reg. 4 Always set to $ff

              .db $ff                   ; reg. 5 Address for SAT, $ff = SAT at $3f00 

              .db $ff                   ; reg. 6 Base address for sprite patterns

              .db $f0                   ; reg. 7 Overrscan Color at Sprite Palette 1   

              .db $00                   ; reg. 8 Horizontal Scroll

              .db $00                   ; reg. 9 Vertical Scroll

              .db $ff                   ; reg. 10 Raster line interrupt off
VDPInitDataEnd:


;============================================================================================
; STEELFINGER STUDIOS
;============================================================================================
.bank SFSBank
.org $0000
;========================================================
; Background
;========================================================
SteelFingerBGPalette:
    .include "..\\assets\\palettes\\backgrounds\\steelFinger_bgPal.inc"
SteelFingerBGPaletteEnd:
;----------------
; BG Tiles
;----------------
SteelFingerTiles:
    .include "..\\assets\\tiles\\backgrounds\\steelFingerStudios_tiles.inc"
SteelFingerTilesEnd:

SteelFingerTateTiles:
    .include "..\\assets\\tiles\\backgrounds\\steelFingerStudiosTate.inc"
SteelFingerTateTilesEnd:
;----------------
; BG Maps
;----------------
SteelFingerStudiosMap:
    .include "..\\assets\\maps\\steelFingerStudios_map.inc"
SteelFingerStudiosMapEnd:
SteelFingerStudiosTateMap:
    .include "..\\assets\\maps\\steelFingerStudiosTate.inc"
SteelFingerStudiosTateMapEnd:
;========================================================
; Sprites
;========================================================
SteelFingerSPRPalette:
    .include "..\\assets\\palettes\\sprites\\steelFinger_SprPal.inc"
SteelFingerSPRPaletteEnd:
;----------------
; Shimmer
;----------------
SteelFingerShimmerTiles:
    .include "..\\assets\\tiles\\sprites\\sfsShimmer\\sfsShimmer_tiles.inc" 
SteelFingerShimmerTilesEnd:

SteelFingerShimmerTateTiles:
    .include "..\\assets\\tiles\\sprites\\sfsShimmer\\sfsShimmerTate.inc" 
SteelFingerShimmerTateTilesEnd:

;============================================================================================
; Demo Level Data
;============================================================================================
.bank DemoLevelBank
.org $0000
;========================================================
; Background
;========================================================
;----------------
; Palettes
;----------------
DemoLevelBGPal:
    .include "..\\assets\\palettes\\backgrounds\\demo.inc"
DemoLevelBGPalEnd:
;----------------
; BG Tiles
;----------------
DemoLevelTiles:
    .include "..\\assets\\tiles\\backgrounds\\demoGaiden2.inc"
DemoLevelTilesEnd:
;----------------
; BG Maps
;----------------
DemoLevelMap:
    .include "..\\assets\\maps\\demoGaiden2.inc"
DemoLevelMapEnd:
;========================================================
; Sprite
;========================================================
;----------------
; Palette
;----------------
DemoLevelSprPal:
    .include "..\\assets\\palettes\\sprites\\demo.inc"
DemoLevelSprPalEnd:
;----------------
; DemoOrb
;----------------
demoOrbTateTiles:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\demoOrbTate.inc"
demoOrbTateTilesEnd:

demoOrbTiles:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\demoOrb.inc"
demoOrbTilesEnd:

demoOrbExplosionTiles0:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\explosion0.inc"
demoOrbExplosionTiles0End:

demoOrbExplosionTiles1:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\explosion1.inc"
demoOrbExplosionTiles1End:

demoOrbExplosionTiles2:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\explosion2.inc"
demoOrbExplosionTiles2End:

demoOrbExplosionTiles3:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\explosion3.inc"
demoOrbExplosionTiles3End:

demoOrbExplosionTiles4:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\explosion4.inc"
demoOrbExplosionTiles4End:
orbShotTiles:
    .include "..\\assets\\tiles\\sprites\\demoOrb\\orbShot.inc"
orbShotTilesEnd:
;----------------
; Score
;----------------
scoreYokoTiles:
    .include "..\\assets\\tiles\\sprites\\score\\tallNumbersYoko.inc"
scoreYokoTilesEnd:
scoreTateTiles:
    .include "..\\assets\\tiles\\sprites\\score\\tallNumbersTate.inc"
scoreTateTilesEnd:

GameOver:
    .include "..\\assets\\tiles\\sprites\\gameOver\\gameOver.inc"
GameOverEnd:

Again:
    .include "..\\assets\\tiles\\sprites\\gameOver\\againYoko.inc"
AgainEnd:

GameOverTitle:
    .include "..\\assets\\tiles\\sprites\\gameOver\\titleYoko.inc"
GameOverTitleEnd:

GameOverCursor:
    .include "..\\assets\\tiles\\sprites\\gameOver\\cursorYoko.inc"
GameOverCursorEnd:

GameOverTate:
    .include "..\\assets\\tiles\\sprites\\gameOver\\gameOverTate.inc"
GameOverTateEnd:

AgainTate:
    .include "..\\assets\\tiles\\sprites\\gameOver\\againTate.inc"
AgainTateEnd:

GameOverTitleTate:
    .include "..\\assets\\tiles\\sprites\\gameOver\\titleTate.inc"
GameOverTitleTateEnd:

GameOverCursorTate:
    .include "..\\assets\\tiles\\sprites\\gameOver\\cursorTate.inc"
GameOverCursorTateEnd:

.bank TonbowTilesBank
.org $0000
;==============================================================
; Tonow Sprite Tiles
;==============================================================
;----------------
; Tonbow Glide
;----------------
TonbowGlide0:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide0.inc"
TonbowGlide0End:
TonbowGlide1:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide1.inc"
TonbowGlide1End:
TonbowGlide2:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide2.inc"
TonbowGlide2End:
TonbowGlide3:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide3.inc"
TonbowGlide3End:
TonbowGlide4:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide4.inc"
TonbowGlide4End:
TonbowGlide5:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide5.inc"
TonbowGlide5End:
TonbowGlide6:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide6.inc"
TonbowGlide6End:
TonbowGlide7:
    .include "..\\assets\\tiles\\sprites\\tonbow\\glide7.inc"
TonbowGlide7End:
;----------------
; Tonbow Flap
;----------------
TonbowFlap0:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap0.inc"
TonbowFlap0End:
TonbowFlap11:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap1.inc"
TonbowFlap1End:
TonbowFlap2:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap2.inc"
TonbowFlap2End:
TonbowFlap3:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap3.inc"
TonbowFlap3End:
TonbowFlap4:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap4.inc"
TonbowFlap4End:
TonbowFlap5:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap5.inc"
TonbowFlap5End:
TonbowFlap6:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap6.inc"
TonbowFlap6End:
TonbowFlap7:
    .include "..\\assets\\tiles\\sprites\\tonbow\\flap7.inc"
TonbowFlap7End:
;----------------
; Tonbow Dash
;----------------
TonbowDash0:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash0.inc"
TonbowDash0End:
TonbowDash1:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash1.inc"
TonbowDash1End:
TonbowDash2:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash2.inc"
TonbowDash2End:
TonbowDash3:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash3.inc"
TonbowDash3End:
TonbowDash4:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash4.inc"
TonbowDash4End:
TonbowDash5:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash5.inc"
TonbowDash5End:
TonbowDash6:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash6.inc"
TonbowDash6End:
TonbowDash7:
    .include "..\\assets\\tiles\\sprites\\tonbow\\dash7.inc"
TonbowDash7End:

TonbowExplosion0:
    .include "..\\assets\\tiles\\sprites\\tonbow\\explosion0.inc"
TonbowExplosion0End:

TonbowExplosion1:
    .include "..\\assets\\tiles\\sprites\\tonbow\\explosion1.inc"
TonbowExplosion1End:

TonbowExplosion2:
    .include "..\\assets\\tiles\\sprites\\tonbow\\explosion2.inc"
TonbowExplosion2End:

TonbowExplosion3:
    .include "..\\assets\\tiles\\sprites\\tonbow\\explosion3.inc"
TonbowExplosion3End:

TonbowExplosion4:
    .include "..\\assets\\tiles\\sprites\\tonbow\\explosion4.inc"
TonbowExplosion4End:

TonbowExplosion5:
    .include "..\\assets\\tiles\\sprites\\tonbow\\explosion5.inc"
TonbowExplosion5End:

TonbowPart0:
    .include "..\\assets\\tiles\\sprites\\tonbow\\part0.inc"
TonbowPart0End:

TonbowPart1:
    .include "..\\assets\\tiles\\sprites\\tonbow\\part1.inc"
TonbowPart1End:

TonbowPart2:
    .include "..\\assets\\tiles\\sprites\\tonbow\\part2.inc"
TonbowPart2End:


;============================================================================================
; Title Screen Data
;============================================================================================
.bank TitleScreenYokoBank 
.org $0000
;========================================================
; Background
;========================================================
;----------------
; Palette
;----------------
TitleScreenBGPal:
    .include "..\\assets\\palettes\\backgrounds\\titleScreen.inc"
TitleScreenBGPalEnd:
;----------------
; BG Tiles
;----------------
TitleScreenTiles:
    .include "..\\assets\\tiles\\backgrounds\\titleScreen.inc"
TitleScreenTilesEnd:

TitleScreenStartTiles:
    .include "..\\assets\\tiles\\backgrounds\\titleScreenStart.inc"
TitleScreenStartTilesEnd:
;----------------
; BG Map
;----------------
TitleScreenMap:
    .include "..\\assets\\maps\\titleScreen.inc"
TitleScreenMapEnd:
;----------------
; Start Options
;----------------
StartTopMap:
	.dw $00F0 $00F1 $00F2 $00F3 $00F1 $00F4 $00F4
StartTopMapEnd:
StartBotMap:
	.dw $00F5 $00F6 $00F7 $00F8 $00F6 $00F4 $00F4
StartBotMapEnd:
OptionsTopMap:
	.dw $00F9 $00F3 $00F1 $00F1 $00F9 $00FA $00F0
OptionsTopMapEnd:
OptionsBotMap:
	.dw $00FB $00FC $00F6 $00FD $00FB $00FE $00F5
OptionsBotMapEnd:
;========================================================
; Sprites
;========================================================
;----------------
; Palette
;----------------
TitleScreenSprPal:
    .include "..\\assets\\palettes\\sprites\\titleScreen.inc"
TitleScreenSprPalEnd:
;----------------
; Satellite
;----------------
SatelliteYoko0Tiles:
    .include "..\\assets\\tiles\\sprites\\satellite\\satelliteYoko0.inc"
SatelliteYoko0TilesEnd:
SatelliteYoko1Tiles:
    .include "..\\assets\\tiles\\sprites\\satellite\\satelliteYoko1.inc"
SatelliteYoko1TilesEnd:
;----------------
; Cursor
;----------------
CursorYokoTiles:
    .include "..\\assets\\tiles\\sprites\\cursor\\yokoCursor.inc"
CursorYokoTilesEnd:


;============================================================================================
; Title Screen TATE Data
;============================================================================================
.bank TitleScreenTateBank 
.org $0000
TitleScreenTateMap:
    .include "..\\assets\\maps\\titleScreenTate.inc"
TitleScreenTateMapEnd:
TitleScreenTateTiles:
    .include "..\\assets\\tiles\\backgrounds\\titleScreenTate.inc"
TitleScreenTateTilesEnd:
TitleScreenTateStartTiles:
.include "..\\assets\\tiles\\backgrounds\\titleScreenTateStart.inc"
TitleScreenTateStartTilesEnd:
;----------------
; Start Options
;----------------
OSMap:
	.dw $00F0 $00F1 $00F2 $00F3 
OSMapEnd:
PTMap:
	.dw $00F4 $00F5 $00F6 $00F7
PTMapEnd:
TAMap:
.dw $00F6 $00F7 $00F8 $00F9
TAMapEnd:
IRMap:
.dw $00FA $00F7 $00FB $00F5
IRMapEnd:
OTMap:
.dw $00F0 $00F1 $00F6 $00F7
OTMapEnd:
NMap:
.dw $00FC $00FD 
NMapEnd:
SMap:
.dw $00F2 $00F3 
SMapEnd:
;----------------
; Satellite
;----------------
SatelliteTate0Tiles:
    .include "..\\assets\\tiles\\sprites\\satellite\\satelliteTate0.inc"
SatelliteTate0TilesEnd:
SatelliteTate1Tiles:
    .include "..\\assets\\tiles\\sprites\\satellite\\satelliteTate1.inc"
SatelliteTate1TilesEnd:
;----------------
; Cursor
;----------------
CursorTateTiles:
    .include "..\\assets\\tiles\\sprites\\cursor\\tateCursor.inc"
CursorTateTilesEnd:


;============================================================================================
; Audio files
;============================================================================================
.bank Audio
.org $0000
SpaceWindPSG:
    .incbin "..\\Audio\\music\\space_wind.bin"
AkiGaHajimaruPSG:
    .incbin "..\\Audio\\music\\aki_ga_hajimaru.bin"
DemoFireSFX:
    .incbin "..\\Audio\\sfx\\demo_fire.bin"
ExplosionSFX:
    .incbin "..\\Audio\\sfx\\explosion.bin"