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
 * BTV is ENDINIT protected: whatever starts this code (boot code or
 * debugger) must leave the core in its init state.
 */

	.section .text.init.enter, "ax", @progbits
	.global	_start
	.type	_start, @function
	.align	1
_start:
	/* Start from the PSW reset value; earlier code may have changed it */
	mov	%d15, 0xb80
	mtcr	0xfe04, %d15
	mov	%d15, 0
	mtcr	0xfe00, %d15
	isync

	/*
	 * Link the CSAs from the last one down: each holds the link word
	 * (addr[31:28] in 19:16, addr[21:6] in 15:0) of the next, the last 0
	 */
	movh.a	%a15, hi:.Lcsa_end
	lea	%a15, [%a15]lo:.Lcsa_end
	movh.a	%a14, hi:.Lcsa
	lea	%a14, [%a14]lo:.Lcsa
	mov	%d15, 0
.Llink:
	st.w	[+%a15]-64, %d15
	mov.d	%d14, %a15
	extr.u	%d15, %d14, 6, 16
	sh	%d14, %d14, -28
	insert	%d15, %d15, %d14, 16, 4
	jne.a	%a15, %a14, .Llink
	mtcr	0xfe38, %d15
	/* FCD trap when 8 CSAs are left */
	addi	%d15, %d15, 56
	mtcr	0xfe3c, %d15
	isync

	mov	%d15, lo:.Ltrap
	addih	%d15, %d15, hi:.Ltrap
	mtcr	0xfe24, %d15
	isync

	movh.a	%a10, hi:__stack
	lea	%a10, [%a10]lo:__stack
	j	_cstart
	.size	_start, .-_start

	/* One 32-byte slot per trap class: a halted PC gives the class */
	.section .text.trap, "ax", @progbits
	.align	8
.Ltrap:
	.rept	8
	j	.
	.align	5
	.endr

	/* Not cleared by __start: the list is in use before .bss is zeroed */
	.section .preserve.csa, "aw", @nobits
	.align	6
.Lcsa:
	.space	64 * 64
.Lcsa_end:
