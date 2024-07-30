
;==============================================================
; Constants
;==============================================================
.define demoOrbVRAM     $2180
.define demoOrbIndex    $0C
.define EXPLOSION0      $0D
.define EXPLOSION1      $11
.define EXPLOSION2      $15
.define EXPLOSION3      $19
.define EXPLOSION4      $1D

.define DEMO_ORB_RESPAWN_TIME    $10



;Updates a DemoOrb's position etc
;Parameters: DE = demoOrb.state
;Affects: A, HL, DE
UpdateDemoOrb:
    ex de, hl
;Check if dying
    ld a, (hl);(demoOrb.alive)      ;\
    bit 0, a                        ; } Check if Demo Orb is alive
    jr z, +                         ;/
    cp $FF                          ;Check if Dying
    jp z, DemoOrbDeathAnimation     ;If dying then do dying animation
;Check if at the end of the screen
    ld de, demoOrbStruct.xPos - demoOrbStruct.state
    add hl, de
    call CheckDemoOrbPos
;Update position
    ld de, demoOrbStruct.yFracPos - demoOrbStruct.xPos
    add hl, de
    call UpdateDemoOrbPosition
;Move Demo Orb
    ld de, demoOrbStruct.xFracPos - demoOrbStruct.hitBox.height 
    add hl, de
    call DemoOrbMove
;Check collision
    ld de, demoOrbStruct.hitBox.width - demoOrbStruct.xFracPos
    add hl, de
    call EnemyList@TonbowHurtboxCollisionCheck
;Update Demo Orb's sprite
    ld de, demoOrbStruct.sprNum - demoOrbStruct.hitBox.width
    add hl, de
    call MultiUpdateSATBuff
+:
    ret

;Checks if Demo Orb is at the edge of the screen
;Parameters: HL = demoOrb.xPos
;Affects: HL, DE, A, B, C
CheckDemoOrbPos:
    ld a, (hl)
    cp $08
    jr nc, +
;If at the end, set to explode and spawn a shot
    ld de, demoOrbStruct.state - demoOrbStruct.xPos
    add hl, de
    ld (hl), $FF
;Spawn Shot
    call SpawnOrbShot
    
;Update position
    ld de, demoOrbStruct.xPos - demoOrbStruct.state
    add hl, de
    ret
+:
    ret

;Deciphers yFracPos from special WORD into sprite coordinates for yPos xPos for demoOrb
;Parameters: HL = demoOrb.yFracPos
;Affects: HL, DE, A, B, C
UpdateDemoOrbPosition:
;Set Y-Fractional-Position to Sprite position 
    ;ld hl, demoOrb.yFracPos                      ;(HL) = WHOLE LO, FRAC
    ld a, (hl)
    srl a
    srl a
    srl a
    srl a                                       ;A = $Aa... A = 0, a = WHOLE LO
    inc hl                                      ;(HL) = UNUSED, WHOLE HI
    push hl                                     ;Save demoOrb.yFracPos HI for later
        ld b, a
        ld a, (hl)
        sla a
        sla a
        sla a
        sla a                                       ;A = $Aa... A = WHOLE HI, a = 0
        or b                                        ;A = WHOLE HI, WHOLE LO
        ld d, $FF       ;\
        ld e, demoOrbStruct.yPos - (demoOrbStruct.yFracPos + 1)      ; } ld hl, demoOrb.yPos
        add hl, de      ;/
        ld (hl), a 
        ld c, a                                     ;Save demoOrb.yPos
    pop hl                                     ;Recover demoOrbyFracPos HI
;Set X-Fractional-Position to Sprite position
    inc hl        ;ld hl, demoOrb.xFracPos     ;(HL) = WHOLE LO, FRAC
    ld a, (hl)
    srl a
    srl a
    srl a
    srl a                                       ;A = $Aa... A = 0, a = WHOLE LO
    inc hl                                      ;(HL) = UNUSED, WHOLE HI
    ld b, a
    ld a, (hl)
    sla a
    sla a
    sla a
    sla a                                       ;A = $Aa... A = WHOLE HI, a = 0
    or b                                        ;A = WHOLE HI, WHOLE LO
    ld e, demoOrbStruct.xPos - (demoOrbStruct.xFracPos + 1) ;Get to demoOrb.xPos
    add hl, de   ;ld hl, demoOrb.xPos
    ld (hl), a
    ld e, demoOrbStruct.hitBox.y1 - demoOrbStruct.xPos
    add hl, de   ;ld hl, demoOrb.hitBox.y1

;Update Demo Orb's hitbox Position
;Parameters: HL = demoOrb.hitBox.y1, A = demoOrb.xPos, C = demoOrb.yPos
;Affects: HL, A, C
UpdateDemoOrbHitBox:
    ;ld hl, demoOrb.hitBox.y1
    ;ld c, (demoOrb.yPos)
    ;ld a, (demoOrb.xPos)
    ld (hl), c
    inc hl                              ;ld hl, demoOrb.hitBox.x1
    ld (hl), a
    inc hl                              ;ld hl, demoOrb.hitBox.y2
    inc hl                              ;ld hl, demoOrb.hitBox.x2
    push hl                             ;\
    ex de, hl                           ; }
    pop hl                              ; } HL = demoOrb.hitBox.width, DE = demoOrb.hitBox.x2
    inc hl                              ;/ 
    add a, (hl)
    ld (de), a                          ;demoOrb hitbox X coordinate has been updated
    ld a, c
    dec de                              ;ld de, demoOrb.hitBox.y2
    inc hl                              ;ld hl, demoOrb.hitBox.height
    add  a, (hl)
    ld (de), a                          ;demoOrb hitbox Y coordinate has been updated

    ret


;Move the Demo Orb across the screen
;Parameters: HL = demoOrb.xFracPos
;Affects: HL, A, C
DemoOrbMove:
    ld a, (demoOrbSpeed)
    ld b, a
    ld a, (hl)
    sub a, b
    call c, DemoOrbMoveCarry
    ld (hl), a

    ret
DemoOrbMoveCarry:
    inc hl
    dec (hl)
    dec hl
    ret

;Collision with an attacking Tonbow
;Parameters: HL = demoOrb.state, demoOrb.alive == $FF
;Affects: HL, DE
DemoOrbDeathAnimation:
;Set Hitbox to zero
    ld de, demoOrbStruct.hitBox.width - demoOrbStruct.state
    add hl, de    
    ld (hl), 0                      ;ld hl, demoOrb.animationTimer
    ld de, demoOrbStruct.animationTimer - demoOrbStruct.hitBox.width
    add hl, de                          ;ld hl, demoOrb.animationTimer
    ld a, (hl)                          ;A holds the timer
    cp $00
    call z, SetDemoOrbDeathAnimationTimer
    ld de, demoOrbStruct.cc - demoOrbStruct.animationTimer
    add hl, de                          ;ld hl, demoOrb.cc
;Set correct frame
    cp 07
    jp c, DemoOrbDeathFrame4
    cp 13
    jp c, DemoOrbDeathFrame3
    cp 19
    jp c, DemoOrbDeathFrame2
    cp 25
    jp c, DemoOrbDeathFrame1
    cp 31
    jp c, DemoOrbDeathFrame0

DemoOrbDeathFrame0:
    ld (hl), EXPLOSION0
    jp EndDemoOrbAnimationUpdate
DemoOrbDeathFrame1:
    ld (hl), EXPLOSION1
    jp EndDemoOrbAnimationUpdate
DemoOrbDeathFrame2:
    ld (hl), EXPLOSION2
    jp EndDemoOrbAnimationUpdate
DemoOrbDeathFrame3:
    ld (hl), EXPLOSION3
    jp EndDemoOrbAnimationUpdate
DemoOrbDeathFrame4:
    ld (hl), EXPLOSION4
    jp EndDemoOrbAnimationUpdate

EndDemoOrbAnimationUpdate:
    ld de, demoOrbStruct.animationTimer - demoOrbStruct.cc
    add hl, de                          ;ld hl, demoOrbStruct.animationTimer
    ld a, (hl)
    cp $01
    jr nz, +
    ld de, demoOrbStruct.state - demoOrbStruct.animationTimer
    add hl, de
    ld (hl), $00                        ;He's Dead Jim
    ld de, demoOrbStruct.spawnTimer - demoOrbStruct.state
    add hl, de
    ld (hl), DEMO_ORB_RESPAWN_TIME
    dec hl                              ;ld hl, demoOrb.animationTimer

+:
    dec (hl) 
;Update Demo Orb's sprite
    ld de, demoOrbStruct.sprNum - demoOrbStruct.animationTimer
    add hl, de
    call MultiUpdateSATBuff
    ret

SetDemoOrbDeathAnimationTimer:
    ld (hl), 30
    ld a, (hl)
    ret


DemoOrbPaletteSwap:
;Update Demo Orb palette (stupid but it works I guess)
    ld hl, $C017 | CRAMWrite
    call SetVDPAddress
    ld a, (frameCount)
    cp $0F
    jr nc, +
-:
    cp $2D
    jr nc, ++
    ld a, $02
    out (VDPData), a
    ld a, $20
    out (VDPData), a
    jr +++
+:
    cp $1E
    jr nc, -
++:
    ld a, $20
    out (VDPData), a
    ld a, $02
    out (VDPData), a
+++:
    ret

;================================================================
; Spawn Demo Orb
;================================================================
;Spawn Demo Orb to a random Y coordinate at the right side of the screen
;Parameters: 
;Affects: HL
SpawnDemoOrb:
;Check if we can spawn a Demo Orb
    ld hl, demoOrbSpawnTimer
    ld a, (hl)
    cp $00
    jr z, +         
    dec (hl)
    ret

+:
;Set up DJNZ
    ld b, DEMO_ORB_MAX
    ld hl, demoOrb0.state               ;Otherwise, get ready to check 
-:
;Check if we are at the max, since we may have added a new demo Orb
    ld a, (enemyList.enemyCountMax)
    ld c, a
    ld a, (enemyList.enemyCount)
    sub a, c
    jp nc, @EndSpawnDemoOrb              ;If we already have the max, then don't spawn more
;Go through and check if there are any Demo Orbs ready to spawn
    ld a, (hl)                          ;ld a, (demoOrb.state)
    cp $00
    jp nz, ++                           ;If it's not dead, don't spawn it
    ld de, demoOrbStruct.spawnTimer - demoOrbStruct.state
    add hl, de         
    ld a, (hl)                           ;ld hl, demoOrb.spawnTimer
    ;cp $00
    ;jr nz, +
;Add Demo Orb to the enemy List
    ld de, demoOrbStruct.hitBox.width - demoOrbStruct.spawnTimer
    add hl, de
    ex de, hl
    push bc
;Check if enemy is already added
    ld hl, enemyList.enemyCount
    call EnemyList@CheckIfInList
    ld a, $00
    cp c
    jr z, @NOTSAFE                               ;If not safe, then dip
;Check if space available
    ld hl, enemyList.enemyCount
    call EnemyList@CheckAvailability
    pop bc
    ex de, hl                           ;ld hl, demoOrbStruct.hitBox.width
@SetUpDemoOrb:
    call RandomNumberGenerator
    ld ixl, a                           ;Save for later
    and $0F                             ;Limit our number so that it fits on screen (Bytes reversed)
    cp $0C
    jr nc, @TargetTonbow                ;If bigger than $B0, then target TONBOW
    jr @SetYPos
@TargetTonbow:
;Remember C holds our value
    ld a, (tonbow.yPos)
    inc a                               ;Can be at $FF, which we don't want
    and $B0                             ;Only need the $10's value
    ;add a, $10                          ;Closer to center of Tonbow
    rrca
    rrca
    rrca
    rrca                                ;And swap around

@SetYPos:
;Check if we spawned here last time
    ld de, demoOrbSpawnPos
    ld b, a
    ld a, (de)
    cp b
;If we did, then get new RNG
    jr z, @SetUpDemoOrb
;Else save our current spawning location
    ld a, b
    ld (de), a
    push bc
        ld b, a
        xor a
        ld de, demoOrbStruct.sprNum - demoOrbStruct.hitBox.width
        add hl, de
        call InitDemoOrb                    ;Leaves HL at demoOrbStruct.updateAIPointer + 1
    pop bc
    dec hl
    dec hl                              ;ld hl, demoOrb.state
    ld de, demoOrbSpawnTimer
    ld a, ixl
    add a, 4
    and $0C
    ;xor a                               ;if zero do we get fast orbs? Pretty consistently, yes
    ld (de), a

    ret
    ;jr ++ 

+:
;Skip spawning this Demo Orb
    dec (hl)                            ;Decrease Spawn Timer
    ld de, demoOrbStruct.state - demoOrbStruct.spawnTimer
    add hl, de                          ;ld hl, demoOrb.spawnTimer
++:
    ld de, _sizeof_demoOrbStruct
    add hl, de                          ;ld hl, demoOrbNext.state
    djnz -

@EndSpawnDemoOrb:
    ret

@NOTSAFE:
    pop bc
    ret

;================================================================
; Initialization
;================================================================
;Initialize a Demo Orb
;Parameters: HL = demoOrb.sprNum, A = yFracPos LO ($X0), B = yFracPos HI ($0X)
;Affects: HL, DE, A, C
InitDemoOrb:
;----------------
; Demo Orb
;----------------  
    ;ld hl, demoOrb.sprNum
    ld de, demoOrbStruct.hitBox.y1 - demoOrbStruct.sprNum 
    add hl, de
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
;State
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl

    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, demoOrb1.width
    ;Sprite is 2x2 for 8x8
    ld (hl), $02                        
    inc hl                              ;ld hl, demoOrb1.height
    ld (hl), $01                        
    inc hl                              ;ld hl, demoOrb1.yPos
    ;ld (hl), $46;(96)
    inc hl                              ;ld hl, demoOrb1.xPos
    ;ld (hl), $C8;(250)
    inc hl                              ;ld hl, demoOrb1.cc
    ld (hl), demoOrbIndex
;Demo Orb specifics
    ld de, demoOrbStruct.yFracPos - demoOrbStruct.cc    ;ld hl, demoOrb1.yFracPos LO
    add hl, de
    ld (hl), a
    inc hl                              ;ld hl, demoOrb1.yFracPos HI
    ld (hl), b
    inc hl                              ;ld hl, demoOrb1.xFracPos LO
    ld (hl), $10
    inc hl                              ;ld hl, demoOrb1.xFracPos HI
    ld (hl), $0F
    inc hl                              ;ld hl, demoOrb1.yVel
    ld (hl), 0
    inc hl                              ;ld hl, demoOrb1.xVel
    ld (hl), 0
    inc hl                              ;ld hl, demoOrb1.animationTimer
    ld (hl), 0
    inc hl                              ;ld hl, demoOrb1.spawnTimer
    ld (hl), 0

    ld de, demoOrbStruct.yFracPos - demoOrbStruct.spawnTimer
    add hl, de
    call UpdateDemoOrbPosition          ;Results in HL = demoOrb.hitBox.height

;Set DemoOrb alive
    ;ld hl, demoOrb.hitBox.height
    ld (hl), $10
    dec hl
    ld (hl), $10                        ;ld hl, demoOrb.hitBox.width
    ld de, demoOrbStruct.state - demoOrbStruct.hitBox.width
    add hl, de                          ;ld hl, demoOrb1.alive
    ld (hl), 1
;Set DemoOrb Update AI Pointer
    inc hl                              ;ld hl, demoOrb.updateAIPointer
    ld de, UpdateDemoOrb
    ld (hl), e
    inc hl
    ld (hl), d
    

    ret