;================================================================
; Demo Level
;================================================================
DemoLevel:

    di
;==============================================================
; Scene beginning
;==============================================================
    ld hl, sceneComplete
    ld (hl), $00

    inc hl                                  ;ld hl, sceneID
    ld (hl), $03

;Start off with no sprites
    ld hl, spriteCount
    ld (hl), $00

;Switch to correct bank for Title Assets
    ld a, DemoLevelBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), a


;==============================================================
; Memory (Structures, Variables & Constants) 
;==============================================================

;Structures and Variables
.enum postBoiler export
    tonbow          instanceof tonbowStruct
    tonbowExplosion instanceof spriteStruct
    tonbowExplosionTimer       db           ;Timer for explosion
    tonbowPart0     instanceof spriteStruct
    tonbowPart1     instanceof spriteStruct
    tonbowPart2     instanceof spriteStruct

    scoreOnes instanceof spriteStruct
    scoreTens instanceof spriteStruct
    scoreHuns instanceof spriteStruct
    scoreTATE instanceof spriteStruct

    demoOrb0 instanceof demoOrbStruct
    demoOrb1 instanceof demoOrbStruct
    demoOrb2 instanceof demoOrbStruct
    demoOrb3 instanceof demoOrbStruct
    demoOrb4 instanceof demoOrbStruct
    demoOrb5 instanceof demoOrbStruct
    demoOrb6 instanceof demoOrbStruct
    demoOrb7 instanceof demoOrbStruct
    demoOrb8 instanceof demoOrbStruct
    demoOrb9 instanceof demoOrbStruct
    demoOrbA instanceof demoOrbStruct
    demoOrbB instanceof demoOrbStruct
    demoOrbSpeed        db              ;Speed at which the Demo Orbs move
    demoOrbSpawnTimer   db              ;Are we allowing a demoOrb to spawn now?
    demoOrbSpawnPos     db              ;Where did the previous Demo Orb spawn in?

    orbShot0 instanceof enemyStruct
    orbShot1 instanceof enemyStruct
    orbShot2 instanceof enemyStruct
    orbShot3 instanceof enemyStruct
    orbShot4 instanceof enemyStruct
    orbShot5 instanceof enemyStruct
    orbShot6 instanceof enemyStruct
    orbShot7 instanceof enemyStruct
    orbShot8 instanceof enemyStruct
    orbShot9 instanceof enemyStruct
    orbShotA instanceof enemyStruct
    orbShotB instanceof enemyStruct

    projectileList instanceof enemyListStruct

    gameOverSprite       instanceof spriteStruct
    againSprite          instanceof spriteStruct
    titleSprite          instanceof spriteStruct
    gameOverCursorSprite instanceof cursorStruct

    newHighScore         instanceof spriteStruct
    highScoreFlag       db


.ende

;Constants
.define scoreVRAM                 $3400
.define DEMO_ORB_MAX              $0C             ;As indicated above by the number of demoOrbStructs
.define ORB_SHOT_VRAM             $2480
.define GAME_OVER_VRAM            ORB_SHOT_VRAM + $40
.define AGAIN_VRAM                $26C0
.define GAME_OVER_TITLE_VRAM      $2800
.define GAME_OVER_CURSOR_VRAM     $3F40

.define TONBOW_BOOM               $2940
.define TONBOW_BOOM_CC            $4A

.define TONBOW_PART0              $3340
.define TONBOW_PART0_CC           $9A

.define TONBOW_PART1              $3380
.define TONBOW_PART1_CC           $9C

.define TONBOW_PART2              $33C0
.define TONBOW_PART2_CC           $9E

;==============================================================
; Intialize our Variables
;==============================================================
    xor a

    ld (frameCount), a 

    ld hl, highScoreFlag
    ld (hl), a

    ld hl, demoOrbSpeed
    ld (hl), $0C                        ;Level 1 demoOrbSpeed

;Set to 0 for smooth transition
    ld (scrollX0), a
    ld (scrollX1), a
    ld (scrollX0Frac), a
    ld (scrollX0Frac + 1), a
    ld (scrollX1Frac), a
    ld (scrollX1Frac + 1), a
    ld (VDPStatus), a
    ld (score), a
    ld (score + 1), a




;==============================================================
; Intialize our objects
;==============================================================

    call InitTonbow                     ;Initialie our Tonbow's variables, as well as GAME OVER

    ld a, (tateMode)
    bit 0, a
    call z, InitScoreYoko
    ld a, (tateMode)
    bit 0, a
    call nz, InitScoreTate

    ld hl, enemyList.enemyCount
    ld a, $01                           ;\ Initialize enemy list to support 1 enemy and 1 projectile
    call InitEnemyList                  ;/
    ld hl, projectileList.enemyCount
    ld a, $01                           ;\ Initialize projectile list to support 1 enemy and 1 projectile
    call InitEnemyList                  ;/
    

    ld hl, demoOrb0.sprNum  
    ld a, $40                          ;Position is $46
    ld b, $04
    call InitDemoOrb                   ;call InitDemoEnemies
    ld de, demoOrb0.hitBox.width
    ld hl, enemyList.enemyCount
    call EnemyList@CheckAvailability

    ld hl, demoOrbSpawnTimer
    ld (hl), $00

;Set all demoOrbs to be dead
    ld hl, demoOrb1.state
    ld b, DEMO_ORB_MAX - 1
    ld de, _sizeof_demoOrbStruct
-:
    add hl, de
    ld (hl), $00
    djnz -
;Set all demoOrbs to be spawnable
    ld hl, demoOrb0.spawnTimer
    ld b, DEMO_ORB_MAX - 1
    ld de, _sizeof_demoOrbStruct
-:
    add hl, de
    ld (hl), $00
    djnz -

;Initialize orbShots
    call InitOrbShots

;==============================================================
; Clear VRAM
;==============================================================
    call BlankScreen

    call ClearVRAM

    call ClearSATBuff

;Reset scroll values
    xor a
    out (PORT_VDP_ADDRESS), a
	ld a, $88
	out (PORT_VDP_ADDRESS), a		;Set BG X-Scroll to 0

    xor a
    out (PORT_VDP_ADDRESS), a
	ld a, $89
	out (PORT_VDP_ADDRESS), a		;Set BG Y-Scroll to 0

;==============================================================
; Setup backdrop
;==============================================================
    call DemoSetUp

;==============================================================
; Load Sprite tiles 
;==============================================================
;Switch to correct bank for Title Assets
    ld a, TonbowTilesBank
    ld ($FFFF), a
;Tonbow
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ld hl, TonbowGlide0
    ld bc, TonbowGlide0End-TonbowGlide0
    call CopyToVDP  

    ld hl, TONBOW_BOOM | VRAMWrite
    call SetVDPAddress
    ld hl, TonbowExplosion0
    ld bc, TonbowExplosion5End-TonbowExplosion0
    call CopyToVDP  

    ld hl, TONBOW_PART0 | VRAMWrite
    call SetVDPAddress
    ld hl, TonbowPart0
    ld bc, TonbowPart0End-TonbowPart0
    call CopyToVDP 

    ld hl, TONBOW_PART1 | VRAMWrite
    call SetVDPAddress
    ld hl, TonbowPart1
    ld bc, TonbowPart1End-TonbowPart1
    call CopyToVDP 

    ld hl, TONBOW_PART2 | VRAMWrite
    call SetVDPAddress
    ld hl, TonbowPart2
    ld bc, TonbowPart2End-TonbowPart2
    call CopyToVDP 
    

;Switch to correct bank for Title Assets
    ld a, DemoLevelBank
    ld ($FFFF), a
;DemoOrb AND explosion
    ld hl, demoOrbVRAM | VRAMWrite
    call SetVDPAddress
    ld hl, demoOrbTiles
    ld bc, demoOrbExplosionTiles4End-demoOrbTiles
    call CopyToVDP  

;OrbShot
    ld hl, ORB_SHOT_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, orbShotTiles
    ld bc, orbShotTilesEnd-orbShotTiles
    call CopyToVDP 

;Do our TATE check
    ld hl, tateMode
    ld a, (hl)
    cp $01
    jr z, +
;-----------------------------------------------------------------
;YOKO

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

;New High Score
    ld hl, NEW_HIGH_SCORE_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, NewHighScoreYoko
    ld bc, NewHighScoreYokoEnd-NewHighScoreYoko
    call CopyToVDP 
    jr ++
;-----------------------------------------------------------------
;TATE
+:
;DemoOrb TATE ONLY
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

;New High Score
    ld hl, NEW_HIGH_SCORE_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, NewHighScoreTate
    ld bc, NewHighScoreTateEnd-NewHighScoreTate
    call CopyToVDP 

;==============================================================
; Set Registers for HBlank
;==============================================================
++:
    ld a, $FF                               ;$07 = HBlank every 8 scanlines
    ld c, $8A
    call UpdateVDPRegister

;Blank Left Column
    ld a, %00110100                         ;BIT 5 BLANK column
    ld c, $80
    call UpdateVDPRegister
    jr +


;==============================================================
; Returning To Demo Level
;==============================================================
ReturnToDemoLevel                           ;Used to activate/reactivate the Demo Level
    halt
    call UpdateSAT                          ;Refresh our sprites
;Switch to correct bank for Title Assets
    ld a, DemoLevelBank
    ld ($FFFF), a
;Check if TATE or YOKO
    ld a, (tateMode)
    bit 0, a
    jr nz, PauseTateExit
;YOKO
    ld hl, pauseCursor.yPos                 ;Move the arrow to exit
    ld (hl), $66
;New High Score
    ld hl, NEW_HIGH_SCORE_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, NewHighScoreYoko
    ld bc, NewHighScoreYokoEnd-NewHighScoreYoko
    call CopyToVDP 
    jr UpdatePauseSprites
;TATE
PauseTateExit:
    ld hl, pauseCursor.xPos                 ;Move the arrow to exit
    ld (hl), $80
    ;New High Score
    ld hl, NEW_HIGH_SCORE_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, NewHighScoreTate
    ld bc, NewHighScoreTateEnd-NewHighScoreTate
    call CopyToVDP 

UpdatePauseSprites:
    call UpdatePauseSpriteBuffer            ;Update all of the sprites on the screen
    halt 
    call UpdateSAT                          ;Last update before fade to black

;If no changes were made, then reset the Options Buffer to reflect the actual status of Options Byte
    ld hl, optionsBuffer
    ld a, (optionsByte)
    ld (hl), a

    call FadeToBlack
;Are we in TATE or YOKO mode?
    call DemoSetUp
    
+:
;Previsualization for fade in
    ;call UpdateSAT                      
;Update our Tonbow sprite if it's alive
    ld a, (tonbow.alive)
    bit 0, a
    jr z, +          
    ld hl, tonbow.sprNum   
    call MultiUpdateSATBuff  
+:
;Change sprites to be 8x16 but keep screen off
    ld a, %00000010                         
    ld c, $81
    call UpdateVDPRegister
    call UpdateSAT                          ;Remove previous screen's sprites
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

;Set up interrupts for the reset
    ei
    halt
;Prevent sprite scrambling if pause button is hit, and make sure we don't update VRAM if on HBLANK
    ld a, (VDPStatus)             ;Check if we are at VBlank
    or a
    jp p, DemoLoop                  ;If on HBlank, don't execute this code

    ld hl, FirstHBlank
    ld (nextHBlankStep), hl         ;Prepare the step for the next HBLANK

    

;========================================================
; Game Logic
;========================================================
    ld hl, frameFinish
    ld (hl), $01


    halt     
    ld a, $0F
    out (PORT_VDP_ADDRESS), a
	ld a, $8A
	out (PORT_VDP_ADDRESS), a		;Set VDP 10,Raster Line Interrupt, to 16

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
    ld hl, SpaceWindPSG
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
    ld de, SpaceWindFM
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

DemoLoop:
;Start LOOP
    halt
;Prevent sprite scrambling if pause button is hit, and make sure we don't update VRAM if on HBLANK
    ld a, (VDPStatus)             ;Check if we are at VBlank
    or a
    jp p, DemoLoop                  ;If on HBlank, don't execute this code
;We are not ready for the next frame
    ld hl, frameFinish
    ld a, (hl)
    cp $11
    jr nz, DemoLoop
    ld (hl), $00
;Check if we need to pause
    ld a, (sceneID)
    cp PAUSE_SCREEN
    jp z, SetUpPause

;Update Sprites
    call UpdateSAT 

;Update Tonow's sprite in VRAM
    call UpdateTonbowGraphics
    
;Update DemoOrb palette
    call DemoOrbPaletteSwap         ;Done during VBlank so no particles drawn on screen

;--------------------
; Update Objects
;--------------------
    ld a, (tateMode)
    cp $01
    jp z, +
;Update score
    call UpdateScoreGraphics
    ;Ones
    ld hl, scoreOnes.sprNum
    call MultiUpdateSATBuff
    ;Tens
    ld hl, scoreTens.sprNum
    call MultiUpdateSATBuff
    ;Hundreds
    ld hl, scoreHuns.sprNum
    call MultiUpdateSATBuff
    jr +++
+:
;Update TATE Score
    ld a, (frameCount)
    bit 0, a
    jr nz, ++
    call UpdateScoreGraphicsTate
++:
    ld hl, scoreTATE.sprNum
    call MultiUpdateSATBuff
+++:
;Update Tonbow based on Player inputs
    call UpdateTonbow
    ld a, (tonbow.alive)            ;\
    cp $00                          ; } Check if Tonbow is Alive
    jr nz, +                        ;/

;----------------------------------------------------------------------------------
HandleGameOverCondition:
;Handle Tonbow death animation and explosion
@PartsHandling:
    ld a, (tonbowPart0.flag)
    ld b, a
    ld a, (tonbowPart1.flag)
    add a, b
    ld b, a
    ld a, (tonbowPart2.flag)
    add a, b
    cp $00
    jr z, @ExplosionFinished

    call UpdateTonbowParts          ;Calls MultiUpdateSATBuff for our parts

@ExplosionHandling:
    ld a, (tonbowExplosionTimer)    ;\    
    cp $00                          ; }
    jr z, @ExplosionFinished        ; } Run Explosion animation
    call TonbowExplosionHandler     ; }
    ld hl, tonbowExplosion.sprNum   ; }
    call MultiUpdateSATBuff         ;/
;If the explosion is still ongoing, then don't show the game over screen yet
    jr ++

@ExplosionFinished:
;Update Game Over screen
    ld hl, gameOverSprite.sprNum
    call MultiUpdateSATBuff
    ld hl, gameOverCursorSprite.sprNum
    call MultiUpdateSATBuff
    ld hl, againSprite.sprNum
    call MultiUpdateSATBuff
    ld hl, titleSprite.sprNum
    call MultiUpdateSATBuff
;Check if we got a high score
    ld a, (highScoreFlag)
    bit 0, a
    jr z, NoHighScore
    ld hl, newHighScore
    call MultiUpdateSATBuff
NoHighScore:
;Update Game Over Cursor
    call GameOverCursorCheck
    jr ++
;----------------------------------------------------------------------------------

+:
;Update our Tonbow sprite if it's alive
    ld hl, tonbow.sprNum              
    call MultiUpdateSATBuff 
++:
;Switch off which is updated first so you can see enemies and projectiles equally
    ld a, (frameCount)
    bit 0, a
    jr z, ProjectileFirst
EnemyFirst:
;Update Enemy AI
    ld hl, enemyList.enemyCount
    call EnemyList@UpdateEnemyAI
;Update Projectile AI
    ld hl, projectileList.enemyCount
    call EnemyList@UpdateEnemyAI
    jr +
    
ProjectileFirst:
;Update Projectile AI
    ld hl, projectileList.enemyCount
    call EnemyList@UpdateEnemyAI
;Update Enemy AI
    ld hl, enemyList.enemyCount
    call EnemyList@UpdateEnemyAI

+:
;Now we are now finished with VBlank check, and SPR collision check
;So wipe the VDPStatus
    xor a
    ld (VDPStatus), a
;--------------------
; Update BG Scrolling
;--------------------
    call DemoUpdateBGParallax

;--------------------
; Update SAT Buffer
;--------------------
    call UpdateEnemySpritesList
    call UpdateProjectileSpritesList

+:
;Check if we need to spawn more Demo Orbs
    call SpawnDemoOrb


;End Loop
    ld hl, sceneComplete
    ld a, (hl)
    cp $02
    ret z
    cp $01
    jp z, DemoLevel

    ld hl, frameFinish
    ld (hl), $01
    
    jp DemoLoop

;-------------------------------------------------------------------------------------

UpdateEnemySpritesList:
;Rearrange enemy sprite order
    ld a, (enemyList.enemyCount)    ;\
    cp $00                          ; } Check if there are any enemies
    ret z                           ;/
;If there are, then rearrange the list if there is more than 1 enemy on screen
    ld hl, enemyList.enemyCountMax
    ld a, (hl)
    cp $01
    ret z
;More than 1 enemy in the list
    ld hl, enemyList.enemy0 + 1
    ld a, (hl)
    ld ixh, a
    dec hl
    ld a, (hl)
    ld ixl, a
    ld c, 0
    ld de, enemyList.enemyCount
    push hl
        call EnemyList@RemoveEnemy
    pop hl
    ld de, enemyList
    ld a, ixl
    ld l, a
    ld a, ixh
    ld h, a
    ex de, hl
    ld hl, enemyList.enemyCount
    call EnemyList@CheckAvailability
    ret

UpdateProjectileSpritesList:
;Rearrange enemy sprite order
    ld a, (projectileList.enemyCount)    ;\
    cp $00                               ; } Check if there are any enemies
    ret z                                ;/
;If there are, then rearrange the list if there is more than 1 enemy on screen
    ld hl, projectileList.enemyCountMax
    ld a, (hl)
    cp $01
    ret z
;More than 1 enemy in the list
    ld hl, projectileList.enemy0 + 1
    ld a, (hl)
    ld ixh, a
    dec hl
    ld a, (hl)
    ld ixl, a
    ld c, 0
    ld de, projectileList.enemyCount
    push hl
        call EnemyList@RemoveEnemy
    pop hl
    ld de, projectileList
    ld a, ixl
    ld l, a
    ld a, ixh
    ld h, a
    ex de, hl
    ld hl, projectileList.enemyCount
    call EnemyList@CheckAvailability

    ret


