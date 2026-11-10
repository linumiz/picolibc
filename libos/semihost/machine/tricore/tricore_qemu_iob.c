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

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

/* QEMU paravirt device (hw/tricore/tricore_virt.c) on the TC397 and TC4D7
 * models: a store to PUTC prints one byte, a store to EXIT exits QEMU
 * with that status */
#define TRICORE_QEMU_PUTC (*(volatile uint32_t *)0xbf000020)
#define TRICORE_QEMU_EXIT (*(volatile uint32_t *)0xbf000028)

static int
tricore_qemu_putc(char c, FILE *file)
{
    (void)file;
    TRICORE_QEMU_PUTC = (unsigned char)c;
    return (unsigned char)c;
}

static FILE __stdio = FDEV_SETUP_STREAM(tricore_qemu_putc, NULL, NULL, _FDEV_SETUP_WRITE);

#ifdef __strong_reference
#define STDIO_ALIAS(x) __strong_reference(stdin, x);
#else
#define STDIO_ALIAS(x) FILE * const x = &__stdio;
#endif

FILE * const stdin = &__stdio;
STDIO_ALIAS(stdout);
STDIO_ALIAS(stderr);

void
_exit(int status)
{
    for (;;)
        TRICORE_QEMU_EXIT = (uint32_t)status;
}
