;==============================================================
; Constants
;==============================================================
.define CURSOR_VRAM             $FA

;==============================================================
; Variables
;==============================================================
;Declared in main.asm so it is ocnsistent throughout the game and doesn't 
;override other sprites

;pauseCursor instanceof cursorStruct         


SetUpPause:
;Dim the screen
    call FadeToBlack

;Turn off HBlank
    ld a, $FF
    out (PORT_VDP_ADDRESS), a
	ld a, $8A
	out (PORT_VDP_ADDRESS), a		;Set VDP 10,Raster Line Interrupt, to 12

;==============================================================
; Turn Off screen
;==============================================================
 ;(Maxim's explanation is too good not to use)
    ld a, %00100000
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Doubled sprites -> 8x16
;           ||||`--- Mega Drive mode 5 enable
;           |||`---- 30 row/240 line mode
;           ||`----- 28 row/224 line mode
;           |`------ VBlank interrupts
;            `------- Enable display    
    ld c, $81
    call UpdateVDPRegister

;==============================================================
; BG Tiles and Map setup
;==============================================================
;Check TATE or YOKO
    ld a, (tateMode)
    bit 0, a
    jr z, +
    call PauseScreenTateSetup
    jr ++
+:
    call PauseScreenYokoSetup

++:
;==============================================================
; Initialize Cursor
;==============================================================
    ld hl, pauseCursor.sprNum
    inc hl                              ;ld hl, spriteSize
    ld (hl), $08                        ;8x8
    inc hl                              ;ld hl, pauseCursor.width
    ;Sprite is 1x1 for 8x8
    ld (hl), $01                        
    inc hl                              ;ld hl, pauseCursor.height
    ld (hl), $01                        

    ld a, (tateMode)
    bit 0, a
    jr nz, +
;YOKO
    inc hl                              ;ld hl, pauseCursor.yPos
    ld (hl), 54
    inc hl                              ;ld hl, pauseCursor.xPos
    ld (hl), 80
    jr ++
+:
;TATE
    inc hl                              ;ld hl, pauseCursor.yPos
    ld (hl), 46
    inc hl                              ;ld hl, pauseCursor.xPos
    ld (hl), 176

++:
    inc hl                              ;ld hl, pauseCursor.cc
    ld (hl), CURSOR_VRAM
    ld a, (tateMode)                    ;If TATE, then TATE = 1, else 0
    add (hl)
    ld (hl), a                          ;If TATE, then use TATE sprite, else use yoko

    ld hl, pauseCursor.state
    ld (hl), 0                          ;Start off at top of menu
    inc hl                              ;Reset pause cool down timer
    ld (hl), 0

;Previsualization for fade in
    call UpdateSAT                      ;Get rid of any unwanted sprites
    ld hl, pauseCursor.sprNum              
    call MultiUpdateSATBuff         
    call UpdateSAT  

;==============================================================
; Turn on screen
;==============================================================
 ;(Maxim's explanation is too good not to use)
    ld a, %01100000
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Doubled sprites -> 8x16
;           ||||`--- Mega Drive mode 5 enable
;           |||`---- 30 row/240 line mode
;           ||`----- 28 row/224 line mode
;           |`------ VBlank interrupts
;            `------- Enable display    
    ld c, $81
    call UpdateVDPRegister             

;Set X-Scroll to 0
    ld a, $00
    out (PORT_VDP_ADDRESS), a
	ld a, $88
	out (PORT_VDP_ADDRESS), a		;Set X-Scroll to 0

    call FadeIn

;==============================================================
; Main Loop
;==============================================================
;Check if we are trying to Unpause
Paused:
    halt
;Check if we need to unpause
    ld a, (sceneID)
;If Scene ID is invalid, do nothing
    cp NO_SCENE_ID
    jp nc, EndPauseHandling
;Else...
;3 * N + PauseJumpTable
    ld c, a
    add c
    add c                           ;3 * N 
    ld h, 0
    ld l, a
    ld de, UnpauseJumpTable
    add hl, de                      ;3 * N + DPadJumpTable
    jp hl                           ;Jump to specific input subroutine


;If not, then handle correct pause screen inputs
;==============================================================
; Handle any actions we can perform on the pause screen
;==============================================================
PauseLoop:
;Update Sprites
    call UpdateSAT 

;Menu Controls
    ld hl, pauseCursor.coolDownTimer
    ld a, (hl)
    cp $00
    jr z, +
    dec (hl)
+:
    call PauseScreenJoypad1Check
    ld a, (sceneID)
    cp $02
    ret z               ;Return To Title

;Update Sprite Buffer
    call UpdatePauseSpriteBuffer

    jp Paused    

;Used so we can move the arrow to EXIT when we hit the PAUSE button instead of exit
UpdatePauseSpriteBuffer:
    ld hl, pauseCursor.sprNum              
    call MultiUpdateSATBuff  

    ret


;========================================================
; Unpause Jump Table
;========================================================
UnpauseJumpTable:
;Where to jump when PAUSE button hit
    jp EndPauseHandling                                         ;$00 = SFS Splash Screen
;Do correct action based on Scene ID                            ;$XX = Scene ID
    jp PauseLoop                                                ;$01 = Pause Screen
    jp EndPauseHandling                                         ;$02 = Title Screen
    jp ReturnToDemoLevel                                        ;$03 = Demo Level 


;========================================================
; DemoLevel Pause Handler
;========================================================
;Handles the pause when on the Demo Level
DemoPause:
    ld hl, sceneID
    ld a, (hl)
    ld de, pauseSceneID
    ld (de), a
    ld (hl), PAUSE_SCREEN

    jp EndPauseHandling                         ;retn


;-------------------------------------------------------------------------------


;========================================================
; Background Tiles
;========================================================
;------------------
; Yoko
;------------------
DemoPauseYokoTiles:
    .include "..\\assets\\tiles\\backgrounds\\pauseYoko.inc"
DemoPauseYokoTilesEnd:

PauseFontYokoTiles:
    .include "..\\assets\\tiles\\backgrounds\\pauseFontYoko.inc"
PauseFontYokoTilesEnd:

;------------------
; TATE
;------------------
DemoPauseTateTiles:
    .include "..\\assets\\tiles\\backgrounds\\pauseTate.inc"
DemoPauseTateTilesEnd:

PauseFontTateTiles:
    .include "..\\assets\\tiles\\backgrounds\\pauseFontTate.inc"
PauseFontTateTilesEnd:

;========================================================
; Tile Maps
;========================================================
;------------------
; Yoko
;------------------
DemoPauseYokoMap:
    .include "..\\assets\\maps\\pauseYoko.inc"
DemoPauseYokoMapEnd:


;------------------
; TATE
;------------------
DemoPauseTateMap:
    .include "..\\assets\\maps\\pauseTate.inc"
DemoPauseTateMapEnd:

;========================================================
; Sprite Tiles
;========================================================
;----------------
; Cursor
;----------------
CursorYoko:
    .include "..\\assets\\tiles\\sprites\\cursor\\yoko.inc"
CursorYokoEnd:

CursorTate:
    .include "..\\assets\\tiles\\sprites\\cursor\\tate.inc"
CursorTateEnd:
