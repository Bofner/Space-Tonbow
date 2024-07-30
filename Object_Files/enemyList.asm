;================================================================
; Handles anything dealing with the Enemy List
;================================================================
EnemyList:

;==============================================================
; Constants
;==============================================================
.define ENEMY_LIST_SIZE     $1F


;================================================================
; Add enemy to enemy list
;================================================================
;Add an enemy to the Enemy list in the first ZERO location
;Parameters: HL = enemyList.enemyCount, DE = enemy.hitBox.width
;Affects: HL, DE, B
@CheckAvailability:
;First, check and make sure that we have don't have too many enemies
    ;ld hl, enemyList.enemyCount
    ld a, (hl)
    inc hl                          ;ld hl, enemyList.enemyCountMax
    cp (hl)
    ret nc                          ;If we are at max, then don't add
;Enter loop for finding nearest ZERO enemy
    ld b, ENEMY_LIST_SIZE
    dec hl                          ;ld hl, enemyList.enemyCount
;And update Enemy Counter
    inc (hl)
-:
    inc hl                          ;We are dealing with WORDS
    inc hl                          ;ld hl, enemyList.enemyX
    ld a, (hl)
    cp $00
    jp z, @AddEnemy          ;If ZERO, then we can add enemy here
    djnz -
@AddEnemy:
;Add enemy to list (Little endian)
    ld (hl), e
    inc hl
    ld (hl), d

    ret

;Check if enemy is already in list... a hacky way to fix a bug...
@CheckIfInList
;Parameters: HL = enemyList.enemyCount, DE = enemy.hitBox.width
;Affects: HL, DE, B   
;Returns C = 1 SAFE, C = 0 NOT SAFE
;Enter loop for finding nearest ZERO enemy
    ld b, ENEMY_LIST_SIZE
    ;ld hl, enemyList.enemyCount
-:
    inc hl                          ;We are dealing with WORDS
    inc hl                          ;ld hl, enemyList.enemyX
    ld a, (hl)
    cp e                            ;This is the ID of the enemy
    jp z, @@NOTSAFE          ;If ZERO, then DON'T ADD ENEMY
    djnz -
@@SAFE
    ld c, $01

    ret

@@NOTSAFE
    ld c, $00
    ret

;================================================================
; Remove an enemy from the list
;================================================================
;Remove an enemy from the Enemy list and move any other enemies up the list so we leave no gaps
;Parameters: HL = enemyList.enemyX, DE, enemyList.enemyCount, C = enemy number
;Affects: HL, DE, A, C
@RemoveEnemy:
;Set current enemy to ZERO
    ;ld hl, enemyList.enemyX LO
    ld (hl), $00
    inc hl                              ;ld hl, enemyList.enemyX HI
    ld (hl), $00
    ld a, (de)
    push de                             ;Save DE, enemyList.enemyCount
        cp c
        jp z, @RemoveEnd                    ;If we are removing the last enemy, dont move other up
    ;Move the rest of the enemies up the list, and replace them with zeros when moved
    -:
        inc hl                              ;ld hl, enemyList.enemyX+1 LO
        ld d, (hl)
        ld (hl), $00
        inc hl                              ;ld hl, enemyList.enemyX+1 HI
        ld e, (hl)
        ld (hl), $00
        dec hl                              ;ld hl, enemyList.enemyX+1 LO
        dec hl                              ;ld hl, enemyList.enemyX HI
        ld (hl), e
        dec hl                              ;ld hl, enemyList.enemyX LO
        ld (hl), d
        ld de, $0003
        add hl, de                          ;ld hl, enemyList.enemyX+2 LO
        inc c
    pop de                             ;Recall DE, enemyList.enemyCount
    ld a, (de)        
    cp $01                              ;If we only had 1 enemy, then we are done
    jp z, @RemoveEnd
    sub a, $02                          ;Otherwise, check if our enemy counter > remaining enemies
    cp c
    push de                             ;Push in case we cycle through
    jr nc, -
    pop de                              ;Pop it off when we are done and don't need it
@RemoveEnd:
;Update current Enemy count
    ex de, hl
    ;ld hl, enemyList.enemyCount
    dec (hl)

    ret


;================================================================
; Update all enemy AI
;================================================================
;Has enemies run their AI Update subroutines
;Parameters: tBD
;Affects: TBD
@UpdateEnemyAI:
;This needs to be made so it can be generalized to update ALL enemies
;In our Enemy List, we will set the UpdateEnemy address of the current enemy to HL, then
;JP HL. But FIRST, we will CALL SavePCForJPHL so that we can return
;If there's no enemies, don't try to update them
;Parameters: HL = list.enemyCount
    ld a, (hl)                      ;list.enemyCount
    ld b, a                         ;For our DJNZ counter
    cp $00
    ret z                           ;If we have no enemies, don't check
;Otherwise, update the enemies AI
    ld c, $00                       ;Set C to be our counter
;Select the current enemy that we want to update
    ld de, enemyListStruct.enemy0 - enemyListStruct.enemyCount 
    add hl, de
-:
    ;ld hl, enemyList.enemy0         ;(HL) now points to enemy0.hitBox.width
    push hl
        ld d, $00     
        ld a, c                         ;\
        add a, a                        ;/ Double C since we are jumping with WORDS
        ld e, a
        add hl, de                      ;(HL) now points to enemy[C].hitBox.width
        ld e, (hl)
        inc hl
        ld d, (hl)                      ;DE = enemy[C].hitBox.width 
    ;Check if enemy is alive or not
        ex de, hl
        ld de, enemyStruct.state - enemyStruct.hitBox.width
        add hl, de                      ;ld hl, enemy.state
        ld a, (hl)
        cp $00
        jr nz, @UpdateLiving
;If dead, then remove from list
    pop hl
    push hl                      ;Save again
    ;ld hl, enemyList.enemy0     ;HL now points to enemyList.enemy0
    ld de, enemyListStruct.enemyCount - enemyListStruct.enemy0
    add hl, de                   ;HL now points to enemyList.enemyCount
    ex de, hl                    ;\
    pop hl                       ; } HL = enemyList.enemy0
    push hl                      ;Save again
    push de                      ;/  DE = enemyList.enemyCount
    ld d, $00
    ld a, c                     ;C still holds the number of enemies we've checked
    add a, a                    ;Double because enemies stored as WORDS
    ld e, a 
    add hl, de                  ;HL now points to enemyList.enemy(the one that is now dead)
    pop de                      ;DE = enemyList.enemyCount
    push bc
    call @RemoveEnemy
    pop bc
    pop hl                      ;Need to get back to list.enemy0
    djnz -                      ;Move onto check the next enemy
    ret                         ;If final enemy is dead, then return
@UpdateLiving:
;Point to that enemy's Update-Subroutine
        ld de, enemyStruct.updateAIPointer - enemyStruct.state
        add hl, de                      ;ld hl, enemy.updateAIPointer, points to desitred subroutine
        ld e, (hl)
        inc hl
        ld d, (hl)
        push de
            ld de, enemyStruct.state - (enemyStruct.updateAIPointer + 1)        ;We are on the HI bit
            add hl, de
        pop de
        ex de, hl                       ;HL = Subroutine JP location
        push bc
    ;Save the current Program Counter
        call @SavePCForJPHL             ;\
        jp (hl)                         ;/ call hl
        pop bc
        inc c                           ;Keep track of how many enemies we've updated
    pop hl                              ;Need to get back to list.enemy0
    djnz -

    ret


;Saves the PC onto the stack. One usecase is for JP HL to be able to RET
;Parameters:
;Affects: IX
@SavePCForJPHL:
    ld ixl, e       ;\Preserve DE
    ld ixh, d       ;/
        pop de       ;DE now has the value of the PC after the CALL instruction
        inc de       ;DE now points just 2 steps after the CALL
        push de      ;Push once so we can use it later
        dec de       ;Now it points to just after call
        push de      ;Push again so we can RET now
    ld e, ixl       ;\
    ld d, ixh       ;/Restore DE

    ret

;================================================================
; Check Enemy Collision w/ Tonbow's Hurtbox
;================================================================
;Check if an enemy is colliding with Tonbow
;Parameters: HL = enemy.hitBox.width, Called from Enemy's UpdateAI subroutine 
;Affects: BC, DE, A 
@TonbowHurtboxCollisionCheck:
;Check if Tonbow is attacking
    ld a, (tonbow.dashState)
    bit 0, a
    jp z, @TonbowCollisionCheck
;If attacking, then see if our enemy is being attacked
    ld de, tonbow.hurtBox.width
    push hl
        call CheckCollisionTwoHitboxes  
    pop hl                              ;A = Hit Result 
    cp $00
    jp z, @TonbowCollisionCheck
;If collision detected, then kill Enemy and +1 score
    push hl
    ;Score
        ld de, enemyStruct.state - enemyStruct.hitBox.width
        add hl, de
        ld (hl), $FF
        call PlusScore
    ;Work in the Audio Bank
        ld a, Audio
        ld ($FFFF), a
    ;Check for FM
        ld a, (playFM)
        cp $01
        jr z, +
	    ld hl, ExplosionSFX
	    ld c, SFX_CHANNEL3		;Channels 3
	    call PSGSFXPlay
        jr ++
    ;Play FM SFX
+:
	    ld hl, MBMSFXBank
	    ld (hl), Audio
	    ld hl, MBMSFXStart
        ld de, ExplosionSFXFM
	    ld a, e
        ld (hl), a
        ld a, d
        inc hl
        ld (hl), a
        call MBMSFXPlay 
++:
    ;Switch to correct bank for Title Assets
        ld a, DemoLevelBank
        ld ($FFFF), a
    pop hl
    
    ret                                 ;Enemy dies, not Tonbow

;================================================================
; Check Enemy Collision w/ Tonbow's Hitbox
;================================================================
@TonbowCollisionCheck:
    ld de, tonbow.hitBox.width
    push hl
        call CheckCollisionTwoHitboxes  
    pop hl                              ;A = Hit Result
    cp $00
    ret z           
;If hit, then tonbow dies
    push hl
        call TonbowDead
    pop hl

    ret


;================================================================
; Initialization
;================================================================
;Initializes the enemy list
;Parameters: HL = enemyList.enemyCountA = Max number of enemies on screen
;Affects: HL, B
InitEnemyList:
    ;ld hl, enemyList.enemyCount
    ld (hl), 0
    inc hl                          ;ld hl, enemyList.enemyCountMax
    ld (hl), a
    ld b, $10
-:
    inc hl                          ;ld hl, enemyList.enemy.hitBox.y1 LO
    ld (hl), 0
    inc hl                          ;ld hl, enemyList.enemy.hitBox.y1 HI
    ld (hl), 0
    djnz -
    inc hl                          ;ld hl, removedFlag
    ld (hl), 0

    ret