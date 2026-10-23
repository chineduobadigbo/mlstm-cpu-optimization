
mlstm_cpu/_C.cpython-311-x86_64-linux-gnu.so:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .plt.sec:

Disassembly of section .text:

000000000002d2f0 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)>:
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:92
   2d2f0:	lea    r10,[rsp+0x8]
   2d2f5:	and    rsp,0xffffffffffffffe0
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10
   2d2f9:	vxorps xmm6,xmm6,xmm6
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:92
   2d2fd:	push   QWORD PTR [r10-0x8]
   2d301:	push   rbp
   2d302:	mov    rbp,rsp
   2d305:	push   r15
   2d307:	push   r14
   2d309:	vmovd  r14d,xmm0
   2d30e:	push   r13
   2d310:	mov    r13,r8
   2d313:	push   r12
   2d315:	mov    r12,rsi
   2d318:	push   r10
   2d31a:	push   rbx
   2d31b:	mov    rbx,rdi
   2d31e:	add    rsp,0xffffffffffffff80
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10
   2d322:	vcomiss xmm1,xmm6
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:92
   2d326:	mov    rax,QWORD PTR [r10+0x8]
   2d32a:	mov    r15,QWORD PTR [r10]
   2d32d:	mov    QWORD PTR [rbp-0x98],rdx
   2d334:	mov    QWORD PTR [rbp-0xa8],rcx
   2d33b:	mov    QWORD PTR [rbp-0xa0],r9
   2d342:	mov    QWORD PTR [rbp-0x40],rax
   2d346:	vmovss DWORD PTR [rbp-0x34],xmm2
   2d34b:	vmovss DWORD PTR [rbp-0x70],xmm3
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10
   2d350:	jb     2d6c0 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x3d0>
csrc/include/stable_math.h:11
   2d356:	vmovss xmm7,DWORD PTR [rip+0x1f5e2]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
   2d35e:	vxorps xmm0,xmm1,xmm7
   2d362:	vmovaps XMMWORD PTR [rbp-0x50],xmm7
std::exp(float)():
/usr/include/c++/11/cmath:223
   2d367:	call   b7b0 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   2d36c:	call   b8c0 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:11
   2d371:	vxorps xmm1,xmm0,XMMWORD PTR [rbp-0x50]
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:106
   2d376:	vaddss xmm0,xmm1,DWORD PTR [rbp-0x34]
float const& std::max<float>(float const&, float const&)():
/usr/include/c++/11/bits/stl_algobase.h:261
   2d37b:	vmovd  xmm6,r14d
   2d380:	vmaxss xmm6,xmm6,xmm0
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:107
   2d384:	vsubss xmm0,xmm0,xmm6
   2d388:	vmovss DWORD PTR [rbp-0x34],xmm6
std::exp(float)():
/usr/include/c++/11/cmath:223
   2d38d:	call   b7b0 <expf@plt>
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:108
   2d392:	vmovd  xmm3,r14d
std::exp(float)():
/usr/include/c++/11/cmath:223
   2d397:	vmovss DWORD PTR [rbp-0x58],xmm0
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:108
   2d39c:	vsubss xmm0,xmm3,DWORD PTR [rbp-0x34]
std::exp(float)():
/usr/include/c++/11/cmath:223
   2d3a1:	call   b7b0 <expf@plt>
   2d3a6:	vxorps xmm4,xmm4,xmm4
   2d3aa:	vmovaps xmm5,xmm0
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   2d3ae:	vxorps xmm0,xmm0,xmm0
   2d3b2:	vcvtsi2ss xmm0,xmm0,r15
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   2d3b7:	vucomiss xmm4,xmm0
   2d3bb:	vmovss xmm4,DWORD PTR [rbp-0x58]
   2d3c0:	ja     2d9df <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6ef>
   2d3c6:	vsqrtss xmm0,xmm0,xmm0
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   2d3ca:	vmovss xmm6,DWORD PTR [rip+0x1f58e]        # 4c960 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x80>
_mm256_set1_ps(float)():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:1321
   2d3d2:	vbroadcastss ymm7,xmm5
   2d3d7:	vbroadcastss ymm3,xmm4
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   2d3dc:	vdivss xmm6,xmm6,xmm0
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:30
   2d3e0:	cmp    r15,0x7
compute_denom_dot():
csrc/include/avx2_recurrent.h:30
   2d3e4:	jle    2d9a0 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6b0>
   2d3ea:	mov    edx,0x8
csrc/include/avx2_recurrent.h:28
   2d3ef:	vxorps xmm1,xmm1,xmm1
   2d3f3:	nop    DWORD PTR [rax+rax*1+0x0]
_mm256_mul_ps(float __vector(8), float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:320
   2d3f8:	vmulps ymm0,ymm3,YMMWORD PTR [r13+rdx*4-0x20]
   2d3ff:	mov    rax,rdx
_mm256_add_ps(float __vector(8), float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:149
   2d402:	vfmadd231ps ymm0,ymm7,YMMWORD PTR [r12+rdx*4-0x20]
_mm256_fmadd_ps(float __vector(8), float __vector(8), float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/fmaintrin.h:65
   2d409:	vfmadd231ps ymm1,ymm0,YMMWORD PTR [rbx+rdx*4-0x20]
_mm256_storeu_ps(float*, float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:911
   2d410:	vmovups YMMWORD PTR [r13+rdx*4-0x20],ymm0
compute_denom_dot():
csrc/include/avx2_recurrent.h:30
   2d417:	add    rdx,0x8
   2d41b:	cmp    r15,rdx
   2d41e:	jge    2d3f8 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x108>
_mm256_extractf128_ps(float __vector(8), int)():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:526
   2d420:	vextractf128 xmm0,ymm1,0x1
_mm_add_ps(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:186
   2d426:	vaddps xmm1,xmm0,xmm1
_mm_movehdup_ps(float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/pmmintrin.h:71
   2d42a:	vmovshdup xmm0,xmm1
_mm_add_ps(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:186
   2d42e:	vaddps xmm1,xmm1,xmm0
_mm_movehl_ps(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:787
   2d432:	vmovhlps xmm0,xmm0,xmm1
_mm_add_ss(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:130
   2d436:	vaddss xmm1,xmm1,xmm0
compute_denom_dot():
csrc/include/avx2_recurrent.h:38
   2d43a:	cmp    r15,rax
   2d43d:	jle    2d613 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x323>
   2d443:	lea    r9,[rax*4+0x20]
   2d44b:	lea    rcx,[rax*4+0x0]
   2d453:	mov    rsi,r15
   2d456:	mov    r11,rax
   2d459:	lea    r8,[r13+r9*1+0x0]
   2d45e:	lea    rdi,[rbx+rcx*1]
   2d462:	sub    rsi,rax
   2d465:	lea    rdx,[r13+rcx*1+0x0]
   2d46a:	cmp    rdi,r8
   2d46d:	lea    r8,[rbx+r9*1]
   2d471:	setae  r14b
   2d475:	cmp    rdx,r8
   2d478:	lea    r10,[rsi-0x1]
   2d47c:	setae  r8b
   2d480:	or     r8d,r14d
   2d483:	cmp    r10,0x2
   2d487:	seta   r14b
   2d48b:	test   r8b,r14b
   2d48e:	je     2d698 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x3a8>
   2d494:	lea    r9,[r12+r9*1-0x1c]
   2d499:	mov    r8,rdx
   2d49c:	sub    r8,r9
   2d49f:	cmp    r8,0x18
   2d4a3:	jbe    2d698 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x3a8>
   2d4a9:	cmp    r10,0x6
   2d4ad:	jbe    2d9ab <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6bb>
   2d4b3:	mov    r9,rsi
   2d4b6:	add    rcx,r12
   2d4b9:	xor    r8d,r8d
   2d4bc:	shr    r9,0x3
   2d4c0:	shl    r9,0x5
   2d4c4:	nop    DWORD PTR [rax+0x0]
csrc/include/avx2_recurrent.h:39
   2d4c8:	vmulps ymm0,ymm7,YMMWORD PTR [rcx+r8*1]
   2d4ce:	vfmadd231ps ymm0,ymm3,YMMWORD PTR [rdx+r8*1]
   2d4d4:	vmovups YMMWORD PTR [rdx+r8*1],ymm0
csrc/include/avx2_recurrent.h:40
   2d4da:	vmulps ymm2,ymm0,YMMWORD PTR [rdi+r8*1]
   2d4e0:	add    r8,0x20
   2d4e4:	vaddss xmm1,xmm1,xmm2
   2d4e8:	vshufps xmm0,xmm2,xmm2,0x55
   2d4ed:	vshufps xmm8,xmm2,xmm2,0xff
   2d4f2:	vaddss xmm1,xmm1,xmm0
   2d4f6:	vunpckhps xmm0,xmm2,xmm2
   2d4fa:	vaddss xmm1,xmm1,xmm0
   2d4fe:	vextractf128 xmm0,ymm2,0x1
   2d504:	vshufps xmm2,xmm0,xmm0,0x55
   2d509:	vaddss xmm1,xmm1,xmm8
   2d50e:	vaddss xmm1,xmm1,xmm0
   2d512:	vaddss xmm1,xmm1,xmm2
   2d516:	vunpckhps xmm2,xmm0,xmm0
   2d51a:	vshufps xmm0,xmm0,xmm0,0xff
   2d51f:	vaddss xmm1,xmm1,xmm2
   2d523:	vaddss xmm1,xmm1,xmm0
csrc/include/avx2_recurrent.h:38
   2d527:	cmp    r8,r9
   2d52a:	jne    2d4c8 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x1d8>
   2d52c:	mov    rdx,rsi
   2d52f:	and    rdx,0xfffffffffffffff8
   2d533:	add    rax,rdx
   2d536:	cmp    rsi,rdx
   2d539:	je     2d613 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x323>
   2d53f:	sub    rsi,rdx
   2d542:	lea    rcx,[rsi-0x1]
   2d546:	cmp    rcx,0x2
   2d54a:	jbe    2d5a7 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x2b7>
csrc/include/avx2_recurrent.h:39
   2d54c:	add    rdx,r11
   2d54f:	vshufps xmm2,xmm5,xmm5,0x0
   2d554:	vshufps xmm0,xmm4,xmm4,0x0
   2d559:	lea    rcx,[rdx*4+0x0]
   2d561:	vmulps xmm2,xmm2,XMMWORD PTR [r12+rdx*4]
   2d567:	mov    rdx,rsi
   2d56a:	lea    rdi,[r13+rcx*1+0x0]
   2d56f:	and    rdx,0xfffffffffffffffc
   2d573:	vfmadd132ps xmm0,xmm2,XMMWORD PTR [rdi]
   2d578:	add    rax,rdx
   2d57b:	vmovups XMMWORD PTR [rdi],xmm0
csrc/include/avx2_recurrent.h:40
   2d57f:	vmulps xmm0,xmm0,XMMWORD PTR [rbx+rcx*1]
   2d584:	vaddss xmm1,xmm1,xmm0
   2d588:	vshufps xmm2,xmm0,xmm0,0x55
   2d58d:	vaddss xmm1,xmm1,xmm2
   2d591:	vunpckhps xmm2,xmm0,xmm0
   2d595:	vshufps xmm0,xmm0,xmm0,0xff
   2d59a:	vaddss xmm1,xmm1,xmm2
   2d59e:	vaddss xmm1,xmm1,xmm0
csrc/include/avx2_recurrent.h:38
   2d5a2:	cmp    rsi,rdx
   2d5a5:	je     2d613 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x323>
csrc/include/avx2_recurrent.h:39
   2d5a7:	lea    rdx,[rax*4+0x0]
   2d5af:	vmulss xmm0,xmm5,DWORD PTR [r12+rax*4]
   2d5b5:	lea    rcx,[r13+rdx*1+0x0]
   2d5ba:	vfmadd231ss xmm0,xmm4,DWORD PTR [rcx]
   2d5bf:	vmovss DWORD PTR [rcx],xmm0
csrc/include/avx2_recurrent.h:38
   2d5c3:	lea    rcx,[rax+0x1]
csrc/include/avx2_recurrent.h:40
   2d5c7:	vfmadd231ss xmm1,xmm0,DWORD PTR [rbx+rax*4]
csrc/include/avx2_recurrent.h:38
   2d5cd:	cmp    rcx,r15
   2d5d0:	jge    2d613 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x323>
csrc/include/avx2_recurrent.h:39
   2d5d2:	vmulss xmm0,xmm5,DWORD PTR [r12+rdx*1+0x4]
   2d5d9:	lea    rcx,[r13+rdx*1+0x4]
csrc/include/avx2_recurrent.h:38
   2d5de:	add    rax,0x2
csrc/include/avx2_recurrent.h:39
   2d5e2:	vfmadd231ss xmm0,xmm4,DWORD PTR [rcx]
   2d5e7:	vmovss DWORD PTR [rcx],xmm0
csrc/include/avx2_recurrent.h:40
   2d5eb:	vfmadd231ss xmm1,xmm0,DWORD PTR [rbx+rdx*1+0x4]
csrc/include/avx2_recurrent.h:38
   2d5f2:	cmp    r15,rax
   2d5f5:	jle    2d613 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x323>
csrc/include/avx2_recurrent.h:39
   2d5f7:	vmulss xmm0,xmm5,DWORD PTR [r12+rdx*1+0x8]
   2d5fe:	lea    rax,[r13+rdx*1+0x8]
   2d603:	vfmadd231ss xmm0,xmm4,DWORD PTR [rax]
   2d608:	vmovss DWORD PTR [rax],xmm0
csrc/include/avx2_recurrent.h:40
   2d60c:	vfmadd231ss xmm1,xmm0,DWORD PTR [rbx+rdx*1+0x8]
csrc/include/avx2_recurrent.h:38
   2d613:	vmovss DWORD PTR [rbp-0x60],xmm5
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:111
   2d618:	vmovss xmm5,DWORD PTR [rbp-0x34]
   2d61d:	vxorps xmm0,xmm5,XMMWORD PTR [rbp-0x50]
   2d622:	vmovss DWORD PTR [rbp-0x6c],xmm1
   2d627:	vmovaps YMMWORD PTR [rbp-0x90],ymm3
   2d62f:	vmovss DWORD PTR [rbp-0x68],xmm4
   2d634:	vmovss DWORD PTR [rbp-0x58],xmm6
std::exp(float)():
/usr/include/c++/11/cmath:223
   2d639:	vzeroupper 
   2d63c:	call   b7b0 <expf@plt>
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:110
   2d641:	vmovss xmm6,DWORD PTR [rbp-0x58]
   2d646:	vmovss xmm1,DWORD PTR [rbp-0x6c]
csrc/include/avx2_recurrent.h:115
   2d64b:	cmp    QWORD PTR [rbp-0x40],0x0
   2d650:	vmovss xmm5,DWORD PTR [rbp-0x60]
csrc/include/avx2_recurrent.h:110
   2d655:	vmulss xmm1,xmm6,xmm1
csrc/include/avx2_recurrent.h:115
   2d659:	vmovss xmm4,DWORD PTR [rbp-0x68]
   2d65e:	vmovaps ymm3,YMMWORD PTR [rbp-0x90]
std::abs(float)():
/usr/include/c++/11/bits/std_abs.h:76
   2d666:	vandps xmm1,xmm1,XMMWORD PTR [rip+0x1f2e2]        # 4c950 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x70>
float const& std::max<float>(float const&, float const&)():
/usr/include/c++/11/bits/stl_algobase.h:261
   2d66e:	vmaxss xmm0,xmm0,xmm1
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:115
   2d672:	jg     2d6f0 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x400>
csrc/include/avx2_recurrent.h:133
   2d674:	vmovss xmm0,DWORD PTR [rbp-0x34]
   2d679:	vzeroupper 
   2d67c:	sub    rsp,0xffffffffffffff80
   2d680:	pop    rbx
   2d681:	pop    r10
   2d683:	pop    r12
   2d685:	pop    r13
   2d687:	pop    r14
   2d689:	pop    r15
   2d68b:	pop    rbp
   2d68c:	lea    rsp,[r10-0x8]
   2d690:	ret    
   2d691:	nop    DWORD PTR [rax+0x0]
compute_denom_dot():
csrc/include/avx2_recurrent.h:39
   2d698:	vmulss xmm0,xmm5,DWORD PTR [r12+rax*4]
   2d69e:	vfmadd231ss xmm0,xmm4,DWORD PTR [r13+rax*4+0x0]
   2d6a5:	vmovss DWORD PTR [r13+rax*4+0x0],xmm0
csrc/include/avx2_recurrent.h:40
   2d6ac:	vfmadd231ss xmm1,xmm0,DWORD PTR [rbx+rax*4]
csrc/include/avx2_recurrent.h:38
   2d6b2:	add    rax,0x1
   2d6b6:	cmp    r15,rax
   2d6b9:	jne    2d698 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x3a8>
   2d6bb:	jmp    2d613 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x323>
std::exp(float)():
/usr/include/c++/11/cmath:223
   2d6c0:	vmovaps xmm0,xmm1
   2d6c4:	vmovss DWORD PTR [rbp-0x50],xmm1
   2d6c9:	call   b7b0 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   2d6ce:	call   b8c0 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:13
   2d6d3:	vmovss xmm1,DWORD PTR [rbp-0x50]
   2d6d8:	vmovss xmm3,DWORD PTR [rip+0x1f260]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
   2d6e0:	vmovaps XMMWORD PTR [rbp-0x50],xmm3
   2d6e5:	vsubss xmm1,xmm1,xmm0
   2d6e9:	jmp    2d376 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x86>
   2d6ee:	xchg   ax,ax
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:111
   2d6f0:	vaddss xmm0,xmm0,DWORD PTR [rbp-0x70]
csrc/include/avx2_recurrent.h:83
   2d6f5:	mov    r14,QWORD PTR [rbp-0xa8]
csrc/include/avx2_recurrent.h:112
   2d6fc:	xor    edx,edx
csrc/include/avx2_recurrent.h:115
   2d6fe:	mov    r13d,0x1
csrc/include/avx2_recurrent.h:112
   2d704:	vdivss xmm1,xmm6,xmm0
update_c_rows_and_dot_avx2<1>():
csrc/include/avx2_recurrent.h:83
   2d708:	vshufps xmm6,xmm4,xmm4,0x0
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:119 (discriminator 1)
   2d70d:	mov    rax,QWORD PTR [rbp-0x98]
   2d714:	lea    rsi,[r14+rdx*4]
update_c_rows_and_dot_avx2<1>():
csrc/include/avx2_recurrent.h:65 (discriminator 1)
   2d718:	vxorps xmm2,xmm2,xmm2
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:119 (discriminator 1)
   2d71c:	vmulss xmm7,xmm5,DWORD PTR [rax+r13*4-0x4]
update_c_rows_and_dot_avx2<1>():
csrc/include/avx2_recurrent.h:64 (discriminator 1)
   2d723:	xor    eax,eax
csrc/include/avx2_recurrent.h:65 (discriminator 1)
   2d725:	cmp    r15,0x7
   2d729:	jg     2d770 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x480>
_mm256_extractf128_ps(float __vector(8), int)():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:526
   2d72b:	vextractf128 xmm0,ymm2,0x1
_mm_add_ps(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:186
   2d731:	vaddps xmm0,xmm0,xmm2
_mm_movehdup_ps(float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/pmmintrin.h:71
   2d735:	vmovshdup xmm2,xmm0
_mm_add_ps(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:186
   2d739:	vaddps xmm0,xmm0,xmm2
_mm_movehl_ps(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:787
   2d73d:	vmovhlps xmm2,xmm2,xmm0
_mm_add_ss(float __vector(4), float __vector(4))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/xmmintrin.h:130
   2d741:	vaddss xmm0,xmm0,xmm2
update_c_rows_and_dot_avx2<1>():
csrc/include/avx2_recurrent.h:81
   2d745:	cmp    r15,rax
   2d748:	jg     2d7a8 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x4b8>
float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)():
csrc/include/avx2_recurrent.h:123 (discriminator 1)
   2d74a:	vmulss xmm0,xmm0,xmm1
   2d74e:	mov    rax,QWORD PTR [rbp-0xa0]
csrc/include/avx2_recurrent.h:115 (discriminator 1)
   2d755:	add    rdx,r15
csrc/include/avx2_recurrent.h:123 (discriminator 1)
   2d758:	vmovss DWORD PTR [rax+r13*4-0x4],xmm0
csrc/include/avx2_recurrent.h:115 (discriminator 1)
   2d75f:	add    r13,0x1
   2d763:	cmp    r13,QWORD PTR [rbp-0x40]
   2d767:	jg     2d674 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x384>
   2d76d:	jmp    2d70d <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x41d>
   2d76f:	nop
_mm256_set1_ps(float)():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:1321
   2d770:	vbroadcastss ymm8,xmm7
   2d775:	mov    ecx,0x8
_mm256_mul_ps(float __vector(8), float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:320
   2d77a:	vmulps ymm0,ymm8,YMMWORD PTR [r12+rcx*4-0x20]
   2d781:	mov    rax,rcx
_mm256_fmadd_ps(float __vector(8), float __vector(8), float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/fmaintrin.h:65
   2d784:	vfmadd231ps ymm0,ymm3,YMMWORD PTR [rsi+rcx*4-0x20]
   2d78b:	vfmadd231ps ymm2,ymm0,YMMWORD PTR [rbx+rcx*4-0x20]
_mm256_storeu_ps(float*, float __vector(8))():
/usr/lib/gcc/x86_64-linux-gnu/11/include/avxintrin.h:911
   2d792:	vmovups YMMWORD PTR [rsi+rcx*4-0x20],ymm0
update_c_rows_and_dot_avx2<1>():
csrc/include/avx2_recurrent.h:65
   2d798:	add    rcx,0x8
   2d79c:	cmp    r15,rcx
   2d79f:	jl     2d72b <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x43b>
   2d7a1:	jmp    2d77a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x48a>
   2d7a3:	nop    DWORD PTR [rax+rax*1+0x0]
   2d7a8:	mov    rcx,r15
   2d7ab:	lea    r11,[rax+rdx*1]
   2d7af:	lea    rdi,[rax*4+0x0]
   2d7b7:	mov    QWORD PTR [rbp-0x50],rax
   2d7bb:	sub    rcx,rax
   2d7be:	lea    r8,[r14+r11*4]
   2d7c2:	lea    r9,[rbx+rdi*1+0x20]
   2d7c7:	mov    QWORD PTR [rbp-0x58],r11
   2d7cb:	lea    r10,[rcx-0x1]
   2d7cf:	cmp    r8,r9
   2d7d2:	lea    r11,[r14+r11*4+0x20]
   2d7d7:	mov    QWORD PTR [rbp-0x60],r10
   2d7db:	lea    r10,[rbx+rdi*1]
   2d7df:	setae  r9b
   2d7e3:	cmp    r10,r11
   2d7e6:	mov    QWORD PTR [rbp-0x68],r10
   2d7ea:	mov    r10,r8
   2d7ed:	setae  r11b
   2d7f1:	or     r9d,r11d
   2d7f4:	lea    r11,[r12+rdi*1+0x4]
   2d7f9:	sub    r10,r11
   2d7fc:	cmp    r10,0x18
   2d800:	seta   r11b
   2d804:	test   r9b,r11b
   2d807:	je     2d9b2 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6c2>
   2d80d:	mov    r10,QWORD PTR [rbp-0x60]
   2d811:	cmp    r10,0x2
   2d815:	jbe    2d9b2 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6c2>
   2d81b:	cmp    r10,0x6
   2d81f:	jbe    2d9d8 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6e8>
   2d825:	mov    r9,rcx
csrc/include/avx2_recurrent.h:81
   2d828:	mov    r11,QWORD PTR [rbp-0x68]
   2d82c:	add    rdi,r12
   2d82f:	vbroadcastss ymm8,xmm7
   2d834:	shr    r9,0x3
   2d838:	mov    r10,r9
   2d83b:	xor    r9d,r9d
   2d83e:	shl    r10,0x5
csrc/include/avx2_recurrent.h:83
   2d842:	vmulps ymm2,ymm8,YMMWORD PTR [rdi+r9*1]
   2d848:	vfmadd231ps ymm2,ymm3,YMMWORD PTR [r8+r9*1]
csrc/include/avx2_recurrent.h:84
   2d84e:	vmovups YMMWORD PTR [r8+r9*1],ymm2
csrc/include/avx2_recurrent.h:85
   2d854:	vmulps ymm2,ymm2,YMMWORD PTR [r11+r9*1]
   2d85a:	add    r9,0x20
   2d85e:	vaddss xmm10,xmm0,xmm2
   2d862:	vshufps xmm0,xmm2,xmm2,0x55
   2d867:	vshufps xmm9,xmm2,xmm2,0xff
   2d86c:	vaddss xmm0,xmm0,xmm10
   2d871:	vunpckhps xmm10,xmm2,xmm2
   2d875:	vextractf128 xmm2,ymm2,0x1
   2d87b:	vaddss xmm0,xmm0,xmm10
   2d880:	vaddss xmm0,xmm0,xmm9
   2d885:	vshufps xmm9,xmm2,xmm2,0x55
   2d88a:	vaddss xmm0,xmm0,xmm2
   2d88e:	vaddss xmm0,xmm0,xmm9
   2d893:	vunpckhps xmm9,xmm2,xmm2
   2d897:	vshufps xmm2,xmm2,xmm2,0xff
   2d89c:	vaddss xmm0,xmm0,xmm9
   2d8a1:	vaddss xmm0,xmm0,xmm2
csrc/include/avx2_recurrent.h:81
   2d8a5:	cmp    r9,r10
   2d8a8:	jne    2d842 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x552>
   2d8aa:	mov    rdi,rcx
   2d8ad:	and    rdi,0xfffffffffffffff8
   2d8b1:	add    rax,rdi
   2d8b4:	cmp    rdi,rcx
   2d8b7:	je     2d74a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x45a>
   2d8bd:	sub    rcx,rdi
   2d8c0:	lea    r8,[rcx-0x1]
   2d8c4:	cmp    r8,0x2
   2d8c8:	jbe    2d926 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x636>
csrc/include/avx2_recurrent.h:82
   2d8ca:	mov    r8,QWORD PTR [rbp-0x58]
csrc/include/avx2_recurrent.h:83
   2d8ce:	vshufps xmm2,xmm7,xmm7,0x0
   2d8d3:	add    r8,rdi
   2d8d6:	add    rdi,QWORD PTR [rbp-0x50]
   2d8da:	vmulps xmm2,xmm2,XMMWORD PTR [r12+rdi*4]
   2d8e0:	lea    r8,[r14+r8*4]
   2d8e4:	vfmadd231ps xmm2,xmm6,XMMWORD PTR [r8]
csrc/include/avx2_recurrent.h:84
   2d8e9:	vmovups XMMWORD PTR [r8],xmm2
csrc/include/avx2_recurrent.h:85
   2d8ee:	vmulps xmm2,xmm2,XMMWORD PTR [rbx+rdi*4]
   2d8f3:	mov    rdi,rcx
   2d8f6:	and    rdi,0xfffffffffffffffc
   2d8fa:	add    rax,rdi
   2d8fd:	vaddss xmm0,xmm0,xmm2
   2d901:	vshufps xmm8,xmm2,xmm2,0x55
   2d906:	vaddss xmm0,xmm0,xmm8
   2d90b:	vunpckhps xmm8,xmm2,xmm2
   2d90f:	vshufps xmm2,xmm2,xmm2,0xff
   2d914:	vaddss xmm0,xmm0,xmm8
   2d919:	vaddss xmm0,xmm0,xmm2
csrc/include/avx2_recurrent.h:81
   2d91d:	cmp    rcx,rdi
   2d920:	je     2d74a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x45a>
csrc/include/avx2_recurrent.h:83
   2d926:	lea    rcx,[rax*4+0x0]
   2d92e:	vmulss xmm2,xmm7,DWORD PTR [r12+rax*4]
   2d934:	lea    rdi,[rsi+rcx*1]
   2d938:	vfmadd231ss xmm2,xmm4,DWORD PTR [rdi]
csrc/include/avx2_recurrent.h:84
   2d93d:	vmovss DWORD PTR [rdi],xmm2
csrc/include/avx2_recurrent.h:81
   2d941:	lea    rdi,[rax+0x1]
csrc/include/avx2_recurrent.h:85
   2d945:	vfmadd231ss xmm0,xmm2,DWORD PTR [rbx+rax*4]
csrc/include/avx2_recurrent.h:81
   2d94b:	cmp    r15,rdi
   2d94e:	jle    2d74a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x45a>
csrc/include/avx2_recurrent.h:83
   2d954:	vmulss xmm2,xmm7,DWORD PTR [r12+rcx*1+0x4]
   2d95b:	lea    rdi,[rsi+rcx*1+0x4]
csrc/include/avx2_recurrent.h:81
   2d960:	add    rax,0x2
csrc/include/avx2_recurrent.h:83
   2d964:	vfmadd231ss xmm2,xmm4,DWORD PTR [rdi]
csrc/include/avx2_recurrent.h:84
   2d969:	vmovss DWORD PTR [rdi],xmm2
csrc/include/avx2_recurrent.h:85
   2d96d:	vfmadd231ss xmm0,xmm2,DWORD PTR [rbx+rcx*1+0x4]
csrc/include/avx2_recurrent.h:81
   2d974:	cmp    r15,rax
   2d977:	jle    2d74a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x45a>
csrc/include/avx2_recurrent.h:83
   2d97d:	vmulss xmm7,xmm7,DWORD PTR [r12+rcx*1+0x8]
   2d984:	lea    rax,[rsi+rcx*1+0x8]
   2d989:	vfmadd231ss xmm7,xmm4,DWORD PTR [rax]
csrc/include/avx2_recurrent.h:84
   2d98e:	vmovss DWORD PTR [rax],xmm7
csrc/include/avx2_recurrent.h:85
   2d992:	vfmadd231ss xmm0,xmm7,DWORD PTR [rbx+rcx*1+0x8]
csrc/include/avx2_recurrent.h:81
   2d999:	jmp    2d74a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x45a>
   2d99e:	xchg   ax,ax
compute_denom_dot():
csrc/include/avx2_recurrent.h:28
   2d9a0:	vxorps xmm1,xmm1,xmm1
csrc/include/avx2_recurrent.h:29
   2d9a4:	xor    eax,eax
   2d9a6:	jmp    2d420 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x130>
csrc/include/avx2_recurrent.h:38
   2d9ab:	xor    edx,edx
   2d9ad:	jmp    2d54c <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x25c>
update_c_rows_and_dot_avx2<1>():
csrc/include/avx2_recurrent.h:83
   2d9b2:	vmulss xmm2,xmm7,DWORD PTR [r12+rax*4]
   2d9b8:	vfmadd231ss xmm2,xmm4,DWORD PTR [rsi+rax*4]
csrc/include/avx2_recurrent.h:84
   2d9be:	vmovss DWORD PTR [rsi+rax*4],xmm2
csrc/include/avx2_recurrent.h:85
   2d9c3:	vfmadd231ss xmm0,xmm2,DWORD PTR [rbx+rax*4]
csrc/include/avx2_recurrent.h:81
   2d9c9:	add    rax,0x1
   2d9cd:	cmp    r15,rax
   2d9d0:	je     2d74a <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x45a>
   2d9d6:	jmp    2d9b2 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x6c2>
   2d9d8:	xor    edi,edi
   2d9da:	jmp    2d8ca <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0x5da>
   2d9df:	vmovss DWORD PTR [rbp-0x60],xmm4
   2d9e4:	vmovss DWORD PTR [rbp-0x58],xmm5
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   2d9e9:	call   bbf0 <sqrtf@plt>
   2d9ee:	vmovss xmm4,DWORD PTR [rbp-0x60]
   2d9f3:	vmovss xmm5,DWORD PTR [rbp-0x58]
   2d9f8:	jmp    2d3ca <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)+0xda>

Disassembly of section .fini:
