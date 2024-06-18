;----------------
; Tonbow
;----------------
InitTonbow:
;Tonbow Sprite Attributes
    ld hl, tonbow.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, tonbow.width
    ;Sprite is 3x3 for 8x8
    ld (hl), $03                        
    inc hl                              ;ld hl, tonbow.height
    ld (hl), $02                        
    inc hl                              ;ld hl, tonbow.yPos
    ld (hl), $0
    inc hl                              ;ld hl, tonbow.xPos
    ld (hl), $00
    inc hl                              ;ld hl, tonbow.cc
    ld (hl), $00
;Tonbow specifics
    ld hl, tonbow.yFracPos              ;ld hl, tonbow.yFracPos LO
    ld (hl), $E0
    inc hl                              ;ld hl, tonbow.yFracPos HI
    ld (hl), $03
    inc hl                              ;ld hl, tonbow.xFracPos LO
    ld (hl), $80
    inc hl                              ;ld hl, tonbow.xFracPos HI
    ld (hl), $00
    inc hl                              ;ld hl, tonbow.yVel
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.xVel
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.yVelMax
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.xVelMax
    ld (hl), 0
;Special tate trick must be done
    inc hl                              ;ld hl, tonbow.rotationState
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.prevRotationState
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.strafeMode
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.flapTimer
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.dashCooldownTimer
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.dashState
    ld (hl), 0
    inc hl                              ;ld hl, tonbow.dashWarmUpTimer
    ld (hl), $00
;Tonbow Hitbox
    ld hl, tonbow.hitBox.width
    ld (hl), $08
    inc hl                              ;ld hl, tonbow.hitBox.height
    ld (hl), $08                        ;Hitbox makes up the middle sprite of the tonbow
    call UpdateTonbowHitBox
    ;ld hl, tonbow.hitBox.xPos
    call UpdateTonbowPosition
    


;Tonbow Hurtbox
    ;call UpdateTonbowHurtBox
    ld hl, tonbow.hurtBox.y1
    inc hl                              ;ld hl, tonbow.hurtBox.x1
    inc hl                              ;ld hl, tonbow.hurtBox.y2
    inc hl                              ;ld hl, tonbow.hurtBox.x2
    inc hl                              ;ld hl, tonbow.hurtBox.width
    ld (hl), $08
    inc hl                              ;ld hl, tonbow.hurtBox.height
    ld (hl), $08

;Set Tonbow Alive
    inc hl                              ;ld hl, tonbow.alive
    ld (hl), 1

GameOverInit:
;Since it's directly tied to the player, let's also update Game Over sprites as well
    ld hl, gameOverSprite
    ;Game Over Sprite Attributes
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x8
    inc hl                              ;ld hl, gameOver.width
    ;Sprite is 4x3 for 8x8
    ld a, (tateMode)
    cp $01
    jr z, +
;YOKO
    ld (hl), $04                        
    inc hl                              ;ld hl, gameOver.height
    ld (hl), $02       
    inc hl                              ;ld hl, gameOver.yPos
    ld (hl), 60
    inc hl                              ;ld hl, gameOver.xPos
    ld (hl), $74  
    jr ++               
+:   
;TATE
    ld (hl), $04                        
    inc hl                              ;ld hl, gameOver.height
    ld (hl), $02         
    inc hl                              ;ld hl, gameOver.yPos
    ld (hl), $50
    inc hl                              ;ld hl, gameOver.xPos
    ld (hl), $90

++:
;CC
    inc hl                              ;ld hl, gameOver.cc
    ld (hl), $26


;Cursor
    ;Title Cursor Attributes
    ld hl, gameOverCursorSprite.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, titleCursor.width
    ;Sprite is 1x1 for 8x8
    ld (hl), $01                        
    inc hl                              ;ld hl, titleCursor.height
    ld (hl), $01                        
    inc hl                              ;ld hl, titleCursor.yPos
;Do some TATE trickery
    ld a, (tateMode)
    bit 0, a
    jr nz, +
    ld (hl), $62
    inc hl                              ;ld hl, titleCursor.xPos
    ld (hl), $65
    jr ++
+:
;TATE Coordinates
    ld (hl), $3E
    inc hl                              ;ld hl, titleCursor.xPos
    ld (hl), $78
++:
    inc hl                              ;ld hl, titleCursor.cc
    ld (hl), $FA
    ld hl, gameOverCursorSprite.state                             
    ld (hl), $00
    inc hl                              ;ld hl, titleCursor.coolDownTimer
    ld (hl), $18

;Again Sprite Attributes
    ld hl, againSprite
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, gameOver.width
    ;Sprite is 4x3 for 8x8
    ld a, (tateMode)
    cp $01
    jr z, +
;YOKO
    ld (hl), $05                        
    inc hl                              ;ld hl, gameOver.height
    ld (hl), $01                        
    inc hl                              ;ld hl, gameOver.yPos
    ld (hl), 98
    inc hl                              ;ld hl, gameOver.xPos
    ld (hl), $70
    jr ++
+:
;TATE
    ld (hl), $01                        
    inc hl                              ;ld hl, gameOver.height
    ld (hl), $03                        
    inc hl                              ;ld hl, gameOver.yPos
    ld (hl), $4C
    inc hl                              ;ld hl, gameOver.xPos
    ld (hl), $78
++:
;CC
    inc hl                              ;ld hl, gameOver.cc
    ld (hl), $36

;Title Sprite Attributes
    ld hl, titleSprite
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, gameOver.width
    ;Sprite is 4x3 for 8x8
    ld a, (tateMode)
    cp $01
    jr z, +
;YOKO
    ld (hl), $05                        
    inc hl                              ;ld hl, gameOver.height
    ld (hl), $01                        
    inc hl                              ;ld hl, gameOver.yPos
    ld (hl), 114
    inc hl                              ;ld hl, gameOver.xPos
    ld (hl), $70
    jr ++
+:
;TATE
    ld (hl), $01                        
    inc hl                              ;ld hl, gameOver.height
    ld (hl), $03                        
    inc hl                              ;ld hl, gameOver.yPos
    ld (hl), $4C
    inc hl                              ;ld hl, gameOver.xPos
    ld (hl), $68
++:
;CC
    inc hl                              ;ld hl, gameOver.cc
    ld (hl), $40

;Init the Tonbow explosion
    ld hl, tonbowExplosion
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, tonbowExplosion.width
    ;Sprite is 3x2 for 8x8
    ld (hl), $03                        
    inc hl                              ;ld hl, tonbowExplosion.height
    ld (hl), $02                        
    inc hl                              ;ld hl, tonbowExplosion.yPos
    ld a, (tonbow.yPos)
    ld (hl), a
    inc hl                              ;ld hl, tonbowExplosion.xPos
    ld a, (tonbow.xPos)
    ld (hl), a
    inc hl                              ;ld hl, tonbowExplosion.cc
    ld (hl), TONBOW_BOOM_CC

    ld hl, tonbowExplosionTimer
    ld (hl), $24

;Init the Tonbow explosion parts
    ld hl, tonbowPart0
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, tonbowPart.width
    ;Sprite is 3x2 for 8x16
    ld (hl), $01                        
    inc hl                              ;ld hl, tonbowPart.height
    ld (hl), $01                        
    inc hl                              ;ld hl, tonbowPart.yPos
    ld a, (tonbow.yPos)
    add a, 8
    ld (hl), a
    inc hl                              ;ld hl, tonbowPart.xPos
    ld a, (tonbow.xPos)
    add a, 8
    ld (hl), a
    inc hl                              ;ld hl, tonbowPart.cc
    ld (hl), TONBOW_PART0_CC
    inc hl                              ;ld hl, tonbowPart.flag
    ld (hl), $01

;Init the Tonbow explosion parts
    ld hl, tonbowPart1
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, tonbowPart.width
    ;Sprite is 3x2 for 8x16
    ld (hl), $01                        
    inc hl                              ;ld hl, tonbowPart.height
    ld (hl), $01                        
    inc hl                              ;ld hl, tonbowPart.yPos
    ld a, (tonbow.yPos)
    add a, 8
    ld (hl), a
    inc hl                              ;ld hl, tonbowPart.xPos
    ld a, (tonbow.xPos)
    add a, 8
    ld (hl), a
    inc hl                              ;ld hl, tonbowPart.cc
    ld (hl), TONBOW_PART1_CC
    inc hl                              ;ld hl, tonbowPart.flag
    ld (hl), $01

;Init the Tonbow explosion parts
    ld hl, tonbowPart2
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, tonbowPart.width
    ;Sprite is 3x2 for 8x16
    ld (hl), $01                        
    inc hl                              ;ld hl, tonbowPart.height
    ld (hl), $01                        
    inc hl                              ;ld hl, tonbowPart.yPos
    ld a, (tonbow.yPos)
    add a, 8
    ld (hl), a
    inc hl                              ;ld hl, tonbowPart.xPos
    ld a, (tonbow.xPos)
    add a, 8
    ld (hl), a
    inc hl                              ;ld hl, tonbowPart.cc
    ld (hl), TONBOW_PART2_CC
    inc hl                              ;ld hl, tonbowPart.flag
    ld (hl), $01


    ret


