;==============================================================
; Tonbow Subroutines
;==============================================================
.define tonbowVRAM              $2000
.define TONBOW_DASH_LENGTH      $16
.define DASH_UDLR_SPEED         $60
.define DASH_DIAG_SPEED         $40
.define DASH_UDLR_DEC           -$04
.define DASH_DIAG_DEC           -$03


;==============================================================
; Frame-by-frame update for Tonbow
;==============================================================
UpdateTonbow:
;Tonbow Controls
    ld a, (tonbow.alive)            ;\
    bit 0, a                        ; } Check if Tonbow is Alive
    ret z                           ;/
    ld a, (tonbow.dashState)        ;\
    bit 0, a                        ; } Check if Tonbow is dashing, leads to ReturnFromDash
    jp nz, TonbowContinueDash       ;/
    ld hl, tonbow.dashWarmUpTimer
    ld a, (hl)
    cp $00
    jr z, +
    dec (hl)
+:
    call TonbowJoypad1Check
ReturnFromDash:
    call UpdateTonbowPosition
    ;call UpdateTonbowGraphics
+:
 
+:
;Keep the Tonbow explosion in line
    ld hl, tonbowExplosion.yPos
    ld a, (tonbow.yPos)
    ld (hl), a
    inc hl                              ;ld hl, tonbowExplosion.xPos
    ld a, (tonbow.xPos)
    ld (hl), a
;And the parts Y
    ld hl, tonbowPart0.yPos
    ld a, (tonbow.yPos)
    add a, 9
    ld (hl), a
    ld hl, tonbowPart1.yPos
    ld (hl), a
    ld hl, tonbowPart2.yPos
    ld (hl), a
;Parts X
    ld hl, tonbowPart0.xPos
    ld a, (tonbow.xPos)
    add a, 8
    ld (hl), a
    ld hl, tonbowPart1.xPos
    ld (hl), a
    ld hl, tonbowPart2.xPos
    ld (hl), a
    ret

;==============================================================
; Update Tonobw Parts position
;==============================================================
;Move the parts across the screen
;When they hit a screen edge, end them
;Parameters: None
;Affects: TBD


UpdateTonbowParts:
    ld a, (tateMode)
    cp $01
    jr z, @Tate
;---------------------------------------------------------------------------
@Yoko:
    ld a, (tonbowPart0.flag)
    cp $01
    jr nz, @@Part1
@@Part0:
;Part 0 Move up and right diagonally, mostly right
    ld hl, tonbowPart0.xPos
    ld a, (hl)
    sub a, $10
    cp RightBounds
    jr nc, +

    inc (hl)
    inc (hl)
    inc (hl)
    dec hl                      ;ld hl, tonbowPart0.yPos
    ld a, (hl)
    cp $04
    jr c, +
    dec (hl)
;Still need to update next frame
    ld hl, tonbowPart0.flag
    ld (hl), $01
;Draw the part to the screen
    ld hl, tonbowPart0.sprNum       
    call MultiUpdateSATBuff   
    jr @@Part1

;If we are at the limit, then we need to set our Output accordingly
+:
    ld hl, tonbowPart0.flag
    ld (hl), $00

;---------------------------------------------------------------------------
@@Part1:
;Part 1 Move up and left diagonally, mostly up
    ld hl, tonbowPart1.xPos
    ld a, (hl)
    cp LeftBounds
    jr c, +

    dec (hl)
    dec hl                      ;ld hl, tonbowPart1.yPos
    ld a, (hl)
    add a, $10
    cp $03 
    jr c, +
    dec (hl)
    dec (hl)
;Still need to update next frame
    ld hl, tonbowPart1.flag
    ld (hl), $01
;Draw the part to the screen
    ld hl, tonbowPart1.sprNum       
    call MultiUpdateSATBuff   
    jr @@Part2

;If we are at the limit, then we need to set our Output accordingly
+:
    ld hl, tonbowPart1.flag
    ld (hl), $00        

;---------------------------------------------------------------------------
@@Part2:
;Part 2 Move down and left diagonally, mostly down
    ld hl, tonbowPart2.xPos
    ld a, (hl)
    cp LeftBounds
    jr c, +

    dec (hl)
    dec hl                      ;ld hl, tonbowPart2.yPos
    ld a, (hl)
    cp $BF
    jr nc, +
    inc (hl)
    inc (hl)
    inc (hl)
;Still need to update next frame
    ld hl, tonbowPart2.flag
    ld (hl), $01
;Draw the part to the screen
    ld hl, tonbowPart2.sprNum       
    call MultiUpdateSATBuff   
    ret

;If we are at the limit, then we need to set our Output accordingly
+:
    ld hl, tonbowPart2.flag
    ld (hl), $00         

    ret

;---------------------------------------------------------------------------
@Tate:
@@Part0:
;Part 0 Move down and right diagonally, mostly Down
    ld hl, tonbowPart0.xPos
    ld a, (hl)
    sub a, $10
    cp RightBounds
    jr nc, +

    inc (hl)
    dec hl                      ;ld hl, tonbowPart0.yPos
    ld a, (hl)
    cp $BF
    jr nc, +
    inc (hl)
    inc (hl)
    inc (hl)
;Still need to update next frame
    ld hl, tonbowPart0.flag
    ld (hl), $01
;Draw the part to the screen
    ld hl, tonbowPart0.sprNum       
    call MultiUpdateSATBuff   
    jr @@Part1

;If we are at the limit, then we need to set our Output accordingly
+:
    ld hl, tonbowPart0.flag
    ld (hl), $00

;---------------------------------------------------------------------------
@@Part1:
;Part 1 Move up and right diagonally, mostly right
    ld hl, tonbowPart1.xPos
    ld a, (hl)
    cp LeftBounds
    jr c, +

    inc (hl)
    inc (hl)
    dec hl                      ;ld hl, tonbowPart1.yPos
    ld a, (hl)
    cp $03 
    jr c, +
    dec (hl)
;Still need to update next frame
    ld hl, tonbowPart1.flag
    ld (hl), $01
;Draw the part to the screen
    ld hl, tonbowPart1.sprNum       
    call MultiUpdateSATBuff   
    jr @@Part2

;If we are at the limit, then we need to set our Output accordingly
+:
    ld hl, tonbowPart1.flag
    ld (hl), $00        

;---------------------------------------------------------------------------
@@Part2:
;Part 2 Move up and left diagonally, mostly left
    ld hl, tonbowPart2.xPos
    ld a, (hl)
    add $10
    cp LeftBounds
    jr c, +

    dec (hl)
    dec (hl)
    dec (hl)
    dec hl                      ;ld hl, tonbowPart2.yPos
    ld a, (hl)
    add a, $08
    cp $03
    jr c, +
    dec (hl)
;Still need to update next frame
    ld hl, tonbowPart2.flag
    ld (hl), $01
;Draw the part to the screen
    ld hl, tonbowPart2.sprNum       
    call MultiUpdateSATBuff   
    ret

;If we are at the limit, then we need to set our Output accordingly
+:
    ld hl, tonbowPart2.flag
    ld (hl), $00         

    ret

;==============================================================
; Update Position
;==============================================================
;Deciphers yFracPos from special WORD into sprite coordinates for yPos xPos
UpdateTonbowPosition:
;Set Y-Fractional-Position to Sprite position 
    ld hl, tonbow.yFracPos                      ;(HL) = WHOLE LO, FRAC
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
;Check to see if yPos is within the limits
    cp VerticalBounds
    call nc, SetTonbowYBoundary
    ld hl, tonbow.yPos
    ld (hl), a
;Set X-Fractional-Position to Sprite position 
    ld hl, tonbow.xFracPos                      ;(HL) = WHOLE LO, FRAC
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
;Check to see if yPos is within the limits
    cp LeftBounds
    call c, SetTonbowLeftBoundary
    cp RightBounds
    call nc, SetTonbowRightBoundary
    ld hl, tonbow.xPos
    ld (hl), a
    jp UpdateTonbowHitBox

SetTonbowYBoundary:
    cp $E0
    jr c, +
;Otherwise, trying t go through top of the screen
    ld a, $FF
    ld hl, tonbow.yFracPos
    ld (hl), $F0
    inc hl
    ld (hl), $0F
    ret
+:
    ld a, $A8
    ld hl, tonbow.yFracPos
    ld (hl), $80
    inc hl
    ld (hl), $0A
    ret

SetTonbowLeftBoundary:
    ld a, $08
    ld hl, tonbow.xFracPos
    ld (hl), $80
    inc hl
    ld (hl), $00
    ret

SetTonbowRightBoundary:
    ld a, $E8
    ld hl, tonbow.xFracPos
    ld (hl), $80
    inc hl
    ld (hl), $0E
    ret


;Also update Tonbow's hitbox
UpdateTonbowHitBox:
    ld hl, tonbow.hitBox.y1
    ld a, (tonbow.yPos)
    add a, $08
    ld (hl), a
    inc hl                              ;ld hl, tonbow.hitBox.x1
    ld a, (tonbow.xPos)
    add a, $08
    ld (hl), a
    inc hl                              ;ld hl, tonbow.hitBox.y2
    ld a, (tonbow.hitBox.height)
    ld b, a
    ld a, (tonbow.hitBox.y1)
    add a, b
    ld (hl), a                          ;Save Second HB Y coordinate
    inc hl                              ;ld hl, tonbow.hitBox.x2
    ld a, (tonbow.hitBox.width)
    ld b, a
    ld a, (tonbow.hitBox.x1)
    add a, b
    ld (hl), a                          ;Save Second HB X coordinate

    ;ret

;AND also update Tonbow's hurtBox
UpdateTonbowHurtBox:
;If we aren't dashing, then set area to zero
    ld a, (tonbow.dashState)
    bit 0, a
    jp z, NoTonbowHurtBox
    ;call z, NoTonbowHurtBox

;Check Rotation State to determine Hurtbox dimensions
    ld a, (tonbow.rotationState)
;Check if it's DIAGONAL
    bit 0, a
    jp nz, TonbowHurtBoxDiagonal
;Check if it's LEFT or RIGHT
    cp $00
    jr z, TonbowHurtBoxHorizontal
    cp $04
    jr z, TonbowHurtBoxHorizontal
;Otherwise, it's UP or DOWN
;-----------------------------------------------------------
TonbowHurtBoxVertical:
;Set Hurt Box dimensions (Vertical is 12x8)
    ld hl, tonbow.hurtBox.width
    ld (hl), $0B
    inc hl                      ;ld hl, tonbow.hurtBox.height
    ld (hl), $07
;Coordinate 1
    ld b, $00
    ;ld a, (tonbow.rotationState)
    cp $02
    jr z, +
;If DOWN, then we need to move the Hurt Box Down
    ld b, $10
+:
    ld hl, tonbow.hurtBox.y1
    ld a, (tonbow.yPos)
    add a, b                    ;ADD 0 if UP, ADD 16 if DOWN
    ld (hl), a                  ;Set tonbow.hurtBox.y1
    inc hl                      ;ld hl, tonbow.hurtBox.x1
    ld a, (tonbow.xPos)
    ld b, $06
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.x1
    inc hl                      ;ld hl, tonbow.hurtBox.y2
;Coordinates 2
    ld a, (tonbow.hurtBox.height)
    ld b, a
    ld a, (tonbow.hurtBox.y1)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.y2
    inc hl                      ;ld hl, tonbow.hurtBox.x2
    ld a, (tonbow.hurtBox.width)
    ld b, a
    ld a, (tonbow.hurtBox.x1)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.x2
;Finished with Vertical   
    ret

;-----------------------------------------------------------
TonbowHurtBoxHorizontal:
;Set Hurt Box dimensions (Horizontal is 8x16)
    ld hl, tonbow.hurtBox.width
    ld (hl), $07
    inc hl                      ;ld hl, tonbow.hurtBox.height
    ld (hl), $0B
;Coordinate 1
    ld hl, tonbow.hurtBox.y1
    ld b, $07
    ld a, (tonbow.yPos)
    add a, b                    ;Make Hurtbox extend beyond Tonbow's head a bit
    ld (hl), a                  ;Set tonbow.hurtBox.y1
    inc hl                      ;ld hl, tonbow.hurtBox.x1
    ld b, $00
    ld a, (tonbow.rotationState)
    cp $04
    jr z, +
;If RIGHT, then we need to move the Hurt Box Right
    ld b, $10
+:
    ld a, (tonbow.xPos)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.x1
    inc hl                      ;ld hl, tonbow.hurtBox.y2
;Coordinates 2
    ld a, (tonbow.hurtBox.height)
    ld b, a
    ld a, (tonbow.hurtBox.y1)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.y2
    inc hl                      ;ld hl, tonbow.hurtBox.x2
    ld a, (tonbow.hurtBox.width)
    ld b, a
    ld a, (tonbow.hurtBox.x1)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.x2
;Finished with Horizontal   
    ret

;-----------------------------------------------------------
TonbowHurtBoxDiagonal:
;Set Hurt Box dimensions (Diagonal is 12x11)
    ld hl, tonbow.hurtBox.width
    ld (hl), $0B
    inc hl                      ;ld hl, tonbow.hurtBox.height
    ld (hl), $0A
;Coordinate 1
    ld hl, tonbow.hurtBox.y1
;Check if UP or DOWN
    ld b, $04
    ld a, (tonbow.rotationState)
    cp $04
    jr c, +
    ld b, $0C                   ;If DIAGONAL DOWN, then move hitbox further down in Y Coords
+:
    ld a, (tonbow.yPos)
    add a, b                    ;Make Hurtbox extend beyond Tonbow's head a bit
    ld (hl), a                  ;Set tonbow.hurtBox.y1
    inc hl                      ;ld hl, tonbow.hurtBox.x1
    ld b, $02
    ld a, (tonbow.rotationState)
    cp $01
    jr nz, +
;If DIAGONAL UP RIGHT, then we need to move the Hurt Box Right
    ld b, $0A
+:
    cp $07
    jr nz, +
;If DIAGONAL DOWN RIGHT, then we need to move the Hurt Box Right
    ld b, $0A
+:
    ld a, (tonbow.xPos)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.x1
    inc hl                      ;ld hl, tonbow.hurtBox.y2
;Coordinates 2
    ld a, (tonbow.hurtBox.height)
    ld b, a
    ld a, (tonbow.hurtBox.y1)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.y2
    inc hl                      ;ld hl, tonbow.hurtBox.x2
    ld a, (tonbow.hurtBox.width)
    ld b, a
    ld a, (tonbow.hurtBox.x1)
    add a, b
    ld (hl), a                  ;Set tonbow.hurtBox.x2
;Finished with DIAGONAL    
    ret

;-----------------------------------------------------------
NoTonbowHurtBox:
;Set area to zero
    ld hl, tonbow.hurtBox.width
    ld (hl), 0

    ret


;==============================================================
; Update Graphics
;==============================================================
UpdateTonbowGraphics:
;Directional Graphics
    ld a, (tonbow.prevRotationState)
    ld b, a
    ld hl, tonbow.rotationState
    ld a, (hl)                                  ;A Holds the rotational state (0-7)
    cp b                                        ;Check if we need to update graphics
    ;jr z, FinishTonbowGraphics
    ld de, TonbowGlide0End-TonbowGlide0         ;DE Holds size of ship graphics in bytes
    push hl
        call Mult8Bit                               
        ex de, hl                               ;DE is now distance to get to correct graphics
    pop hl
    ld hl, tonbowVRAM | VRAMWrite
    call SetVDPAddress
;Determine if flapping, gliding or dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, TonbowDashing
    ld a, (tonbow.flapTimer)
    bit 2, a
    jr z, TonbowGliding
TonbowFlapping:
    ld hl, TonbowFlap0
    jr +
TonbowDashing:
;Update Dash Cool Down timer
    ld hl, tonbow.dashCoolDownTimer
    ld a, (hl)
    cp 0
    jp z, TonbowEndDash                         ;If Our dash is done, end it
;If still dashing, choose dash graphic and dec cooldown timer
    dec (hl)
    ld hl, TonbowDash0
    ld a, (tonbow.dashCoolDownTimer)
    cp TONBOW_DASH_LENGTH - 1
    jr nc, +                                    ;Skip graphic update if already dashing
    jr ++
TonbowGliding:
    ld hl, TonbowGlide0
+:
    add hl, de                                  ;HL now holds new graphics
    call TonbowVDPWrite
FinishTonbowGraphics:
    ld hl, tonbow.flapTimer
    bit 3, (hl)
    jr nz, +
    inc (hl)
    jr ++
+:
    ld (hl), 0
++:

    ret

;==============================================================
; Dash
;==============================================================
TonbowDashSetup:
    ld a, (tonbow.dashWarmUpTimer)  ;\
    cp $00                          ; } If not warmed up, don't dash
    ret nz                          ;/
;Set Tonbow to the Dash state
    ld hl, tonbow.dashState
    ld (hl), $01
;Set Dash Timer
    ld hl, tonbow.dashCoolDownTimer
    ld (hl), TONBOW_DASH_LENGTH


DashSetupAnyDirection:
;Start with the yVel for YOKO, xVel if TATE
    ld a, (tonbow.rotationState)
    ld c, a                         ;C = (tonbow.rotationState)
    cp $00
    jr z, DashSetupLeftRight
    cp $04
    jr z, DashSetupLeftRight
;If we get here, then we are dealing with anything but LEFT or RIGHT
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    
;Check if we are dashing diagonally or UDLR
    ld a, DASH_DIAG_SPEED
    bit 0, c
    call z, DashSetupSetUDLRSpeed           ;Set A to UDLR if NOT diagonal
;Set Dash velocity
    ld (hl), a
;Check if we are moving UP or DOWN
    ld a, c ;(tonbow.rotationState)
    cp $04                                  ;If ROTATION is less than 4, then UP
    jr c, +
;Update position for moving DOWN
    call UpdatePositionDown
    bit 0, c ;(tonbow.rotationState)
    jr nz, DashSetupLeftRight
;If not on diagonal, then we can return
    ret

;Update position for moving UP
+:  
    call UpdatePositionUp
;Check if we are on a diagonal or not
    bit 0, c ;(tonbow.rotationState)
    jr nz, DashSetupLeftRight

;If not on diagonal, then we can return
    ret

;Either on a diagonal, or dashing LEFT or RIGHT
DashSetupLeftRight:
;Start with the xVel for YOKO, yVel if TATE
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    
;Check if we are dashing diagonally or UDLR
    ld a, DASH_DIAG_SPEED
    bit 0, c
    call z, DashSetupSetUDLRSpeed           ;Set A to UDLR if NOT diagonal
;Set Dash velocity
    ld (hl), a
;Check if we are moving LEFT or RIGHT
    ld a, c ;(tonbow.rotationState)
    cp $03                                  ;If ROTATION is 3, 4, or 5, then LEFT
    jr z, +
    cp $04
    jr z, +
    cp $05
    jr z, +
;Otherwise, we are RIGHT, so update position for moving RIGHT
    call UpdatePositionRight
    ret

;Update position for moving LEFT
+:  
    call UpdatePositionLeft

    ret

;Change the Dash decrement if not moving Diagonally
DashSetupSetUDLRSpeed:
    ld a, DASH_UDLR_SPEED
    ret


;-----------------------------------------------------------------------------------
TonbowContinueDash:
;How can I turn this into a single subroutine? - I did it!
ContinueDashAnyDirection:
;Start with the yVel for YOKO, xVel if TATE
    ld a, (tonbow.rotationState)
    ld c, a                         ;C = (tonbow.rotationState)
    cp $00
    jr z, ContinueDashUpdateLeftRight
    cp $04
    jr z, ContinueDashUpdateLeftRight
;If we get here, then we are dealing with anything but LEFT or RIGHT
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    
;Check if Velocity is 0 already
    ld a, (hl)                  
    cp 0
    jp z, StopDashingSpeedZero  ;If zero, then stop dashing
;Check if dash cool down is over
    ld a, (tonbow.dashCoolDownTimer)
    cp 0                        
    jp z, StopDashingSpeedZero  ;If yes, then stop dashing
;Check if we are dashing diagonally or UDLR
    ld a, DASH_DIAG_DEC
    bit 0, c
    call z, ContinueDashSetUDLRDecrease     ;Set A to UDLR if NOT diagonal
;Decrease Dash velocity
    add a, (hl)
    ld (hl), a
;Check if we are moving UP or DOWN
    ld a, c ;(tonbow.rotationState)
    cp $04                                  ;If ROTATION is less than 4, then UP
    jr c, +
;Update position for moving DOWN
    call UpdatePositionDown
    bit 0, c ;(tonbow.rotationState)
    jr nz, ContinueDashUpdateLeftRight
;If not on diagonal, then we can return
    jp ReturnFromDash

;Update position for moving UP
+:  
    call UpdatePositionUp
;Check if we are on a diagonal or not
    bit 0, c ;(tonbow.rotationState)
    jr nz, ContinueDashUpdateLeftRight

;If not on diagonal, then we can return
    jp ReturnFromDash

;Either on a diagonal, or dashing LEFT or RIGHT
ContinueDashUpdateLeftRight:
;Start with the xVel for YOKO, yVel if TATE
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    
;Check if Velocity is 0 already
    ld a, (hl)                  
    cp 0
    jp z, StopDashingSpeedZero  ;If zero, then stop dashing
;Check if dash cool down is over
    ld a, (tonbow.dashCoolDownTimer)
    cp 0                        
    jp z, StopDashingSpeedZero  ;If yes, then stop dashing
;Check if we are dashing diagonally or UDLR
    ld a, DASH_DIAG_DEC
    bit 0, c
    call z, ContinueDashSetUDLRDecrease     ;Set A to UDLR if NOT diagonal
;Decrease Dash velocity
    add a, (hl)
    ld (hl), a
;Check if we are moving LEFT or RIGHT
    ld a, c ;(tonbow.rotationState)
    cp $03                                  ;If ROTATION is 3, 4, or 5, then LEFT
    jr z, +
    cp $04
    jr z, +
    cp $05
    jr z, +
;Otherwise, we are RIGHT, so update position for moving RIGHT
    call UpdatePositionRight
    jp ReturnFromDash

;Update position for moving LEFT
+:  
    call UpdatePositionLeft

    jp ReturnFromDash


;Change the Dash decrement if not moving Diagonally
ContinueDashSetUDLRDecrease:
    ld a, DASH_UDLR_DEC
    ret


StopDashingSpeedZero:
    call TonbowEndDash

    jp ReturnFromDash


TonbowEndDash:
    ld hl, tonbow.dashState
    ld (hl), 0
    ld hl, tonbow.dashWarmUpTimer
    ld (hl), TONBOW_DASH_LENGTH


    ret

;==============================================================
; Collision
;==============================================================
TonbowDead:
;Set Tonbow to dead
    ld hl, tonbow.alive
    ld (hl), 0

    ld hl, tonbow.hitBox.width
    ld (hl), 0

    ld hl, tonbow.hurtBox.width
    ld (hl), 0
;Check if we have a high score
    ld a, (highScoreSMS + 1)
    ld c, a                 ;C has our previous high score
    ld a, (score + 1)
    cp c
    jr c, @Audio
    ld a, (highScoreSMS)
    ld c, a                 ;C has our previous high score
    ld a, (score)
    cp c
    jr c, @Audio
;Set High Score
    ld hl, highScoreSMS
    ld (hl), a
    ld c, a                 ;Save score in C
    ;RAM Select Register
    ld a, %00001000
    ld (sramSwitch), a
    ld hl, highScoreOffset
    ld a, c                 ;Put score back in A
    ld (hl), a
    ld a, %00000000
    ld (sramSwitch), a
    ld hl, highScoreFlag
    ld (hl), $01

@Audio:
;If we got a high score, then don't run GAME OVER code yet
    ld a, (highScoreFlag)
    bit 0, a
    ;ret nz

;Work in the Audio Bank
    ld a, Audio
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), Audio
;Check for FM
    ld a, (playFM)
    cp $01
    jr z, +
;PSG の秋が始まる
    call PSGStop
    call PSGSFXStop
    ld hl, AkiGaHajimaruPSG
    call PSGPlayNoRepeat
    jr ++
;FM の秋が始まる
+:
;If we have it, we want to use FM
    ld hl, onFM
    ld (hl), $01
;So turn it on
    ;ld a, $01
    ;out ($f2),a
;Cut current song and SFX
    call MBMStop
    call MBMSFXStop
;Load Aki Ga Hajimaru
    ld hl, MBMStart
    ld de, AkiGaHajimaruFM
    ld a, e
    ld (hl), a
    ld a, d
    inc hl
    ld (hl), a
    call MBMPlayNoRepeat
;Switch to correct bank for Title Assets
++:
    ld a, DemoLevelBank
    ld ($FFFF), a
    ld hl, currentBank
    ld (hl), DemoLevelBank

    ret

;Handler Explosion Animation
TonbowExplosionHandler:
    ld hl, tonbowExplosion.cc
    ld de, tonbowExplosionTimer
    ld a, (de)
    dec a
    ld (de), a
    cp $20
    jr nc, @Frame0
    cp $1A
    jr nc, @Frame1
    cp $13
    jr nc, @Frame2
    cp $0E
    jr nc, @Frame3
    cp $08
    jr nc, @Frame4
    cp $01
    jr nc, @Frame5


@Frame0
    ld a, $4A ;TONBOW_BOOM_CC
    ld a, (hl)
    ret
@Frame1
    ld a, $4A + $0C
    ld (hl), a
    ret

@Frame2
    ld a, $4A + $18
    ld (hl), a
    ret

@Frame3
    ld a, $4A + $24
    ld (hl), a
    ret

@Frame4
    ld a, $4A + $30
    ld (hl), a
    ret

@Frame5
    ld a, $4A + $3C
    ld (hl), a
    ret



;==============================================================
; Fast Tonbow VDP Write
;==============================================================
;Copies data to the VRAM quickly, just for Tonbow
;Parameters: HL = data address
;Affects: HL
TonbowVDPWrite:
;Switch to correct bank for Title Assets
    ld a, TonbowTilesBank
    ld ($FFFF), a
    ld c, VDPData
;Tile 1
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 2
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 3
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 4
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 5
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 6
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 7
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 8
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile 9
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    ;ret
;Tile A
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile B
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Tile C
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
;Switch to Demo Level Bank
    ld a, DemoLevelBank
    ld ($FFFF), a
    ret





