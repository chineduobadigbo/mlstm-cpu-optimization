
mlstm_cpu/_C.cpython-311-x86_64-linux-gnu.so:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .plt.sec:

Disassembly of section .text:

0000000000044dc0 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)>:
mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   44dc0:	endbr64 
   44dc4:	lea    r10,[rsp+0x8]
   44dc9:	and    rsp,0xffffffffffffffe0
   44dcd:	push   QWORD PTR [r10-0x8]
   44dd1:	mov    rax,r10
   44dd4:	push   rbp
   44dd5:	mov    rbp,rsp
   44dd8:	push   r15
   44dda:	push   r14
   44ddc:	push   r13
   44dde:	push   r12
   44de0:	push   r10
   44de2:	push   rbx
   44de3:	sub    rsp,0x1e0
   44dea:	mov    r11,QWORD PTR [rax+0x30]
   44dee:	mov    rbx,QWORD PTR [rax+0x28]
   44df2:	mov    QWORD PTR [rbp-0x118],rcx
   44df9:	mov    rcx,QWORD PTR [rax+0x38]
   44dfd:	mov    r14,QWORD PTR [r10+0x18]
   44e01:	mov    QWORD PTR [rbp-0x48],rdi
   44e05:	mov    rdi,QWORD PTR [r10+0x8]
   44e09:	mov    QWORD PTR [rbp-0x120],r8
csrc/kernels/mlstm_core_scalar_c_rm.inc:73
   44e10:	mov    rax,rcx
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   44e13:	mov    r8,QWORD PTR [r10]
   44e16:	mov    QWORD PTR [rbp-0x50],rsi
csrc/kernels/mlstm_core_scalar_c_rm.inc:73
   44e1a:	imul   rax,r11
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   44e1e:	mov    QWORD PTR [rbp-0x1f0],rdi
   44e25:	mov    rdi,QWORD PTR [r10+0x10]
   44e29:	mov    r10,QWORD PTR [r10+0x20]
   44e2d:	mov    QWORD PTR [rbp-0x150],rdx
   44e34:	mov    QWORD PTR [rbp-0xc0],r8
   44e3b:	mov    QWORD PTR [rbp-0x158],rdi
   44e42:	mov    QWORD PTR [rbp-0x1f8],r14
   44e49:	mov    QWORD PTR [rbp-0x128],r10
   44e50:	mov    QWORD PTR [rbp-0x1b8],rbx
   44e57:	mov    QWORD PTR [rbp-0xf0],rcx
csrc/kernels/mlstm_core_scalar_c_rm.inc:73
   44e5e:	mov    QWORD PTR [rbp-0x1c0],rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   44e65:	vmovss DWORD PTR [rbp-0x12c],xmm0
csrc/kernels/mlstm_core_scalar_c_rm.inc:74
   44e6d:	test   r14,r14
   44e70:	jle    457b3 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9f3>
   44e76:	test   rbx,rbx
   44e79:	jle    457b3 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9f3>
   44e7f:	test   r10,r10
   44e82:	jle    457b3 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9f3>
   44e88:	imul   rax,rbx
   44e8c:	mov    rdi,rcx
   44e8f:	vxorps xmm0,xmm0,xmm0
   44e93:	mov    r13,r11
   44e96:	vcvtsi2ss xmm0,xmm0,r11
   44e9b:	vxorps xmm8,xmm8,xmm8
   44ea0:	mov    QWORD PTR [rbp-0x1b0],0x0
   44eab:	mov    QWORD PTR [rbp-0x1a8],0x0
   44eb6:	mov    QWORD PTR [rbp-0x1d0],rax
   44ebd:	mov    rax,rbx
   44ec0:	mov    QWORD PTR [rbp-0x1a0],0x0
   44ecb:	imul   rax,r10
   44ecf:	mov    QWORD PTR [rbp-0x198],0x0
   44eda:	mov    QWORD PTR [rbp-0x190],0x0
   44ee5:	imul   rdi,rax
   44ee9:	mov    QWORD PTR [rbp-0x1d8],rax
   44ef0:	imul   rax,r11
   44ef4:	vmovss DWORD PTR [rbp-0xb8],xmm0
   44efc:	mov    QWORD PTR [rbp-0x188],0x0
   44f07:	mov    QWORD PTR [rbp-0x1e0],rdi
   44f0e:	mov    rdi,rbx
   44f11:	mov    QWORD PTR [rbp-0x1e8],rax
   44f18:	mov    rax,rbx
   44f1b:	mov    rbx,rcx
   44f1e:	imul   rcx,rax
   44f22:	shl    rax,0x2
   44f26:	lea    rbx,[rdx+rbx*4]
   44f2a:	mov    QWORD PTR [rbp-0x168],0x0
   44f35:	mov    QWORD PTR [rbp-0x110],rax
   44f3c:	imul   rdi,r11
   44f40:	lea    rax,[r11-0x1]
   44f44:	mov    QWORD PTR [rbp-0x78],rax
   44f48:	mov    rax,r11
   44f4b:	shr    rax,0x3
   44f4f:	mov    QWORD PTR [rbp-0x108],rcx
   44f56:	shl    rcx,0x2
   44f5a:	shl    rax,0x5
   44f5e:	mov    QWORD PTR [rbp-0xe0],rdi
   44f65:	shl    rdi,0x2
   44f69:	mov    r14,rax
   44f6c:	mov    rax,r11
   44f6f:	mov    QWORD PTR [rbp-0x100],rcx
   44f76:	and    rax,0xfffffffffffffff8
   44f7a:	mov    QWORD PTR [rbp-0x1c8],rbx
   44f81:	mov    QWORD PTR [rbp-0x80],rax
   44f85:	lea    rax,[r11*4+0x0]
   44f8d:	mov    QWORD PTR [rbp-0x68],rax
   44f91:	lea    rax,[rsi+0x4]
   44f95:	mov    QWORD PTR [rbp-0x200],rax
   44f9c:	lea    rax,[r8+0x20]
   44fa0:	mov    QWORD PTR [rbp-0x208],rax
   44fa7:	mov    rax,r11
   44faa:	mov    r11,r14
   44fad:	mov    r14,r9
   44fb0:	and    eax,0x7
   44fb3:	mov    QWORD PTR [rbp-0xf8],rdi
   44fba:	mov    QWORD PTR [rbp-0x88],rax
   44fc1:	sub    rax,0x1
   44fc5:	mov    QWORD PTR [rbp-0x90],rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:75
   44fcc:	mov    rax,QWORD PTR [rbp-0x1b0]
   44fd3:	mov    rsi,QWORD PTR [rbp-0x1a8]
   44fda:	mov    QWORD PTR [rbp-0xc8],0x0
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   44fe5:	mov    r15,QWORD PTR [rbp-0x188]
   44fec:	shl    rax,0x2
   44ff0:	mov    QWORD PTR [rbp-0x180],rax
   44ff7:	mov    rax,QWORD PTR [rbp-0x1f0]
   44ffe:	lea    rax,[rax+rsi*4]
   45002:	mov    QWORD PTR [rbp-0xe8],rax
   45009:	mov    rax,QWORD PTR [rbp-0x1a0]
   45010:	mov    QWORD PTR [rbp-0xd0],rax
   45017:	mov    rax,QWORD PTR [rbp-0x198]
   4501e:	mov    QWORD PTR [rbp-0x178],rax
   45025:	mov    rax,QWORD PTR [rbp-0x190]
   4502c:	mov    QWORD PTR [rbp-0x170],rax
   45033:	mov    rax,r15
   45036:	mov    r15,r11
   45039:	mov    r11,rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   4503c:	mov    rax,QWORD PTR [rbp-0xd0]
   45043:	mov    rbx,QWORD PTR [rbp-0x48]
   45047:	mov    QWORD PTR [rbp-0xa0],0x0
csrc/kernels/mlstm_core_scalar_c_rm.inc:79
   45052:	mov    rdi,QWORD PTR [rbp-0xc8]
   45059:	mov    rcx,QWORD PTR [rbp-0x178]
   45060:	mov    QWORD PTR [rbp-0x138],r11
   45067:	lea    rsi,[rax*4+0x0]
   4506f:	mov    rax,QWORD PTR [rbp-0xe8]
   45076:	mov    QWORD PTR [rbp-0x160],rsi
   4507d:	vmovss xmm6,DWORD PTR [rax+rdi*4]
   45082:	mov    rdi,QWORD PTR [rbp-0x170]
   45089:	mov    QWORD PTR [rbp-0x40],rcx
   4508d:	mov    rax,QWORD PTR [rbp-0x1c8]
   45094:	mov    QWORD PTR [rbp-0xb0],rdi
   4509b:	lea    rax,[rax+rdi*4]
   4509f:	vmovss DWORD PTR [rbp-0x94],xmm6
   450a7:	mov    QWORD PTR [rbp-0x60],rax
   450ab:	lea    rax,[rcx*4+0x0]
   450b3:	add    rbx,rax
   450b6:	add    rax,QWORD PTR [rbp-0x200]
   450bd:	mov    QWORD PTR [rbp-0x58],rax
   450c1:	mov    rax,rsi
   450c4:	add    rsi,QWORD PTR [rbp-0xc0]
   450cb:	mov    QWORD PTR [rbp-0xd8],rsi
   450d2:	mov    rsi,QWORD PTR [rbp-0x208]
   450d9:	add    rsi,rax
   450dc:	lea    rax,[r14+r11*4]
   450e0:	mov    QWORD PTR [rbp-0x140],rax
   450e7:	mov    rax,QWORD PTR [rbp-0x180]
   450ee:	mov    QWORD PTR [rbp-0x148],rsi
   450f5:	mov    QWORD PTR [rbp-0xa8],rax
   450fc:	nop    DWORD PTR [rax+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   45100:	mov    rax,QWORD PTR [rbp-0xa8]
   45107:	mov    rsi,QWORD PTR [rbp-0x120]
   4510e:	vmovss xmm1,DWORD PTR [rsi+rax*1]
   45113:	mov    rsi,QWORD PTR [rbp-0x118]
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   4511a:	vcomiss xmm1,xmm8
mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   4511f:	vmovss xmm6,DWORD PTR [rsi+rax*1]
   45124:	mov    rax,QWORD PTR [rbp-0x58]
   45128:	vmovss DWORD PTR [rbp-0x38],xmm6
   4512d:	lea    r12,[rax-0x4]
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   45131:	jb     4582f <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa6f>
csrc/include/stable_math.h:11
   45137:	vxorps xmm0,xmm1,XMMWORD PTR [rip+0x7801]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
std::exp(float)():
/usr/include/c++/11/cmath:223
   4513f:	call   b7b0 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   45144:	call   b8c0 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:11
   45149:	vxorps xmm0,xmm0,XMMWORD PTR [rip+0x77ef]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:25
   45151:	vaddss xmm0,xmm0,DWORD PTR [rbp-0x94]
float const& std::max<float>(float const&, float const&)():
/usr/include/c++/11/bits/stl_algobase.h:261
   45159:	vmovss xmm6,DWORD PTR [rbp-0x38]
   4515e:	vmaxss xmm7,xmm6,xmm0
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:26
   45162:	vsubss xmm0,xmm0,xmm7
   45166:	vmovss DWORD PTR [rbp-0x94],xmm7
std::exp(float)():
/usr/include/c++/11/cmath:223
   4516e:	call   b7b0 <expf@plt>
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:27
   45173:	vmovss xmm6,DWORD PTR [rbp-0x38]
std::exp(float)():
/usr/include/c++/11/cmath:223
   45178:	vmovss DWORD PTR [rbp-0x70],xmm0
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:27
   4517d:	vsubss xmm0,xmm6,DWORD PTR [rbp-0x94]
std::exp(float)():
/usr/include/c++/11/cmath:223
   45185:	call   b7b0 <expf@plt>
   4518a:	vxorps xmm8,xmm8,xmm8
   4518f:	vmovss xmm3,DWORD PTR [rbp-0x70]
   45194:	vmovss xmm5,DWORD PTR [rbp-0xb8]
   4519c:	vmovaps xmm6,xmm0
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   451a0:	vucomiss xmm8,xmm5
   451a4:	ja     458b3 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xaf3>
   451aa:	vsqrtss xmm5,xmm5,xmm5
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   451ae:	vmovss xmm7,DWORD PTR [rip+0x77aa]        # 4c960 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x80>
   451b6:	vdivss xmm5,xmm7,xmm5
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   451ba:	test   r13,r13
   451bd:	jle    45889 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xac9>
   451c3:	mov    rdi,QWORD PTR [rbp-0xd8]
   451ca:	lea    rax,[rbx+0x20]
   451ce:	cmp    rdi,rax
   451d1:	setae  al
   451d4:	cmp    rbx,QWORD PTR [rbp-0x148]
   451db:	setae  dl
   451de:	or     eax,edx
   451e0:	mov    rdx,rdi
   451e3:	sub    rdx,QWORD PTR [rbp-0x58]
   451e7:	cmp    rdx,0x18
   451eb:	seta   dl
   451ee:	test   al,dl
   451f0:	je     45850 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa90>
   451f6:	mov    rax,QWORD PTR [rbp-0x78]
   451fa:	cmp    rax,0x2
   451fe:	jbe    45850 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa90>
   45204:	cmp    rax,0x6
   45208:	jbe    4589b <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xadb>
   4520e:	vbroadcastss ymm7,xmm3
   45213:	vbroadcastss ymm4,xmm6
   45218:	xor    eax,eax
csrc/kernels/mlstm_core_scalar_c_rm.inc:30
   4521a:	mov    rdx,rdi
   4521d:	vbroadcastss ymm2,xmm5
   45222:	vmovaps xmm0,xmm8
   45226:	cs nop WORD PTR [rax+rax*1+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   45230:	vmulps ymm10,ymm4,YMMWORD PTR [r12+rax*1]
   45236:	vfmadd231ps ymm10,ymm7,YMMWORD PTR [rdx+rax*1]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   4523c:	vmovups YMMWORD PTR [rdx+rax*1],ymm10
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   45241:	vmulps ymm1,ymm2,YMMWORD PTR [rbx+rax*1]
   45246:	add    rax,0x20
   4524a:	vmulps ymm9,ymm1,ymm10
   4524f:	vaddss xmm0,xmm0,xmm9
   45254:	vshufps xmm1,xmm9,xmm9,0x55
   4525a:	vshufps xmm10,xmm9,xmm9,0xff
   45260:	vaddss xmm0,xmm0,xmm1
   45264:	vunpckhps xmm1,xmm9,xmm9
   45269:	vaddss xmm0,xmm0,xmm1
   4526d:	vextractf128 xmm1,ymm9,0x1
   45273:	vshufps xmm9,xmm1,xmm1,0x55
   45278:	vaddss xmm0,xmm0,xmm10
   4527d:	vaddss xmm0,xmm0,xmm1
   45281:	vaddss xmm0,xmm0,xmm9
   45286:	vunpckhps xmm9,xmm1,xmm1
   4528a:	vshufps xmm1,xmm1,xmm1,0xff
   4528f:	vaddss xmm0,xmm0,xmm9
   45294:	vaddss xmm0,xmm0,xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   45298:	cmp    r15,rax
   4529b:	jne    45230 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x470>
   4529d:	mov    rdx,QWORD PTR [rbp-0x80]
   452a1:	mov    rax,rdx
   452a4:	cmp    r13,rdx
   452a7:	je     45893 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xad3>
   452ad:	cmp    QWORD PTR [rbp-0x90],0x2
   452b5:	mov    rsi,QWORD PTR [rbp-0x88]
   452bc:	jbe    458ab <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xaeb>
   452c2:	vzeroupper 
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   452c5:	vshufps xmm4,xmm6,xmm6,0x0
   452ca:	vshufps xmm2,xmm3,xmm3,0x0
   452cf:	vshufps xmm1,xmm5,xmm5,0x0
   452d4:	mov    rdi,QWORD PTR [rbp-0xd0]
   452db:	lea    rcx,[rax+rdi*1]
   452df:	mov    rdi,QWORD PTR [rbp-0xc0]
   452e6:	add    rax,QWORD PTR [rbp-0x40]
   452ea:	lea    rcx,[rdi+rcx*4]
   452ee:	mov    rdi,QWORD PTR [rbp-0x50]
   452f2:	vmulps xmm4,xmm4,XMMWORD PTR [rdi+rax*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   452f7:	mov    rdi,QWORD PTR [rbp-0x48]
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   452fb:	vfmadd132ps xmm2,xmm4,XMMWORD PTR [rcx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   45300:	vmovups XMMWORD PTR [rcx],xmm2
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   45304:	vmulps xmm1,xmm1,XMMWORD PTR [rdi+rax*4]
   45309:	mov    rax,rsi
   4530c:	and    rax,0xfffffffffffffffc
   45310:	add    rdx,rax
   45313:	vmulps xmm1,xmm1,xmm2
   45317:	vaddss xmm0,xmm0,xmm1
   4531b:	vshufps xmm2,xmm1,xmm1,0x55
   45320:	vaddss xmm0,xmm0,xmm2
   45324:	vunpckhps xmm2,xmm1,xmm1
   45328:	vshufps xmm1,xmm1,xmm1,0xff
   4532d:	vaddss xmm0,xmm0,xmm2
   45331:	vaddss xmm0,xmm0,xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   45335:	cmp    rax,rsi
   45338:	je     453cc <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x60c>
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   4533e:	mov    rsi,QWORD PTR [rbp-0x160]
   45345:	mov    rdi,QWORD PTR [rbp-0xc0]
   4534c:	lea    rax,[rdx*4+0x0]
   45354:	vmulss xmm1,xmm6,DWORD PTR [r12+rdx*4]
   4535a:	lea    rcx,[rax+rsi*1]
   4535e:	add    rcx,rdi
   45361:	vfmadd231ss xmm1,xmm3,DWORD PTR [rcx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   45366:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   4536a:	vmulss xmm2,xmm5,DWORD PTR [rbx+rdx*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   4536f:	lea    rcx,[rdx+0x1]
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   45373:	vfmadd231ss xmm0,xmm2,xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   45378:	cmp    r13,rcx
   4537b:	jle    453cc <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x60c>
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   4537d:	lea    rcx,[rax+rsi*1+0x4]
   45382:	vmulss xmm1,xmm6,DWORD PTR [r12+rax*1+0x4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   45389:	add    rdx,0x2
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   4538d:	add    rcx,rdi
   45390:	vfmadd231ss xmm1,xmm3,DWORD PTR [rcx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   45395:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   45399:	vmulss xmm2,xmm5,DWORD PTR [rbx+rax*1+0x4]
   4539f:	vfmadd231ss xmm0,xmm1,xmm2
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   453a4:	cmp    r13,rdx
   453a7:	jle    453cc <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x60c>
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   453a9:	lea    rdx,[rax+rsi*1+0x8]
   453ae:	vmulss xmm1,xmm6,DWORD PTR [r12+rax*1+0x8]
   453b5:	add    rdx,rdi
   453b8:	vfmadd231ss xmm1,xmm3,DWORD PTR [rdx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   453bd:	vmovss DWORD PTR [rdx],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   453c1:	vmulss xmm2,xmm5,DWORD PTR [rbx+rax*1+0x8]
   453c7:	vfmadd231ss xmm0,xmm1,xmm2
std::abs(float)():
/usr/include/c++/11/bits/std_abs.h:76
   453cc:	vandps xmm7,xmm0,XMMWORD PTR [rip+0x757c]        # 4c950 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x70>
   453d4:	vmovss DWORD PTR [rbp-0x38],xmm7
   453d9:	vmovss DWORD PTR [rbp-0xb4],xmm5
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:38
   453e1:	vmovss xmm5,DWORD PTR [rbp-0x94]
   453e9:	vxorps xmm0,xmm5,XMMWORD PTR [rip+0x754f]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
   453f1:	vmovss DWORD PTR [rbp-0x98],xmm6
   453f9:	vmovss DWORD PTR [rbp-0x70],xmm3
std::exp(float)():
/usr/include/c++/11/cmath:223
   453fe:	call   b7b0 <expf@plt>
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   45403:	vmovss xmm3,DWORD PTR [rbp-0x70]
   45408:	cmp    QWORD PTR [rbp-0xf0],0x0
   45410:	vxorps xmm8,xmm8,xmm8
float const& std::max<float>(float const&, float const&)():
/usr/include/c++/11/bits/stl_algobase.h:261
   45415:	vmaxss xmm7,xmm0,DWORD PTR [rbp-0x38]
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   4541a:	vmovss xmm6,DWORD PTR [rbp-0x98]
csrc/kernels/mlstm_core_scalar_c_rm.inc:38
   45422:	vaddss xmm7,xmm7,DWORD PTR [rbp-0x12c]
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   4542a:	vmovss xmm5,DWORD PTR [rbp-0xb4]
   45432:	jle    4567b <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x8bb>
   45438:	lea    rcx,[rbx+0x20]
   4543c:	mov    rax,QWORD PTR [rbp-0xb0]
   45443:	xor    esi,esi
   45445:	vbroadcastss ymm4,xmm3
   4544a:	mov    QWORD PTR [rbp-0x70],rcx
   4544e:	mov    r11,QWORD PTR [rbp-0x138]
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   45455:	vshufps xmm9,xmm3,xmm3,0x0
   4545a:	lea    r8,[rax*4+0x0]
   45462:	mov    rax,QWORD PTR [rbp-0x150]
   45469:	lea    rdi,[rax+r8*1]
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   4546d:	mov    rax,QWORD PTR [rbp-0x140]
   45474:	add    r8,QWORD PTR [rbp-0x158]
   4547b:	nop    DWORD PTR [rax+rax*1+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:41
   45480:	vmulss xmm13,xmm6,DWORD PTR [rdi]
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   45484:	test   r13,r13
   45487:	jle    45808 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa48>
   4548d:	cmp    rax,QWORD PTR [rbp-0x70]
   45491:	lea    rcx,[rax+0x20]
   45495:	lea    r9,[rsi+r11*1]
   45499:	setae  dl
   4549c:	cmp    rbx,rcx
   4549f:	setae  cl
   454a2:	or     edx,ecx
   454a4:	mov    rcx,rax
   454a7:	sub    rcx,QWORD PTR [rbp-0x58]
   454ab:	cmp    rcx,0x18
   454af:	seta   cl
   454b2:	test   dl,cl
   454b4:	je     457d0 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa10>
   454ba:	mov    rcx,QWORD PTR [rbp-0x78]
   454be:	cmp    rcx,0x2
   454c2:	jbe    457d0 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa10>
   454c8:	cmp    rcx,0x6
   454cc:	jbe    45811 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa51>
   454d2:	vbroadcastss ymm2,xmm13
   454d7:	xor    edx,edx
csrc/kernels/mlstm_core_scalar_c_rm.inc:43
   454d9:	vmovaps xmm0,xmm8
   454dd:	nop    DWORD PTR [rax]
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   454e0:	vmulps ymm10,ymm2,YMMWORD PTR [r12+rdx*1]
   454e6:	vfmadd231ps ymm10,ymm4,YMMWORD PTR [rax+rdx*1]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   454ec:	vmovups YMMWORD PTR [rax+rdx*1],ymm10
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   454f1:	vmulps ymm11,ymm10,YMMWORD PTR [rbx+rdx*1]
   454f6:	add    rdx,0x20
   454fa:	vaddss xmm0,xmm0,xmm11
   454ff:	vshufps xmm10,xmm11,xmm11,0x55
   45505:	vshufps xmm12,xmm11,xmm11,0xff
   4550b:	vaddss xmm0,xmm0,xmm10
   45510:	vunpckhps xmm10,xmm11,xmm11
   45515:	vaddss xmm0,xmm0,xmm10
   4551a:	vextractf128 xmm10,ymm11,0x1
   45520:	vshufps xmm11,xmm10,xmm10,0x55
   45526:	vaddss xmm0,xmm0,xmm12
   4552b:	vaddss xmm0,xmm0,xmm10
   45530:	vaddss xmm0,xmm0,xmm11
   45535:	vunpckhps xmm11,xmm10,xmm10
   4553a:	vshufps xmm10,xmm10,xmm10,0xff
   45540:	vaddss xmm0,xmm0,xmm11
   45545:	vaddss xmm0,xmm0,xmm10
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   4554a:	cmp    r15,rdx
   4554d:	jne    454e0 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x720>
   4554f:	mov    rcx,QWORD PTR [rbp-0x80]
   45553:	cmp    r13,rcx
   45556:	je     45651 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x891>
   4555c:	cmp    QWORD PTR [rbp-0x90],0x2
   45564:	mov    r10,QWORD PTR [rbp-0x88]
   4556b:	jbe    45827 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa67>
   45571:	mov    QWORD PTR [rbp-0x38],rcx
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   45575:	mov    rdx,QWORD PTR [rbp-0x50]
   45579:	add    r9,rcx
   4557c:	add    rcx,QWORD PTR [rbp-0x40]
   45580:	vshufps xmm2,xmm13,xmm13,0x0
   45586:	lea    r9,[r14+r9*4]
   4558a:	vmulps xmm2,xmm2,XMMWORD PTR [rdx+rcx*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   4558f:	mov    rdx,QWORD PTR [rbp-0x48]
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   45593:	vfmadd231ps xmm2,xmm9,XMMWORD PTR [r9]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   45598:	vmovups XMMWORD PTR [r9],xmm2
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   4559d:	vmulps xmm2,xmm2,XMMWORD PTR [rdx+rcx*4]
   455a2:	mov    rdx,QWORD PTR [rbp-0x38]
   455a6:	mov    rcx,r10
   455a9:	and    rcx,0xfffffffffffffffc
   455ad:	add    rdx,rcx
   455b0:	vaddss xmm0,xmm0,xmm2
   455b4:	vshufps xmm10,xmm2,xmm2,0x55
   455b9:	vaddss xmm0,xmm0,xmm10
   455be:	vunpckhps xmm10,xmm2,xmm2
   455c2:	vshufps xmm2,xmm2,xmm2,0xff
   455c7:	vaddss xmm0,xmm0,xmm10
   455cc:	vaddss xmm0,xmm0,xmm2
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   455d0:	cmp    rcx,r10
   455d3:	je     45651 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x891>
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   455d5:	lea    rcx,[rsi+rdx*1]
   455d9:	vmulss xmm1,xmm13,DWORD PTR [r12+rdx*4]
   455df:	lea    r9,[rdx*4+0x0]
   455e7:	add    rcx,r11
   455ea:	lea    rcx,[r14+rcx*4]
   455ee:	vfmadd231ss xmm1,xmm3,DWORD PTR [rcx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   455f3:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   455f7:	lea    rcx,[rdx+0x1]
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   455fb:	vfmadd231ss xmm0,xmm1,DWORD PTR [rbx+rdx*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   45601:	cmp    r13,rcx
   45604:	jle    45651 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x891>
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   45606:	vmulss xmm1,xmm13,DWORD PTR [r12+r9*1+0x4]
   4560d:	add    rcx,rsi
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   45610:	add    rdx,0x2
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   45614:	add    rcx,r11
   45617:	lea    rcx,[r14+rcx*4]
   4561b:	vfmadd231ss xmm1,xmm3,DWORD PTR [rcx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   45620:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   45624:	vfmadd231ss xmm0,xmm1,DWORD PTR [rbx+r9*1+0x4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   4562b:	cmp    r13,rdx
   4562e:	jle    45651 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x891>
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   45630:	vmulss xmm13,xmm13,DWORD PTR [r12+r9*1+0x8]
   45637:	add    rdx,rsi
   4563a:	add    rdx,r11
   4563d:	lea    rdx,[r14+rdx*4]
   45641:	vfmadd231ss xmm13,xmm3,DWORD PTR [rdx]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   45646:	vmovss DWORD PTR [rdx],xmm13
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   4564a:	vfmadd231ss xmm0,xmm13,DWORD PTR [rbx+r9*1+0x8]
csrc/kernels/mlstm_core_scalar_c_rm.inc:49
   45651:	vmulss xmm0,xmm5,xmm0
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   45655:	add    rdi,0x4
   45659:	add    r8,0x4
   4565d:	add    rsi,r13
   45660:	add    rax,QWORD PTR [rbp-0x68]
csrc/kernels/mlstm_core_scalar_c_rm.inc:49
   45664:	vdivss xmm0,xmm0,xmm7
   45668:	vmovss DWORD PTR [r8-0x4],xmm0
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   4566e:	cmp    QWORD PTR [rbp-0x60],rdi
   45672:	jne    45480 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x6c0>
   45678:	vzeroupper 
csrc/kernels/mlstm_core_scalar_c_rm.inc:52
   4567b:	mov    rax,QWORD PTR [rbp-0xe8]
   45682:	mov    rsi,QWORD PTR [rbp-0xc8]
mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   45689:	mov    rdi,QWORD PTR [rbp-0x100]
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:52
   45690:	vmovss xmm7,DWORD PTR [rbp-0x94]
mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   45698:	add    QWORD PTR [rbp-0x60],rdi
   4569c:	mov    rdi,QWORD PTR [rbp-0xf8]
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:52
   456a3:	vmovss DWORD PTR [rax+rsi*4],xmm7
mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   456a8:	mov    rsi,QWORD PTR [rbp-0x108]
   456af:	add    QWORD PTR [rbp-0xa0],0x1
   456b7:	add    rbx,rdi
   456ba:	mov    rax,QWORD PTR [rbp-0xa0]
   456c1:	add    QWORD PTR [rbp-0x58],rdi
   456c5:	mov    rdi,QWORD PTR [rbp-0xe0]
   456cc:	add    QWORD PTR [rbp-0xb0],rsi
   456d3:	add    QWORD PTR [rbp-0x40],rdi
   456d7:	mov    rdi,QWORD PTR [rbp-0x110]
   456de:	add    QWORD PTR [rbp-0xa8],rdi
   456e5:	cmp    QWORD PTR [rbp-0x128],rax
   456ec:	jne    45100 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x340>
csrc/kernels/mlstm_core_scalar_c_rm.inc:75
   456f2:	add    QWORD PTR [rbp-0xc8],0x1
   456fa:	mov    r11,QWORD PTR [rbp-0x138]
   45701:	mov    rdi,QWORD PTR [rbp-0xf0]
   45708:	add    QWORD PTR [rbp-0x178],r13
   4570f:	add    QWORD PTR [rbp-0x170],rdi
   45716:	mov    rax,QWORD PTR [rbp-0xc8]
   4571d:	add    QWORD PTR [rbp-0x180],0x4
   45725:	add    r11,QWORD PTR [rbp-0x1c0]
   4572c:	add    QWORD PTR [rbp-0xd0],r13
   45733:	cmp    QWORD PTR [rbp-0x1b8],rax
   4573a:	jne    4503c <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x27c>
csrc/kernels/mlstm_core_scalar_c_rm.inc:74
   45740:	mov    rdi,QWORD PTR [rbp-0x1d0]
   45747:	add    QWORD PTR [rbp-0x168],0x1
   4574f:	mov    r11,r15
   45752:	add    QWORD PTR [rbp-0x188],rdi
   45759:	mov    rsi,QWORD PTR [rbp-0x1d8]
   45760:	mov    rdi,QWORD PTR [rbp-0x1e0]
   45767:	add    QWORD PTR [rbp-0x1b0],rsi
   4576e:	add    QWORD PTR [rbp-0x190],rdi
   45775:	mov    rax,QWORD PTR [rbp-0x168]
   4577c:	mov    rdi,QWORD PTR [rbp-0x1e8]
   45783:	add    QWORD PTR [rbp-0x198],rdi
   4578a:	mov    rdi,QWORD PTR [rbp-0xe0]
   45791:	add    QWORD PTR [rbp-0x1a0],rdi
   45798:	mov    rdi,QWORD PTR [rbp-0x1b8]
   4579f:	add    QWORD PTR [rbp-0x1a8],rdi
   457a6:	cmp    QWORD PTR [rbp-0x1f8],rax
   457ad:	jne    44fcc <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x20c>
csrc/kernels/mlstm_core_scalar_c_rm.inc:97
   457b3:	add    rsp,0x1e0
   457ba:	pop    rbx
   457bb:	pop    r10
   457bd:	pop    r12
   457bf:	pop    r13
   457c1:	pop    r14
   457c3:	pop    r15
   457c5:	pop    rbp
   457c6:	lea    rsp,[r10-0x8]
   457ca:	ret    
   457cb:	nop    DWORD PTR [rax+rax*1+0x0]
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:43
   457d0:	vmovaps xmm0,xmm8
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   457d4:	xor    edx,edx
   457d6:	cs nop WORD PTR [rax+rax*1+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   457e0:	vmulss xmm1,xmm13,DWORD PTR [r12+rdx*4]
   457e6:	vfmadd231ss xmm1,xmm3,DWORD PTR [rax+rdx*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   457ec:	vmovss DWORD PTR [rax+rdx*4],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   457f1:	vfmadd231ss xmm0,xmm1,DWORD PTR [rbx+rdx*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   457f7:	add    rdx,0x1
   457fb:	cmp    r13,rdx
   457fe:	jne    457e0 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa20>
   45800:	jmp    45651 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x891>
   45805:	nop    DWORD PTR [rax]
csrc/kernels/mlstm_core_scalar_c_rm.inc:43
   45808:	vmovaps xmm0,xmm8
   4580c:	jmp    45651 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x891>
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   45811:	mov    QWORD PTR [rbp-0x38],0x0
   45819:	mov    r10,r13
csrc/kernels/mlstm_core_scalar_c_rm.inc:43
   4581c:	vmovaps xmm0,xmm8
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   45820:	xor    ecx,ecx
   45822:	jmp    45575 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x7b5>
   45827:	mov    rdx,rcx
   4582a:	jmp    455d5 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x815>
std::exp(float)():
/usr/include/c++/11/cmath:223
   4582f:	vmovaps xmm0,xmm1
   45833:	vmovss DWORD PTR [rbp-0x70],xmm1
   45838:	call   b7b0 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   4583d:	call   b8c0 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:13
   45842:	vmovss xmm1,DWORD PTR [rbp-0x70]
   45847:	vsubss xmm0,xmm1,xmm0
   4584b:	jmp    45151 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x391>
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   45850:	mov    rdx,QWORD PTR [rbp-0xd8]
csrc/kernels/mlstm_core_scalar_c_rm.inc:30
   45857:	vmovaps xmm0,xmm8
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   4585b:	xor    eax,eax
   4585d:	nop    DWORD PTR [rax]
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   45860:	vmulss xmm1,xmm6,DWORD PTR [r12+rax*4]
   45866:	vfmadd231ss xmm1,xmm3,DWORD PTR [rdx+rax*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   4586c:	vmovss DWORD PTR [rdx+rax*4],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   45871:	vmulss xmm2,xmm5,DWORD PTR [rbx+rax*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   45876:	add    rax,0x1
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   4587a:	vfmadd231ss xmm0,xmm1,xmm2
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   4587f:	cmp    r13,rax
   45882:	jne    45860 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xaa0>
   45884:	jmp    453cc <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x60c>
   45889:	vmovss DWORD PTR [rbp-0x38],xmm8
   4588e:	jmp    453d9 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x619>
   45893:	vzeroupper 
   45896:	jmp    453cc <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x60c>
   4589b:	mov    rsi,r13
   4589e:	xor    eax,eax
csrc/kernels/mlstm_core_scalar_c_rm.inc:30
   458a0:	vmovaps xmm0,xmm8
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   458a4:	xor    edx,edx
   458a6:	jmp    452c5 <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x505>
   458ab:	vzeroupper 
   458ae:	jmp    4533e <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x57e>
   458b3:	vmovaps xmm0,xmm5
   458b7:	vmovss DWORD PTR [rbp-0x70],xmm6
   458bc:	vmovss DWORD PTR [rbp-0x38],xmm3
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   458c1:	call   bbf0 <sqrtf@plt>
   458c6:	vmovss xmm6,DWORD PTR [rbp-0x70]
   458cb:	vmovss xmm3,DWORD PTR [rbp-0x38]
   458d0:	vxorps xmm8,xmm8,xmm8
   458d5:	vmovaps xmm5,xmm0
   458d9:	jmp    451ae <mlstm_cpu::mlstm_core_sequence_compiler_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x3ee>

Disassembly of section .fini:

mlstm_cpu/_C.cpython-311-x86_64-linux-gnu.so:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .plt.sec:

Disassembly of section .text:

000000000002da00 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)>:
mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_avx2_c_rm_fused_r1.cpp:22
   2da00:	endbr64 
   2da04:	push   rbp
   2da05:	mov    rbp,rsp
   2da08:	push   r15
   2da0a:	push   r14
   2da0c:	push   r13
   2da0e:	push   r12
   2da10:	push   rbx
   2da11:	sub    rsp,0x118
csrc/include/avx2_recurrent.h:153
   2da18:	cmp    QWORD PTR [rbp+0x28],0x0
csrc/kernels/mlstm_core_avx2_c_rm_fused_r1.cpp:22
   2da1d:	mov    QWORD PTR [rbp-0x60],rdi
   2da21:	mov    QWORD PTR [rbp-0x68],rsi
   2da25:	mov    QWORD PTR [rbp-0x138],rdx
   2da2c:	mov    QWORD PTR [rbp-0x70],rcx
   2da30:	mov    QWORD PTR [rbp-0x78],r8
sequence_rows_avx2<1>():
csrc/include/avx2_recurrent.h:153
   2da34:	jle    2dd72 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x372>
   2da3a:	mov    rcx,QWORD PTR [rbp+0x40]
   2da3e:	imul   rcx,QWORD PTR [rbp+0x48]
   2da43:	cmp    QWORD PTR [rbp+0x38],0x0
   2da48:	jle    2dd72 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x372>
   2da4e:	cmp    QWORD PTR [rbp+0x30],0x0
   2da53:	jle    2dd72 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x372>
   2da59:	mov    rdi,QWORD PTR [rbp+0x38]
   2da5d:	mov    rdx,QWORD PTR [rbp+0x38]
   2da61:	vmovaps xmm3,xmm0
   2da65:	mov    QWORD PTR [rbp-0xf0],r9
   2da6c:	mov    QWORD PTR [rbp-0x108],0x0
   2da77:	mov    rax,QWORD PTR [rbp+0x38]
   2da7b:	imul   rdx,rcx
   2da7f:	shl    rdi,0x2
   2da83:	shl    rcx,0x2
   2da87:	mov    QWORD PTR [rbp-0x100],0x0
   2da92:	mov    QWORD PTR [rbp-0xd0],rdi
   2da99:	mov    rdi,QWORD PTR [rbp+0x18]
   2da9d:	imul   rax,QWORD PTR [rbp+0x40]
   2daa2:	mov    QWORD PTR [rbp-0x50],rcx
   2daa6:	mov    QWORD PTR [rbp-0x40],rdi
   2daaa:	mov    rcx,QWORD PTR [rbp+0x40]
   2daae:	lea    rdi,[rdx*4+0x0]
   2dab6:	mov    rdx,QWORD PTR [rbp+0x30]
   2daba:	mov    QWORD PTR [rbp-0x110],rdi
   2dac1:	mov    QWORD PTR [rbp-0xf8],0x0
   2dacc:	mov    QWORD PTR [rbp-0xd8],0x0
   2dad7:	imul   rdx,rax
   2dadb:	lea    rsi,[rdx*4+0x0]
   2dae3:	mov    QWORD PTR [rbp-0x118],rsi
   2daea:	mov    rsi,rax
   2daed:	shl    rax,0x2
   2daf1:	sub    rsi,rdx
   2daf4:	mov    rdx,QWORD PTR [rbp+0x38]
   2daf8:	imul   rdx,QWORD PTR [rbp+0x48]
   2dafd:	mov    QWORD PTR [rbp-0xe8],rax
   2db04:	lea    rdi,[rsi*4+0x0]
   2db0c:	mov    rsi,QWORD PTR [rbp+0x10]
   2db10:	mov    QWORD PTR [rbp-0x120],rdi
   2db17:	mov    rdi,QWORD PTR [rbp+0x30]
   2db1b:	mov    QWORD PTR [rbp-0x48],rsi
   2db1f:	mov    rsi,QWORD PTR [rbp+0x30]
   2db23:	lea    rax,[rdx*4+0x0]
   2db2b:	imul   rdi,QWORD PTR [rbp+0x38]
   2db30:	mov    QWORD PTR [rbp-0xe0],rax
   2db37:	imul   rsi,rdx
   2db3b:	mov    QWORD PTR [rbp-0x128],rdi
   2db42:	lea    rdi,[rsi*4+0x0]
   2db4a:	mov    rsi,QWORD PTR [rbp+0x48]
   2db4e:	mov    QWORD PTR [rbp-0x130],rdi
   2db55:	lea    rdi,[rcx*4+0x0]
   2db5d:	mov    QWORD PTR [rbp-0x58],rdi
   2db61:	lea    r10,[rsi*4+0x0]
   2db69:	mov    r13,r10
   2db6c:	nop    DWORD PTR [rax+0x0]
csrc/include/avx2_recurrent.h:154
   2db70:	mov    rbx,QWORD PTR [rbp-0x108]
   2db77:	mov    rax,QWORD PTR [rbp-0x138]
   2db7e:	xor    r12d,r12d
mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_avx2_c_rm_fused_r1.cpp:22
   2db81:	mov    rcx,QWORD PTR [rbp-0xf0]
   2db88:	add    rax,rbx
   2db8b:	add    rbx,QWORD PTR [rbp+0x20]
   2db8f:	mov    r11,rbx
   2db92:	mov    rbx,QWORD PTR [rbp-0x100]
   2db99:	mov    r15,rax
   2db9c:	mov    rax,r13
   2db9f:	mov    r13,r11
   2dba2:	lea    r10,[rbx*4+0x0]
   2dbaa:	mov    rbx,QWORD PTR [rbp-0xf8]
   2dbb1:	mov    r14,r10
   2dbb4:	nop    DWORD PTR [rax+0x0]
sequence_rows_avx2<1>():
csrc/include/avx2_recurrent.h:156
   2dbb8:	mov    rdi,QWORD PTR [rbp-0x48]
csrc/include/avx2_recurrent.h:158
   2dbbc:	mov    rsi,QWORD PTR [rbp-0x40]
   2dbc0:	mov    r9,r13
csrc/include/avx2_recurrent.h:156
   2dbc3:	mov    QWORD PTR [rbp-0x38],0x0
   2dbcb:	mov    rdx,QWORD PTR [rbp-0x78]
csrc/include/avx2_recurrent.h:158
   2dbcf:	vmovss xmm2,DWORD PTR [rsi+r12*4]
   2dbd5:	lea    r8,[rbx+rdi*1]
   2dbd9:	mov    rsi,QWORD PTR [rbp-0x60]
   2dbdd:	mov    rdi,QWORD PTR [rbp-0x70]
   2dbe1:	lea    r10,[rdx+r14*1]
   2dbe5:	mov    rdx,QWORD PTR [rbp-0x68]
   2dbe9:	lea    r11,[rdi+r14*1]
   2dbed:	lea    rdi,[rsi+rbx*1]
   2dbf1:	lea    rsi,[rdx+rbx*1]
   2dbf5:	mov    rdx,r15
   2dbf8:	nop    DWORD PTR [rax+rax*1+0x0]
   2dc00:	vmovss xmm1,DWORD PTR [r10]
   2dc05:	vmovss xmm0,DWORD PTR [r11]
   2dc0a:	push   QWORD PTR [rbp+0x48]
   2dc0d:	push   QWORD PTR [rbp+0x40]
   2dc10:	mov    QWORD PTR [rbp-0xc8],rax
   2dc17:	mov    QWORD PTR [rbp-0xb8],r9
   2dc1e:	mov    QWORD PTR [rbp-0xb0],r8
   2dc25:	mov    QWORD PTR [rbp-0xa8],rcx
   2dc2c:	mov    QWORD PTR [rbp-0xa0],r10
   2dc33:	mov    QWORD PTR [rbp-0x98],r11
   2dc3a:	mov    QWORD PTR [rbp-0x90],rdx
   2dc41:	mov    QWORD PTR [rbp-0x88],rsi
   2dc48:	mov    QWORD PTR [rbp-0x80],rdi
   2dc4c:	vmovss DWORD PTR [rbp-0xbc],xmm3
   2dc54:	call   2d2f0 <float mlstm_cpu::detail::step_state_rows_avx2<1>(float const*, float const*, float const*, float, float, float*, float*, float, float*, long, long, float)>
csrc/include/avx2_recurrent.h:156
   2dc59:	mov    rcx,QWORD PTR [rbp-0xd0]
   2dc60:	mov    r10,QWORD PTR [rbp-0xa0]
   2dc67:	mov    r11,QWORD PTR [rbp-0x98]
   2dc6e:	mov    rdi,QWORD PTR [rbp-0x80]
csrc/include/avx2_recurrent.h:158
   2dc72:	vmovaps xmm2,xmm0
csrc/include/avx2_recurrent.h:156
   2dc76:	add    r10,rcx
csrc/include/avx2_recurrent.h:158
   2dc79:	mov    rax,QWORD PTR [rbp-0x40]
csrc/include/avx2_recurrent.h:156
   2dc7d:	mov    rsi,QWORD PTR [rbp-0x88]
   2dc84:	add    r11,rcx
   2dc87:	mov    rcx,QWORD PTR [rbp-0xe8]
   2dc8e:	add    QWORD PTR [rbp-0x38],0x1
   2dc93:	mov    rdx,QWORD PTR [rbp-0x90]
   2dc9a:	mov    r9,QWORD PTR [rbp-0xb8]
csrc/include/avx2_recurrent.h:158
   2dca1:	vmovss DWORD PTR [rax+r12*4],xmm0
csrc/include/avx2_recurrent.h:156
   2dca7:	add    rdi,rcx
   2dcaa:	add    rsi,rcx
   2dcad:	mov    rcx,QWORD PTR [rbp-0xe0]
   2dcb4:	mov    rax,QWORD PTR [rbp-0x38]
   2dcb8:	vmovss xmm3,DWORD PTR [rbp-0xbc]
   2dcc0:	add    rdx,rcx
   2dcc3:	add    r9,rcx
   2dcc6:	cmp    QWORD PTR [rbp+0x30],rax
   2dcca:	pop    rcx
   2dccb:	mov    rax,QWORD PTR [rbp-0xc8]
   2dcd2:	pop    r8
   2dcd4:	mov    rcx,QWORD PTR [rbp-0xa8]
   2dcdb:	mov    r8,QWORD PTR [rbp-0xb0]
   2dce2:	jne    2dc00 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x200>
csrc/include/avx2_recurrent.h:154
   2dce8:	add    r12,0x1
   2dcec:	add    r15,rax
   2dcef:	add    r13,rax
   2dcf2:	add    rcx,QWORD PTR [rbp-0x50]
   2dcf6:	add    r14,0x4
   2dcfa:	add    rbx,QWORD PTR [rbp-0x58]
   2dcfe:	cmp    QWORD PTR [rbp+0x38],r12
   2dd02:	jne    2dbb8 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x1b8>
csrc/include/avx2_recurrent.h:153
   2dd08:	mov    rbx,QWORD PTR [rbp-0xd0]
   2dd0f:	add    QWORD PTR [rbp-0xd8],0x1
   2dd17:	mov    r13,rax
   2dd1a:	add    QWORD PTR [rbp-0x40],rbx
   2dd1e:	mov    rdi,QWORD PTR [rbp-0x118]
   2dd25:	mov    rbx,QWORD PTR [rbp-0x110]
   2dd2c:	mov    rsi,QWORD PTR [rbp-0x120]
   2dd33:	mov    rdx,QWORD PTR [rbp-0x128]
   2dd3a:	mov    rcx,QWORD PTR [rbp-0x130]
   2dd41:	add    QWORD PTR [rbp-0xf0],rbx
   2dd48:	mov    rax,QWORD PTR [rbp-0xd8]
   2dd4f:	add    QWORD PTR [rbp-0xf8],rdi
   2dd56:	add    QWORD PTR [rbp-0x48],rsi
   2dd5a:	add    QWORD PTR [rbp-0x100],rdx
   2dd61:	add    QWORD PTR [rbp-0x108],rcx
   2dd68:	cmp    QWORD PTR [rbp+0x28],rax
   2dd6c:	jne    2db70 <mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x170>
mlstm_cpu::mlstm_core_sequence_avx2_c_rm_fused_r1(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_avx2_c_rm_fused_r1.cpp:25
   2dd72:	lea    rsp,[rbp-0x28]
   2dd76:	pop    rbx
   2dd77:	pop    r12
   2dd79:	pop    r13
   2dd7b:	pop    r14
   2dd7d:	pop    r15
   2dd7f:	pop    rbp
   2dd80:	ret    

Disassembly of section .fini:

mlstm_cpu/_C.cpython-311-x86_64-linux-gnu.so:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .plt.sec:

Disassembly of section .text:

0000000000046f60 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)>:
mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   46f60:	endbr64 
   46f64:	push   r15
   46f66:	push   r14
   46f68:	push   r13
   46f6a:	push   r12
   46f6c:	push   rbp
   46f6d:	push   rbx
   46f6e:	sub    rsp,0x138
   46f75:	mov    r15,QWORD PTR [rsp+0x1a0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:73
   46f7d:	mov    rax,QWORD PTR [rsp+0x1a8]
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   46f85:	mov    QWORD PTR [rsp+0xf8],rdi
   46f8d:	mov    QWORD PTR [rsp+0x100],rsi
csrc/kernels/mlstm_core_scalar_c_rm.inc:73
   46f95:	imul   rax,r15
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   46f99:	mov    QWORD PTR [rsp+0x70],rdx
csrc/kernels/mlstm_core_scalar_c_rm.inc:74
   46f9e:	cmp    QWORD PTR [rsp+0x188],0x0
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   46fa7:	mov    QWORD PTR [rsp+0x108],rcx
   46faf:	mov    QWORD PTR [rsp+0x110],r8
   46fb7:	mov    QWORD PTR [rsp+0x118],r9
csrc/kernels/mlstm_core_scalar_c_rm.inc:73
   46fbf:	mov    QWORD PTR [rsp+0xd0],rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   46fc7:	vmovss DWORD PTR [rsp+0x64],xmm0
csrc/kernels/mlstm_core_scalar_c_rm.inc:74
   46fcd:	jle    47504 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5a4>
   46fd3:	cmp    QWORD PTR [rsp+0x198],0x0
   46fdc:	jle    47504 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5a4>
   46fe2:	cmp    QWORD PTR [rsp+0x190],0x0
   46feb:	jle    47504 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5a4>
   46ff1:	mov    rcx,QWORD PTR [rsp+0x1a8]
   46ff9:	mov    rdx,QWORD PTR [rsp+0x198]
   47001:	vxorps xmm0,xmm0,xmm0
   47005:	vxorps xmm7,xmm7,xmm7
   47009:	vcvtsi2ss xmm0,xmm0,r15
   4700e:	mov    QWORD PTR [rsp+0xc8],0x0
   4701a:	lea    r14,[r15*4+0x0]
   47022:	mov    QWORD PTR [rsp+0xc0],0x0
   4702e:	imul   rdx,r15
   47032:	imul   rax,QWORD PTR [rsp+0x198]
   4703b:	mov    QWORD PTR [rsp+0xb8],0x0
   47047:	mov    QWORD PTR [rsp+0xb0],0x0
   47053:	mov    QWORD PTR [rsp+0xa8],0x0
   4705f:	mov    QWORD PTR [rsp+0xd8],rax
   47067:	mov    rax,QWORD PTR [rsp+0x198]
   4706f:	imul   rax,QWORD PTR [rsp+0x190]
   47078:	vmovss DWORD PTR [rsp+0x60],xmm0
   4707e:	mov    QWORD PTR [rsp+0xa0],0x0
   4708a:	mov    QWORD PTR [rsp+0x78],0x0
   47093:	imul   rcx,rax
   47097:	mov    QWORD PTR [rsp+0xe0],rax
   4709f:	imul   rax,r15
   470a3:	mov    QWORD PTR [rsp+0xe8],rcx
   470ab:	lea    rcx,[rdx*4+0x0]
   470b3:	sub    rax,rdx
   470b6:	mov    QWORD PTR [rsp+0x40],rcx
   470bb:	shl    rax,0x2
   470bf:	mov    QWORD PTR [rsp+0xf0],rax
   470c7:	mov    rax,QWORD PTR [rsp+0x198]
   470cf:	shl    rax,0x2
   470d3:	mov    QWORD PTR [rsp+0x58],rax
   470d8:	mov    rax,QWORD PTR [rsp+0x1a8]
   470e0:	imul   rax,QWORD PTR [rsp+0x198]
   470e9:	mov    QWORD PTR [rsp+0x50],rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:75
   470ee:	mov    rax,QWORD PTR [rsp+0xb0]
   470f6:	mov    rbp,QWORD PTR [rsp+0x170]
   470fe:	mov    QWORD PTR [rsp+0x38],0x0
   47107:	mov    rcx,QWORD PTR [rsp+0xc0]
   4710f:	mov    rsi,QWORD PTR [rsp+0xb8]
   47117:	add    rbp,rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:72
   4711a:	mov    QWORD PTR [rsp+0x90],rax
   47122:	mov    rax,QWORD PTR [rsp+0xa8]
   4712a:	shl    rcx,0x2
   4712e:	mov    r12,rbp
   47131:	mov    QWORD PTR [rsp+0x98],rcx
   47139:	mov    rcx,QWORD PTR [rsp+0x178]
   47141:	mov    QWORD PTR [rsp+0x88],rax
   47149:	mov    rax,QWORD PTR [rsp+0xa0]
   47151:	lea    rcx,[rcx+rsi*4]
   47155:	mov    QWORD PTR [rsp+0x48],rcx
   4715a:	mov    rcx,QWORD PTR [rsp+0x100]
   47162:	mov    QWORD PTR [rsp+0x80],rax
   4716a:	mov    rax,QWORD PTR [rsp+0xc8]
   47172:	add    rcx,rax
   47175:	mov    QWORD PTR [rsp+0x128],rcx
   4717d:	mov    rcx,QWORD PTR [rsp+0xf8]
   47185:	add    rax,rcx
   47188:	mov    QWORD PTR [rsp+0x120],rax
csrc/kernels/mlstm_core_scalar_c_rm.inc:79
   47190:	mov    rax,QWORD PTR [rsp+0x48]
   47195:	mov    rcx,QWORD PTR [rsp+0x38]
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   4719a:	mov    QWORD PTR [rsp+0x10],0x0
   471a3:	mov    rsi,QWORD PTR [rsp+0x98]
   471ab:	mov    r13,QWORD PTR [rsp+0x128]
csrc/kernels/mlstm_core_scalar_c_rm.inc:79
   471b3:	vmovss xmm4,DWORD PTR [rax+rcx*4]
   471b8:	mov    rax,QWORD PTR [rsp+0x110]
   471c0:	mov    rbp,QWORD PTR [rsp+0x120]
   471c8:	mov    rbx,QWORD PTR [rsp+0x88]
   471d0:	add    rax,rsi
   471d3:	vmovss DWORD PTR [rsp+0xc],xmm4
   471d9:	mov    QWORD PTR [rsp+0x20],rax
   471de:	mov    rax,QWORD PTR [rsp+0x108]
   471e6:	add    rax,rsi
   471e9:	mov    rsi,QWORD PTR [rsp+0x80]
   471f1:	mov    QWORD PTR [rsp+0x18],rax
   471f6:	mov    rax,QWORD PTR [rsp+0x90]
   471fe:	add    r13,rax
   47201:	add    rbp,rax
   47204:	mov    rax,QWORD PTR [rsp+0x118]
   4720c:	lea    rax,[rax+rsi*4]
   47210:	mov    QWORD PTR [rsp+0x68],rax
   47215:	mov    rax,r12
   47218:	mov    r12,r14
   4721b:	mov    r14,rbp
   4721e:	mov    rbp,r13
   47221:	mov    r13,rax
   47224:	nop    DWORD PTR [rax+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   47228:	mov    rax,QWORD PTR [rsp+0x20]
   4722d:	vmovss xmm1,DWORD PTR [rax]
   47231:	mov    rax,QWORD PTR [rsp+0x18]
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   47236:	vcomiss xmm1,xmm7
mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   4723a:	vmovss xmm4,DWORD PTR [rax]
   4723e:	vmovss DWORD PTR [rsp+0x28],xmm4
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   47244:	jb     47516 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5b6>
csrc/include/stable_math.h:11
   4724a:	vxorps xmm0,xmm1,XMMWORD PTR [rip+0x56ee]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
std::exp(float)():
/usr/include/c++/11/cmath:223
   47252:	call   b7b0 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   47257:	call   b8c0 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:11
   4725c:	vxorps xmm0,xmm0,XMMWORD PTR [rip+0x56dc]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:25
   47264:	vaddss xmm0,xmm0,DWORD PTR [rsp+0xc]
float const& std::max<float>(float const&, float const&)():
/usr/include/c++/11/bits/stl_algobase.h:261
   4726a:	vmovss xmm7,DWORD PTR [rsp+0x28]
   47270:	vmaxss xmm6,xmm7,xmm0
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:26
   47274:	vsubss xmm0,xmm0,xmm6
   47278:	vmovss DWORD PTR [rsp+0xc],xmm6
std::exp(float)():
/usr/include/c++/11/cmath:223
   4727e:	call   b7b0 <expf@plt>
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:27
   47283:	vmovss xmm7,DWORD PTR [rsp+0x28]
std::exp(float)():
/usr/include/c++/11/cmath:223
   47289:	vmovss DWORD PTR [rsp+0x2c],xmm0
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:27
   4728f:	vsubss xmm0,xmm7,DWORD PTR [rsp+0xc]
std::exp(float)():
/usr/include/c++/11/cmath:223
   47295:	call   b7b0 <expf@plt>
   4729a:	vmovss xmm6,DWORD PTR [rsp+0x60]
   472a0:	vxorps xmm7,xmm7,xmm7
   472a4:	vmovss xmm2,DWORD PTR [rsp+0x2c]
   472aa:	vmovaps xmm5,xmm0
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   472ae:	vucomiss xmm7,xmm6
   472b2:	ja     47544 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5e4>
   472b8:	vsqrtss xmm4,xmm6,xmm6
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   472bc:	vmovss xmm6,DWORD PTR [rip+0x569c]        # 4c960 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x80>
   472c4:	vdivss xmm4,xmm6,xmm4
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   472c8:	test   r15,r15
   472cb:	jle    47539 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5d9>
csrc/kernels/mlstm_core_scalar_c_rm.inc:30
   472d1:	vmovaps xmm1,xmm7
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   472d5:	xor    eax,eax
   472d7:	nop    WORD PTR [rax+rax*1+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:32
   472e0:	vmulss xmm0,xmm5,DWORD PTR [rbp+rax*4+0x0]
   472e6:	vfmadd231ss xmm0,xmm2,DWORD PTR [r13+rax*4+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:33
   472ed:	vmovss DWORD PTR [r13+rax*4+0x0],xmm0
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   472f4:	vmulss xmm3,xmm4,DWORD PTR [r14+rax*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   472fa:	add    rax,0x1
csrc/kernels/mlstm_core_scalar_c_rm.inc:34
   472fe:	vfmadd231ss xmm1,xmm0,xmm3
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   47303:	cmp    r15,rax
   47306:	jne    472e0 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x380>
std::abs(float)():
/usr/include/c++/11/bits/std_abs.h:76
   47308:	vandps xmm6,xmm1,XMMWORD PTR [rip+0x5640]        # 4c950 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x70>
   47310:	vmovss DWORD PTR [rsp+0x28],xmm6
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:38
   47316:	vmovss xmm7,DWORD PTR [rsp+0xc]
   4731c:	vxorps xmm0,xmm7,XMMWORD PTR [rip+0x561c]        # 4c940 <pybind11::detail::function_record_PyTypeObject_methods::tp_plainname_impl+0x60>
   47324:	vmovss DWORD PTR [rsp+0x34],xmm4
   4732a:	vmovss DWORD PTR [rsp+0x30],xmm5
   47330:	vmovss DWORD PTR [rsp+0x2c],xmm2
std::exp(float)():
/usr/include/c++/11/cmath:223
   47336:	call   b7b0 <expf@plt>
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   4733b:	vmovss xmm2,DWORD PTR [rsp+0x2c]
float const& std::max<float>(float const&, float const&)():
/usr/include/c++/11/bits/stl_algobase.h:261
   47341:	vmaxss xmm6,xmm0,DWORD PTR [rsp+0x28]
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   47347:	vxorps xmm7,xmm7,xmm7
   4734b:	cmp    QWORD PTR [rsp+0x1a8],0x0
csrc/kernels/mlstm_core_scalar_c_rm.inc:38
   47354:	vaddss xmm6,xmm6,DWORD PTR [rsp+0x64]
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   4735a:	vmovss xmm5,DWORD PTR [rsp+0x30]
   47360:	vmovss xmm4,DWORD PTR [rsp+0x34]
   47366:	jle    473ee <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x48e>
   4736c:	mov    rax,QWORD PTR [rsp+0x1a8]
   47374:	mov    rsi,QWORD PTR [rsp+0x70]
   47379:	lea    r8,[rbx*4+0x0]
   47381:	mov    rdx,QWORD PTR [rsp+0x68]
   47386:	add    rax,rbx
   47389:	lea    rdi,[r8+rsi*1]
   4738d:	add    r8,QWORD PTR [rsp+0x180]
   47395:	lea    r10,[rsi+rax*4]
   47399:	nop    DWORD PTR [rax+0x0]
csrc/kernels/mlstm_core_scalar_c_rm.inc:41
   473a0:	vmulss xmm3,xmm5,DWORD PTR [rdi]
csrc/kernels/mlstm_core_scalar_c_rm.inc:43
   473a4:	vmovaps xmm1,xmm7
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   473a8:	test   r15,r15
   473ab:	jle    473d0 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x470>
   473ad:	xor    eax,eax
   473af:	nop
csrc/kernels/mlstm_core_scalar_c_rm.inc:45
   473b0:	vmulss xmm0,xmm3,DWORD PTR [rbp+rax*4+0x0]
   473b6:	vfmadd231ss xmm0,xmm2,DWORD PTR [rdx+rax*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:46
   473bc:	vmovss DWORD PTR [rdx+rax*4],xmm0
csrc/kernels/mlstm_core_scalar_c_rm.inc:47
   473c1:	vfmadd231ss xmm1,xmm0,DWORD PTR [r14+rax*4]
csrc/kernels/mlstm_core_scalar_c_rm.inc:44
   473c7:	add    rax,0x1
   473cb:	cmp    r15,rax
   473ce:	jne    473b0 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x450>
csrc/kernels/mlstm_core_scalar_c_rm.inc:49
   473d0:	vmulss xmm1,xmm4,xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   473d4:	add    rdi,0x4
   473d8:	add    r8,0x4
   473dc:	add    rdx,r12
csrc/kernels/mlstm_core_scalar_c_rm.inc:49
   473df:	vdivss xmm1,xmm1,xmm6
   473e3:	vmovss DWORD PTR [r8-0x4],xmm1
csrc/kernels/mlstm_core_scalar_c_rm.inc:40
   473e9:	cmp    r10,rdi
   473ec:	jne    473a0 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x440>
csrc/kernels/mlstm_core_scalar_c_rm.inc:52
   473ee:	mov    rax,QWORD PTR [rsp+0x48]
   473f3:	mov    rcx,QWORD PTR [rsp+0x38]
   473f8:	vmovss xmm4,DWORD PTR [rsp+0xc]
mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   473fe:	mov    rsi,QWORD PTR [rsp+0x58]
   47403:	add    QWORD PTR [rsp+0x10],0x1
   47409:	add    rbx,QWORD PTR [rsp+0x50]
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:52
   4740e:	vmovss DWORD PTR [rax+rcx*4],xmm4
mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/mlstm_core_scalar_c_rm.inc:77
   47413:	mov    rcx,QWORD PTR [rsp+0x40]
   47418:	mov    rax,QWORD PTR [rsp+0x10]
   4741d:	add    QWORD PTR [rsp+0x20],rsi
   47422:	add    QWORD PTR [rsp+0x18],rsi
   47427:	add    rbp,rcx
   4742a:	add    r14,rcx
   4742d:	cmp    QWORD PTR [rsp+0x190],rax
   47435:	jne    47228 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x2c8>
   4743b:	mov    r14,r12
   4743e:	mov    r12,r13
csrc/kernels/mlstm_core_scalar_c_rm.inc:75
   47441:	mov    rsi,QWORD PTR [rsp+0xd0]
   47449:	add    QWORD PTR [rsp+0x38],0x1
   4744f:	add    QWORD PTR [rsp+0x80],rsi
   47457:	mov    rax,QWORD PTR [rsp+0x38]
   4745c:	add    r12,r14
   4745f:	mov    rsi,QWORD PTR [rsp+0x1a8]
   47467:	add    QWORD PTR [rsp+0x90],r14
   4746f:	add    QWORD PTR [rsp+0x88],rsi
   47477:	add    QWORD PTR [rsp+0x98],0x4
   47480:	cmp    QWORD PTR [rsp+0x198],rax
   47488:	jne    47190 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x230>
csrc/kernels/mlstm_core_scalar_c_rm.inc:74
   4748e:	mov    rsi,QWORD PTR [rsp+0xd8]
   47496:	add    QWORD PTR [rsp+0x78],0x1
   4749c:	add    QWORD PTR [rsp+0xa0],rsi
   474a4:	mov    rax,QWORD PTR [rsp+0x78]
   474a9:	mov    rsi,QWORD PTR [rsp+0xe8]
   474b1:	add    QWORD PTR [rsp+0xa8],rsi
   474b9:	mov    rsi,QWORD PTR [rsp+0x40]
   474be:	add    QWORD PTR [rsp+0xb0],rsi
   474c6:	mov    rsi,QWORD PTR [rsp+0x198]
   474ce:	add    QWORD PTR [rsp+0xb8],rsi
   474d6:	mov    rsi,QWORD PTR [rsp+0xe0]
   474de:	add    QWORD PTR [rsp+0xc0],rsi
   474e6:	mov    rsi,QWORD PTR [rsp+0xf0]
   474ee:	add    QWORD PTR [rsp+0xc8],rsi
   474f6:	cmp    QWORD PTR [rsp+0x188],rax
   474fe:	jne    470ee <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x18e>
csrc/kernels/mlstm_core_scalar_c_rm.inc:97
   47504:	add    rsp,0x138
   4750b:	pop    rbx
   4750c:	pop    rbp
   4750d:	pop    r12
   4750f:	pop    r13
   47511:	pop    r14
   47513:	pop    r15
   47515:	ret    
std::exp(float)():
/usr/include/c++/11/cmath:223
   47516:	vmovaps xmm0,xmm1
   4751a:	vmovss DWORD PTR [rsp+0x2c],xmm1
   47520:	call   b7b0 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   47525:	call   b8c0 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:13
   4752a:	vmovss xmm1,DWORD PTR [rsp+0x2c]
   47530:	vsubss xmm0,xmm1,xmm0
   47534:	jmp    47264 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x304>
step_state():
csrc/kernels/mlstm_core_scalar_c_rm.inc:31
   47539:	vmovss DWORD PTR [rsp+0x28],xmm7
   4753f:	jmp    47316 <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x3b6>
   47544:	vmovaps xmm0,xmm6
   47548:	vmovss DWORD PTR [rsp+0x2c],xmm5
   4754e:	vmovss DWORD PTR [rsp+0x28],xmm2
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   47554:	call   bbf0 <sqrtf@plt>
   47559:	vmovss xmm5,DWORD PTR [rsp+0x2c]
   4755f:	vmovss xmm2,DWORD PTR [rsp+0x28]
   47565:	vxorps xmm7,xmm7,xmm7
   47569:	vmovaps xmm4,xmm0
   4756d:	jmp    472bc <mlstm_cpu::mlstm_core_sequence_scalar_c_rm_reference(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x35c>

Disassembly of section .fini:

mlstm_cpu/_C_fastmath.cpython-311-x86_64-linux-gnu.so:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .plt.sec:

Disassembly of section .text:

0000000000022f50 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)>:
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:72
   22f50:	endbr64 
   22f54:	lea    r10,[rsp+0x8]
   22f59:	and    rsp,0xffffffffffffffe0
   22f5d:	push   QWORD PTR [r10-0x8]
   22f61:	mov    rax,r10
   22f64:	push   rbp
   22f65:	mov    rbp,rsp
   22f68:	push   r15
   22f6a:	push   r14
   22f6c:	push   r13
   22f6e:	push   r12
   22f70:	push   r10
   22f72:	push   rbx
   22f73:	sub    rsp,0x1e0
   22f7a:	mov    QWORD PTR [rbp-0x48],rdi
   22f7e:	mov    rdi,QWORD PTR [r10+0x8]
   22f82:	mov    rbx,QWORD PTR [rax+0x20]
   22f86:	mov    r11,QWORD PTR [rax+0x30]
   22f8a:	mov    QWORD PTR [rbp-0x50],rsi
   22f8e:	mov    QWORD PTR [rbp-0x1e8],rdi
   22f95:	mov    rdi,QWORD PTR [r10+0x10]
   22f99:	mov    QWORD PTR [rbp-0x118],rcx
   22fa0:	mov    QWORD PTR [rbp-0x150],rdi
   22fa7:	mov    rdi,QWORD PTR [rax+0x28]
   22fab:	mov    rax,QWORD PTR [rax+0x38]
   22faf:	mov    QWORD PTR [rbp-0x120],r8
   22fb6:	mov    r8,QWORD PTR [r10]
   22fb9:	mov    r10,QWORD PTR [r10+0x18]
   22fbd:	mov    QWORD PTR [rbp-0x148],rdx
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:73
   22fc4:	mov    rcx,rax
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:72
   22fc7:	mov    QWORD PTR [rbp-0x128],rbx
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:73
   22fce:	imul   rcx,r11
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:72
   22fd2:	mov    QWORD PTR [rbp-0xc0],r8
   22fd9:	mov    QWORD PTR [rbp-0x1f0],r10
   22fe0:	mov    QWORD PTR [rbp-0x1b0],rdi
   22fe7:	mov    QWORD PTR [rbp-0xf0],rax
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:73
   22fee:	mov    QWORD PTR [rbp-0x1b8],rcx
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:72
   22ff5:	vmovss DWORD PTR [rbp-0xb8],xmm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:74
   22ffd:	test   r10,r10
   23000:	jle    238d0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x980>
   23006:	test   rdi,rdi
   23009:	jle    238d0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x980>
   2300f:	mov    r10,rbx
   23012:	test   rbx,rbx
   23015:	jle    238d0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x980>
   2301b:	mov    rbx,rdi
   2301e:	imul   rcx,rdi
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   23022:	vxorps xmm0,xmm0,xmm0
   23026:	mov    r13,r11
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   23029:	mov    QWORD PTR [rbp-0x1a8],0x0
   23034:	imul   rdi,r10
   23038:	mov    QWORD PTR [rbp-0x1a0],0x0
mlstm_cpu::inv_sqrt_dim(long)():
csrc/include/stable_math.h:17
   23043:	vcvtsi2ss xmm0,xmm0,r11
   23048:	mov    QWORD PTR [rbp-0x1c8],rcx
   2304f:	mov    rcx,rax
   23052:	imul   rax,rdi
   23056:	mov    QWORD PTR [rbp-0x1d0],rdi
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   2305d:	mov    QWORD PTR [rbp-0x198],0x0
   23068:	imul   rdi,r11
   2306c:	mov    QWORD PTR [rbp-0x190],0x0
   23077:	vrsqrtss xmm1,xmm0,xmm0
   2307b:	mov    QWORD PTR [rbp-0x1d8],rax
   23082:	mov    rax,rbx
   23085:	imul   rax,r11
   23089:	mov    QWORD PTR [rbp-0x1e0],rdi
   23090:	mov    rdi,rbx
   23093:	mov    rbx,rcx
   23096:	vmulss xmm0,xmm1,xmm0
   2309a:	imul   rcx,rdi
   2309e:	lea    rbx,[rdx+rbx*4]
   230a2:	mov    QWORD PTR [rbp-0x188],0x0
   230ad:	vfmadd213ss xmm0,xmm1,DWORD PTR [rip+0x39d2]        # 26a88 <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0xe8>
   230b6:	mov    QWORD PTR [rbp-0x1c0],rbx
   230bd:	mov    QWORD PTR [rbp-0xe0],rax
   230c4:	shl    rax,0x2
   230c8:	mov    QWORD PTR [rbp-0x100],rax
   230cf:	mov    rax,rdi
   230d2:	shl    rax,0x2
   230d6:	mov    QWORD PTR [rbp-0x110],rcx
   230dd:	shl    rcx,0x2
   230e1:	mov    QWORD PTR [rbp-0xf8],rax
   230e8:	lea    rax,[r11-0x1]
   230ec:	vmulss xmm1,xmm1,DWORD PTR [rip+0x3998]        # 26a8c <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0xec>
   230f4:	mov    QWORD PTR [rbp-0x78],rax
   230f8:	mov    rax,r11
   230fb:	shr    rax,0x3
   230ff:	mov    QWORD PTR [rbp-0x108],rcx
   23106:	mov    QWORD PTR [rbp-0x180],0x0
   23111:	shl    rax,0x5
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:74
   23115:	mov    QWORD PTR [rbp-0x160],0x0
   23120:	mov    r14,rax
   23123:	mov    rax,r11
std::sqrt(float)():
/usr/include/c++/11/cmath:464
   23126:	vmulss xmm7,xmm0,xmm1
   2312a:	and    rax,0xfffffffffffffff8
   2312e:	mov    QWORD PTR [rbp-0x80],rax
   23132:	lea    rax,[r11*4+0x0]
   2313a:	mov    QWORD PTR [rbp-0x68],rax
   2313e:	lea    rax,[rsi+0x4]
   23142:	mov    QWORD PTR [rbp-0x200],rax
   23149:	lea    rax,[r8+0x20]
   2314d:	mov    QWORD PTR [rbp-0x1f8],rax
   23154:	mov    rax,r11
   23157:	mov    r11,r14
   2315a:	mov    r14,r9
   2315d:	and    eax,0x7
   23160:	vmovss DWORD PTR [rbp-0x98],xmm7
   23168:	mov    QWORD PTR [rbp-0x88],rax
   2316f:	sub    rax,0x1
   23173:	mov    QWORD PTR [rbp-0x90],rax
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:75
   2317a:	mov    rax,QWORD PTR [rbp-0x1a8]
   23181:	mov    rsi,QWORD PTR [rbp-0x1a0]
   23188:	mov    QWORD PTR [rbp-0xc8],0x0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:72
   23193:	mov    r15,QWORD PTR [rbp-0x180]
   2319a:	shl    rax,0x2
   2319e:	mov    QWORD PTR [rbp-0x178],rax
   231a5:	mov    rax,QWORD PTR [rbp-0x1e8]
   231ac:	lea    rax,[rax+rsi*4]
   231b0:	mov    QWORD PTR [rbp-0xe8],rax
   231b7:	mov    rax,QWORD PTR [rbp-0x198]
   231be:	mov    QWORD PTR [rbp-0xd0],rax
   231c5:	mov    rax,QWORD PTR [rbp-0x190]
   231cc:	mov    QWORD PTR [rbp-0x170],rax
   231d3:	mov    rax,QWORD PTR [rbp-0x188]
   231da:	mov    QWORD PTR [rbp-0x168],rax
   231e1:	mov    rax,r15
   231e4:	mov    r15,r11
   231e7:	mov    r11,rax
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:77
   231ea:	mov    rax,QWORD PTR [rbp-0xd0]
   231f1:	mov    rbx,QWORD PTR [rbp-0x48]
   231f5:	mov    QWORD PTR [rbp-0xa0],0x0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:79
   23200:	mov    rdi,QWORD PTR [rbp-0xc8]
   23207:	mov    rcx,QWORD PTR [rbp-0x170]
   2320e:	mov    QWORD PTR [rbp-0x130],r11
   23215:	lea    rsi,[rax*4+0x0]
   2321d:	mov    rax,QWORD PTR [rbp-0xe8]
   23224:	mov    QWORD PTR [rbp-0x158],rsi
   2322b:	vmovss xmm6,DWORD PTR [rax+rdi*4]
   23230:	mov    rdi,QWORD PTR [rbp-0x168]
   23237:	mov    QWORD PTR [rbp-0x40],rcx
   2323b:	mov    rax,QWORD PTR [rbp-0x1c0]
   23242:	mov    QWORD PTR [rbp-0xb0],rdi
   23249:	lea    rax,[rax+rdi*4]
   2324d:	vmovss DWORD PTR [rbp-0x94],xmm6
   23255:	mov    QWORD PTR [rbp-0x60],rax
   23259:	lea    rax,[rcx*4+0x0]
   23261:	add    rbx,rax
   23264:	add    rax,QWORD PTR [rbp-0x200]
   2326b:	mov    QWORD PTR [rbp-0x58],rax
   2326f:	mov    rax,rsi
   23272:	add    rsi,QWORD PTR [rbp-0xc0]
   23279:	mov    QWORD PTR [rbp-0xd8],rsi
   23280:	mov    rsi,QWORD PTR [rbp-0x1f8]
   23287:	add    rsi,rax
   2328a:	lea    rax,[r14+r11*4]
   2328e:	mov    QWORD PTR [rbp-0x138],rax
   23295:	mov    rax,QWORD PTR [rbp-0x178]
   2329c:	mov    QWORD PTR [rbp-0x140],rsi
   232a3:	mov    QWORD PTR [rbp-0xa8],rax
   232aa:	nop    WORD PTR [rax+rax*1+0x0]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   232b0:	mov    rax,QWORD PTR [rbp-0xa8]
   232b7:	mov    rsi,QWORD PTR [rbp-0x120]
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   232be:	vxorps xmm4,xmm4,xmm4
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   232c2:	vmovss xmm1,DWORD PTR [rsi+rax*1]
   232c7:	mov    rsi,QWORD PTR [rbp-0x118]
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   232ce:	vcomiss xmm1,xmm4
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:79 (discriminator 3)
   232d2:	vmovss xmm7,DWORD PTR [rsi+rax*1]
   232d7:	mov    rax,QWORD PTR [rbp-0x58]
   232db:	vmovss DWORD PTR [rbp-0x38],xmm7
   232e0:	lea    r12,[rax-0x4]
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:10 (discriminator 3)
   232e4:	jb     2394f <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9ff>
csrc/include/stable_math.h:11
   232ea:	vxorps xmm0,xmm1,XMMWORD PTR [rip+0x37ae]        # 26aa0 <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0x100>
std::exp(float)():
/usr/include/c++/11/cmath:223
   232f2:	call   9660 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   232f7:	call   9750 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:11
   232fc:	vxorps xmm0,xmm0,XMMWORD PTR [rip+0x379c]        # 26aa0 <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0x100>
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:25
   23304:	vaddss xmm0,xmm0,DWORD PTR [rbp-0x94]
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:26
   2330c:	vmaxss xmm7,xmm0,DWORD PTR [rbp-0x38]
   23311:	vsubss xmm0,xmm0,xmm7
   23315:	vmovss DWORD PTR [rbp-0x94],xmm7
std::exp(float)():
/usr/include/c++/11/cmath:223
   2331d:	call   9660 <expf@plt>
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:27
   23322:	vmovss xmm6,DWORD PTR [rbp-0x38]
std::exp(float)():
/usr/include/c++/11/cmath:223
   23327:	vmovss DWORD PTR [rbp-0x70],xmm0
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:27
   2332c:	vsubss xmm0,xmm6,DWORD PTR [rbp-0x94]
std::exp(float)():
/usr/include/c++/11/cmath:223
   23334:	call   9660 <expf@plt>
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   23339:	test   r13,r13
   2333c:	vmovss xmm5,DWORD PTR [rbp-0x70]
std::exp(float)():
/usr/include/c++/11/cmath:223
   23341:	vmovaps xmm9,xmm0
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   23345:	jle    239b1 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa61>
   2334b:	mov    rdi,QWORD PTR [rbp-0xd8]
   23352:	lea    rax,[rbx+0x20]
   23356:	cmp    rdi,rax
   23359:	setae  al
   2335c:	cmp    rbx,QWORD PTR [rbp-0x140]
   23363:	setae  dl
   23366:	or     eax,edx
   23368:	mov    rdx,rdi
   2336b:	sub    rdx,QWORD PTR [rbp-0x58]
   2336f:	cmp    rdx,0x18
   23373:	seta   dl
   23376:	test   al,dl
   23378:	je     23970 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa20>
   2337e:	mov    rax,QWORD PTR [rbp-0x78]
   23382:	cmp    rax,0x2
   23386:	jbe    23970 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa20>
   2338c:	cmp    rax,0x6
   23390:	jbe    239c5 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa75>
   23396:	vbroadcastss ymm7,xmm5
   2339b:	vbroadcastss ymm6,xmm0
   233a0:	xor    eax,eax
   233a2:	mov    rdx,rdi
   233a5:	vbroadcastss ymm4,DWORD PTR [rbp-0x98]
   233ae:	vxorps xmm1,xmm1,xmm1
   233b2:	nop    WORD PTR [rax+rax*1+0x0]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   233b8:	vmulps ymm0,ymm6,YMMWORD PTR [r12+rax*1]
   233be:	vfmadd231ps ymm0,ymm7,YMMWORD PTR [rdx+rax*1]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:33
   233c4:	vmovups YMMWORD PTR [rdx+rax*1],ymm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   233c9:	vmulps ymm3,ymm4,YMMWORD PTR [rbx+rax*1]
   233ce:	add    rax,0x20
   233d2:	vfmadd231ps ymm1,ymm0,ymm3
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   233d7:	cmp    r15,rax
   233da:	jne    233b8 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x468>
   233dc:	vextractf128 xmm0,ymm1,0x1
   233e2:	mov    rdx,QWORD PTR [rbp-0x80]
   233e6:	vaddps xmm1,xmm0,xmm1
   233ea:	mov    rax,rdx
   233ed:	vmovhlps xmm0,xmm1,xmm1
   233f1:	vaddps xmm0,xmm0,xmm1
   233f5:	vshufps xmm1,xmm0,xmm0,0x55
   233fa:	vaddps xmm0,xmm1,xmm0
   233fe:	cmp    r13,rdx
   23401:	je     239bd <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa6d>
   23407:	cmp    QWORD PTR [rbp-0x90],0x2
   2340f:	mov    rsi,QWORD PTR [rbp-0x88]
   23416:	jbe    239d5 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa85>
   2341c:	vzeroupper 
   2341f:	mov    rdi,QWORD PTR [rbp-0xd0]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   23426:	vshufps xmm4,xmm9,xmm9,0x0
   2342c:	vshufps xmm3,xmm5,xmm5,0x0
   23431:	vbroadcastss xmm1,DWORD PTR [rbp-0x98]
   2343a:	lea    rcx,[rax+rdi*1]
   2343e:	mov    rdi,QWORD PTR [rbp-0xc0]
   23445:	add    rax,QWORD PTR [rbp-0x40]
   23449:	lea    rcx,[rdi+rcx*4]
   2344d:	mov    rdi,QWORD PTR [rbp-0x50]
   23451:	vmulps xmm4,xmm4,XMMWORD PTR [rdi+rax*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   23456:	mov    rdi,QWORD PTR [rbp-0x48]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   2345a:	vfmadd132ps xmm3,xmm4,XMMWORD PTR [rcx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:33
   2345f:	vmovups XMMWORD PTR [rcx],xmm3
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   23463:	vmulps xmm1,xmm1,XMMWORD PTR [rdi+rax*4]
   23468:	mov    rax,rsi
   2346b:	and    rax,0xfffffffffffffffc
   2346f:	add    rdx,rax
   23472:	vmulps xmm1,xmm1,xmm3
   23476:	vmovhlps xmm3,xmm1,xmm1
   2347a:	vaddps xmm3,xmm3,xmm1
   2347e:	vshufps xmm1,xmm3,xmm3,0x55
   23483:	vaddps xmm1,xmm1,xmm3
   23487:	vaddss xmm0,xmm0,xmm1
   2348b:	cmp    rax,rsi
   2348e:	je     2352a <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5da>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   23494:	mov    rsi,QWORD PTR [rbp-0x158]
   2349b:	mov    rdi,QWORD PTR [rbp-0xc0]
   234a2:	lea    rax,[rdx*4+0x0]
   234aa:	vmulss xmm1,xmm9,DWORD PTR [r12+rdx*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   234b0:	vmovss xmm4,DWORD PTR [rbp-0x98]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   234b8:	lea    rcx,[rax+rsi*1]
   234bc:	add    rcx,rdi
   234bf:	vfmadd231ss xmm1,xmm5,DWORD PTR [rcx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:33
   234c4:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   234c8:	vmulss xmm3,xmm4,DWORD PTR [rbx+rdx*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   234cd:	lea    rcx,[rdx+0x1]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   234d1:	vfmadd231ss xmm0,xmm1,xmm3
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   234d6:	cmp    r13,rcx
   234d9:	jle    2352a <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5da>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   234db:	lea    rcx,[rax+rsi*1+0x4]
   234e0:	vmulss xmm1,xmm9,DWORD PTR [r12+rax*1+0x4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   234e7:	add    rdx,0x2
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   234eb:	add    rcx,rdi
   234ee:	vfmadd231ss xmm1,xmm5,DWORD PTR [rcx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:33
   234f3:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   234f7:	vmulss xmm3,xmm4,DWORD PTR [rax+rbx*1+0x4]
   234fd:	vfmadd231ss xmm0,xmm3,xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   23502:	cmp    r13,rdx
   23505:	jle    2352a <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5da>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   23507:	lea    rdx,[rax+rsi*1+0x8]
   2350c:	vmulss xmm1,xmm9,DWORD PTR [r12+rax*1+0x8]
   23513:	add    rdx,rdi
   23516:	vfmadd231ss xmm1,xmm5,DWORD PTR [rdx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:33
   2351b:	vmovss DWORD PTR [rdx],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   2351f:	vmulss xmm3,xmm4,DWORD PTR [rax+rbx*1+0x8]
   23525:	vfmadd231ss xmm0,xmm1,xmm3
std::abs(float)():
/usr/include/c++/11/bits/std_abs.h:76
   2352a:	vandps xmm4,xmm0,XMMWORD PTR [rip+0x357e]        # 26ab0 <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0x110>
   23532:	vmovss DWORD PTR [rbp-0x38],xmm4
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:38
   23537:	vmovss xmm6,DWORD PTR [rbp-0x94]
   2353f:	vxorps xmm0,xmm6,XMMWORD PTR [rip+0x3559]        # 26aa0 <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0x100>
   23547:	vmovss DWORD PTR [rbp-0x70],xmm5
std::exp(float)():
/usr/include/c++/11/cmath:223
   2354c:	vmovss DWORD PTR [rbp-0xb4],xmm9
   23554:	call   9660 <expf@plt>
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:40
   23559:	vmovss xmm5,DWORD PTR [rbp-0x70]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:38
   2355e:	vmaxss xmm0,xmm0,DWORD PTR [rbp-0x38]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:40
   23563:	cmp    QWORD PTR [rbp-0xf0],0x0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:38
   2356b:	vaddss xmm0,xmm0,DWORD PTR [rbp-0xb8]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:40
   23573:	vmovss xmm9,DWORD PTR [rbp-0xb4]
   2357b:	jle    23798 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x848>
   23581:	lea    rcx,[rbx+0x20]
   23585:	mov    rax,QWORD PTR [rbp-0xb0]
   2358c:	xor    esi,esi
   2358e:	vbroadcastss ymm3,xmm5
   23593:	mov    QWORD PTR [rbp-0x70],rcx
   23597:	vmovss xmm7,DWORD PTR [rip+0x34f1]        # 26a90 <std::__detail::__to_chars_10_impl<unsigned int>(char*, unsigned int, unsigned int)::__digits+0xf0>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   2359f:	vshufps xmm6,xmm5,xmm5,0x0
   235a4:	lea    r8,[rax*4+0x0]
   235ac:	mov    rax,QWORD PTR [rbp-0x148]
   235b3:	mov    r11,QWORD PTR [rbp-0x130]
   235ba:	vdivss xmm0,xmm7,xmm0
   235be:	lea    rdi,[rax+r8*1]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:40
   235c2:	mov    rax,QWORD PTR [rbp-0x138]
   235c9:	add    r8,QWORD PTR [rbp-0x150]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:49
   235d0:	vmulss xmm4,xmm0,DWORD PTR [rbp-0x98]
   235d8:	nop    DWORD PTR [rax+rax*1+0x0]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:41
   235e0:	vmulss xmm2,xmm9,DWORD PTR [rdi]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   235e4:	test   r13,r13
   235e7:	jle    23928 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9d8>
   235ed:	cmp    rax,QWORD PTR [rbp-0x70]
   235f1:	lea    rcx,[rax+0x20]
   235f5:	lea    r9,[rsi+r11*1]
   235f9:	setae  dl
   235fc:	cmp    rbx,rcx
   235ff:	setae  cl
   23602:	or     edx,ecx
   23604:	mov    rcx,rax
   23607:	sub    rcx,QWORD PTR [rbp-0x58]
   2360b:	cmp    rcx,0x18
   2360f:	seta   cl
   23612:	test   dl,cl
   23614:	je     238f0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9a0>
   2361a:	mov    rcx,QWORD PTR [rbp-0x78]
   2361e:	cmp    rcx,0x2
   23622:	jbe    238f0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9a0>
   23628:	cmp    rcx,0x6
   2362c:	jbe    23931 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9e1>
   23632:	vbroadcastss ymm8,xmm2
   23637:	xor    edx,edx
   23639:	vxorps xmm1,xmm1,xmm1
   2363d:	nop    DWORD PTR [rax]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   23640:	vmulps ymm0,ymm8,YMMWORD PTR [r12+rdx*1]
   23646:	vfmadd231ps ymm0,ymm3,YMMWORD PTR [rax+rdx*1]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:46
   2364c:	vmovups YMMWORD PTR [rax+rdx*1],ymm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   23651:	vfmadd231ps ymm1,ymm0,YMMWORD PTR [rbx+rdx*1]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   23657:	add    rdx,0x20
   2365b:	cmp    r15,rdx
   2365e:	jne    23640 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x6f0>
   23660:	vextractf128 xmm0,ymm1,0x1
   23666:	mov    rcx,QWORD PTR [rbp-0x80]
   2366a:	vaddps xmm0,xmm0,xmm1
   2366e:	vmovhlps xmm1,xmm0,xmm0
   23672:	vaddps xmm1,xmm1,xmm0
   23676:	vshufps xmm0,xmm1,xmm1,0x55
   2367b:	vaddps xmm0,xmm0,xmm1
   2367f:	cmp    r13,rcx
   23682:	je     23773 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x823>
   23688:	cmp    QWORD PTR [rbp-0x90],0x2
   23690:	mov    r10,QWORD PTR [rbp-0x88]
   23697:	jbe    23947 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9f7>
   2369d:	mov    QWORD PTR [rbp-0x38],rcx
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   236a1:	mov    rdx,QWORD PTR [rbp-0x50]
   236a5:	add    r9,rcx
   236a8:	add    rcx,QWORD PTR [rbp-0x40]
   236ac:	vshufps xmm1,xmm2,xmm2,0x0
   236b1:	lea    r9,[r14+r9*4]
   236b5:	vmulps xmm1,xmm1,XMMWORD PTR [rdx+rcx*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   236ba:	mov    rdx,QWORD PTR [rbp-0x48]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   236be:	vfmadd231ps xmm1,xmm6,XMMWORD PTR [r9]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:46
   236c3:	vmovups XMMWORD PTR [r9],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   236c8:	vmulps xmm1,xmm1,XMMWORD PTR [rdx+rcx*4]
   236cd:	mov    rdx,QWORD PTR [rbp-0x38]
   236d1:	mov    rcx,r10
   236d4:	and    rcx,0xfffffffffffffffc
   236d8:	add    rdx,rcx
   236db:	vmovhlps xmm8,xmm1,xmm1
   236df:	vaddps xmm8,xmm8,xmm1
   236e3:	vshufps xmm1,xmm8,xmm8,0x55
   236e9:	vaddps xmm1,xmm1,xmm8
   236ee:	vaddss xmm0,xmm0,xmm1
   236f2:	cmp    rcx,r10
   236f5:	je     23773 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x823>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   236f7:	lea    rcx,[rsi+rdx*1]
   236fb:	vmulss xmm1,xmm2,DWORD PTR [r12+rdx*4]
   23701:	lea    r9,[rdx*4+0x0]
   23709:	add    rcx,r11
   2370c:	lea    rcx,[r14+rcx*4]
   23710:	vfmadd231ss xmm1,xmm5,DWORD PTR [rcx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:46
   23715:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   23719:	lea    rcx,[rdx+0x1]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   2371d:	vfmadd231ss xmm0,xmm1,DWORD PTR [rbx+rdx*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   23723:	cmp    r13,rcx
   23726:	jle    23773 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x823>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   23728:	vmulss xmm1,xmm2,DWORD PTR [r12+r9*1+0x4]
   2372f:	add    rcx,rsi
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   23732:	add    rdx,0x2
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   23736:	add    rcx,r11
   23739:	lea    rcx,[r14+rcx*4]
   2373d:	vfmadd231ss xmm1,xmm5,DWORD PTR [rcx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:46
   23742:	vmovss DWORD PTR [rcx],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   23746:	vfmadd231ss xmm0,xmm1,DWORD PTR [r9+rbx*1+0x4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   2374d:	cmp    r13,rdx
   23750:	jle    23773 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x823>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   23752:	vmulss xmm2,xmm2,DWORD PTR [r12+r9*1+0x8]
   23759:	add    rdx,rsi
   2375c:	add    rdx,r11
   2375f:	lea    rdx,[r14+rdx*4]
   23763:	vfmadd231ss xmm2,xmm5,DWORD PTR [rdx]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:46
   23768:	vmovss DWORD PTR [rdx],xmm2
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   2376c:	vfmadd231ss xmm0,xmm2,DWORD PTR [r9+rbx*1+0x8]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:49
   23773:	vmulss xmm0,xmm4,xmm0
   23777:	vmovss DWORD PTR [r8],xmm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:40
   2377c:	add    rdi,0x4
   23780:	add    r8,0x4
   23784:	add    rsi,r13
   23787:	add    rax,QWORD PTR [rbp-0x68]
   2378b:	cmp    QWORD PTR [rbp-0x60],rdi
   2378f:	jne    235e0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x690>
   23795:	vzeroupper 
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:52
   23798:	mov    rax,QWORD PTR [rbp-0xe8]
   2379f:	mov    rsi,QWORD PTR [rbp-0xc8]
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:77
   237a6:	mov    rdi,QWORD PTR [rbp-0x108]
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:52
   237ad:	vmovss xmm6,DWORD PTR [rbp-0x94]
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:77
   237b5:	add    QWORD PTR [rbp-0x60],rdi
   237b9:	mov    rdi,QWORD PTR [rbp-0x100]
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:52
   237c0:	vmovss DWORD PTR [rax+rsi*4],xmm6
mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:77
   237c5:	mov    rsi,QWORD PTR [rbp-0x110]
   237cc:	add    QWORD PTR [rbp-0xa0],0x1
   237d4:	add    rbx,rdi
   237d7:	mov    rax,QWORD PTR [rbp-0xa0]
   237de:	add    QWORD PTR [rbp-0x58],rdi
   237e2:	mov    rdi,QWORD PTR [rbp-0xe0]
   237e9:	add    QWORD PTR [rbp-0xb0],rsi
   237f0:	add    QWORD PTR [rbp-0x40],rdi
   237f4:	mov    rdi,QWORD PTR [rbp-0xf8]
   237fb:	add    QWORD PTR [rbp-0xa8],rdi
   23802:	cmp    QWORD PTR [rbp-0x128],rax
   23809:	jne    232b0 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x360>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:75
   2380f:	add    QWORD PTR [rbp-0xc8],0x1
   23817:	mov    r11,QWORD PTR [rbp-0x130]
   2381e:	mov    rdi,QWORD PTR [rbp-0xf0]
   23825:	add    QWORD PTR [rbp-0x170],r13
   2382c:	add    QWORD PTR [rbp-0x168],rdi
   23833:	mov    rax,QWORD PTR [rbp-0xc8]
   2383a:	add    QWORD PTR [rbp-0x178],0x4
   23842:	add    r11,QWORD PTR [rbp-0x1b8]
   23849:	add    QWORD PTR [rbp-0xd0],r13
   23850:	cmp    QWORD PTR [rbp-0x1b0],rax
   23857:	jne    231ea <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x29a>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:74
   2385d:	mov    rdi,QWORD PTR [rbp-0x1c8]
   23864:	add    QWORD PTR [rbp-0x160],0x1
   2386c:	mov    r11,r15
   2386f:	add    QWORD PTR [rbp-0x180],rdi
   23876:	mov    rax,QWORD PTR [rbp-0x160]
   2387d:	mov    rdi,QWORD PTR [rbp-0x1d8]
   23884:	add    QWORD PTR [rbp-0x188],rdi
   2388b:	mov    rdi,QWORD PTR [rbp-0x1e0]
   23892:	add    QWORD PTR [rbp-0x190],rdi
   23899:	mov    rdi,QWORD PTR [rbp-0xe0]
   238a0:	add    QWORD PTR [rbp-0x198],rdi
   238a7:	mov    rdi,QWORD PTR [rbp-0x1b0]
   238ae:	add    QWORD PTR [rbp-0x1a0],rdi
   238b5:	mov    rdi,QWORD PTR [rbp-0x1d0]
   238bc:	add    QWORD PTR [rbp-0x1a8],rdi
   238c3:	cmp    QWORD PTR [rbp-0x1f0],rax
   238ca:	jne    2317a <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x22a>
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:97
   238d0:	add    rsp,0x1e0
   238d7:	pop    rbx
   238d8:	pop    r10
   238da:	pop    r12
   238dc:	pop    r13
   238de:	pop    r14
   238e0:	pop    r15
   238e2:	pop    rbp
   238e3:	lea    rsp,[r10-0x8]
   238e7:	ret    
   238e8:	nop    DWORD PTR [rax+rax*1+0x0]
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:43
   238f0:	vxorps xmm0,xmm0,xmm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   238f4:	xor    edx,edx
   238f6:	cs nop WORD PTR [rax+rax*1+0x0]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:45
   23900:	vmulss xmm1,xmm2,DWORD PTR [r12+rdx*4]
   23906:	vfmadd231ss xmm1,xmm5,DWORD PTR [rax+rdx*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:46
   2390c:	vmovss DWORD PTR [rax+rdx*4],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:47
   23911:	vfmadd231ss xmm0,xmm1,DWORD PTR [rbx+rdx*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   23917:	add    rdx,0x1
   2391b:	cmp    r13,rdx
   2391e:	jne    23900 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x9b0>
   23920:	jmp    23773 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x823>
   23925:	nop    DWORD PTR [rax]
   23928:	vxorps xmm0,xmm0,xmm0
   2392c:	jmp    23777 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x827>
   23931:	mov    QWORD PTR [rbp-0x38],0x0
   23939:	mov    r10,r13
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:43
   2393c:	vxorps xmm0,xmm0,xmm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:44
   23940:	xor    ecx,ecx
   23942:	jmp    236a1 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x751>
   23947:	mov    rdx,rcx
   2394a:	jmp    236f7 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x7a7>
std::exp(float)():
/usr/include/c++/11/cmath:223
   2394f:	vmovaps xmm0,xmm1
   23953:	vmovss DWORD PTR [rbp-0x70],xmm1
   23958:	call   9660 <expf@plt>
std::log1p(float)():
/usr/include/c++/11/cmath:1552
   2395d:	call   9750 <log1pf@plt>
mlstm_cpu::log_sigmoid_stable(float)():
csrc/include/stable_math.h:13
   23962:	vmovss xmm1,DWORD PTR [rbp-0x70]
   23967:	vsubss xmm0,xmm1,xmm0
   2396b:	jmp    23304 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x3b4>
step_state():
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   23970:	mov    rdx,QWORD PTR [rbp-0xd8]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:30
   23977:	vxorps xmm0,xmm0,xmm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   2397b:	xor    eax,eax
   2397d:	nop    DWORD PTR [rax]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   23980:	vmulss xmm1,xmm9,DWORD PTR [r12+rax*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   23986:	vmovss xmm7,DWORD PTR [rbp-0x98]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:32
   2398e:	vfmadd231ss xmm1,xmm5,DWORD PTR [rdx+rax*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:33
   23994:	vmovss DWORD PTR [rdx+rax*4],xmm1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   23999:	vmulss xmm3,xmm7,DWORD PTR [rbx+rax*4]
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   2399e:	add    rax,0x1
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:34
   239a2:	vfmadd231ss xmm0,xmm1,xmm3
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   239a7:	cmp    r13,rax
   239aa:	jne    23980 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0xa30>
   239ac:	jmp    2352a <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5da>
   239b1:	mov    DWORD PTR [rbp-0x38],0x0
   239b8:	jmp    23537 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5e7>
   239bd:	vzeroupper 
   239c0:	jmp    2352a <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x5da>
   239c5:	mov    rsi,r13
   239c8:	xor    eax,eax
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:30
   239ca:	vxorps xmm0,xmm0,xmm0
csrc/kernels/fastmath/../mlstm_core_scalar_c_rm.inc:31
   239ce:	xor    edx,edx
   239d0:	jmp    2341f <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x4cf>
   239d5:	vzeroupper 
   239d8:	jmp    23494 <mlstm_cpu::mlstm_core_sequence_compiler_fastmath_c_rm(float const*, float const*, float const*, float const*, float const*, float*, float*, float*, float*, long, long, long, long, long, float)+0x544>

Disassembly of section .fini:
