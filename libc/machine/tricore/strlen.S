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
 * Byte steps to a word boundary, so a word load never crosses into the
 * next memory region, then 4 bytes per ld.w with EQANY.B (any byte zero).
 */
	.section .text.strlen
	.global	strlen
	.type	strlen, @function
	.align	1
strlen:
	mov.aa	%a2, %a4
	mov.d	%d1, %a4
	jz.t	%d1, 0, 1f
	ld.bu	%d0, [%a2+]1
	jeq	%d0, 0, .Lend
1:	mov.d	%d1, %a2
	jz.t	%d1, 1, .Lwords
	ld.bu	%d0, [%a2+]1
	jeq	%d0, 0, .Lend
	ld.bu	%d0, [%a2+]1
	jeq	%d0, 0, .Lend
	/* An 8-byte aligned loop runs at the same speed wherever the code lands */
	.align	3
.Lwords:
	ld.w	%d0, [%a2+]4
	eqany.b	%d1, %d0, 0
	jeq	%d1, 0, .Lwords
	lea	%a2, [%a2]-4
.Lbytes:
	ld.bu	%d0, [%a2+]1
	jne	%d0, 0, .Lbytes
.Lend:
	mov.d	%d2, %a2
	mov.d	%d3, %a4
	sub	%d2, %d2, %d3
	add	%d2, -1
	ret
	.size	strlen, .-strlen
