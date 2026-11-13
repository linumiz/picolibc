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
 * Outside peripheral space (segments E-F) ld.d/st.d work at any even
 * address (TC1.6.2 vol1 Tables 1-3); peripheral space and pointers of
 * different parity take the byte path.
 */
	.section .text.memcpy
	.global	memcpy
	.type	memcpy, @function
	.align	1
memcpy:
	mov.aa	%a2, %a4
	jlt.u	%d4, 4, .Lsmall
	mov.d	%d0, %a4
	mov.d	%d1, %a5
	max.u	%d2, %d0, %d1
	sh	%d2, %d2, -29
	jeq	%d2, 7, .Lbytes
	xor	%d2, %d0, %d1
	jnz.t	%d2, 0, .Lbytes
	jz.t	%d0, 0, .Leven
	ld.bu	%d2, [%a5+]1
	st.b	[%a4+]1, %d2
	add	%d4, -1
.Leven:
	sh	%d3, %d4, -4
	jeq	%d3, 0, .Ltail
	add	%d3, -1
	mov.a	%a3, %d3
	/* An 8-byte aligned loop runs at the same speed wherever the code lands */
	.align	3
.Lloop16:
	ld.d	%e0, [%a5+]8
	ld.d	%e2, [%a5+]8
	st.d	[%a4+]8, %e0
	st.d	[%a4+]8, %e2
	loop	%a3, .Lloop16
.Ltail:
	jz.t	%d4, 3, 1f
	ld.d	%e0, [%a5+]8
	st.d	[%a4+]8, %e0
1:	jz.t	%d4, 2, 2f
	ld.w	%d0, [%a5+]4
	st.w	[%a4+]4, %d0
2:	jz.t	%d4, 1, 3f
	ld.hu	%d0, [%a5+]2
	st.h	[%a4+]2, %d0
3:	jz.t	%d4, 0, .Lret
	ld.bu	%d0, [%a5]0
	st.b	[%a4]0, %d0
.Lret:
	ret
.Lsmall:
	/* Below 4 bytes the setup costs more than it saves */
	jz.t	%d4, 0, 4f
	ld.bu	%d0, [%a5+]1
	st.b	[%a4+]1, %d0
4:	jz.t	%d4, 1, .Lret
	ld.bu	%d0, [%a5]0
	st.b	[%a4]0, %d0
	ld.bu	%d0, [%a5]1
	st.b	[%a4]1, %d0
	ret
.Lbytes:
	add	%d4, -1
	mov.a	%a3, %d4
5:	ld.bu	%d0, [%a5+]1
	st.b	[%a4+]1, %d0
	loop	%a3, 5b
	ret
	.size	memcpy, .-memcpy
