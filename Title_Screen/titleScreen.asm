;================================================================
; Title Screen
;================================================================
TitleScreen:

;==============================================================
; Scene beginning
;==============================================================
    ld hl, sceneComplete
    ld (hl), $00

    inc hl                                  ;ld hl, sceneID
    ld (hl), $02

;Start off with no sprites
    ld hl, spriteCount
    ld (hl), $00

;Switch to correct bank for Title Assets
    ld a, TitleScreenYokoBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), a

;==============================================================
; Memory (Structures, Variables & Constants) 
;==============================================================

;Structures and Variables
.enum postBoiler export
    titleCursor         instanceof cursorStruct
    satellite           instanceof spriteStruct
    satelliteTimer      db
    satellitePosition   db
    scoreDigitCheck     db  ;Used to check if the previous digit was't drawn
.ende

;Constants
.define nothingConstant         $0000
.define SATELLITE_TIME          $60
.define SATELLITE_POS           $01
.define HIGH_SCORE_FONT_BLANK   $0480
.define HIGH_MAP_START_TATE     $3AC8
.define PLAYER_MAP_START_TATE   $3AC6

;==============================================================
; Intialize our Variables
;==============================================================
    xor a

    ld (frameCount), a 

;Satellite Attributes
    ld hl, satellite.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, satelliteTop.width
    ;Sprite is 1x1 for 8x16
    ld (hl), $06                        
    inc hl                              ;ld hl, satelliteTop.height
    ld (hl), $03                        
    inc hl                              ;ld hl, satelliteTop.yPos
;Do some TATE trickery
    ld a, (tateMode)
    bit 0, a
    jr nz, +
    ld (hl), $60
    inc hl                              ;ld hl, satelliteTop.xPos
    ld (hl), $18
    jr ++
+:
;TATE Coordinates
    ld (hl), $0A
    inc hl                              ;ld hl, satelliteTop.xPos
    ld (hl), $40
++:
    
    inc hl                              ;ld hl, satelliteTop.cc
    ld (hl), $00

    ld hl, satelliteTimer
    ld (hl), SATELLITE_TIME
    ld hl, satellitePosition
    ld (hl), SATELLITE_POS


;Title Cursor Attributes
    ld hl, titleCursor.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, titleCursor.width
    ;Sprite is 1x1 for 8x16
    ld (hl), $01                        
    inc hl                              ;ld hl, titleCursor.height
    ld (hl), $01                        
    inc hl                              ;ld hl, titleCursor.yPos
;Do some TATE trickery
    ld a, (tateMode)
    bit 0, a
    jr nz, +
    ld (hl), $80
    inc hl                              ;ld hl, titleCursor.xPos
    ld (hl), $6C
    jr ++
+:
;TATE Coordinates
    ld (hl), $46
    inc hl                              ;ld hl, titleCursor.xPos
    ld (hl), $4A
++:
    inc hl                              ;ld hl, titleCursor.cc
    ld (hl), $FA
    ld hl, titleCursor.state                             
    ld (hl), $00
    inc hl                              ;ld hl, titleCursor.coolDownTimer
    ld (hl), $00


;==============================================================
; Clear VRAM
;==============================================================
    call BlankScreen

    call ClearVRAM

    call ClearSATBuff

;==============================================================
; Load Palette
;==============================================================
;All black palette to be used once we are making things pretty
;Write current BG palette to currentPalette struct
    ld hl, currentBGPal.color0
    ld de, FadedPalette
    ld b, $10
    call PalBufferWrite

;Write current SPR palette to currentPalette struct
    ld hl, currentSPRPal.color0
    ld de, FadedPalette
    ld b, $10
    call PalBufferWrite

;Write target BG palette to targetPalette struct
    ld hl, targetBGPal.color0
    ld de, TitleScreenBGPal
    ld b, $10
    call PalBufferWrite


;Write target SPR palette to targetPalette struct
    ld hl, targetSPRPal.color0
    ld de, TitleScreenSprPal
    ld b, $10
    call PalBufferWrite

;Actually update the palettes in VRAM
    call LoadBackgroundPalette
    call LoadSpritePalette

;==============================================================
; Load BG tiles 
;==============================================================
    
    ld a, (tateMode)
    bit 0, a
    jp nz, DrawTateTitle
DrawYokoTitle:
;----------------
; Tiles
;----------------
;Put Title Screen Tiles into VRAM
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ld hl, TitleScreenTiles
    ld bc, TitleScreenTilesEnd-TitleScreenTiles
    call CopyToVDP
;Throw the START and OPTIONS into VRAM
	ld hl, $1E00 | VRAMWrite
    call SetVDPAddress
    ld hl, TitleScreenStartTiles
    ld bc, TitleScreenStartTilesEnd-TitleScreenStartTiles
    call CopyToVDP
;For HIGH SCORE
	ld hl, $3200 | VRAMWrite
    call SetVDPAddress
    ld hl, HighYokoTiles
    ld bc, HighYokoTilesEnd-HighYokoTiles
    call CopyToVDP

;----------------
; BG Map
;----------------
;Write Background Map
    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, TitleScreenMap
    ld bc, TitleScreenMapEnd-TitleScreenMap
    call CopyToVDP
;Throw the START onto the screen
	ld hl, $3C1E | VRAMWrite
    call SetVDPAddress
    ld hl, StartTopMap
    ld bc, StartTopMapEnd-StartTopMap
    call CopyToVDP
	ld hl, $3C5E | VRAMWrite
    call SetVDPAddress
    ld hl, StartBotMap
    ld bc, StartBotMapEnd-StartBotMap
    call CopyToVDP
;Throw the OPTIONS onto the screen
	ld hl, $3C9E | VRAMWrite
    call SetVDPAddress
    ld hl, OptionsTopMap
    ld bc, OptionsTopMapEnd-OptionsTopMap
    call CopyToVDP
	ld hl, $3CDE | VRAMWrite
    call SetVDPAddress
    ld hl, OptionsBotMap
    ld bc, OptionsBotMapEnd-OptionsBotMap
    call CopyToVDP
;Write High score 
    ld hl, $3D9E | VRAMWrite
    call SetVDPAddress
    ld hl, HighYokoMap
    ld bc, HighYokoMapEnd-HighYokoMap
    call CopyToVDP
;----------------
; Sprites
;----------------
;Satellite
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ld hl, SatelliteYoko0Tiles
    ld bc, SatelliteYoko0TilesEnd-SatelliteYoko0Tiles
    call CopyToVDP
;Title Cursor
    ld hl, $3F40 | VRAMWrite
    call SetVDPAddress
    ld hl, CursorYokoTiles
    ld bc, CursorYokoTilesEnd-CursorYokoTiles
    call CopyToVDP

    jp EndDrawTitleScreen

DrawTateTitle:
;----------------
; Update Palette
;----------------
    ld hl, targetSPRPal.color0
    ld (hl), $10                ;Dark Blue

;----------------
; Tiles
;----------------
;Swap to bank that contains the TATE title screen data
    ld a, TitleScreenTateBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), a
;Load data into VRAM
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ld hl, TitleScreenTateTiles
    ld bc, TitleScreenTateTilesEnd-TitleScreenTateTiles
    call CopyToVDP
;Throw the START and OPTIONS into VRAM
	ld hl, $1E00 | VRAMWrite
    call SetVDPAddress
    ld hl, TitleScreenTateStartTiles
    ld bc, TitleScreenTateStartTilesEnd-TitleScreenTateStartTiles
    call CopyToVDP

;HIGH into VRAM
	ld hl, $3200 | VRAMWrite
    call SetVDPAddress
    ld hl, HighTateTiles
    ld bc, HighTateTilesEnd-HighTateTiles
    call CopyToVDP
;----------------
; BG Map
;----------------
;Write Background Map
    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, TitleScreenTateMap
    ld bc, TitleScreenTateMapEnd-TitleScreenTateMap
    call CopyToVDP
;Throw the OPTIONS onto the screen
	ld hl, $3ACE | VRAMWrite
    call SetVDPAddress
    ld hl, OSMap
    ld bc, OSMapEnd-OSMap
    call CopyToVDP
	ld hl, $3B0E | VRAMWrite
    call SetVDPAddress
    ld hl, PTMap
    ld bc, PTMapEnd-PTMap
    call CopyToVDP
    ld hl, $3B4E | VRAMWrite
    call SetVDPAddress
    ld hl, TAMap
    ld bc, TAMapEnd-TAMap
    call CopyToVDP
	ld hl, $3B8E | VRAMWrite
    call SetVDPAddress
    ld hl, IRMap
    ld bc, IRMapEnd-IRMap
    call CopyToVDP
    ld hl, $3BCE | VRAMWrite
    call SetVDPAddress
    ld hl, OTMap
    ld bc, OTMapEnd-OTMap
    call CopyToVDP
    ld hl, $3C0E | VRAMWrite
    call SetVDPAddress
    ld hl, NMap
    ld bc, NMapEnd-NMap
    call CopyToVDP
    ld hl, $3C4E | VRAMWrite
    call SetVDPAddress
    ld hl, SMap
    ld bc, SMapEnd-SMap
    call CopyToVDP

;Write HIGH: 068 to the sreen 
    ld b, $07
    ld c, $09                                       ;Using sprite palette
    ld a, $90                                       ;First HIGH in VRAM for map
    ld hl, HIGH_MAP_START_TATE | VRAMWrite          ;Starting point for HIGH: 068
    ld de, $0040                                    ;Value to increment HL to next tile
-:
    call SetVDPAddress
    out (VDPData), a                                ;\
    push af                                         ; }
    ld a, c                                         ; } Write the tile to the map
    out (VDPData), a                                ; }
    pop af                                          ;/
;Increment our data
    inc a
    add hl, de

    djnz -

/*
    ;Put HI score on screen
    ld hl, $3AC6 | VRAMWrite
    call SetVDPAddress
    ld hl, $0990
    ld a, l
    out (VDPData), a
    ld a, h
    out (VDPData), a
;Put GH score on screen
    ld hl, $3B06 | VRAMWrite
    call SetVDPAddress
    ld hl, $0991
    ld a, l
    out (VDPData), a
    ld a, h
    out (VDPData), a

*/



;----------------
; Sprites
;----------------
;Satellite
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ld hl, SatelliteTate0Tiles
    ld bc, SatelliteTate0TilesEnd-SatelliteTate0Tiles
    call CopyToVDP
;Title Cursor
    ld hl, $3F40 | VRAMWrite
    call SetVDPAddress
    ld hl, CursorTateTiles
    ld bc, CursorTateTilesEnd-CursorTateTiles
    call CopyToVDP

;Swap back to default Title screen bank 
    ld a, TitleScreenYokoBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), a
EndDrawTitleScreen:

;Write the individual numbers, this works with TATE and YOKO
;Determine if we're using Yoko or TATE
    ld a, (tateMode)
    cp $01
    jr z, +
;We are in YOKO mode
    ld ix, HighScoreYokoFont
    jr Write100Digit
;We are in TATE mode
+:
    ld ix, HighScoreTateFont
;Swap into TATE bank
    ld a, TitleScreenTateBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), a

Write100Digit:
    ld hl, $3280 | VRAMWrite
    call SetVDPAddress 
    ld a, (highScoreSMS + 1)
    ld de, $20
    call Mult8Bit
;Check if we hit zero
    xor a
    cp l
    jr z, +
    ;ld hl, distance from beginning of HighScoreFont
    ld bc, scoreDigitCheck
    ld a, $01
    ld (bc), a
    ld a, ixh
    ld d, a
    ld a, ixl
    ld e, a
    ;ld de, HighScoreFont 
    add hl, de
-:
    ld bc, $20
    call CopyToVDP
    jr Write10Digit
+:
;If 100's is zero set our flag and set the blank digit
    ld hl, scoreDigitCheck
    ld (hl), $00
    ld a, ixh
    ld h, a
    ld a, ixl
    ld l, a
    ld de, HIGH_SCORE_FONT_BLANK                        ;Get to the end of the file for blank tile
    add hl, de
    ;ld hl, HighScoreFontEnd - $20           
    jr -
Write10Digit:
    ld hl, $32A0 | VRAMWrite
    call SetVDPAddress 
    ld a, (highScoreSMS)        ;Grab 10's and 1's digit
    and $F0                     ;Mask it
    srl a
    srl a
    srl a
    srl a                       ;Shift it over to get one digit
    ld de, $20
    call Mult8Bit
;Check if we hit zero
    xor a
    cp l
    jr z, +
    ;ld hl, distance from beginning of HighScoreYokoFont
--:
    ld bc, scoreDigitCheck
    ld a, $01
    ld (bc), a
    ld a, ixh
    ld d, a
    ld a, ixl
    ld e, a
    ;ld de, HighScoreFont 
    add hl, de
-:
    ld bc, $20
    call CopyToVDP
    jr Write1Digit
+:
;If 10's is zero check out flag and maybe set the blank digit
    ld bc, scoreDigitCheck
    ld a, (bc)
    cp $00
    jr nz, --                           ;100's wasn't a zero, so go back
    xor a
    ld (bc), a                          ;Otherwise set flag and print nothing
    ld a, ixh
    ld h, a
    ld a, ixl
    ld l, a
    ld de, HIGH_SCORE_FONT_BLANK
    add hl, de
    ;ld hl, HighScoreYokoFontEnd - $20
    jr -
Write1Digit:
    ld hl, $32C0 | VRAMWrite
    call SetVDPAddress 
    ld a, (highScoreSMS)        ;Grab 10's and 1's digit
    and $0F                     ;Mask it for 1's
    ld de, $20
    call Mult8Bit
    ;ld hl, distance from beginning of HighScoreYokoFont
    ld a, ixh
    ld d, a
    ld a, ixl
    ld e, a
    ;ld de, HighScoreFont 
    ;ld de, HighScoreFont 
    add hl, de
    ld bc, $20
    call CopyToVDP

;Swap back to YOKO for game logic Title screen bank 
    ld a, TitleScreenYokoBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), a

;==============================================================
; Turn on screen
;==============================================================
 ;(Maxim's explanation is too good not to use)
    ld a, %01100010
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Doubled sprites -> 8x16
;           ||||`--- Mega Drive mode 5 enable
;           |||`---- 30 row/240 line mode
;           ||`----- 28 row/224 line mode
;           |`------ VBlank interrupts
;            `------- Enable display    
    ld c, $81
    call UpdateVDPRegister

;Turn H-BLANK off
	ld a, $FF                               
    ld c, $8A
    call UpdateVDPRegister

    ei

	ld hl, satellite.sprNum   
    call MultiUpdateSATBuff  
    ld hl, titleCursor.sprNum   
    call MultiUpdateSATBuff  
	halt
	call UpdateSAT 

	call FadeIn

;Begin Music
;Work in the Audio Bank
    ld a, Audio
    ld ($FFFF), a
;Check for FM
    ld a, (playFM)
    cp $01
    jr z, +
;PSG Space Wind
    ;Turn FM off
    ld hl, onFM
    ld (hl), $00
    ld a, $00
    out ($f2),a
    ld hl, DangerousPlanetPSG
    call PSGPlay 
    jr ++
;FM Space Wind
+:
;If we have it, we want to use FM
    ld hl, onFM
    ld (hl), $01
;So turn it on
    ld a, $01
    out ($f2),a
    ld hl, MBMStart
    ld de, DangerousPlanetFM
    ld a, e
    ld (hl), a
    ld a, d
    inc hl
    ld (hl), a
    call MBMPlay
;Switch to correct bank for Title Assets
++:
    ld a, (currentBank)
    ld ($FFFF), a

TitleLoop:
	halt     
;Prevent sprite scrambling if pause button is hit
    ld a, (VDPStatus)       ;Check if we are at VBlank
    or a
    jp p, TitleLoop               ;If not on VBlank, don't execute this code 

;Update Sprites                          
    call UpdateSAT 
;Reset VBlank status
    ld hl, VDPStatus
    ld a, (hl)
    res 7, a
    ld (hl), a

;Update Satellite
    ld hl, satelliteTimer
    ld a, (hl)
    cp $00
    jr nz, +
    ld (hl), SATELLITE_TIME     ;Reset timer
    ld hl, satellitePosition
    ld a, (hl)
    neg
    ld (hl), a                  ;Satellite will bounce up and down, so reverse the direction
    ld b, a                     ;Save A
    ld hl, satellite.yPos
;Adjust for TATE MODE
    ld a, (tateMode)
    ld d, $00
    ld e, a
    add hl, de
;Adjust Satellite position for bounce
    ld a, b                     ;Revive A
    add a, (hl)
    ld (hl), a
    jr ++                       ;Don't decrease timer
+:
;Decrease timer
    dec (hl)
++:
;Update Satellite Sprite
	ld hl, satellite.sprNum   
    call MultiUpdateSATBuff  


;Update Cursor
    call TitleCursorCheck
    ld hl, titleCursor.sprNum   
    call MultiUpdateSATBuff  

    ld a, (sceneComplete)
    cp $00
	jp z, TitleLoop

;If we're done...

;Cut the music
    ld a, Audio
    ld ($FFFF), a
;Check for FM
    ld a, (playFM)
    cp $01
    jr z, +
    call PSGStop
    jr ++
+:
    call MBMStop
++:
;Switch to correct bank for Title Assets
    ld a, (currentBank)
    ld ($FFFF), a   
;Cut to black

    call FadeToBlack

	ret




