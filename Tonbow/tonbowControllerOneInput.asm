;==================================================
; Constants
;==================================================
.define TONBOW_UDLR_SPEED           $20             ;2 Pixels per frame
.define TONBOW_DIAG_SPEED           $17             ;1.4 pixels per frame (Normalized)

;==================================================
; Check Controls for Player 1 Input
;==================================================

;Checks the input of player 1 joypad
    ;Parameters: None
    ;Affects: A, C, DE, HL
TonbowJoypad1Check:
/*
TH = 0	?	0	S	A	0	0	D	U
TH = 1	?	1	C	B	R	L	D	U
*/
;Check if SMS Button 2 is being pressed...
    in a, $DC                       ;Send Joypad port 1 input data to register A
    ld (DCInput), a                 ;Save $DC input for later
    bit    5,a
    jr z, ButtonCheck_Tonbow               ;...If true, then skip checking START button

;Check if Genesis START button pressed (code from vingazole)
    ld     a, $0D        ; configure TH as an output, set TH=0
    out    ($3F), a      ;
;Genesis Safety
    nop
    nop                 
    in     a, $DC        ; read START button status
    bit    5, a          ;
    call   z, $0066      ; if it is 0 (button pressed), call the PAUSE routine at $0066
;Set up to check regular SMS buttons
    ld     a, $2D        ; configure TH as an output, set TH=1
    out    ($3F), a      ;
    nop 
    nop

ButtonCheck_Tonbow:
;Disable Strafe mode
    ld hl, tonbow.strafeMode
    ld (hl), $00
;Check for directional inputs
    ld a, (DCInput)
    cpl                             ;If button is pressed, 1 indicates such
    and %00110000                   ;Mask off player 2 inputs and D-Pad
    rrca
    rrca
    rrca
    rrca                            ;Move the 2 button input pressed to 0th and 1st bit
;3 * N + ActionButtonJumpTable
    ld c, a
    add a, c
    add a, c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, ActionButtonJumpTable_Tonbow 
    add hl, de                      ;3 * N + ActionButtonJumpTable
    jp hl                           ;Jump to specific input subroutine
;All of the possiblities for the Jump table move on to DPadCheck

DPadCheck_Tonbow:
;Store preivous state
    ld hl, tonbow.rotationState
    ld de, tonbow.prevRotationState
    ld a, (hl)
    ld (de), a                      ;Store previous state
;Check DPad
    ld a, (DCInput)                 ;Recall Joypad 1 input data
    cpl                             ;Invert the bits so 1 indicates a press
    and %00001111                   ;Make a mask to only look at the D-Pad
;3 * N + DPadJumpTable
    ld c, a
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, DPadJumpTable_Tonbow 
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
;This RET is just for safety, as each possible jump has its own RET
    ret


;==================================================
; Button Actions
;==================================================
ButtonOne_Tonbow:
;Check if we are already dashing
    ld a, (tonbow.dashCoolDownTimer)
    cp $00
    jr nz, +
;Check if we are warming up
    ld a, (tonbow.dashWarmUpTimer)
    cp $00
    jr nz, ++
    call TonbowDashSetup
+:
    ret
++:
    jp DPadCheck_Tonbow 

ButtonTwo_Tonbow:
    ld hl, tonbow.strafeMode
    ld (hl), $01
+:
    jp DPadCheck_Tonbow 

ButtonOneAndTwo_Tonbow:
    ld hl, tonbow.strafeMode
    ld (hl), $01
    ld a, (tonbow.dashCoolDownTimer)
    cp $00
    jr nz, +
;Check if we are warming up
    ld a, (tonbow.dashWarmUpTimer)
    cp $00
    jr nz, ++
    call TonbowDashSetup
+:
    ret
++:
    jp DPadCheck_Tonbow 



;==================================================
; DPad Actions
;==================================================
;----------------
; Up
;----------------
DPadUp_Tonbow:
;Update Y-Velocity
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_UDLR_SPEED     ;NOTE this is not negative
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly
    ;^^^ this can be what pushing up does, then this below part
    ;can be handled elsewhere

;Parameters: HL = tonbow.yVel, B = (tateMode)
UpdatePositionUp:
;Update yFracPos
    ld de, tonbow.yFracPos
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +
    ld a, (tateMode)    ;\
    add a, a            ; } TATE 
    add a, e            ; } Double because Tonbow.yFracPos is a WORD
    ld e, a             ;/  
+: 
    
    bit 0, b
    jr z, +
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +
;Addition for TATE
    ld a, (de)
    add a, (hl)                 ;We want to ADD the VELOCITY TO the POSITION if TATE
    jr ++
+:
;Subtraction for YOKO
    ld a, (de)
    sub a, (hl)                 ;We want to subtract the VELOCITY FROM the POSITION if YOKO
++:
;Do the Carry if necessary for our 
    call c, CarryDPadUp       ;Since our FracPos are stored as a WORD, it has to be manually carried
    ld (de), a

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 0
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 2
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.yVel
    ld (hl), 0
+++:

    ret

CarryDPadUp:
    push af
    ex de, hl                   ;Can't do dec(DE), so swap HL and DE
        inc hl
        bit 0, b
        jr z, +
        ld a, (tonbow.dashState)
        bit 0, a
        jr nz, +
    ;INC for TATE
        inc (hl)                ;This is for TATE
        jr ++
    +:        
    ;DEC for YOKO
        dec (hl)
    ++:
    ;Get us back to the LO byte of FracPos        
        dec hl
    ex de, hl                   ;And swap back
    pop af

    ret             


;----------------
; Down
;----------------
DPadDown_Tonbow:
;Update Y-Velocity
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_UDLR_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

;If YOKO, update DOWN, if TATE update LEFT

;Parameters: HL = tonbow.yVel, B = (tateMode)
UpdatePositionDown:
;Update yFracPos
    ld de, tonbow.yFracPos
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +
    ld a, (tateMode)    ;\
    add a, a            ; } TATE 
    add a, e            ; } Double because Tonbow.FracPos are a WORD
    ld e, a             ;/   
+:
    
    bit 0, b
    jr z, +
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +
;Addition for TATE
    ld a, (de)
    sub a, (hl)                 ;We want to ADD the VELOCITY TO the POSITION if TATE
    jr ++
+:
;Subtraction for YOKO
    ld a, (de)
    add a, (hl)                 ;We want to subtract the VELOCITY FROM the POSITION if YOKO
++:
;Do the Carry if necessary for our 
    call c, CarryDPadDown       ;Since our FracPos are stored as a WORD, it has to be manually carried
    ld (de), a

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 4
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 6
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.yVel
    ld (hl), 0
+++:
    
    ret

CarryDPadDown:
    push af
    ex de, hl                   ;Can't do dec(DE), so swap HL and DE
        inc hl
        bit 0, b
        jr z, +
        ld a, (tonbow.dashState)
        bit 0, a
        jr nz, +
    ;INC for TATE
        dec (hl)                ;This is for TATE
        jr ++
    +:        
    ;DEC for YOKO
        inc (hl)
    ++:
    ;Get us back to the LO byte of FracPos        
        dec hl
    ex de, hl                   ;And swap back
    pop af

    ret            

;----------------
; Left
;----------------
DPadLeft_Tonbow:
;Update X-Velocity
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    neg                 ;Used for L/R
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_UDLR_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

;Parameters: HL = tonbow.xVel
UpdatePositionLeft:
;Update yFracPos
    ld de, tonbow.xFracPos
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +
    ld a, (tateMode)    ;\
    add a, a            ; } TATE 
    neg                 ;Again, for L/R
    add a, e            ; } Double because Tonbow.FracPos are a WORD
    ld e, a             ;/  
+: 
    ld a, (de)
;Subtraction for YOKO and TATE
    sub a, (hl)                 ;We want to subtract the VELOCITY FROM the POSITION if YOKO
;Do the Carry if necessary for our 
    call c, CarryDPadLeft       ;Since our FracPos are stored as a WORD, it has to be manually carried
    ld (de), a

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 2
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 4
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.xVel
    ld (hl), 0
+++:

    ret

CarryDPadLeft:
    ex de, hl                   ;Can't do dec(DE), so swap HL and DE
        inc hl
    ;DEC for YOKO and TATE
        dec (hl)
    ;Get us back to the LO byte of FracPos        
        dec hl
    ex de, hl                   ;And swap back

    ret    


;----------------
; Right
;----------------
DPadRight_Tonbow:
;Update X-Velocity
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    neg                 ;Used for L/R
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_UDLR_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

;Parameters: HL = tonbow.xVel
UpdatePositionRight:
;Update yFracPos
    ld de, tonbow.xFracPos
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +
    ld a, (tateMode)    ;\
    add a, a            ; } TATE 
    neg                 ;Again, for L/R
    add a, e            ; } Double because Tonbow.FracPos are a WORD
    ld e, a             ;/   
+:
    ld a, (de)
;Add for YOKO and TATE
    add a, (hl)                 ;We want to subtract the VELOCITY FROM the POSITION if YOKO
;Do the Carry if necessary for our 
    call c, CarryDPadRight       ;Since our FracPos are stored as a WORD, it has to be manually carried
    ld (de), a

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 6
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 0
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.xVel
    ld (hl), 0
+++:

    ret

CarryDPadRight:
    ex de, hl                   ;Can't do dec(DE), so swap HL and DE
        inc hl
    ;INC for YOKO and TATE
        inc (hl)
    ;Get us back to the LO byte of FracPos        
        dec hl
    ex de, hl                   ;And swap back

    ret    

;----------------
;Multi Button
;----------------
DPadUpLeft_Tonbow:
;Update Y-Velocity
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     ;NOTE this is not negative
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly
    ;^^^ this can be what pushing up does, then this below part
    ;can be handled elsewhere

    call UpdatePositionUp

;Update X-Velocity
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    neg                 ;Used for L/R
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

    call UpdatePositionLeft

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 1
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 3
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.yVel
    ld (hl), 0
    inc hl                     ;ld hl, tonbow.xVel
    ld (hl), 0
+++:

    ret

DPadUpRight_Tonbow:
;Update Y-Velocity
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     ;NOTE this is not negative
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly
    ;^^^ this can be what pushing up does, then this below part
    ;can be handled elsewhere

    call UpdatePositionUp

;Update X-Velocity
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    neg                 ;Used for L/R
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

    call UpdatePositionRight

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 7
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 1
++:     
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.yVel
    ld (hl), 0
    inc hl                     ;ld hl, tonbow.xVel
    ld (hl), 0
+++:

    ret

DPadDownLeft_Tonbow:
;Update Y-Velocity
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     ;NOTE this is not negative
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly
    ;^^^ this can be what pushing up does, then this below part
    ;can be handled elsewhere

    call UpdatePositionDown

;Update X-Velocity
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    neg                 ;Used for L/R
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

    call UpdatePositionLeft

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 3
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 5
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.yVel
    ld (hl), 0
    inc hl                     ;ld hl, tonbow.xVel
    ld (hl), 0
+++:

    ret

DPadDownRight_Tonbow:
;Update Y-Velocity
    ld hl, tonbow.yVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     ;NOTE this is not negative
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly
    ;^^^ this can be what pushing up does, then this below part
    ;can be handled elsewhere

    call UpdatePositionDown

;Update X-Velocity
    ld hl, tonbow.xVel
    ld a, (tateMode)    ;\
    ld b, a             ; } TATE 
    neg                 ;Used for L/R
    add a, l            ; } (switch to xVel)
    ld l, a             ;/ 
    ld (hl), 0                  ;For now, reset VEL, for easy controls
    ld a, TONBOW_DIAG_SPEED     
    add a, (hl)
    ld (hl), a                  ;Velocity is stored properly

    call UpdatePositionRight

;Check if strafing
    ld a, (tonbow.strafeMode)
    bit 0, a
    jr nz, ++
;Check if Dashing
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
;If not strafing or dashing, set Tonbow Rotation State
    ld a, (tateMode)
    bit 0, a
    jr z, +
    ld hl, tonbow.rotationState
    ld (hl), 5
    jr ++
+:
    ld hl, tonbow.rotationState
    ld (hl), 7
++:    
    ld a, (tonbow.dashState)
    bit 0, a
    jr nz, +++
    ld hl, tonbow.yVel
    ld (hl), 0
    inc hl                     ;ld hl, tonbow.xVel
    ld (hl), 0
+++:

    ret


;==================================================
; Jump Tables
;==================================================
ActionButtonJumpTable_Tonbow:
;If nothing is pressed, move on to check DPad
    jp DPadCheck_Tonbow
;If a button is pressed, then move, or if both, change direction
    jp ButtonOne_Tonbow                ;Left Button
    jp ButtonTwo_Tonbow                ;Right Button
    jp ButtonOneAndTwo_Tonbow          ;Double input 


DPadJumpTable_Tonbow:
;If nothing is pressed, leave
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
;If a direction is pressed, then jump to do the correct action
    jp DPadUp_Tonbow                                                   ;Only UP is pressed
    jp DPadDown_Tonbow                                                 ;Only DOWN is pressed
;In the case that UP and DOWN are both pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    jp DPadLeft_Tonbow                                                 ;Only LEFT is pressed
    jp DPadUpLeft_Tonbow                                               ;UP and LEFT are pressed
    jp DPadDownLeft_Tonbow                                             ;LEFT & DOWN are pressed
;In the case that LEFT and UP and DOWN are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    jp DPadRight_Tonbow                                                ;Only RIGHT
    jp DPadUpRight_Tonbow                                              ;RIGHT & UP
    jp DPadDownRight_Tonbow                                            ;RIGHT & DOWN
;In the case that RIGHT and UP and DOWN are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion   
;In the case that RIGHT and LEFT are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion   
;In the case that RIGHT and LEFT and UP are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion 
;In the case that RIGHT and LEFT and DOWN are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion   
;In the case that RIGHT and LEFT and DOWN and UP are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion     
