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

#ifndef _MACHINE_FENV_H_
#define _MACHINE_FENV_H_

#include <sys/cdefs.h>

_BEGIN_STD_C

/* TC1.6.2 has a single-precision FPU; double is libgcc soft-float */
#ifdef __TC162__
#define __DOUBLE_NOROUND
#define __LONG_DOUBLE_NOROUND
#endif

/*
 * The FPU exception flags share PSW bits with the ALU flags, and RET
 * restores them from the caller's context, so only rounding is offered.
 * Rounding modes are PSW.RM in place, PSW[25:24].
 */
#define FE_TONEAREST  0x00000000
#define FE_UPWARD     0x01000000
#define FE_DOWNWARD   0x02000000
#define FE_TOWARDZERO 0x03000000

typedef int fenv_t;
typedef int fexcept_t;

_END_STD_C

#if !defined(__declare_fenv_inline) && defined(__declare_extern_inline)
#define __declare_fenv_inline(type) __declare_extern_inline(type)
#endif

#ifdef __declare_fenv_inline
#include <machine/fenv-fp.h>
#endif

#endif /* _MACHINE_FENV_H_ */
