;==============================================================
;All Structs that are sprites MUST have the following
;==============================================================
.struct spriteStruct
    sprNum          db      ;The draw-number of the sprite 
    spriteSize      db      ;$08 or $10 for 8x8 or 8x16
    width           db      ;The width of the OBJ     
    height          db      ;The height of the OBJ
    yPos            db      ;The Y coord of the OBJ's top left corner
    xPos            db      ;The X coord of the OBJ's top left corner
    cc              db      ;The first character code for the OBJ 
    flag            db      ;General purpose flag for a sprite
    ;xCenter         db      ;The X coord of the OBJ's center
    yCenter         db      ;The Y coord of the OBJ's center
.endst

;==============================================================
; Hit Box structure
;==============================================================
.struct hitBoxStruct
    y1                    db      ;Top left corner of Hitbox yPos
    x1                    db      ;Top left corner of Hitbox xPos
    y2                    db      ;Bottom right corner of Hitbox yPos
    x2                    db      ;Bottom right corner of Hitbox xPos
    width                 db      ;How far across Hitbox stretches in pixels, if 0, then invincible
    height                db      ;How far down the Hitbox stretches in pixels
.endst

;==============================================================
;Used when writing sprite data to the buffers
;==============================================================
.struct spriteBufferTemporaryVariablesStruct
    spriteSize      db      ;$08 or $10
    width           db      ;Stores the width
    volatileHeight  db      ;Height value that changes
    height          db      ;Stores the height
    yPos            db      ;The Y coord of the OBJ (volatile)
    xPos            db      ;The X coord of the OBJ (volatile)
    volatileXPos    db      ;xPos, but it changes
    cc              db      ;The first character code for the OBJ (volatile)
.endst


;==============================================================
; Palette structure
;==============================================================
.struct paletteStruct
    color0      db
    color1      db
    color2      db
    color3      db
    color4      db
    color5      db
    color6      db
    color7      db
    color8      db
    color9      db
    colorA      db
    colorB      db
    colorC      db
    colorD      db
    colorE      db
    colorF      db
.endst

;==============================================================
; Parallax Scrolling structure
;==============================================================
.struct parallaxScrollStruct
    xPos                    db  ;Actual Value sent to VDP Register 
    xFracPos                dw  ;Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI
.endst

;==============================================================
; Enemy Structure
;==============================================================
.struct enemyStruct
    hitBox instanceof hitBoxStruct
/*
    y1                    db      ;Top left corner of Hitbox yPos
    x1                    db      ;Top left corner of Hitbox xPos
    y2                    db      ;Bottom right corner of Hitbox yPos
    x2                    db      ;Bottom right corner of Hitbox xPos
    width                 db      ;How far across Hitbox stretches in pixels, if 0, then invincible
    height                db      ;How far down the Hitbox stretches in pixels
*/
    state                       db          ;Is it alive? Dead? Dying? Spawning? etc
                                            ;$01 = Alive, $FF = Dying, $00 = Dead
    updateAIPointer             dw          ;Points to the subroutine to update the AI
    instanceof spriteStruct
/*
    sprNum          db      ;The draw-number of the sprite 
    spriteSize      db      ;$08 or $10 for 8x8 or 8x16
    width           db      ;The width of the OBJ     
    height          db      ;The height of the OBJ
    yPos            db      ;The Y coord of the OBJ's top left corner
    xPos            db      ;The X coord of the OBJ's top left corner
    cc              db      ;The first character code for the OBJ 
    xCenter         db      ;The X coord of the OBJ's center
    yCenter         db      ;The Y coord of the OBJ's center
*/
    yFracPos                    dw          ;Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI
    xFracPos                    dw          ;
    yVel                        db          ;Velocity %SYYYFFFF 
    xVel                        db          ;Velocity %SXXXFFFF 
    animationTimer              db
    spawnTimer                  db

;Any special enemy traits can go down here
    
.endst

;==============================================================
; Enemy List structure
;==============================================================
.struct enemyListStruct
    enemyCount            db      ;How many enemies are on screen
    enemyCountMax         db      ;How many enemies/projectiles does the current level allow?
    enemy0                dw      ;Pointer to enemy.updateAIPointer
    enemy1                dw      ;Pointer to enemy.updateAIPointer
    enemy2                dw      ;Pointer to enemy.updateAIPointer
    enemy3                dw      ;Pointer to enemy.updateAIPointer
    enemy4                dw      ;Pointer to enemy.updateAIPointer
    enemy5                dw      ;Pointer to enemy.updateAIPointer
    enemy6                dw      ;Pointer to enemy.updateAIPointer
    enemy7                dw      ;Pointer to enemy.updateAIPointer
    enemy8                dw      ;Pointer to enemy.updateAIPointer
    enemy9                dw      ;Pointer to enemy.updateAIPointer
    enemyA                dw      ;Pointer to enemy.updateAIPointer
    enemyB                dw      ;Pointer to enemy.updateAIPointer
    enemyC                dw      ;Pointer to enemy.updateAIPointer
    enemyD                dw      ;Pointer to enemy.updateAIPointer
    enemyE                dw      ;Pointer to enemy.updateAIPointer
    enemyF                dw      ;Pointer to enemy.updateAIPointer
    enemy10               dw      ;Pointer to enemy.updateAIPointer
    enemy11               dw      ;Pointer to enemy.updateAIPointer
    enemy12               dw      ;Pointer to enemy.updateAIPointer
    enemy13               dw      ;Pointer to enemy.updateAIPointer
    enemy14               dw      ;Pointer to enemy.updateAIPointer
    enemy15               dw      ;Pointer to enemy.updateAIPointer
    enemy16               dw      ;Pointer to enemy.updateAIPointer
    enemy17               dw      ;Pointer to enemy.updateAIPointer
    enemy18               dw      ;Pointer to enemy.updateAIPointer
    enemy19               dw      ;Pointer to enemy.updateAIPointer
    enemy1A               dw      ;Pointer to enemy.updateAIPointer
    enemy1B               dw      ;Pointer to enemy.updateAIPointer
    enemy1C               dw      ;Pointer to enemy.updateAIPointer
    enemy1D               dw      ;Pointer to enemy.updateAIPointer
    enemy1E               dw      ;Pointer to enemy.updateAIPointer
    enemy1F               dw      ;Pointer to enemy.updateAIPointer
    ;removedFlag           db      ;Flag for if enemy is removed from list
.endst


;==============================================================
; Tonbow Structure
;==============================================================
.struct tonbowStruct
;Life-related attributes
    hitBox instanceof hitBoxStruct
    hurtBox instanceof hitBoxStruct
    alive                       db      ;Is tonbow alive?
;Sprite Attributes
    instanceof spriteStruct
    /*
    sprNum                  db      ;The draw-number of the sprite 
    spriteSize              db      ;$08 or $10 for 8x8 or 8x16
    width                   db      ;The width of the OBJ     
    height                  db      ;The height of the OBJ
    yPos                    db      ;The Y coord of the OBJ's top left corner
    xPos                    db      ;The X coord of the OBJ's top left corner
    cc                      db      ;The first character code for the OBJ 
    xCenter                 db      ;The X coord of the OBJ's center
    yCenter                 db      ;The Y coord of the OBJ's center
    */
;Tonbow Specifics
    yFracPos                    dw          ;Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI
    xFracPos                    dw          ;
    yVel                        db          ;Velocity %SYYYFFFF 
    xVel                        db          ;Velocity %SXXXFFFF 
    yVelMax                     db          ;MAX velocity
    xVelMax                     db          ;
    rotationState               db          ;0-7
    prevRotationState           db          ;Check if state has changed
    strafeMode                  db          ;On or off for strafing
    flapTimer                   db          ;Timer for wing flapping
    dashCoolDownTimer           db          ;So we don't spam inputs
    dashState                   db          ;Are we dashing? $01 = YES, $00 = NO
    dashWarmUpTimer             db
    
.endst


;==============================================================
; DemoOrb Structure
;==============================================================
.struct demoOrbStruct
    instanceof enemyStruct
    
.endst

;==============================================================
; Orb Shot Structure
;==============================================================
.struct orbShotStruct
    instanceof enemyStruct
.endst

;==============================================================
; Cursor Structure
;==============================================================
.struct cursorStruct
    instanceof spriteStruct
    state                   db      ;The location of the cursor
    coolDownTimer           db      ;So we don't spam inputs

.endst



