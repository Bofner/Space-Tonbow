;========================================================
; Used to updated the difficulty of the game
;========================================================

;Referenced from PlusScore
UpdateLevel:
;Update level
    ld a, (score)
    cp $26
    jr nc, +
;3 * N + DPadJumpTable
    ld c, a
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, UpdateLevelJumpTable 
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine
+:
    and $09
    cp $09
    jp z, ScoreIncreaseSpeed
    ret


UpdateLevelJumpTable:
    jp ScoreIncreaseEnemies         ;1, Enemies = 2
    ret                             ;2
    nop
    nop
    jp ScoreIncreaseEnemies         ;3, Enemies = 3
    jp ScoreIncreaseSpeed           ;4
    jp ScoreIncreaseEnemies         ;5, Enemies = 4
    jp ScoreIncreaseSpeed           ;6
    jp ScoreIncreaseEnemies         ;7, Enemies = 5
    jp ScoreIncreaseEnemies         ;8, Enemies = 6
    jp ScoreIncreaseSpeed           ;9
;-------------------------------------------------------------------------------------   
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
;-------------------------------------------------------------------------------------   
    jp ScoreIncreaseSpeed           ;10
    jp ScoreIncreaseSpeed           ;11
    jp ScoreIncreaseEnemies         ;12, Enemies = 7
    jp ScoreIncreaseSpeed           ;13
    jp ScoreIncreaseSpeed           ;14
    jp ScoreIncreaseEnemies         ;15, Enemies = 8
    jp ScoreIncreaseEnemies         ;16, Enemies = 9
    jp ScoreIncreaseEnemies         ;17, Enemies = $0A
    jp ScoreIncreaseSpeed           ;18
    jp ScoreIncreaseSpeed           ;19
;-------------------------------------------------------------------------------------   
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
    ret                             ;Buffer (Score is written in decimal in the byte)
    nop
    nop
;-------------------------------------------------------------------------------------
    jp ScoreIncreaseEnemies         ;20, Enemies = $0B
    jp ScoreIncreaseSpeed           ;21
    jp ScoreIncreaseEnemies         ;22, Enemies = $0C
    jp ScoreIncreaseSpeed           ;23
    ret                             ;24
    nop
    nop
    jp ScoreIncreaseSpeed           ;25
    jp ScoreIncreaseSpeed           ;26

    ret


ScoreIncreaseEnemies:
;Increase maximum enemies on screen
    ld hl, enemyList.enemyCountMax
    inc (hl)
    ld hl, projectileList.enemyCountMax
    inc (hl)

    ret

ScoreIncreaseSpeed:
;Enemy speed increases
    ld hl, demoOrbSpeed
    inc (hl)
    inc (hl)

    ret
