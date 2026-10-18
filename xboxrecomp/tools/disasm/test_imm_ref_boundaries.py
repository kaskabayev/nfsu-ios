"""Weak immediate references must not split an existing instruction stream."""
import copy
import struct
from tools.disasm.test_decode_at import _engine, BASE
from tools.disasm.functions import FunctionDetector

def detector(tail, target_offset):
    data = b'\xb8' + struct.pack('<I', BASE + target_offset) + b'\xc3' + b'\x90'*4 + tail
    engine, section = _engine(BASE, data)
    engine.image.read_bytes_at_va = lambda addr, size: data[addr-BASE:addr-BASE+size]
    for insn in engine._cs.disasm(data, BASE):
        engine.instructions[insn.address] = engine._classify_instruction(insn)
    det = FunctionDetector(engine, engine.image, None, None)
    return det, section, BASE + target_offset

def test_immediate_inside_memory_operand_is_not_a_function():
    # test [esi+edx*4+0x1018],ebx; ret. Offset +1 also happens to decode to ret.
    det, sec, target = detector(bytes.fromhex('859c9618100000c3'), 11)
    assert det.engine.probes_as_returning_body(target)
    det._pass_imm_ref_targets([sec])
    assert target not in det._candidates

def test_real_prologue_can_realign_an_overlapping_sweep():
    # Sweep sees mov eax,0xc3ec8b55; the referenced entry is push ebp;mov ebp,esp;ret.
    det, sec, target = detector(bytes.fromhex('b8558becc3c3'), 11)
    assert det.engine.instruction_covering(target) is not None
    det._pass_imm_ref_targets([sec])
    assert target in det._candidates

def test_instruction_boundary_remains_a_candidate():
    det, sec, target = detector(bytes.fromhex('558becc3'), 10)
    det._pass_imm_ref_targets([sec])
    assert target in det._candidates

def test_constant_return_stub_can_realign_an_overlapping_sweep():
    det, sec, target = detector(bytes.fromhex('b9b878563412c3'), 11)
    assert det.engine.instruction_covering(target) is not None
    det._pass_imm_ref_targets([sec])
    assert target in det._candidates

def test_virtual_dispatch_thunk_can_realign_an_overlapping_sweep():
    det, sec, target = detector(bytes.fromhex('b98b01ff6010c3'), 11)
    assert det.engine.instruction_covering(target) is not None
    det._pass_imm_ref_targets([sec])
    assert target in det._candidates

def test_d3d_pushbuffer_word_is_not_a_function():
    # D3D stores NV2A method headers as immediates; one may equal a game
    # address. A D3D-section source must not make a target in .text a
    # function start.
    det, sec, target = detector(bytes.fromhex('558becc3'), 10)
    d3d, text = copy.copy(sec), copy.copy(sec)
    d3d.name, d3d.virtual_size = "D3D", 5          # the mov at BASE
    text.name, text.virtual_addr = ".text", sec.virtual_addr + 5
    text.virtual_size = sec.virtual_size - 5
    det._pass_imm_ref_targets([d3d, text])
    assert target not in det._candidates

def test_d3d_function_pointer_into_d3d_stays_a_function():
    # D3D keeps pointers to its own functions (NFSU2 sub_002F1FC0 is reached
    # only that way). Source and target both in D3D: still a start.
    det, sec, target = detector(bytes.fromhex('558becc3'), 10)
    sec.name = "D3D"
    det._pass_imm_ref_targets([sec])
    assert target in det._candidates

def _tail_body(jump_to_offset):
    # mov ecx,[BASE+0x100]; jmp <BASE+jump_to_offset>, placed at offset 10.
    rel = jump_to_offset - (10 + 6 + 5)
    return bytes.fromhex('8b0d') + struct.pack('<I', BASE + 0x100) + b'\xe9' + struct.pack('<i', rel)

def test_tail_jump_into_a_known_function_is_a_function():
    # NFS Carbon's script native PrecalculateDriftOpponentScores (0x1A9E70):
    # taken by `push`, no ret, ends in a jmp to the real method.
    det, sec, target = detector(_tail_body(0), 10)
    det._add_candidate(BASE, 0.9, "test")
    det._pass_imm_ref_targets([sec])
    assert target in det._candidates

def test_tail_jump_to_nowhere_known_is_not_a_function():
    det, sec, target = detector(_tail_body(7), 10)
    det._pass_imm_ref_targets([sec])
    assert target not in det._candidates
