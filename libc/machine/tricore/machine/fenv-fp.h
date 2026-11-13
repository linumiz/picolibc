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

/* The environment is the rounding mode, PSW.RM (PSW[25:24]) */

__declare_fenv_inline(int) feclearexcept(int excepts)
{
    (void)excepts;
    return 0;
}

__declare_fenv_inline(int) fegetexceptflag(fexcept_t *flagp, int excepts)
{
    (void)excepts;
    *flagp = 0;
    return 0;
}

__declare_fenv_inline(int) fesetexceptflag(const fexcept_t *flagp, int excepts)
{
    (void)flagp;
    (void)excepts;
    return 0;
}

__declare_fenv_inline(int) feraiseexcept(int excepts)
{
    return excepts != 0;
}

__declare_fenv_inline(int) fesetexcept(int excepts)
{
    return excepts != 0;
}

__declare_fenv_inline(int) fetestexcept(int excepts)
{
    (void)excepts;
    return 0;
}

__declare_fenv_inline(int) fegetround(void)
{
    unsigned int psw;

    __asm__ volatile("mfcr %0, 0xfe04" : "=d"(psw));
    return psw & FE_TOWARDZERO;
}

__declare_fenv_inline(int) fesetround(int rounding_mode)
{
    if (rounding_mode & ~FE_TOWARDZERO)
        return 1;
    /* UPDFL: mask in bits 15:8, value in 7:0, over PSW[31:24] */
    __asm__ volatile("updfl %0" : : "d"(0x300 | (rounding_mode >> 24)) : "memory");
    return 0;
}

__declare_fenv_inline(int) fegetenv(fenv_t *envp)
{
    *envp = fegetround();
    return 0;
}

__declare_fenv_inline(int) feholdexcept(fenv_t *envp)
{
    *envp = fegetround();
    return 0;
}

__declare_fenv_inline(int) fesetenv(const fenv_t *envp)
{
    return fesetround(*envp);
}

__declare_fenv_inline(int) feupdateenv(const fenv_t *envp)
{
    return fesetround(*envp);
}

#if __BSD_VISIBLE
__declare_fenv_inline(int) feenableexcept(int __mask)
{
    (void)__mask;
    return 0;
}

__declare_fenv_inline(int) fedisableexcept(int __mask)
{
    (void)__mask;
    return 0;
}

__declare_fenv_inline(int) fegetexcept(void)
{
    return 0;
}
#endif
