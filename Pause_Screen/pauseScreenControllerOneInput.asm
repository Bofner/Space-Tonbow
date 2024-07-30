;==================================================
; Constants
;==================================================
.define TATEMODE_YOKO_VRAM           $39E4
.define TATEMODE_TATE_VRAM           $3BAC
.define CURSOR_COOLDOWN_TIME         $0A

;==================================================
; Check Controls for Player 1 Input
;==================================================

;Checks the input of player 1 joypad
    ;Parameters: None
    ;Affects: A, C, DE, HL
PauseScreenJoypad1Check:

MDStartButtonCheck_pause:
/*
TH = 0	?	0	S	A	0	0	D	U
TH = 1	?	1	C	B	R	L	D	U
*/
;Check if SMS Button 2 is being pressed...
    in a, $DC                       ;Send Joypad port 1 input data to register A
    ld (DCInput), a                 ;Save $DC input for later
    bit    5,a
    jr z, ButtonCheck_pause         ;...If true, then skip checking START button

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

ButtonCheck_pause:
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
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, ActionButtonJumpTable_pause
    add hl, de                      ;3 * N + ActionButtonJumpTable
    jp hl                           ;Jump to specific input subroutine
;All of the possiblities for the Jump table move on to DPadCheck

DPadCheck_pause:
    ld a, (DCInput)                 ;Recall Joypad 1 input data
    cpl                             ;Invert the bits so 1 indicates a press
    and %00001111                   ;Make a mask to only look at the D-Pad
;3 * N + DPadJumpTable
    ld c, a
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, DPadJumpTable_pause
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
;This RET is just for safety, as each possible jump has its own RET
    ret


;==================================================
; Button Actions
;==================================================
ButtonOne_pause:
;Check if we are on coolDown
    ld hl, pauseCursor.coolDownTimer
    ld a, (hl)
    cp $00
    jr nz, +                        ;If we are still on cool down, then don't do anything
;Otherwise set cool down timer and execute
    ld hl, pauseCursor.coolDownTimer
    ld (hl), CURSOR_COOLDOWN_TIME + 2

    ld a, (pauseCursor.state)
;3 * N + PauseJumpTable
    ld c, a
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, PauseCursorButtonStateTable
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
+:
    jp DPadCheck_pause

ButtonTwo_pause:
    ;Code Here
+:
    jp DPadCheck_pause

ButtonOneAndTwo_pause:
    ;Code Here
+:
    jp DPadCheck_pause



;==================================================
; DPad Actions
;==================================================
DPadUp_pause:
;Check if we are at the first state
    ld a, (pauseCursor.state)
    sub 1
    bit 7, a
    jr nz, ++
;Check if we are on coolDown
    ld hl, pauseCursor.coolDownTimer
    ld a, (hl)
    cp $00
    jr nz, ++                        ;If we are still on cool down, then don't move
    ld hl, pauseCursor.yPos
;If in TATE mode, we want to effect the xPos
    ld a, (tateMode)    ;\
    ld d, 0             ; } TATE
    ld e, a             ; }
    add hl, de          ;/    
;Also work in TATE mode where we need to ADD 24 instead
    ld a, (tateMode)
    ld b, a         
    ld a, -24            ;Distance between options
    bit 0, b            ;Check if TATE
    jr z, +
    neg                 ;If yes, then change the sign
+:
    add a, (hl)         ;And move Cursor to next option
    ld (hl), a
;Change state
    ld hl, pauseCursor.state
    dec (hl)
;Set cool down timer
    inc hl              ;ld hl, pauseCursor.coolDownTimer
    ld (hl), CURSOR_COOLDOWN_TIME
++:
    ret


DPadDown_pause:
;Check if we are at the final state
    ld a, (pauseCursor.state)
    cp $02
    jr nc, ++
;Check if we are on coolDown
    ld hl, pauseCursor.coolDownTimer
    ld a, (hl)
    cp $00
    jr nz, ++                        ;If we are still on cool down, then don't move
    ld hl, pauseCursor.yPos
;If in TATE mode, we want to effect the xPos
    ld a, (tateMode)    ;\
    ld d, 0             ; } TATE
    ld e, a             ; }
    add hl, de          ;/    
;Also work in TATE mode where we need to SUBTRACT 24 instead
    ld a, (tateMode)
    ld b, a         
    ld a, 24            ;Distance between options
    bit 0, b            ;Check if TATE
    jr z, +
    neg                 ;If yes, then change the sign
+:
    add a, (hl)         ;And move Cursor to next option
    ld (hl), a
;Change state
    ld hl, pauseCursor.state
    inc (hl)
;Set cool down timer
    inc hl              ;ld hl, pauseCursor.coolDownTimer
    ld (hl), CURSOR_COOLDOWN_TIME
++:
    ret

;Left and Right will fundtion the same 
DPadLeft_pause:
    ;Code Here

    ;ret

DPadRight_pause:
;Check if we are on coolDown
    ld hl, pauseCursor.coolDownTimer
    ld a, (hl)
    cp $00
    jr nz, +                        ;If we are still on cool down, then don't do anything
;Otherwise set cool down timer and execute
    ld hl, pauseCursor.coolDownTimer
    ld (hl), CURSOR_COOLDOWN_TIME + 2

    ld a, (pauseCursor.state)
;3 * N + PauseJumpTable
    ld c, a
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, PauseCursorDpadStateTable
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
+:
    ret

;----------------
;Multi Button
;----------------
DPadUpLeft_pause:
    ;Code Here

    ret

DPadUpRight_pause:
    ;Code Here

    ret

DPadDownLeft_pause:
    ;Code Here

    ret

DPadDownRight_pause:
    ;Code Here

    ret

;==================================================
; Cursor States
;==================================================
;---------------------
; State 0, TATE Mode
;---------------------
CursorState0:
;This will work differently depending on if in TATE or not
    ld a, (tateMode)
    bit 0, a
    jr nz, PauseModeChangeTate

;--------------
; Yoko
;--------------
PauseModeChangeYoko:
;Check if TATE has been switched on or is off
    ld a, (optionsBuffer)
    bit 0, a                            
    jr nz, +

;Change so TATE is ON in the buffer
    ld hl, optionsBuffer
    ld a, (hl)
    set 0, a                        ;Turn TATE mode ON in the buffer
    ld (hl), a
;ON Message
    ld hl, TATEMODE_YOKO_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, TateOnMsg

    jr PauseModeChangeYokoWrite

+:
;Change so TATE is OFF in the buffer
    ld hl, optionsBuffer
    ld a, (hl)
    res 0, a                        ;Turn TATE mode ON in the buffer
    ld (hl), a
;OFF Message
    ld hl, TATEMODE_YOKO_VRAM | VRAMWrite
    call SetVDPAddress
    ld hl, TateOffMsg

PauseModeChangeYokoWrite:
-:  ld a,(hl)
    cp $ff
    jr z,+
    out (VDPData),a
    xor a
    out (VDPData),a
    inc hl
    jr -
+:
    
    ret


;--------------
; TATE
;--------------
PauseModeChangeTate:
;Check if TATE has been switched on or is off
    ld a, (optionsBuffer)
    bit 0, a                            
    jr nz, +

;Change so TATE is ON in the buffer
    ld hl, optionsBuffer
    ld a, (hl)
    set 0, a                        ;Turn TATE mode ON in the buffer
    ld (hl), a
;ON Message
    ld hl, TATEMODE_TATE_VRAM | VRAMWrite
    call SetVDPAddress
    ld de, TateOnMsg
    jr PauseModeChangeTateWrite
+:
;Change so TATE is OFF in the buffer
    ld hl, optionsBuffer
    ld a, (hl)
    res 0, a                        ;Turn TATE mode ON in the buffer
    ld (hl), a
;OFF Message
    ld hl, TATEMODE_TATE_VRAM | VRAMWrite
    call SetVDPAddress
    ld de, TateOffMsg

PauseModeChangeTateWrite:
    ld b, 0                         ;\
    ld c, $40                       ; } For writing our message vertically
-:  ld a, (de)                      ;/
    cp $ff
    jr z,+
    out (VDPData),a
    xor a
    out (VDPData),a
    inc de
;Move to next row
    add hl, bc                      ;Should be one below
    call SetVDPAddress
    jr -
+:

    ret

;---------------------
; State 1, Apply
;---------------------
CursorState1:
    ld hl, optionsBuffer
    ld a, (hl)
    ld hl, optionsByte
    ld (hl), a

    ld hl, tateMode
    bit 0, a                    ;A = (optionsByte)
    jr z, +                     ;If bit is zero, then set tateMode to 0
    ld (hl), 1
    jr ++
+:
    ld (hl), 0

++:
    call GameOverInit
    ld a, (tateMode)
    bit 0, a
    call z, InitYokoHighScore
    jr +
    call InitTateHighScore
+:
    pop hl                      ;This upsets the stack for some reasons
    jp SetUpPause
    ret

;---------------------
; State 2, Exit
;---------------------
CursorState2:
;Exit on button press
    ld hl, sceneID
    ld a, (pauseSceneID)
    ld (hl), a
    ret

;---------------------
; State 3, Exit
;---------------------
CursorState3:


    ret

;---------------------
; State 4, Exit
;---------------------
CursorState4:


    ret

;---------------------
; State 5, Bestiary
;---------------------
CursorState5:

    ret

NoCursorAction:

    ret

;==================================================
; Action Button Jump Table
;==================================================
ActionButtonJumpTable_pause:
;If nothing is pressed, move on to check DPad
    jp DPadCheck_pause
;If a button is pressed, then move, or if both, change direction
    jp ButtonOne_pause                ;Left Button
    jp ButtonTwo_pause                ;Right Button
    jp ButtonOneAndTwo_pause          ;Double input 


;==================================================
; DPad Jump Table
;==================================================
DPadJumpTable_pause:
;If nothing is pressed, leave
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
;If a direction is pressed, then jump to do the correct action
    jp DPadUp_pause                                                   ;Only UP is pressed
    jp DPadDown_pause                                                 ;Only DOWN is pressed
;In the case that UP and DOWN are both pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    jp DPadLeft_pause                                                 ;Only LEFT is pressed
    jp DPadUpLeft_pause                                               ;UP and LEFT are pressed
    jp DPadDownLeft_pause                                             ;LEFT & DOWN are pressed
;In the case that LEFT and UP and DOWN are pressed
    ret                         ;JP is 3 bytes...
    nop                         ;...RET is only 1...
    nop                         ;...So 2 NOPs are added for cushion
    jp DPadRight_pause                                                ;Only RIGHT
    jp DPadUpRight_pause                                              ;RIGHT & UP
    jp DPadDownRight_pause                                            ;RIGHT & DOWN
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

;==================================================
; Pause Cursor DPad Jump Table
;==================================================
PauseCursorDpadStateTable:
    jp CursorState0                     ;State 0, TATE Mode
    jp NoCursorAction                     ;State 1, Apply
    jp NoCursorAction                     ;State 2,Exit
    jp NoCursorAction                   ;State 3, Apply
    jp NoCursorAction                   ;State 4, Exit
    jp NoCursorAction                     ;State 5, Bestiary

;==================================================
; Pause Cursor Button Jump Table
;==================================================
PauseCursorButtonStateTable:
    jp CursorState0                     ;State 0, TATE Mode
    jp CursorState1                   ;State 1, Apply
    jp CursorState2                   ;State 2, Exit
    jp NoCursorAction                     ;State 3, Apply
    jp NoCursorAction                     ;State 4, Exit
    jp NoCursorAction                     ;State 5, Bestiary

;==================================================
; State Change words
;==================================================
.asciitable
    map " " = $d6
    map "0" to "9" = $d7
    map "!" = $e1
    map "," = $e2
    map "." = $e3
    map "'" = $e4
    map "?" = $e5
    map "A" to "Z" = $e6
.enda
;---------------------
; State 0, TATE Mode
;---------------------
;OFF
TateOffMsg:
    .asc "OFF"
    .db $ff     ;Terminator byte
TateOffMsgEnd:
;-------------------------
;ON
TateOnMsg:
    .asc "ON "
    .db $ff     ;Terminator byte
TateOnMsgEnd:

