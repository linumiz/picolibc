/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright © 2026 Linumiz
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials provided
 *    with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

	.section .text.longjmp
	.global	longjmp
	.type	longjmp, @function
	.align	1
longjmp:
	/*
	 * Free CSAs until PCXI is the one setjmp saved. In user mode only RET
	 * (upper) and RSLCX (lower) can do that; MTCR is supervisor-only
	 */
	ld.w	%d5, [%a4]0
	mov.aa	%a12, %a4
	mov	%d8, %d4
	mov	%d9, %d5
	/* longjmp is noreturn, so GCC may enter it by J: test before freeing */
	j	.Lcheck
.Lfree:
	jz.t	%d0, 20, .Llower
	/*
	 * RET jumps to A11. Each free reloads one register bank, so env, val
	 * and the target PCXI are kept in both and refreshed from the other
	 */
	movh.a	%a11, hi:.Lfreed_upper
	lea	%a11, [%a11]lo:.Lfreed_upper
	ret
.Lfreed_upper:
	mov.aa	%a12, %a4
	mov	%d8, %d4
	mov	%d9, %d5
	j	.Lcheck
.Llower:
	rslcx
	mov.aa	%a4, %a12
	mov	%d4, %d8
	mov	%d5, %d9
.Lcheck:
	mfcr	%d0, 0xfe00
	jne	%d0, %d5, .Lfree

	ld.a	%a10, [%a4]4
	ld.a	%a2, [%a4]8
	ld.d	%e8, [%a4]12
	ld.d	%e10, [%a4]20
	ld.da	%a12, [%a4]28
	ld.da	%a14, [%a4]36
	ld.d	%e12, [%a4]44
	ld.d	%e14, [%a4]52
	/* val, or 1 if val is 0 */
	eq	%d2, %d4, 0
	or	%d2, %d4
	ji	%a2
	.size	longjmp, .-longjmp
