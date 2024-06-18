
GameOverCursorCheck:
;Check if we are on coolDown
    ld hl, gameOverCursorSprite.coolDownTimer
    ld a, (hl)
    cp $00
    jp nz, GameOverCursorCoolDown   ;If we are still on cool down, then don't move
;Check for directional inputs
    in a, $DC                       ;Send Joypad port 1 input data to register A
    ld (DCInput), a                 ;Save $DC input for later
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
    ld de, ActionButtonJumpTable_GameOver
    add hl, de                      ;3 * N + ActionButtonJumpTable
    jp hl                           ;Jump to specific input subroutine
;All of the possiblities for the Jump table move on to DPadCheck

DPadCheck_GameOver:
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
    ld de, DPadJumpTable_GameOver
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
;This RET is just for safety, as each possible jump has its own RET
    ret

ButtonOne_GameOver:
;Check if we are on the AGAIN button
	ld hl, gameOverCursorSprite.state
	ld a, (hl)
	cp $01
	jr z, +					;If not, then move to title screen
;Reset level
	ld hl, sceneComplete
	ld (hl), $01
;Cut to black
    call FadeToBlack
;Disable interrupts
    di
;Demo Level will handle resetting itself
	ret
+:
ButtonTwo_GameOver:
    ld hl, sceneComplete
	ld (hl), $02
;Cut to black
    call FadeToBlack
;Disable interrupts 
    ;di
;Demo Level will handle getting to the title screen
	ret


DPadUp_GameOver:
;Check if we are on the START button
	ld hl, gameOverCursorSprite.state
	ld a, (hl)
	cp $00
	ret z							;If we are, then do nothing
;Move cursor to options and change state to reflect the change
	ld (hl), $00
;Check if we are in TATE mode
    ld a, (tateMode)   
    bit 0, a
    jr nz, +  
;Move cursor in Yoko       
	ld hl, gameOverCursorSprite.yPos    
	ld a, -$10
	add a, (hl)
	ld (hl), a
	ret
+:
;Move cursor in TATE mode
    ld hl, gameOverCursorSprite.xPos    
	ld a, $10
	add a, (hl)
	ld (hl), a
    ret


DPadDown_GameOver:
;Check if we are on Options
	ld hl, gameOverCursorSprite.state
	ld a, (hl)
	cp $01
	ret z							;If we are, then do nothing
;Move cursor to START and change state to reflect the change
	ld (hl), $01
;Check if we are in TATE mode
	ld a, (tateMode)            
    bit 0, a
    jr nz, +     
;Move cursor in Yoko   
	ld hl, gameOverCursorSprite.yPos    
	ld a, $10
	add a, (hl)
	ld (hl), a
	ret
+:
;Move cursor in TATE mode
    ld hl, gameOverCursorSprite.xPos    
	ld a, -$10
	add a, (hl)
	ld (hl), a
    ret

;==================================================
; Jump Tables
;==================================================
ActionButtonJumpTable_GameOver:
;If nothing is pressed, move on to check DPad
    jp DPadCheck_GameOver
;If button one is pressed, check where the cursor is, otherwise check if in options
    jp ButtonOne_GameOver               ;Left Button
    jp ButtonTwo_GameOver			   ;Right Button


DPadJumpTable_GameOver:
;If nothing is pressed, leave
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
;If a direction is pressed, then jump to do the correct action
    jp DPadUp_GameOver                                                  	;Only UP is pressed
    jp DPadDown_GameOver                                                	;Only DOWN is pressed
;In the case that UP and DOWN are both pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    ret                                                						;Only LEFT is pressed
	nop
	nop
    jp DPadUp_GameOver                                              		;UP and LEFT are pressed
    jp DPadDown_GameOver                                            		;LEFT & DOWN are pressed
;In the case that LEFT and UP and DOWN are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    ret						                                               ;Only RIGHT
	nop
	nop
    jp DPadUp_GameOver                                             ;RIGHT & UP
    jp DPadDown_GameOver                                           ;RIGHT & DOWN
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


GameOverCursorCoolDown:
    ld hl, gameOverCursorSprite.coolDownTimer
    ld a, (hl)
    dec a
    ld (hl), a

    ret