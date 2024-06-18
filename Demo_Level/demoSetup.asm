;==============================================================
; Reuseable YOKO Setup
;==============================================================
DemoSetUp:
    ld hl, sceneID
    ld (hl), DEMO_LEVEL
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
    ld de, DemoLevelBGPal
    ld b, $10
    call PalBufferWrite


;Write target SPR palette to targetPalette struct
    ld hl, targetSPRPal.color0
    ld de, DemoLevelSprPal
    ld b, $10
    call PalBufferWrite


;Actually update the palettes in VRAM
    call LoadBackgroundPalette
    call LoadSpritePalette

;==============================================================
; Load BG tiles 
;==============================================================

    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ld hl, DemoLevelTiles
    ld bc, DemoLevelTilesEnd-DemoLevelTiles
    call CopyToVDP

;GameOverCursor
    ld hl, GAME_OVER_CURSOR_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOverCursor
    ld bc, GameOverCursorEnd-GameOverCursor
    call CopyToVDP 



;==============================================================
; Write background map
;==============================================================

    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, DemoLevelMap
    ld bc, DemoLevelMapEnd-DemoLevelMap
    call CopyToVDP

;==============================================================
; Write Score
;==============================================================
    ld hl, scoreVRAM | VRAMWrite
    call SetVDPAddress
    ld a, (tateMode)
    bit 0, a
    jr z, +
;TATE Score
    call InitScoreTate
    ;ld hl, scoreTateTiles
    jr +++
+:
;YOKO Score
    call InitScoreYoko
    ld hl, scoreYokoTiles
++:
    ld bc, scoreYokoTilesEnd - scoreYokoTiles
    call CopyToVDP
    call UpdateScoreGraphics

;==============================================================
; Demo Orb sprite
;==============================================================
+++:
;Do our TATE check
    ld hl, tateMode
    ld a, (hl)
    cp $01
    jr z, +
;DemoOrb YOKO 
    ld hl, demoOrbVRAM | VRAMWrite
    call SetVDPAddress
    ld hl, demoOrbTiles
    ld bc, demoOrbTilesEnd-demoOrbTiles
    call CopyToVDP  

;GameOver
    ld hl, GAME_OVER_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOver
    ld bc, GameOverEnd-GameOver
    call CopyToVDP 

;GameOver Again
    ld hl, AGAIN_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, Again
    ld bc, AgainEnd-Again
    call CopyToVDP 
    
;GameOverTitle
    ld hl, GAME_OVER_TITLE_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOverTitle
    ld bc, GameOverTitleEnd-GameOverTitle
    call CopyToVDP 

;GameOverCursor
    ld hl, GAME_OVER_CURSOR_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOverCursor
    ld bc, GameOverCursorEnd-GameOverCursor
    call CopyToVDP 

    ret
+:
;DemoOrb TATE 
    ld hl, demoOrbVRAM | VRAMWrite
    call SetVDPAddress
    ld hl, demoOrbTateTiles
    ld bc, demoOrbTateTilesEnd-demoOrbTateTiles
    call CopyToVDP  

;GameOver TATE
    ld hl, GAME_OVER_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOverTate
    ld bc, GameOverTateEnd-GameOverTate
    call CopyToVDP 

;GameOver Again TATE
    ld hl, AGAIN_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, AgainTate
    ld bc, AgainTateEnd-AgainTate
    call CopyToVDP 
    
;GameOverTitle TATE
    ld hl, GAME_OVER_TITLE_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOverTitleTate
    ld bc, GameOverTitleTateEnd-GameOverTitleTate
    call CopyToVDP 

;GameOverCursor TATE
    ld hl, GAME_OVER_CURSOR_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, GameOverCursorTate
    ld bc, GameOverCursorTateEnd-GameOverCursorTate
    call CopyToVDP 

    ret