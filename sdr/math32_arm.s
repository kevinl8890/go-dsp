
TEXT ·FastAtan2(SB),7,$0
	MOVF	y+0(FP), F6
	MOVF	x+4(FP), F4

	ABSF	F6, F2

	MOVF	$1e-10, F0
	ADDF	F0, F2

	MOVF	$0.0, F5
	CMPF	F5, F4
	BGE	L1

	ADDF	F2, F4, F1	// x + abs(y)
	SUBF	F4, F2, F4	// abs(y) - x
	MOVF	$2.356194496154785, F3	// pi * 3/4
	B	L2
L1:
	SUBF	F2, F4, F1	// x - abs(y)
	ADDF	F2, F4, F4	// abs(y) + x
	MOVF	$0.7853981852531433, F3	// pi * 1/4
L2:
	DIVF	F4, F1, F2

	MOVF	$0.1963, F1
	MULF	F2, F1
	MULF	F2, F1
	MOVF	$0.9817, F0
	SUBF	F0, F1
	MULF	F2, F1
	ADDF	F3, F1

	MOVF	$-1.0, F0
	CMPF	F5, F6
	MULF.LT	F0, F1
	MOVF	F1, ret+8(FP)
	RET


TEXT ·Scalef32(SB),7,$0
	B ·scalef32(SB)
