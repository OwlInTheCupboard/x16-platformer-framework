
.macro math_add_16bit addr, value
  clc
  lda #<value
  adc addr
  sta addr
  lda #>value
  adc addr+1
  sta addr+1
.endmacro

.macro math_floor_16bit addr, addr2
  lda addr
  sta addr2
  lda addr+1
  sta addr2+1
  ldy #4
  @loop:
    clc
    ror addr2+1
    ror addr2
    dey
    bne @loop
.endmacro
