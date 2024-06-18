;==============================================================
; Constants
;==============================================================
.define ZERO_VRAM	        $A2
.define TATE_SCORE_VRAM     $3240
.define TATE_SCORE_CC       $92
.define TATE_SCORE_ZERO     scoreTateTiles + $40

;Adds 1 to the score, which is represented in Decimal
;Parameters: None
;Affects: HL, DE, A
PlusScore:
;Update Level
    call UpdateLevel
;Add one to score
	ld de, score
    ex de, hl
    ld a, (hl)
    add a, 1
    ld (hl), a
;Check if > $0A
    and $0A
    cp $0A
    call nc, ScoreCarryTens
;Update Graphics
    ;call UpdateScoreGraphics
    ex de, hl
    ret
ScoreCarryTens:
;If > $0A, set to DEC representation of our score
    ld a, (hl)
    add a, $06
    ld (hl), a
    ;Check if > $99
    cp $9A
    jp nc, ScoreOver100
    ret
ScoreOver100:
    ld (hl), $00
    inc hl
    ld a, (hl)
    add a, 1
    ld (hl), a
;Later implement some kind of STOP at 999    
    ret



;================================================================
; Update Score Graphics
;================================================================
;Updates the score (8-Bit)
;Parameters: 
;Affects: HL, A
UpdateScoreGraphics:
    ld a, (tateMode)
    cp $01
    jr z, UpdateScoreGraphicsTate
;Select Hundred
    ld a, (score + 1)
    ld hl, scoreHuns.cc
    cp $00                  
    jp z, UpdateTensGraphics   ;If less than 1, don't display a number
    ld (hl), ZERO_VRAM      
    add a, a                ;Double A since 8x16
    add a, (hl)             ;Add value to the Zero RAM value
    ld (hl), a
    ld hl, scoreTens.cc
    ld (hl), ZERO_VRAM

UpdateTensGraphics:
    ld a, (score)
    ld hl, scoreTens.cc
    and $F0                 ;Mask out the ONES place
    cp $00                  
    jp z, UpdateOnesGraphics   ;If less than 1, don't display a number
    ld (hl), ZERO_VRAM      
    srl a                   ;\    
    srl a                   ; } Move tens digit to the ONES digit
    srl a                   ; }
    srl a                   ;/
    add a, a                ;Double A since 8x16
    add a, (hl)             ;Add value to the Zero RAM value
    ld (hl), a
    ld hl, scoreOnes.cc
    ld (hl), ZERO_VRAM

UpdateOnesGraphics:
    ld a, (score)
    ld hl, scoreOnes.cc
    and $0F                 ;Mask out the TENS place
    ld (hl), ZERO_VRAM      
    add a, a                ;Double A since 8x16
    add a, (hl)             ;Add value to the Zero RAM value
    ld (hl), a

    ret

UpdateScoreGraphicsTate:
@Hundreds:
;Update hundreds place
    ld a, (score + 1)
    cp $00                  
    jp z, @Tens             ;If less than 1, don't display a number
;Do the update for the bottom half of the hundreds...
    ld hl, TATE_SCORE_VRAM | VRAMWrite  
    call SetVDPAddress
    ld hl, TATE_SCORE_ZERO
    ld b, a                 ;\
    ld de, $40              ; }
-:                          ; } Get to correct digit
    add hl, de              ; }       
    djnz -                  ;/         
    ld b, $20
    call FastCopyToVDP
    push hl
;Do the update for the top half of the hundreds...
    ld hl, TATE_SCORE_VRAM + $40 | VRAMWrite  
    call SetVDPAddress
    pop hl
    ld b, $20
    call FastCopyToVDP

@Tens:
;Update Tens place
    ld a, (score)
    and $F0                 ;Mask out the ONES place
    cp $00                  
    jp z, @Ones             ;If less than 1, don't display a number
;Do the update for the bottom half of the tens...
    ld hl, TATE_SCORE_VRAM + $20 | VRAMWrite  
    call SetVDPAddress
    ld hl, TATE_SCORE_ZERO
    srl a                   ;\    
    srl a                   ; } Move tens digit to the ONES digit
    srl a                   ; }
    srl a                   ;/
    ld b, a                 ;\
    ld de, $40              ; }
-:                          ; } Get to correct digit
    add hl, de              ; }       
    djnz -                  ;/         
    ld b, $20
    call FastCopyToVDP
    push hl
;Do the update for the top half of the tens...
    ld hl, TATE_SCORE_VRAM + $60 | VRAMWrite  
    call SetVDPAddress
    pop hl
    ld b, $20
    call FastCopyToVDP

@Ones:
;Update ones place
    ld a, (score)
    and $0F
;Do the update for the bottom half of the ones...
    ld hl, TATE_SCORE_VRAM + $80| VRAMWrite  
    call SetVDPAddress
    ld hl, TATE_SCORE_ZERO
    cp $00
    jr z, +
    ld b, a                 ;\
    ld de, $40              ; }
-:                          ; } Get to correct digit
    add hl, de              ; }       
    djnz -                  ;/     
+:    
    ld b, $20
    call FastCopyToVDP
    push hl
;Do the update for the top half of the ones...
    ld hl, TATE_SCORE_VRAM + $C0 | VRAMWrite  
    call SetVDPAddress
    pop hl
    ld b, $20
    call FastCopyToVDP
    ret


;================================================================
; Initialization
;================================================================
;Initializes the score
;Parameters: 
;Affects: HL, A
InitScoreYoko:
;ONES
;Don't forget TATE shit
    ld hl, scoreOnes.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, scoreOnes.width
    ;Sprite is 1x2 for 8x8
    ld (hl), $01                        
    inc hl                              ;ld hl, scoreOnes.height
    ld (hl), $01                        
    inc hl                              ;ld hl, scoreOnes.yPos
    ld (hl), $00
    inc hl                              ;ld hl, scoreOnes.xPos
    ld (hl), $F4;244
    inc hl                              ;ld hl, scoreOnes.cc
    ld (hl), ZERO_VRAM
;TENS
	ld hl, scoreTens.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, scoreOnes.width
    ;Sprite is 1x2 for 8x8
    ld (hl), $01                        
    inc hl                              ;ld hl, scoreOnes.height
    ld (hl), $01                        
    inc hl                              ;ld hl, scoreOnes.yPos
    ld (hl), $00
    inc hl                              ;ld hl, scoreOnes.xPos
	ld a, (scoreOnes.xPos)
	sub a, $08
    ld (hl), a
    inc hl                              ;ld hl, scoreOnes.cc
    ld (hl), ZERO_VRAM - 2

;HUNDREDS
	ld hl, scoreHuns.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, scoreOnes.width
    ;Sprite is 1x2 for 8x8
    ld (hl), $01                        
    inc hl                              ;ld hl, scoreOnes.height
    ld (hl), $01                        
    inc hl                              ;ld hl, scoreOnes.yPos
    ld (hl), $00
    inc hl                              ;ld hl, scoreOnes.xPos
    ld a, (scoreOnes.xPos)
	sub a, $10
    ld (hl), a
    inc hl                              ;ld hl, scoreOnes.cc
    ld (hl), ZERO_VRAM - 2

ret

InitScoreTate:
;ONES
;Don't forget TATE shit
    ld hl, scoreTATE.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $10                        ;8x16
    inc hl                              ;ld hl, scoreOnes.width
    ;Sprite is 2x2 for 8x16
    ld (hl), $02                        
    inc hl                              ;ld hl, scoreOnes.height
    ld (hl), $02                        
    inc hl                              ;ld hl, scoreOnes.yPos
    ld (hl), $A0;186
    inc hl                              ;ld hl, scoreOnes.xPos
    ld (hl), $EC;244
    inc hl                              ;ld hl, scoreOnes.cc
    ld (hl), TATE_SCORE_CC

    ret