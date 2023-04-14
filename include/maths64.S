
//
// Copyright (c) 2014 Jason L. Wright (jason@thought.net)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

// basic assembly math routines for DARPA Cyber Grand Challenge

#ifdef APPLE
.macro .type
.endm

.macro .size
.endm

// OSX symbols need a leading underscore
# define SYM(x) _##x

#else
# define SYM(x) x
#endif // APPLE

.macro ENTER base
    .global \base, \base\()f, \base\()l
    .type \base, @function
    .type \base\()f, @function
    .type \base\()l, @function
.endm

.macro END base
    .size \base, . - \base
    .size \base\()f, . - \base\()f
    .size \base\()l, . - \base\()l
.endm

ENTER SYM(cgc_sin)
SYM(cgc_sinl):
    fldt    8(%rsp)
    call    internal_sin
    ret

SYM(cgc_sinf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_sin
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_sin):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_sin
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_sin:
    fsin
    fnstsw  %ax
    sahf
    jp      2f
    ret
2:
    call    SYM(cgc_twopi_rem)
    fsin
    ret

END SYM(cgc_sin)

ENTER SYM(cgc_cos)
SYM(cgc_cosl):
    fldt    8(%rsp)
    call    internal_cos
    ret

SYM(cgc_cosf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_cos
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_cos):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_cos
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_cos:
    fcos
    fnstsw  %ax
    sahf
    jp      2f
    ret
2:
    call    SYM(cgc_twopi_rem)
    fcos
    ret
END SYM(cgc_cos)

ENTER SYM(cgc_tan)
SYM(cgc_tanl):
    fldt    8(%rsp)
    call    internal_tan
    ret

SYM(cgc_tanf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_tan
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_tan):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_tan
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_tan:
    fptan
    fnstsw  %ax
    sahf
    jp      2f
    fstp    %st(0)
    ret
2:
    call    SYM(cgc_twopi_rem)
    fptan
    fstp    %st(0)
    ret
END SYM(cgc_tan)

.type SYM(cgc_twopi_rem), @function
SYM(cgc_twopi_rem):
    fldpi
    fadd    %st(0)
    fxch    %st(1)
1:
    fprem
    fnstsw  %ax
    sahf
    jp      1b
    fstp    %st(1)
    ret
.size    SYM(cgc_twopi_rem), . - SYM(cgc_twopi_rem)

ENTER SYM(cgc_remainder)
SYM(cgc_remainderl):
    fldt    24(%rsp)
    fldt    8(%rsp)
    call    internal_remainder
    ret

SYM(cgc_remainderf):
    movss   %xmm0, -8(%rsp)
    movss   %xmm1, -12(%rsp)
    flds    -12(%rsp)
    flds    -8(%rsp)
    call    internal_remainder
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_remainder):
    movsd   %xmm0, -8(%rsp)
    movsd   %xmm1, -16(%rsp)
    fldl    -16(%rsp)
    fldl    -8(%rsp)
    call    internal_remainder
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_remainder:
1:
    fprem1
    fstsw   %ax
    sahf
    jp      1b
    fstp    %st(1)
    ret
END SYM(cgc_remainder)

ENTER SYM(cgc_log)
SYM(cgc_logl):
    fldt    8(%rsp)
    call    internal_log
    ret

SYM(cgc_logf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_log
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_log):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_log
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_log:
    fldln2
    fxch    %st(1)
    fyl2x
    ret
END SYM(cgc_log)

ENTER SYM(cgc_log10)
SYM(cgc_log10l):
    fldt    8(%rsp)
    call    internal_log10
    ret

SYM(cgc_log10f):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_log10
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_log10):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_log10
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_log10:
    fldlg2
    fxch    %st(1)
    fyl2x
    ret
END SYM(cgc_log10)

ENTER SYM(cgc_significand)
SYM(cgc_significandl):
    fldt    8(%rsp)
    call    internal_significand
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret

SYM(cgc_significandf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_significand
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret

SYM(cgc_significand):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_significand
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret

internal_significand:
    fxtract
    fstp    %st(1)
    ret
END SYM(cgc_significand)

ENTER SYM(cgc_scalbn)
SYM(cgc_scalbnl):
    mov     %edi, -4(%rsp)
    fildl   -4(%rsp)
    fldt    8(%rsp)
    call    internal_scalbn
    ret
SYM(cgc_scalbnf):
    movss   %xmm0, -4(%rsp)
    mov     %edi, -8(%rsp)
    fildl   -8(%rsp)
    flds    -4(%rsp)
    call    internal_scalbn
    fstps   -4(%rsp)
    movss   -4(%rsp), %xmm0
    ret
SYM(cgc_scalbn):
    movsd   %xmm0, -8(%rsp)
    mov     %edi, -12(%rsp)
    fildl   -12(%rsp)
    fldl    -8(%rsp)
    call    internal_scalbn
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
internal_scalbn:
    fscale
    fstp    %st(1)
    ret
END SYM(cgc_scalbn)

ENTER SYM(cgc_scalbln)
SYM(cgc_scalblnl):
    int3
    mov     %rdi, -8(%rsp)
    fildll  -8(%rsp)
    fldt    8(%rsp)
    call    internal_scalbn
    ret
SYM(cgc_scalblnf):
    int3
    jmp     SYM(cgc_scalbnf)
SYM(cgc_scalbln):
    int3
    movsd   %xmm0, -8(%rsp)
    mov     %rdi, -16(%rsp)
    fildll  -16(%rsp)
    fldl    -8(%rsp)
    call    internal_scalbn
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
END SYM(cgc_scalbln)

ENTER SYM(cgc_rint)
SYM(cgc_rintl):
    movq    %xmm0, -16(%rsp)
    fldt    -16(%rsp)
    frndint
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret
SYM(cgc_rintf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    frndint
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_rint):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    frndint
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
END SYM(cgc_rint)

ENTER SYM(cgc_sqrt)
SYM(cgc_sqrtl):
    movq    %xmm0, -16(%rsp)
    fldt    -16(%rsp)
    fsqrt
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret
SYM(cgc_sqrtf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    fsqrt
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_sqrt):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    fsqrt
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
END SYM(cgc_sqrt)

ENTER SYM(cgc_fabs)
SYM(cgc_fabsl):
    movq    %xmm0, -16(%rsp)
    fldt    -16(%rsp)
    fabs
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret
SYM(cgc_fabsf):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    fabs
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_fabs):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    fabs
    fstpl   -8(%rsp)
    movq    -8(%rsp), %xmm0
    ret
END SYM(cgc_fabs)

ENTER SYM(cgc_atan2)
SYM(cgc_atan2l):
    movq    %xmm0, -16(%rsp)
    movq    %xmm1, -32(%rsp)
    fldt    -16(%rsp)
    fldt    -32(%rsp)
    fpatan
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret
SYM(cgc_atan2f):
    movss   %xmm0, -8(%rsp)
    movss   %xmm1, -12(%rsp)
    flds    -8(%rsp)
    flds    -12(%rsp)
    fpatan
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_atan2):
    movsd   %xmm0, -8(%rsp)
    movsd   %xmm1, -16(%rsp)
    fldl    -8(%rsp)
    fldl    -12(%rsp)
    fpatan
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
END SYM(cgc_atan2)

ENTER SYM(cgc_log2)
SYM(cgc_log2l):
    movq    %xmm0, -16(%rsp)
    fldt    -16(%rsp)
    call    internal_log2
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret
SYM(cgc_log2f):
    movss   %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    internal_log2
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_log2):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_log2
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
internal_log2:
    fld1
    fxch
    fyl2x
    ret
END SYM(cgc_log2)

ENTER SYM(cgc_exp2)
    .type    SYM(cgc_exp2x), @function
SYM(cgc_exp2l):
    movq    %xmm0, -16(%rsp)
    fldt    -16(%rsp)
    call    cgc_exp2x
    fstpt   -16(%rsp)
    movq    -16(%rsp), %xmm0
    ret
SYM(cgc_exp2f):
    movss    %xmm0, -8(%rsp)
    flds    -8(%rsp)
    call    cgc_exp2x
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_exp2):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    cgc_exp2x
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
SYM(cgc_exp2x):
    fld     %st(0)
    frndint
    fsubr   %st,%st(1)
    fxch
    f2xm1
    fld1
    faddp
    fscale
    fstp    %st(1)
    ret
END SYM(cgc_exp2)
.size    SYM(cgc_exp2x), . - SYM(cgc_exp2x)

ENTER SYM(cgc_pow)
SYM(cgc_powl):
    fldt    24(%rsp)
    fldt    8(%rsp)
    call    internal_pow
    ret
SYM(cgc_powf):
    movss   %xmm0, -8(%rsp)
    movss   %xmm1, -12(%rsp)
    flds    -12(%rsp)
    flds    -8(%rsp)
    call    internal_pow
    fstps   -8(%rsp)
    movss   -8(%rsp), %xmm0
    ret
SYM(cgc_pow):
    movsd   %xmm0, -8(%rsp)
    movsd   %xmm1, -16(%rsp)
    fldl    -16(%rsp)
    fldl    -8(%rsp)
    call    internal_pow
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
internal_pow:
    fyl2x
    jmp     SYM(cgc_exp2x)
END SYM(cgc_pow)

ENTER SYM(cgc_exp)
SYM(cgc_expl):
    fldt    8(%rsp)
    call    internal_exp
    ret
SYM(cgc_expf):
    movss   %xmm0, -4(%rsp)
    flds    -4(%rsp)
    call    internal_exp
    fstps   -4(%rsp)
    movss   -4(%rsp), %xmm0
    ret
SYM(cgc_exp):
    movsd   %xmm0, -8(%rsp)
    fldl    -8(%rsp)
    call    internal_exp
    fstpl   -8(%rsp)
    movsd   -8(%rsp), %xmm0
    ret
internal_exp:
    fldl2e
    fmulp
    jmp     SYM(cgc_exp2x)
END SYM(cgc_exp)

.global SYM(cgc_setjmp)
.type SYM(cgc_setjmp), @function
SYM(cgc_setjmp):
    int3
    mov     4(%esp), %ecx
    mov     0(%esp), %rdx
    mov     %rdx, 0(%rdi)
    mov    %rbx, 4(%rdi)
    movl    %edi, 20(%ecx)
    xorl    %eax, %eax
    ret
.size SYM(cgc_setjmp), . - SYM(cgc_setjmp)

.global SYM(cgc_longjmp)
.type SYM(cgc_longjmp), @function
SYM(cgc_longjmp):
    int3
    movl    4(%esp), %edx
    movl    8(%esp), %eax
    movl    0(%edx), %ecx
    movl    4(%edx), %ebx
    movl    8(%edx), %esp
    movl    12(%edx), %ebp
    movl    16(%edx), %esi
    movl    20(%edx), %edi
    testl   %eax, %eax
    jnz    1f
    incl    %eax
1:
    movl    %ecx, 0(%esp)
    ret
.size SYM(cgc_longjmp), . - SYM(cgc_longjmp)
