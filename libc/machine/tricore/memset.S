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
 * Same shape as memcpy: one byte to reach an even address, 16 bytes per
 * loop pass, then 8/4/2/1 by the bits of n; peripheral space takes bytes.
 */
	.section .text.memset
	.global	memset
	.type	memset, @function
	.align	1
memset:
	mov.aa	%a2, %a4
	jlt.u	%d5, 4, .Lsmall
	mov.d	%d2, %a4
	sh	%d3, %d2, -29
	jeq	%d3, 7, .Lbytes
	and	%d4, %d4, 0xff
	sh	%d0, %d4, 8
	or	%d4, %d4, %d0
	sh	%d0, %d4, 16
	or	%d4, %d4, %d0
	jz.t	%d2, 0, .Leven
	st.b	[%a4+]1, %d4
	add	%d5, -1
.Leven:
	mov	%d0, %d4
	mov	%d1, %d4
	sh	%d3, %d5, -4
	jeq	%d3, 0, .Ltail
	add	%d3, -1
	mov.a	%a3, %d3
	/* An 8-byte aligned loop runs at the same speed wherever the code lands */
	.align	3
.Lloop16:
	st.d	[%a4+]8, %e0
	st.d	[%a4+]8, %e0
	loop	%a3, .Lloop16
.Ltail:
	jz.t	%d5, 3, 1f
	st.d	[%a4+]8, %e0
1:	jz.t	%d5, 2, 2f
	st.w	[%a4+]4, %d4
2:	jz.t	%d5, 1, 3f
	st.h	[%a4+]2, %d4
3:	jz.t	%d5, 0, .Lret
	st.b	[%a4]0, %d4
.Lret:
	ret
.Lsmall:
	/* Below 4 bytes the setup costs more than it saves */
	jz.t	%d5, 0, 4f
	st.b	[%a4+]1, %d4
4:	jz.t	%d5, 1, .Lret
	st.b	[%a4]0, %d4
	st.b	[%a4]1, %d4
	ret
.Lbytes:
	add	%d5, -1
	mov.a	%a3, %d5
5:	st.b	[%a4+]1, %d4
	loop	%a3, 5b
	ret
	.size	memset, .-memset
