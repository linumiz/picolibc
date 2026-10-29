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

/*
 * jmp_buf layout, 15 words: caller's PCXI, A10 (SP), return address,
 * then D8-D11, A12-A15, D12-D15 in upper-context CSA order.
 */

	.section .text.setjmp
	.global	setjmp
	.type	setjmp, @function
	.align	1
setjmp:
	/*
	 * After CALL only A10 and A11 are defined; the caller's other upper
	 * registers are in the CSA that PCXI links to, readable after DSYNC
	 */
	dsync
	mfcr	%d0, 0xfe00
	extr.u	%d1, %d0, 16, 4
	sh	%d1, %d1, 28
	insert	%d1, %d1, %d0, 6, 16
	mov.a	%a2, %d1
	ld.w	%d0, [%a2]0
	st.w	[%a4]0, %d0
	st.a	[%a4]4, %a10
	st.a	[%a4]8, %a11
	ld.d	%e0, [%a2]16
	st.d	[%a4]12, %e0
	ld.d	%e0, [%a2]24
	st.d	[%a4]20, %e0
	ld.d	%e0, [%a2]32
	st.d	[%a4]28, %e0
	ld.d	%e0, [%a2]40
	st.d	[%a4]36, %e0
	ld.d	%e0, [%a2]48
	st.d	[%a4]44, %e0
	ld.d	%e0, [%a2]56
	st.d	[%a4]52, %e0
	mov	%d2, 0
	ret
	.size	setjmp, .-setjmp
