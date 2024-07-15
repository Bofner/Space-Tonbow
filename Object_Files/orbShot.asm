;==============================================================
; Constants
;==============================================================
.define ORBSHOTINDEX	$24
.define ORB_SHOT_SPEED  $05
.define ORB_SHOT_WIDTH  $07
.define ORB_SHOT_HEIGHT	$06

;Shot will be spawned into existance by the Demo Orb, but after that it
;Will be its own entity, and will act on its own
SpawnOrbShot:
;Check if the Orb exploded at the end of the screen or if it was killed by Tonbow
; ^^This is done by only running this when it reaches the edge of the screen

;Make our sound effect
	push hl
;Work in the Audio Bank
	ld a, (tonbow.alive)
	cp $00
	jr z, +
    ld a, Audio
    ld ($FFFF), a
	ld hl, DemoFireSFX
	ld c, SFX_CHANNELS2AND3		;Channels 1 and 3
	call PSGSFXPlay
;Switch to correct bank for Title Assets
    ld a, DemoLevelBank
    ld ($FFFF), a
+:
	pop hl

;Find out which number demoOrb just called the spawn and select
	;ld hl, demoOrbStruct.state
	push hl								;Save demoOrbStruct.state
		ld de, demoOrb0.state
		scf									;\
		ccf									;/ Set Carry Flag to 0
		sbc hl, de							;Subtract with Carry (Carry = 0)
		ld d, _sizeof_demoOrbStruct
		ld a, l
		ld h, a
		call Div8Bit
		ld a, l								;We are looking at the Ath demoOrb
;Grab the corresponding orbShot
		ld d, $00
		ld e, _sizeof_orbShotStruct
		call Mult8Bit						;HL = distance between orbShot0 and orbShotA
		ld de, orbShot0
		add hl, de							;HL = Ath orbShot	
;Initialize the orbShot 	
	;Set Hitbox dimensions
		ld de, orbShotStruct.hitBox.width - orbShotStruct.hitBox.y1
		add hl, de
		ld (hl), ORB_SHOT_WIDTH
		inc hl								;ld hl, orbShotStruct.hitBox.height
		ld (hl), ORB_SHOT_HEIGHT

	;Set alive
		ld de, orbShotStruct.state - orbShotStruct.hitBox.height
		add hl, de							;ld hl, orbShot.state
		ld (hl), $01
	;Set Y Position
		ld de, orbShotStruct.yPos - orbShotStruct.state
		add hl, de							;ld hl, orbShot.yPos
	pop ix								;Grab demoOrb.state
	push ix								;Throw it back
		ld de, demoOrbStruct.yPos - demoOrbStruct.state
		add ix, de							;ld ix, demoOrbStruct.yPos
		ld a, (ix + 0)
		add a, $04
		ld (hl), a				
	;Set X Position			
		inc hl								;ld hl, orbShot.xPos
		inc ix								;ld ix, demoOrb.xPos
		ld a, (ix + 0)
		ld (hl), a		
	;Set the hitbox X
		ld de, orbShotStruct.hitBox.x1 - orbShotStruct.xPos
		add hl, de							;ld hl, orbShot.hitBox.yPos
		;make a smaller hitbox for bullet
		add a, 1
		ld (hl), a							
		add a, ORB_SHOT_WIDTH
		inc hl								;ld hl, orbShot.hitBox.x1
		inc hl								;ld hl, orbShot.hitBox.x2
		ld (hl), a
	;Set the hitbox Y
		ld de, orbShotStruct.hitBox.y1 - orbShotStruct.hitBox.x2
		add hl, de							;ld hl, orbShot.hitBox.yPos
		dec ix								;ld ix, demoOrb.yPos
		ld a, (ix +0)
		;make a smaller hitbox for bullet
		add a, 6
		ld (hl), a							
		add a, ORB_SHOT_HEIGHT
		inc hl								;ld hl, orbShot.hitBox.y1
		inc hl								;ld hl, orbShot.hitBox.y2
		ld (hl), a

	

;Add the corresponding orbShot into the projectileList
		ld de, orbShotStruct.hitBox.width - orbShotStruct.hitBox.y2
		add hl, de
		ex de, hl
		ld hl, projectileList.enemyCount	;HL = enemyList.enemyCount, DE = enemy.hitBox.width
	;Check if enemy is already added
    	call EnemyList@CheckIfInList
    	ld a, $00
    	cp c
    	jr z, @NOTSAFE                               ;If not safe, then dip
	;Check if space available
    	ld hl, projectileList.enemyCount
		call EnemyList@CheckAvailability

	pop hl								;Recover demoOrbStruct.state
	ret

@NOTSAFE:
	pop hl
	ret

;----------------------------------------------------------------------------------
;Updates the shot 
;Parameters: DE = shot.state
;Affects: A, HL, DE, C
UpdateOrbShot:
;Check if reached other side of the screen
	ex de, hl
	ld de, orbShotStruct.xPos - orbShotStruct.state
	add hl, de
	ld a, (hl)
	cp RightBounds + $10
	jp nc, DespawnOrbShot
;Update position and hitbox
	call OrbShotMove
;Check for collisions
	ld de, orbShotStruct.hitBox.width - orbShotStruct.xPos
    add hl, de
	call EnemyList@TonbowCollisionCheck
;Update Shot's sprite
    ld de, orbShotStruct.sprNum - orbShotStruct.hitBox.width
    add hl, de
    call MultiUpdateSATBuff

	ret


;------------------------------------------------------------------------------------
;Move the Orb Shot across the screen
;Parameters: HL = orbShot.xPos
;Affects: HL, A, C
OrbShotMove:
;Update Position
    ld a, ORB_SHOT_SPEED
    add a, (hl)
    ld (hl), a
;Update hitbox
	ld de, orbShotStruct.hitBox.x1 - orbShotStruct.xPos
	add hl, de
	ld (hl), a							
	add a, ORB_SHOT_WIDTH
	inc hl								;ld hl, orbShot.hitBox.y1
	inc hl								;ld hl, orbShot.hitBox.x2
	ld (hl), a
	ld de, orbShotStruct.xPos - orbShotStruct.hitBox.x2
	add hl, de

    ret



DespawnOrbShot:
	xor a
	ld de, orbShotStruct.state - orbShotStruct.xPos
	add hl, de
	ld (hl), a								;Set State to dead
	ld de, orbShotStruct.hitBox.width - orbShotStruct.state
	ld (hl), a								;Set hitBox width to zero


	ret


;Initialize all Orb Shots
;Parameters: 
;Affects: HL, DE, A, C
InitOrbShots:
;----------------
; Orb Shot
;----------------  
    ld hl, orbShot0.hitBox.y1
	dec hl
	ld b, DEMO_ORB_MAX					;Our counter for orb shots
-:
	inc hl								;ld hl, orbShot0.hitBox.y1
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
;State
    ld (hl), 0							
	ld de, UpdateOrbShot
    inc hl								;ld hl, updateAIPointer LO
    ld (hl), e							
    inc hl								;ld hl, updateAIPointer HI
    ld (hl), d							
    inc hl								;ld hl, sprNum

    inc hl                              ;ld hl, spriteSize
    ld (hl), $08                        ;8x8
    inc hl                              ;ld hl, orbShot.width
    ;Sprite is 2x2 for 8x8
    ld (hl), $01                        
    inc hl                              ;ld hl, orbShot.height
    ld (hl), $01                        
    inc hl                              ;ld hl, orbShot.yPos
    ld (hl), $00
    inc hl                              ;ld hl, orbShot.xPos
    ld (hl), $00
    inc hl                              ;ld hl, orbShot.cc
    ld (hl), ORBSHOTINDEX
;Orb Shot specifics
    ld de, orbShotStruct.yFracPos - orbShotStruct.cc    ;ld hl, orbShot.yFracPos LO
    add hl, de
    ld (hl), $00
    inc hl                              ;ld hl, orbShot.yFracPos HI
    ld (hl), $00
    inc hl                              ;ld hl, orbShot.xFracPos LO
    ld (hl), $00
    inc hl                              ;ld hl, orbShot.xFracPos HI
    ld (hl), $00
    inc hl                              ;ld hl, orbShot.yVel
    ld (hl), 0
    inc hl                              ;ld hl, orbShot.xVel
    ld (hl), 0
    inc hl                              ;ld hl, orbShot.animationTimer
    ld (hl), 0
    inc hl                              ;ld hl, orbShot.spawnTimer
    ld (hl), 0
	djnz -

	ret
