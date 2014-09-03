
TEXT ·Ui8toi16(SB),4,$0
	MOVW	input+0(FP), R1
	MOVW	input_len+4(FP), R2
	MOVW	output+12(FP), R3
	MOVW	output_len+16(FP), R4
	// Choose the shortest length
	CMP	R2, R4
	MOVW.LT	R4, R2
	// If no input then skip loop
	CMP	$0, R2
	BEQ	ui8toi16_done
	ADD	R1, R2
ui8toi16_loop:
	MOVBU	0(R1), R0
	ADD	$1, R1
	SUB	$128, R0
	MOVBU	R0, 0(R3)
	MOVBU	R0, 1(R3)
	ADD	$2, R3
	CMP	R2, R1
	BLT	ui8toi16_loop
ui8toi16_done:
	RET

TEXT ·Ui8toi16b(SB),4,$0
	MOVW	output_len+16(FP), R4
	MOVW	R4>>1, R4
	MOVW	R4, output_len+16(FP)
	B	·Ui8toi16(SB)



// TEXT ·Ui8tof32(SB),4,$0
// 	MOVW	input+0(FP), R1
// 	MOVW	input_len+4(FP), R2
// 	MOVW	output+12(FP), R3
// 	MOVW	output_len+16(FP), R0
// 	// Choose the shortest length
// 	CMP	R2, R0
// 	MOVW.LT	R0, R2
// 	// If no input then skip loop
// 	CMP	$0, R2
// 	BEQ	ui8tof32_done

// 	MOVW	$128, R0
// 	WORD	$0xeee00b10 // vdup.8 q0, r0

// 	AND	$(~15), R2, R4
// 	ADD	R1, R2
// 	ADD	R1, R4
// ui8tof32_loop:
// 	// WORD	$0xf461428f // vld1.32 {d20, d21, d22, d23}, [r1]
// 	WORD	$0xf461478d // vld1.32 {d20}, [r1]!
// 	WORD	$0xf3842280 // vsubl.u8 q1, d20, d0
// 	// WORD	$0xf3854280 // vsubl.u8 q2, d21, d0
// 	// WORD	$0xf3866280 // vsubl.u8 q3, d22, d0
// 	// WORD	$0xf3878280 // vsubl.u8 q4, d23, d0
// 	WORD	$0xf2904a12 // vmovl.s16 q2, d2
// 	WORD	$0xf2906a13 // vmovl.s16 q3, d3
// 	WORD	$0xf3bb4644 // vcvt.f32.s32 q2, q2
// 	WORD	$0xf3bb6646 // vcvt.f32.s32 q3, q3
// 	WORD	$0xf403428d // vst1.32 {d4, d5, d6, d7}, [r3]!
// 	CMP	R4, R1
// 	BLT	ui8tof32_loop

// 	CMP	R1, R2
// 	BEQ	ui8tof32_done

// ui8tof32_loop2:
// 	MOVBU	0(R1), R4
// 	ADD	$1, R1
// 	SUB	$128, R4
// 	MOVWF	R4, F0
// 	MOVF	F0, 0(R3)
// 	ADD	$4, R3
// 	CMP	R2, R1
// 	BLT	ui8tof32_loop2

// ui8tof32_done:
// 	RET


TEXT ·Ui8tof32(SB),4,$0
	MOVW	input+0(FP), R1
	MOVW	input_len+4(FP), R2
	MOVW	output+12(FP), R3
	MOVW	output_len+16(FP), R0
	// Choose the shortest length
	CMP	R2, R0
	MOVW.LT	R0, R2
	// If no input then skip loop
	CMP	$0, R2
	BEQ	ui8tof32_done

	AND	$(~3), R2, R0
	ADD	R1, R2
	ADD	R1, R0
ui8tof32_loop:
	MOVBU	0(R1), R4
	MOVBU	1(R1), R5
	MOVBU	2(R1), R6
	MOVBU	3(R1), R7
	ADD	$4, R1
	SUB	$128, R4
	SUB	$128, R5
	SUB	$128, R6
	SUB	$128, R7
	WORD	$0xee0f4b10 // vmov.32 d15[0], r4
	WORD	$0xeeb80acf // vcvt.f32.s32 s0, s30
	WORD	$0xee0f5b10 // vmov.32 d15[0], r5
	WORD	$0xeef80acf // vcvt.f32.s32 s1, s30
	WORD	$0xee0f6b10 // vmov.32 d15[0], r6
	WORD	$0xeeb81acf // vcvt.f32.s32 s2, s30
	WORD	$0xee0f7b10 // vmov.32 d15[0], r7
	WORD	$0xeef81acf // vcvt.f32.s32 s3, s30
	WORD	$0xeca30a04 // vstmia r3!, {s0, s1, s2, s3}
	CMP	R0, R1
	BLT	ui8tof32_loop

	CMP	R1, R2
	BEQ	ui8tof32_done

ui8tof32_tail_loop:
	MOVBU	0(R1), R4
	SUB	$128, R4
	MOVWF	R4, F0
	// MOVF	F0, (R3)
	// MOVM.IA.W	[F0], (R3)
	WORD	$0xeca30a01 // vstmia     r3!, {s0}
	ADD	$1, R1
	// ADD	$4, R3
	CMP	R2, R1
	BLT	ui8tof32_tail_loop
ui8tof32_done:
	RET



TEXT ·Ui8toc64(SB),4,$0
	MOVW	input_len+4(FP), R2
	AND	$(~1), R2
	MOVW	R2, input_len+4(FP)
	MOVW	output_len+16(FP), R0
	MOVW	R0<<1, R0
	MOVW	R0, output_len+16(FP)
	B	·Ui8tof32(SB)



TEXT ·F32toi16(SB),4,$0
	MOVW	input+0(FP), R1
	MOVW	input_len+4(FP), R2
	MOVW	output+12(FP), R3
	MOVW	output_len+16(FP), R0
	MOVF	scale+24(FP), F0
	// Choose the shortest length
	CMP	R2, R0
	MOVW.LT	R0, R2
	MOVW	R2<<2, R2
	// If no input then skip loop
	CMP	$0, R2
	BEQ	f32toi16_done

	AND	$(~1), R2, R7
	ADD	R1, R2
	ADD	R1, R7
f32toi16_loop:
	// MOVF	0(R1), F1
	// MOVF	4(R1), F2
	// ADD	$8, R1
	// MULF	F0, F1
	// MOVFW	F1, R0
	// MOVHU	R0, (R3)
	// MULF	F0, F2
	// MOVFW	F2, R0
	// MOVHU	R0, 2(R3)

	WORD	$0xecb11a02 // vldmia r1!, {s2, s3}
	WORD	$0xee211a00 // vmul.f32 s2, s2, s0
	WORD	$0xeebdfac1 // vcvt.s32.f32 s30, s2
	WORD	$0xee1f0b10 // vmov.32 r0, d15[0]
	WORD	$0xe1c300b0 // strh r0, [r3]
	WORD	$0xee611a80 // vmul.f32 s3, s3, s0
	WORD	$0xeebdfae1 // vcvt.s32.f32 s30, s3
	WORD	$0xee1f0b10 // vmov.32 r0, d15[0]
	WORD	$0xe1c300b2 // strh r0, [r3, #0x2]

	ADD	$4, R3

	CMP	R2, R1
	BLT	f32toi16_loop

	CMP	R1, R2
	BEQ	f32toi16_done

f32toi16_tail_loop:
	MOVF	0(R1), F1
	ADD	$4, R1
	MULF	F0, F1
	MOVFW	F1, R0
	MOVHU	R0, (R3)
	ADD	$2, R3
	CMP	R7, R1
	BLT	f32toi16_tail_loop

f32toi16_done:
	RET



// TODO: detect endianess and use faster single instruction only if native little-endian
TEXT ·F32toi16ble(SB),4,$0
	MOVW	input+0(FP), R1
	MOVW	input_len+4(FP), R2
	MOVW	output+12(FP), R3
	MOVW	output_len+16(FP), R0
	MOVF	scale+24(FP), F0
	// Choose the shortest length
	MOVW	R2<<1, R2
	CMP	R2, R0
	MOVW.LT	R0, R2
	MOVW	R2<<1, R2
	// If no input then skip loop
	CMP	$0, R2
	BEQ	f32toi16b_done
	ADD	R1, R2
f32toi16b_loop:
	MOVF	0(R1), F1
	ADD	$4, R1

	MULF	F0, F1
	MOVFW	F1, F1
	MOVW	F1, R0

	// Native endianess
	MOVHU	R0, (R3)

	// Little endian
	// MOVW	R0>>8, R4
	// MOVBU	R0, 0(R3)
	// MOVBU	R4, 1(R3)

	ADD	$2, R3

	CMP	R2, R1
	BLT	f32toi16b_loop
f32toi16b_done:
	RET
