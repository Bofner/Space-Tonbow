
PauseScreenYokoSetup:
;==============================================================
; Load BG tiles 
;==============================================================
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ld hl, DemoPauseYokoTiles
    ld bc, DemoPauseYokoTilesEnd-DemoPauseYokoTiles
    call CopyToVDP

    ld hl, TEXT_START | VRAMWrite
    call SetVDPAddress
    ld hl, PauseFontYokoTiles
    ld bc, PauseFontYokoTilesEnd-PauseFontYokoTiles
    call CopyToVDP

;==============================================================
; Write background map
;==============================================================

    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, DemoPauseYokoMap
    ld bc, DemoPauseYokoMapEnd-DemoPauseYokoMap
    call CopyToVDP

;==============================================================
; Load Sprite tiles 
;==============================================================

    ld hl, $3F40 | VRAMWrite                        ;In middle of SAT
    call SetVDPAddress
    ld hl, CursorYoko
    ld bc, CursorYokoEnd-CursorYoko
    call CopyToVDP

    ld hl, $3F60 | VRAMWrite                        ;In middle of SAT
    call SetVDPAddress
    ld hl, CursorTate
    ld bc, CursorTateEnd-CursorTate
    call CopyToVDP

    ret


PauseScreenTateSetup:
;==============================================================
; Load BG tiles 
;==============================================================
    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ld hl, DemoPauseTateTiles
    ld bc, DemoPauseTateTilesEnd-DemoPauseTateTiles
    call CopyToVDP

    ld hl, TEXT_START | VRAMWrite
    call SetVDPAddress
    ld hl, PauseFontTateTiles
    ld bc, PauseFontTateTilesEnd-PauseFontTateTiles
    call CopyToVDP

;==============================================================
; Write background map
;==============================================================

    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, DemoPauseTateMap
    ld bc, DemoPauseTateMapEnd-DemoPauseTateMap
    call CopyToVDP

;==============================================================
; Load Sprite tiles 
;==============================================================

    ld hl, $3F40 | VRAMWrite                        ;In middle of SAT
    call SetVDPAddress
    ld hl, CursorYoko
    ld bc, CursorYokoEnd-CursorYoko
    call CopyToVDP

    ld hl, $3F60 | VRAMWrite                        ;In middle of SAT
    call SetVDPAddress
    ld hl, CursorTate
    ld bc, CursorTateEnd-CursorTate
    call CopyToVDP

    ret