
TitleCursorCheck:
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
    ld de, ActionButtonJumpTable_TitleScreen
    add hl, de                      ;3 * N + ActionButtonJumpTable
    jp hl                           ;Jump to specific input subroutine
;All of the possiblities for the Jump table move on to DPadCheck

DPadCheck_TitleScreen:
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
    ld de, DPadJumpTable_TitleScreen 
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
;This RET is just for safety, as each possible jump has its own RET
    ret

ButtonOne_TitleScreen:
;Check if we are on the start button
	ld hl, titleCursor.state
	ld a, (hl)
	cp $01
	jr z, +					;If not, then move to options screen

	ld hl, sceneComplete
	ld (hl), $01
	ret
+:
    ld hl, sceneID
    ld a, (hl)
    ld de, pauseSceneID
    ld (de), a
    ld (hl), PAUSE_SCREEN
;Cut to black
    call FadeToBlack
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

;Switch to correct bank for Title Assets
    ld a, DemoLevelBank
    ld ($FFFF), a
;Write target BG palette to targetPalette struct
    ld hl, targetBGPal.color0
    ld de, DemoLevelBGPal
    ld b, $10
    call PalBufferWrite
;Switch to correct bank for Title Assets
    ld a, TitleScreenYokoBank
    ld ($FFFF), a
;Go to Options screen
    call SetUpPause
;Return from Options screen
    halt
    call UpdateSAT                          ;Refresh our sprites
;Check if TATE or YOKO
    ld a, (tateMode)
    bit 0, a
    jr nz, +
;YOKO
    ld hl, pauseCursor.yPos                 ;Move the arrow to exit
    ld (hl), $66
    jr ++
;TATE
+:
    ld hl, pauseCursor.xPos                 ;Move the arrow to exit
    ld (hl), $80
++:
    call UpdatePauseSpriteBuffer            ;Update all of the sprites on the screen
    halt 
    call UpdateSAT                          ;Last update before fade to black

;If no changes were made, then reset the Options Buffer to reflect the actual status of Options Byte
    ld hl, optionsBuffer
    ld a, (optionsByte)
    ld (hl), a
    pop hl                  ;Get rid of the RET statement
    call FadeToBlack
    jp TitleScreen

ButtonTwo_TitleScreen:
    ld hl, tateMode
    ld a, (hl)
    bit 0, a
    jr nz, +
    ld (hl), $01
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
    call FadeToBlack
    jp TitleScreen
+:
    ld (hl), $00
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
    call FadeToBlack
    jp TitleScreen

	ret


DPadUp_TitleScreen:
;Check if we are on the START button
	ld hl, titleCursor.state
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
	ld hl, titleCursor.yPos    
	ld a, -$10
	add a, (hl)
	ld (hl), a
	ret
+:
;Move cursor in TATE mode
    ld hl, titleCursor.xPos    
	ld a, $10
	add a, (hl)
	ld (hl), a
    ret


DPadDown_TitleScreen:
;Check if we are on Options
	ld hl, titleCursor.state
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
	ld hl, titleCursor.yPos    
	ld a, $10
	add a, (hl)
	ld (hl), a
	ret
+:
;Move cursor in TATE mode
    ld hl, titleCursor.xPos    
	ld a, -$10
	add a, (hl)
	ld (hl), a
    ret

;==================================================
; Jump Tables
;==================================================
ActionButtonJumpTable_TitleScreen:
;If nothing is pressed, move on to check DPad
    jp DPadCheck_TitleScreen
;If button one is pressed, check where the cursor is, otherwise check if in options
    jp ButtonOne_TitleScreen               ;Left Button
    jp ButtonTwo_TitleScreen			   ;Right Button


DPadJumpTable_TitleScreen:
;If nothing is pressed, leave
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
;If a direction is pressed, then jump to do the correct action
    jp DPadUp_TitleScreen                                                  	;Only UP is pressed
    jp DPadDown_TitleScreen                                                	;Only DOWN is pressed
;In the case that UP and DOWN are both pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    ret                                                						;Only LEFT is pressed
	nop
	nop
    jp DPadUp_TitleScreen                                              		;UP and LEFT are pressed
    jp DPadDown_TitleScreen                                            		;LEFT & DOWN are pressed
;In the case that LEFT and UP and DOWN are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    ret						                                               ;Only RIGHT
	nop
	nop
    jp DPadUp_TitleScreen                                             ;RIGHT & UP
    jp DPadDown_TitleScreen                                           ;RIGHT & DOWN
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
