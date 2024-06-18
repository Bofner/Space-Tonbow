;Updates the scroll of the Parallax stars int he BG
;Parameters: None
;Affects:HL, BC, DE, A
DemoUpdateBGParallax:
	ld hl, scrollX0Frac
    ld a, (hl)
    sub a, $03
    call c, BGScrollCarry
    ld (hl), a              ;Save new value
    inc hl
    inc hl                  ;ld hl, scrollX1Frac
    ld a, (hl)
    sub a, $08
    call c, BGScrollCarry
    ld (hl), a              ;Save new value
    ld hl, scrollX0Frac
    jp BGScrollConvertToPixels
BGScrollCarry:
    inc hl
    dec (hl)
    dec hl
    ret

BGScrollConvertToPixels
;Set Y-Fractional-Position to scrollX BG Pixel position 
    ;ld hl, scrollX0Frac                       ;(HL) = WHOLE LO, FRAC
    ld a, (hl)
    srl a
    srl a
    srl a
    srl a                                       ;A = $Aa... A = 0, a = WHOLE LO
    inc hl                                      ;(HL) = UNUSED, WHOLE HI
    push hl                                     ;Save scrollX0Frac HI for later
        ld b, a
        ld a, (hl)
        sla a
        sla a
        sla a
        sla a                                       ;A = $Aa... A = WHOLE HI, a = 0
        or b                                        ;A = WHOLE HI, WHOLE LO
        ld d, $FF       ;\
        ld e, scrollX0 - (scrollX0Frac + 1)         ; } ld hl, scrollX0
        add hl, de      ;/
        ld (hl), a 
        ld c, a                                     ;Save scrollX0
    pop hl                                     ;Recover scrollX0Frac HI
;Set Second BG X-scroll speed
    inc hl        ;ld hl, scrollX1Frac          ;(HL) = WHOLE LO, FRAC
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
    ld e, scrollX1 - (scrollX1Frac + 1)         ;Get to demoOrb.xPos
    add hl, de                                  ;ld hl, scrollX1
    ld (hl), a                                  ;Save Value

	ret