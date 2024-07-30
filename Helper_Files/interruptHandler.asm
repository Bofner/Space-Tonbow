;Get here after coming from $0038
InterruptHandler:
;Check if we are at VBlank, Bit 7 tells us that
    ld a, (VDPStatus)
    bit 7, a                ;Z is set if bit is 0
    jp nz, VBlank           ;If bit 7 is 1, then we are at VBlank

;=========================================================
; HBlank
;=========================================================
HBlank:
    push hl                         ;Preserve HL
    ld hl, frameFinish
    push af
    ld a, (hl)
    res 4, a
    ld (hl), a
    pop af
    ld hl, VDPStatus
    bit 5, a                        ;A = VDPStatus already
    jr z, +
    set 5, (hl)                     ;Sprite collision      
+:
	ld hl, (nextHBlankStep)		    ;\ JUMP to next step for HBLANK
	jp (hl)					        ;/

;Potential idea. This game will only use HBlank for parallax... I think. 
;This current iteration is good for when a bunch of different things are happening
;But I if I use this loading step to instead set up the next X-Scroll speed,
;That might make this slightly more efficient (and faster), so we would only have to do
/*
    ld hl, (nextXScrollValue)		    ;Load next Hscroll value
    ld a, (hl)
    out (PORT_VDP_ADDRESS), a
	ld a, $88
	out (PORT_VDP_ADDRESS), a		;Set BG X-Scroll to whatever
    ld bc, $02                      ;One WORD
    add hl, bc                      ;HL points to next scrollX value
    ld (nextXScrollValue), hl
    exx
    ex af, af'
    ei
    reti
;Then at VBlank, the first value in the chain would replace this bad value,
;Or maybe the last one in the chain is 0, and we have a HUD at the top of the 
;screen, so VBlank uses this to change the value, and then point to the first
;one in the chain to restart the cycle
*/


FirstHBlank:
    ld hl, +
    ld (nextHBlankStep), hl         ;Prepare the step for the next HBLANK
    ld hl, scrollX0
    ld a, (hl)
	out (PORT_VDP_ADDRESS), a
	ld a, $88
	out (PORT_VDP_ADDRESS), a		;Set BG X-Scroll to whatever
;Restore registers
    pop hl
    pop af
    ei
    reti

+:
    ld hl, FirstHBlank
    ld (nextHBlankStep), hl         ;Prepare the step for the next HBLANK
    ld hl, scrollX1
    ld a, (hl)
	out (PORT_VDP_ADDRESS), a
	ld a, $88
	out (PORT_VDP_ADDRESS), a		;Set BG X-Scroll to something
;Restore registers
    pop hl
    pop af
    ei
    reti

;=========================================================
; VBlank
;=========================================================
;If we are on the last scanline
VBlank:
;We are at VBlank
    push hl                         ;Preserve HL
    push bc
    push de

    ld hl, VDPStatus
    bit 7, a                        ;A = VDPStatus already
    jr z, +
    set 7, (hl)                     ;Sprite collision 
+:
;Update frame count up to 60
    ld hl, frameCount               ;Update frame count
    ld a, 60                        ;Check if we are at 60
    cp (hl)
    jr nz, +                        ;If we are, then reset
ResetFrameCount:
    ld (hl), -1
+:
    inc (hl)                        ;Otherwise, increase

UpdateMusic:
;Work in the Audio Bank
    ld a, Audio
    ld ($FFFF), a
    ld a, (playFM)
    cp $01
    jr z, +
-:
    call PSGFrame
    call PSGSFXFrame
    jr ++
+:
;Check if we actually want to use FM
    ld a, (onFM)
    cp $01
    jr nz, -
;Preserve ix and af'
    exx
    push hl
    exx
    ld a, ixh
    ld h, a
    ld a, ixl
    ld l, a
    push hl
    ld a, iyh
    ld h, a
    ld a, iyl
    ld l, a
    ex af, af'
    push af
    push hl
    call MBMFrame
    ld a, (frameCount)
    bit 0, a
    jr z, +
    call MBMSFXFrame
+:
    pop hl
    pop af
    ex af, af'
    ld a, l
    ld iyl, a
    ld a, h
    ld iyh, a
    pop hl
    ld a, l
    ld ixl, a
    ld a, h
    ld ixh, a
    exx
    pop hl
    exx

++:
;Switch to correct bank for Title Assets
    ld a, (currentBank)
    ld ($FFFF), a
EndVBlank:
;Check if we have completed the previous frame
    ld hl, frameFinish
    ld a, (hl)
    cp $00
    jr z, +

;If yes, then set a variable to say such
    set 4, a
    ld (hl), a
    jr ++
;Else, set it to say NO, we need to SLOW DOWN
+:
    ld (hl), $00
;Restore registers
++:
    pop de
    pop bc
    pop hl
    pop af
    ei
;Leave
    reti


