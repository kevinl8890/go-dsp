
TEXT ·FastAtan2(SB),7,$0
	JMP ·fastAtan2(SB)

// 	MOVSS	y+0(FP), X1
// 	MOVSS	x+4(FP), X4

// 	MOVQ	$(1<<31), BX
// 	MOVQ	BX, X3
// 	MOVSS	X3, X5

// 	// abs(y) + 1.0e-10
// 	ANDNPS	X1, X3
// 	ADDSS	$1.0e-10, X3

// 	MOVSS	X4, X2

// 	MOVSS	$0.0, X0
// 	UCOMISS	X0, X4
// 	JHI	L4

// 	ADDSS	X3, X2	// abs(y) + x
// 	MOVSS	X3, X0
// 	SUBSS	X4, X0	// abs(y) - x
// 	DIVSS	X0, X2
// 	MOVSS	$2.356194496154785, X3
// 	JMP	L5
// L4:
// 	SUBSS	X3, X2	// x - abs(y)
// 	ADDSS	X3, X4	// x + abs(y)
// 	DIVSS	X4, X2
// 	MOVSS	$0.7853981852531433, X3
// L5:

// 	MOVSS	$0.1963, X0
// 	MULSS	X2, X0
// 	MULSS	X2, X0
// 	SUBSS	$0.9817, X0
// 	MULSS	X2, X0
// 	ADDSS	X3, X0

// 	// if x < 0: -angle
// 	ANDPS	X1, X5
// 	XORPS	X5, X0

// 	MOVSS	X0, ret+8(FP)
// 	RET

TEXT ·Scalef32(SB),7,$0
	MOVQ	input+0(FP), SI
	MOVQ	input_len+8(FP), AX
	MOVQ	output+24(FP), DI
	MOVQ	output_len+32(FP), CX
	MOVQ	scale+48(FP), X8
	PSHUFD	$0, X8, X8

	CMPQ	AX, CX
	JGE	scalef32_min_len
	MOVQ	AX, CX
scalef32_min_len:

	MOVQ	CX, DX
	ANDQ	$(~31), CX

	MOVQ	$0, AX
	CMPQ	AX, CX
	JGE	scalef32_stepper

scalef32_loop:
	MOVUPS	(SI), X0
	MOVUPS	16(SI), X1
	MOVUPS	32(SI), X2
	MOVUPS	48(SI), X3
	LEAQ	(DI)(AX*4), BX
	MULPS	X8, X0
	MULPS	X8, X1
	MULPS	X8, X2
	MULPS	X8, X3
	MOVUPS	X0, (BX)
	MOVUPS	X1, 16(BX)
	MOVUPS	X2, 32(BX)
	MOVUPS	X3, 48(BX)
	ADDQ	$64, SI
	ADDQ	$16, AX
	CMPQ	AX, CX
	JLT	scalef32_loop

scalef32_stepper:
	CMPQ	AX, DX
	JGE	scalef32_done

scalef32_step:
	MOVSS	(SI), X0
	LEAQ	(DI)(AX*4), BX
	MULSS	X8, X0
	MOVSS	X0, (BX)
	ADDQ	$4, SI
	INCQ	AX
	CMPQ	AX, DX
	JLT	scalef32_step

scalef32_done:
	RET
