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

;==============================================================
; Memory (Structures, Variables & Constants) 
;==============================================================

;Structures and Variables
.enum postBoiler export
    titleCursor         instanceof cursorStruct
    satellite           instanceof spriteStruct
    satelliteTimer      db
    satellitePosition   db
.ende

;Constants
.define nothingConstant     $0000
.define SATELLITE_TIME      $60
.define SATELLITE_POS       $01

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
EndDrawTitleScreen:



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

    call FadeToBlack

	ret




