#!/usr/bin/env python3
"""Generate midi2ttl KiCad project (schematic + PCB + JLCPCB fab files)."""

from __future__ import annotations

import csv
import json
import re
import subprocess
import uuid
import zipfile
from pathlib import Path

import pcbnew

ROOT = Path(__file__).resolve().parents[1]
SYM_DIR = Path("/usr/share/kicad/symbols")
FP_DIR = Path("/usr/share/kicad/footprints")
FAB = ROOT / "fab"


def uid() -> str:
    return str(uuid.uuid4())


def extract_symbol(lib_path: Path, name: str) -> str:
    text = lib_path.read_text(encoding="utf-8")
    start = text.find(f'(symbol "{name}"')
    if start < 0:
        raise RuntimeError(f"Symbol {name} not found in {lib_path}")
    start = text.rfind("\n", 0, start) + 1
    i = start
    depth = 0
    in_str = False
    while i < len(text):
        c = text[i]
        if c == '"' and (i == 0 or text[i - 1] != "\\"):
            in_str = not in_str
        elif not in_str:
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    return text[start : i + 1]
        i += 1
    raise RuntimeError(f"Unclosed symbol {name}")


def embed_symbol(block: str, lib: str, name: str) -> str:
    """Prefix only the outer symbol name for lib_symbols embedding."""
    block = block.replace(f'(symbol "{name}"', f'(symbol "{lib}:{name}"', 1)
    if not block.startswith("\t"):
        block = "\t" + block
    return block


def make_h11l1sr2m() -> str:
    """System H11L1 with pin numbers 4/5 corrected to match onsemi datasheet."""
    block = extract_symbol(SYM_DIR / "Isolator.kicad_sym", "H11L1")
    block = block.replace('(symbol "H11L1"', '(symbol "H11L1SR2M"', 1)
    block = block.replace('(symbol "H11L1_', '(symbol "H11L1SR2M_')
    block = block.replace('(property "Value" "H11L1"', '(property "Value" "H11L1SR2M"')
    # KiCad library has pin 4/5 swapped vs datasheet; fix numbers (keep graphics).
    block = block.replace('(number "4"', '(number "TMP4"')
    block = block.replace('(number "5"', '(number "4"')
    block = block.replace('(number "TMP4"', '(number "5"')
    # Default footprint for SMD SOP-6-2.54mm (JLCPCB H11L1SR2M)
    block = re.sub(
        r'\(property "Footprint" ""',
        '(property "Footprint" "Package_DIP:SMDIP-6_W9.53mm"',
        block,
        count=1,
    )
    return embed_symbol(block, "midi2ttl", "H11L1SR2M")


def inst(lib_id, ref, value, x, y, footprint, extras=None, rot=0):
    extras = extras or {}
    props = [
        ("Reference", ref, False),
        ("Value", value, False),
        ("Footprint", footprint, True),
        ("Datasheet", extras.get("Datasheet", "~"), True),
        ("Description", extras.get("Description", ""), True),
    ]
    for k, v in extras.items():
        if k in ("Datasheet", "Description"):
            continue
        props.append((k, str(v), True))
    prop_txt = []
    for i, (name, val, hide) in enumerate(props):
        hide_s = "\n\t\t\t\t(hide yes)" if hide else ""
        prop_txt.append(
            f"""\t\t(property "{name}" "{val}"
\t\t\t(at {x} {y + 2.54 - i * 1.27} {rot})
\t\t\t(effects
\t\t\t\t(font
\t\t\t\t\t(size 1.27 1.27)
\t\t\t\t){hide_s}
\t\t\t)
\t\t)"""
        )
    return f"""\t(symbol
\t\t(lib_id "{lib_id}")
\t\t(at {x} {y} {rot})
\t\t(unit 1)
\t\t(exclude_from_sim no)
\t\t(in_bom yes)
\t\t(on_board yes)
\t\t(dnp no)
\t\t(uuid "{uid()}")
{chr(10).join(prop_txt)}
\t\t(instances
\t\t\t(project "midi2ttl"
\t\t\t\t(path "/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
\t\t\t\t\t(reference "{ref}")
\t\t\t\t\t(unit 1)
\t\t\t\t)
\t\t\t)
\t\t)
\t)"""


def global_label(name, shape, x, y, rot=0):
    return f"""\t(global_label "{name}"
\t\t(shape {shape})
\t\t(at {x} {y} {rot})
\t\t(effects
\t\t\t(font
\t\t\t\t(size 1.27 1.27)
\t\t\t)
\t\t\t(justify left)
\t\t)
\t\t(uuid "{uid()}")
\t\t(property "Intersheetrefs" "${{INTERSHEET_REFS}}"
\t\t\t(at {x} {y} 0)
\t\t\t(effects
\t\t\t\t(font
\t\t\t\t\t(size 1.27 1.27)
\t\t\t\t)
\t\t\t\t(hide yes)
\t\t\t)
\t\t)
\t)"""


def no_connect(x, y):
    return f"""\t(no_connect
\t\t(at {x} {y})
\t\t(uuid "{uid()}")
\t)"""


def text(txt, x, y, size=1.27):
    return f"""\t(text "{txt}"
\t\t(exclude_from_sim no)
\t\t(at {x} {y} 0)
\t\t(effects
\t\t\t(font
\t\t\t\t(size {size} {size})
\t\t\t)
\t\t\t(justify left bottom)
\t\t)
\t\t(uuid "{uid()}")
\t)"""


def build_schematic():
    sheet_uuid = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    wire_fp = "midi2ttl:WirePad_THT_Relief"
    r_fp = "Resistor_SMD:R_0603_1608Metric"
    c_fp = "Capacitor_SMD:C_0603_1608Metric"
    d_fp = "Diode_SMD:D_SOD-123"
    u_fp = "Package_DIP:SMDIP-6_W9.53mm"
    mh_fp = "MountingHole:MountingHole_3.2mm_M3"

    libs = [
        make_h11l1sr2m(),
        embed_symbol(extract_symbol(SYM_DIR / "Connector_Generic.kicad_sym", "Conn_01x01"), "Connector_Generic", "Conn_01x01"),
        embed_symbol(extract_symbol(SYM_DIR / "Device.kicad_sym", "R"), "Device", "R"),
        embed_symbol(extract_symbol(SYM_DIR / "Device.kicad_sym", "C"), "Device", "C"),
        embed_symbol(extract_symbol(SYM_DIR / "Diode.kicad_sym", "1N4148"), "Diode", "1N4148"),
        embed_symbol(extract_symbol(SYM_DIR / "Mechanical.kicad_sym", "MountingHole"), "Mechanical", "MountingHole"),
    ]

    ux, uy = 88.9, 57.15
    parts = [
        inst("Connector_Generic:Conn_01x01", "J1", "MIDI_IN_4", 25.4, 50.8, wire_fp, {"Description": "DIN5 pin4"}),
        inst("Connector_Generic:Conn_01x01", "J2", "MIDI_IN_5", 25.4, 63.5, wire_fp, {"Description": "DIN5 pin5"}),
        inst("Device:R", "R1", "220", 45.72, 63.5, r_fp, {"LCSC": "C22962"}, rot=90),
        inst("Diode:1N4148", "D1", "1N4148W", 63.5, 57.15, d_fp, {"LCSC": "C81598"}),
        inst("midi2ttl:H11L1SR2M", "U1", "H11L1SR2M", ux, uy, u_fp, {"LCSC": "C20082"}),
        inst("Device:R", "R2", "470", 114.3, 44.45, r_fp, {"LCSC": "C23179"}, rot=90),
        inst("Device:C", "C1", "100nF", 101.6, 76.2, c_fp, {"LCSC": "C14663"}),
        inst("Connector_Generic:Conn_01x01", "J3", "HOST_BOOT", 139.7, 25.4, wire_fp, {"Description": "JST pin1 /BOOT"}),
        inst("Connector_Generic:Conn_01x01", "J4", "HOST_RX", 139.7, 38.1, wire_fp, {"Description": "JST pin2 RXD0"}),
        inst("Connector_Generic:Conn_01x01", "J5", "HOST_TX", 139.7, 50.8, wire_fp, {"Description": "JST pin3 TXD0"}),
        inst("Connector_Generic:Conn_01x01", "J6", "HOST_VCC", 139.7, 63.5, wire_fp, {"Description": "JST pin4 VCC"}),
        inst("Connector_Generic:Conn_01x01", "J7", "HOST_GND", 139.7, 76.2, wire_fp, {"Description": "JST pin5 GND"}),
        inst("Connector_Generic:Conn_01x01", "J8", "HOST_SCK", 139.7, 88.9, wire_fp, {"Description": "JST pin6 SCK1"}),
        inst("Device:R", "R3", "220", 177.8, 50.8, r_fp, {"LCSC": "C22962"}, rot=90),
        inst("Device:R", "R4", "220", 177.8, 63.5, r_fp, {"LCSC": "C22962"}, rot=90),
        inst("Connector_Generic:Conn_01x01", "J9", "MIDI_OUT_4", 203.2, 50.8, wire_fp, {"Description": "DIN5 pin4"}),
        inst("Connector_Generic:Conn_01x01", "J10", "MIDI_OUT_5", 203.2, 63.5, wire_fp, {"Description": "DIN5 pin5"}),
        inst("Connector_Generic:Conn_01x01", "J11", "MIDI_OUT_2", 203.2, 76.2, wire_fp, {"Description": "DIN5 pin2 GND"}),
        inst("Mechanical:MountingHole", "H1", "M3", 25.4, 101.6, mh_fp),
        inst("Mechanical:MountingHole", "H2", "M3", 203.2, 101.6, mh_fp),
    ]

    def gl(name, shape, x, y, rot=0):
        return global_label(name, shape, x, y, rot)

    # After pin swap: U1 pin5 = VO (right), pin4 = GND (bottom), pin6 = VCC (top)
    gls = [
        gl("MIDI_IN_4", "passive", 25.4 - 2.54, 50.8),
        gl("MIDI_IN_5", "passive", 25.4 - 2.54, 63.5),
        gl("MIDI_IN_4", "passive", ux - 7.62, uy + 2.54),  # A
        gl("MIDI_IN_5", "passive", 45.72, 63.5 + 3.81, 270),  # R1
        gl("OPTO_C", "passive", 45.72, 63.5 - 3.81, 90),
        gl("OPTO_C", "passive", ux - 7.62, uy - 2.54),  # C
        gl("MIDI_IN_4", "passive", 63.5 - 3.81, 57.15),  # D1 K
        gl("OPTO_C", "passive", 63.5 + 3.81, 57.15, 180),  # D1 A
        gl("VCC", "passive", ux, uy + 7.62, 270),
        gl("GND", "passive", ux, uy - 7.62, 90),
        gl("RX", "passive", ux + 7.62, uy, 180),  # VO pin5
        gl("VCC", "passive", 114.3, 44.45 + 3.81, 270),
        gl("RX", "passive", 114.3, 44.45 - 3.81, 90),
        gl("VCC", "passive", 101.6 - 3.81, 76.2),
        gl("GND", "passive", 101.6 + 3.81, 76.2, 180),
        gl("BOOT", "passive", 139.7 - 2.54, 25.4),
        gl("RX", "passive", 139.7 - 2.54, 38.1),
        gl("TX", "passive", 139.7 - 2.54, 50.8),
        gl("VCC", "passive", 139.7 - 2.54, 63.5),
        gl("GND", "passive", 139.7 - 2.54, 76.2),
        gl("SCK", "passive", 139.7 - 2.54, 88.9),
        gl("VCC", "passive", 177.8, 50.8 - 3.81, 90),
        gl("MIDI_OUT_4", "passive", 177.8, 50.8 + 3.81, 270),
        gl("TX", "passive", 177.8, 63.5 - 3.81, 90),
        gl("MIDI_OUT_5", "passive", 177.8, 63.5 + 3.81, 270),
        gl("MIDI_OUT_4", "passive", 203.2 - 2.54, 50.8),
        gl("MIDI_OUT_5", "passive", 203.2 - 2.54, 63.5),
        gl("GND", "passive", 203.2 - 2.54, 76.2),
    ]

    # U1 NC pin3 is at about (-2.54?); system symbol hides NC. BOOT/SCK unused.
    ncs = [
        no_connect(139.7 - 2.54, 25.4),
        no_connect(139.7 - 2.54, 88.9),
    ]

    sch = f"""(kicad_sch
\t(version 20250114)
\t(generator "eeschema")
\t(generator_version "9.0")
\t(uuid "{sheet_uuid}")
\t(paper "A4")
\t(title_block
\t\t(title "midi2ttl")
\t\t(date "2026-09-21")
\t\t(rev "1")
\t\t(company "harvie")
\t\t(comment 1 "MIDI IN/OUT for Korg monotribe serial / 3.3V or 5V UART hosts")
\t\t(comment 2 "H11L1SR2M (LCSC C20082); Basic passives on JLCPCB")
\t)
\t(lib_symbols
{chr(10).join(libs)}
\t)
{chr(10).join(parts)}
{chr(10).join(gls)}
{chr(10).join(ncs)}
{text("MIDI IN DIN5 wires: pin4 / pin5", 12.7, 35.56, 1.5)}
{text("HOST = monotribe Serial JST-PH 6P (or MCU UART)", 119.38, 15.24, 1.5)}
{text("MIDI OUT DIN5 wires: pin4 / pin5 / pin2(GND)", 165.1, 35.56, 1.5)}
{text("VCC = host logic rail (3.3V or 5V). H11L1 rated 3-15V. No LDO/level shifter.", 12.7, 114.3, 1.27)}
{text("Monotribe pinout: 1=/BOOT 2=RXD0 3=TXD0 4=3.3V 5=GND 6=SCK1", 12.7, 119.38, 1.27)}
\t(sheet_instances
\t\t(path "/"
\t\t\t(page "1")
\t\t)
\t)
\t(embedded_fonts no)
)
"""
    (ROOT / "midi2ttl.kicad_sch").write_text(sch, encoding="utf-8")
    # Also write corrected symbol lib for editing
    raw = make_h11l1sr2m()
    raw = raw.replace('(symbol "midi2ttl:H11L1SR2M"', '(symbol "H11L1SR2M"', 1)
    (ROOT / "midi2ttl.kicad_sym").write_text(
        f'(kicad_symbol_lib\n\t(version 20241209)\n\t(generator "midi2ttl")\n{raw}\n)\n',
        encoding="utf-8",
    )
    print("Wrote schematic")


def mm(x: float) -> int:
    return int(round(pcbnew.FromMM(x)))


def add_fp(board, lib, name, ref, x, y, rot_deg=0):
    lib_path = str(ROOT / "footprints" / "midi2ttl.pretty") if lib == "midi2ttl" else str(FP_DIR / f"{lib}.pretty")
    fp = pcbnew.FootprintLoad(lib_path, name)
    if fp is None:
        raise RuntimeError(f"Cannot load {lib_path}/{name}")
    fp.SetReference(ref)
    fp.SetPosition(pcbnew.VECTOR2I(mm(x), mm(y)))
    fp.SetOrientation(pcbnew.EDA_ANGLE(rot_deg, pcbnew.DEGREES_T))
    board.Add(fp)
    return fp


def ensure_net(board, net_name):
    net = board.FindNet(net_name)
    if net is None:
        net = pcbnew.NETINFO_ITEM(board, net_name)
        board.Add(net)
    return net


def set_net(board, fp, pad_name, net_name):
    net = ensure_net(board, net_name)
    pad = fp.FindPadByNumber(pad_name)
    if pad is None:
        raise RuntimeError(f"{fp.GetReference()} missing pad {pad_name}")
    pad.SetNet(net)


def add_track(board, x1, y1, x2, y2, net_name, width=0.25, layer=pcbnew.F_Cu):
    net = ensure_net(board, net_name)
    track = pcbnew.PCB_TRACK(board)
    track.SetStart(pcbnew.VECTOR2I(mm(x1), mm(y1)))
    track.SetEnd(pcbnew.VECTOR2I(mm(x2), mm(y2)))
    track.SetWidth(mm(width))
    track.SetLayer(layer)
    track.SetNet(net)
    board.Add(track)


def add_poly_zone(board, pts, net_name, layer):
    net = ensure_net(board, net_name)
    zone = pcbnew.ZONE(board)
    zone.SetLayer(layer)
    zone.SetNet(net)
    outline = zone.Outline()
    outline.NewOutline()
    for x, y in pts:
        outline.Append(mm(x), mm(y))
    zone.SetLocalClearance(mm(0.25))
    zone.SetMinThickness(mm(0.2))
    zone.SetThermalReliefGap(mm(0.25))
    zone.SetThermalReliefSpokeWidth(mm(0.3))
    zone.SetPadConnection(pcbnew.ZONE_CONNECTION_THERMAL)
    board.Add(zone)


def add_silk_text(board, txt, x, y, size=1.0):
    t = pcbnew.PCB_TEXT(board)
    t.SetText(txt)
    t.SetPosition(pcbnew.VECTOR2I(mm(x), mm(y)))
    t.SetLayer(pcbnew.F_SilkS)
    t.SetTextSize(pcbnew.VECTOR2I(mm(size), mm(size)))
    t.SetTextThickness(mm(0.15))
    board.Add(t)


def pad_xy(fp, name):
    p = fp.FindPadByNumber(name)
    pos = p.GetPosition()
    return pcbnew.ToMM(pos.x), pcbnew.ToMM(pos.y)



def add_path(board, pts, net_name, width=0.3, layer=pcbnew.F_Cu):
    for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
        if abs(x1 - x2) < 1e-6 and abs(y1 - y2) < 1e-6:
            continue
        add_track(board, x1, y1, x2, y2, net_name, width, layer)


def add_via(board, x, y, net_name):
    net = ensure_net(board, net_name)
    via = pcbnew.PCB_VIA(board)
    via.SetPosition(pcbnew.VECTOR2I(mm(x), mm(y)))
    via.SetDrill(mm(0.3))
    via.SetWidth(mm(0.6))
    via.SetNet(net)
    board.Add(via)


def build_pcb():
    """56x42 mm board, generous spacing, mostly B.Cu return + short F.Cu links."""
    board = pcbnew.CreateEmptyBoard()
    board.SetFileName(str(ROOT / "midi2ttl.kicad_pcb"))

    W, H = 56.0, 42.0
    for (x1, y1), (x2, y2) in zip([(0, 0), (W, 0), (W, H), (0, H)], [(W, 0), (W, H), (0, H), (0, 0)]):
        s = pcbnew.PCB_SHAPE(board)
        s.SetShape(pcbnew.SHAPE_T_SEGMENT)
        s.SetStart(pcbnew.VECTOR2I(mm(x1), mm(y1)))
        s.SetEnd(pcbnew.VECTOR2I(mm(x2), mm(y2)))
        s.SetLayer(pcbnew.Edge_Cuts)
        s.SetWidth(mm(0.1))
        board.Add(s)

    for n in ["GND", "VCC", "RX", "TX", "MIDI_IN_4", "MIDI_IN_5", "MIDI_OUT_4", "MIDI_OUT_5", "BOOT", "SCK", "OPTO_C"]:
        ensure_net(board, n)

    add_fp(board, "MountingHole", "MountingHole_3.2mm_M3", "H1", 4.0, 4.0)
    add_fp(board, "MountingHole", "MountingHole_3.2mm_M3", "H2", 52.0, 38.0)

    # ---- Placement (left=IN, center=opto, right=HOST, bottom=OUT) ----
    j_in4 = add_fp(board, "midi2ttl", "WirePad_THT_Relief", "J1", 7.0, 14.0, 270)
    j_in5 = add_fp(board, "midi2ttl", "WirePad_THT_Relief", "J2", 7.0, 22.0, 270)
    j_in4.SetValue("IN4")
    j_in5.SetValue("IN5")

    d1 = add_fp(board, "Diode_SMD", "D_SOD-123", "D1", 15.0, 12.0, 90)  # vertical: K top / A bottom-ish after rot
    d1.SetValue("1N4148W")
    r1 = add_fp(board, "Resistor_SMD", "R_0603_1608Metric", "R1", 15.0, 22.0)
    r1.SetValue("220")
    u1 = add_fp(board, "Package_DIP", "SMDIP-6_W9.53mm", "U1", 26.0, 17.0)
    u1.SetValue("H11L1SR2M")
    r2 = add_fp(board, "Resistor_SMD", "R_0603_1608Metric", "R2", 36.0, 10.0)
    r2.SetValue("470")
    c1 = add_fp(board, "Capacitor_SMD", "C_0603_1608Metric", "C1", 26.0, 8.0)
    c1.SetValue("100nF")

    host_fps = []
    for i, (ref, val, net) in enumerate(zip(
        ["J3", "J4", "J5", "J6", "J7", "J8"],
        ["BOOT", "RX", "TX", "VCC", "GND", "SCK"],
        ["BOOT", "RX", "TX", "VCC", "GND", "SCK"],
    )):
        fp = add_fp(board, "midi2ttl", "WirePad_THT_Relief", ref, 49.0, 7.0 + i * 5.0, 90)
        fp.SetValue(val)
        host_fps.append((fp, net))

    r3 = add_fp(board, "Resistor_SMD", "R_0603_1608Metric", "R3", 16.0, 29.0, 90)
    r3.SetValue("220")
    r4 = add_fp(board, "Resistor_SMD", "R_0603_1608Metric", "R4", 28.0, 29.0, 90)
    r4.SetValue("220")
    j_o4 = add_fp(board, "midi2ttl", "WirePad_THT_Relief", "J9", 16.0, 36.0, 0)
    j_o5 = add_fp(board, "midi2ttl", "WirePad_THT_Relief", "J10", 28.0, 36.0, 0)
    j_o2 = add_fp(board, "midi2ttl", "WirePad_THT_Relief", "J11", 40.0, 36.0, 0)
    j_o4.SetValue("OUT4")
    j_o5.SetValue("OUT5")
    j_o2.SetValue("OUT2")

    # ---- Nets ----
    # D_SOD-123 rot90: check pad positions after place
    set_net(board, j_in4, "1", "MIDI_IN_4")
    set_net(board, j_in5, "1", "MIDI_IN_5")
    set_net(board, r1, "1", "MIDI_IN_5")
    set_net(board, r1, "2", "OPTO_C")
    # Diode antiparallel: K->MIDI_IN_4, A->OPTO_C. After rot90 pad1(K) ends at smaller Y (top).
    set_net(board, d1, "1", "MIDI_IN_4")
    set_net(board, d1, "2", "OPTO_C")
    set_net(board, u1, "1", "MIDI_IN_4")
    set_net(board, u1, "2", "OPTO_C")
    set_net(board, u1, "4", "GND")
    set_net(board, u1, "5", "RX")
    set_net(board, u1, "6", "VCC")
    set_net(board, r2, "1", "VCC")
    set_net(board, r2, "2", "RX")
    set_net(board, c1, "1", "VCC")
    set_net(board, c1, "2", "GND")
    for fp, net in host_fps:
        set_net(board, fp, "1", net)
    # R3/R4 rot90: pad1 toward +Y (OUT)
    set_net(board, r3, "1", "MIDI_OUT_4")
    set_net(board, r3, "2", "VCC")
    set_net(board, r4, "1", "MIDI_OUT_5")
    set_net(board, r4, "2", "TX")
    set_net(board, j_o4, "1", "MIDI_OUT_4")
    set_net(board, j_o5, "1", "MIDI_OUT_5")
    set_net(board, j_o2, "1", "GND")

    p = pad_xy
    j3, j4, j5, j6, j7, j8 = [fp for fp, _ in host_fps]

    # ---- Routes: star VCC/GND on B.Cu, short F.Cu hops ----
    # MIDI IN4: stay left of OPTO corridor (x=18.5)
    add_path(board, [p(j_in4, "1"), p(d1, "1")], "MIDI_IN_4", 0.35)
    add_path(board, [p(d1, "1"), (13.0, p(d1, "1")[1]), (13.0, 12.0), (p(u1, "1")[0], 12.0), p(u1, "1")], "MIDI_IN_4", 0.3)
    # MIDI IN5
    add_path(board, [p(j_in5, "1"), p(r1, "1")], "MIDI_IN_5", 0.35)
    # OPTO_C: R1.2 and D1.A to U1.2 (corridor x=18.5, clear of U1 body)
    add_path(board, [p(r1, "2"), (18.5, p(r1, "2")[1]), (18.5, p(u1, "2")[1]), p(u1, "2")], "OPTO_C", 0.25)
    add_path(board, [p(d1, "2"), (18.5, p(d1, "2")[1]), (18.5, p(u1, "2")[1])], "OPTO_C", 0.25)

    # VCC: keep on y=5.5 spine above U1; no diagonal across C1
    add_path(board, [p(u1, "6"), (p(u1, "6")[0], 5.5), (p(c1, "1")[0], 5.5), p(c1, "1")], "VCC", 0.4)
    add_path(board, [(p(c1, "1")[0], 5.5), (p(r2, "1")[0], 5.5), p(r2, "1")], "VCC", 0.35)
    # VCC to J6 on B.Cu at x=47.5 (RX host via uses ~46.5)
    add_via(board, p(c1, "1")[0], 5.5, "VCC")
    add_path(board, [(p(c1, "1")[0], 5.5), (47.5, 5.5), (47.5, p(j6, "1")[1]), p(j6, "1")], "VCC", 0.35, pcbnew.B_Cu)
    add_via(board, p(j6, "1")[0] - 1.5, p(j6, "1")[1], "VCC")
    add_path(board, [(47.5, p(j6, "1")[1]), (p(j6, "1")[0] - 1.5, p(j6, "1")[1])], "VCC", 0.3, pcbnew.B_Cu)
    # VCC to R3
    add_path(board, [(p(c1, "1")[0], 5.5), (p(r3, "2")[0], 5.5), (p(r3, "2")[0], p(r3, "2")[1]), p(r3, "2")], "VCC", 0.35, pcbnew.B_Cu)
    add_via(board, p(r3, "2")[0], p(r3, "2")[1], "VCC")

    # GND: C1 via into plane (away from VCC pad)
    add_via(board, p(c1, "2")[0] + 1.5, p(c1, "2")[1], "GND")
    add_path(board, [p(c1, "2"), (p(c1, "2")[0] + 1.5, p(c1, "2")[1])], "GND", 0.3)

    # RX F.Cu U1.5-R2 then B.Cu to J4 (via at x=45, clear of VCC at 47.5)
    add_path(board, [p(u1, "5"), (p(r2, "2")[0], p(u1, "5")[1]), p(r2, "2")], "RX", 0.3)
    add_path(board, [p(r2, "2"), (p(r2, "2")[0], p(j4, "1")[1])], "RX", 0.3)
    add_via(board, 43.0, p(j4, "1")[1], "RX")
    add_path(board, [(p(r2, "2")[0], p(j4, "1")[1]), (43.0, p(j4, "1")[1])], "RX", 0.3)
    add_path(board, [(43.0, p(j4, "1")[1]), p(j4, "1")], "RX", 0.3, pcbnew.B_Cu)
    add_via(board, p(j4, "1")[0] - 1.2, p(j4, "1")[1], "RX")
    add_path(board, [(43.0, p(j4, "1")[1]), (p(j4, "1")[0] - 1.2, p(j4, "1")[1])], "RX", 0.3, pcbnew.B_Cu)

    # TX B.Cu at x=42 (clear of VCC spine near host)
    tx_x = 42.0
    add_via(board, tx_x, p(j5, "1")[1], "TX")
    add_path(board, [p(j5, "1"), (tx_x, p(j5, "1")[1])], "TX", 0.3)
    add_path(board, [(tx_x, p(j5, "1")[1]), (tx_x, p(r4, "2")[1]), p(r4, "2")], "TX", 0.3, pcbnew.B_Cu)
    add_via(board, p(r4, "2")[0], p(r4, "2")[1], "TX")

    # OUT shorts
    add_path(board, [p(r3, "1"), p(j_o4, "1")], "MIDI_OUT_4", 0.3)
    add_path(board, [p(r4, "1"), p(j_o5, "1")], "MIDI_OUT_5", 0.3)

    margin = 0.5
    outline = [(margin, margin), (W - margin, margin), (W - margin, H - margin), (margin, H - margin)]
    add_poly_zone(board, outline, "GND", pcbnew.F_Cu)
    add_poly_zone(board, outline, "GND", pcbnew.B_Cu)

    add_silk_text(board, "midi2ttl", 18, 2.5, 1.2)
    add_silk_text(board, "IN", 5.5, 10.0, 0.9)
    add_silk_text(board, "HOST", 45.0, 4.5, 0.9)
    add_silk_text(board, "OUT", 20, 40.5, 0.9)
    add_silk_text(board, "3V3/5V", 30, 2.5, 0.9)

    for fp, code in [(u1, "C20082"), (r1, "C22962"), (r2, "C23179"), (r3, "C22962"), (r4, "C22962"), (c1, "C14663"), (d1, "C81598")]:
        try:
            fp.SetProperty("LCSC", code)
        except Exception:
            pass

    pcbnew.ZONE_FILLER(board).Fill(board.Zones())
    pcbnew.SaveBoard(str(ROOT / "midi2ttl.kicad_pcb"), board)
    print("Wrote PCB")



def write_project_meta():
    pro = {
        "board": {
            "design_settings": {
                "defaults": {},
                "rules": {
                    "min_clearance": 0.2,
                    "min_track_width": 0.15,
                    "min_via_diameter": 0.45,
                    "min_through_hole_diameter": 0.3,
                },
                "track_widths": [0.0, 0.2, 0.25, 0.3, 0.4, 0.5],
                "via_dimensions": [{"diameter": 0.6, "drill": 0.3}],
            }
        },
        "boards": [],
        "libraries": {"pinned_footprint_libs": [], "pinned_symbol_libs": []},
        "meta": {"filename": "midi2ttl.kicad_pro", "version": 3},
        "net_settings": {
            "classes": [
                {
                    "clearance": 0.2,
                    "name": "Default",
                    "track_width": 0.25,
                    "via_diameter": 0.6,
                    "via_drill": 0.3,
                    "wire_width": 6,
                }
            ],
            "meta": {"version": 3},
        },
        "pcbnew": {
            "last_paths": {"plot": "fab/", "pos_files": "fab/"},
            "page_layout_descr_file": "",
        },
        "schematic": {
            "meta": {"version": 1},
            "plot_directory": "fab/",
        },
        "sheets": [["aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", "Root"]],
        "text_variables": {},
    }
    (ROOT / "midi2ttl.kicad_pro").write_text(json.dumps(pro, indent=2), encoding="utf-8")
    (ROOT / "fp-lib-table").write_text(
        '(fp_lib_table\n  (version 7)\n  (lib (name "midi2ttl")(type "KiCad")(uri "${KIPRJMOD}/footprints/midi2ttl.pretty")(options "")(descr "custom"))\n)\n',
        encoding="utf-8",
    )
    (ROOT / "sym-lib-table").write_text(
        '(sym_lib_table\n  (version 7)\n  (lib (name "midi2ttl")(type "KiCad")(uri "${KIPRJMOD}/midi2ttl.kicad_sym")(options "")(descr "custom"))\n)\n',
        encoding="utf-8",
    )


def write_bom():
    FAB.mkdir(exist_ok=True)
    (FAB / "BOM-JLCPCB.csv").write_text(
        'Comment,Designator,Footprint,LCSC Part #\n'
        'H11L1SR2M Schmitt optocoupler SOP-6,U1,SMDIP-6_W9.53mm,C20082\n'
        '220R 1% 0603,"R1,R3,R4",R_0603_1608Metric,C22962\n'
        '470R 1% 0603,R2,R_0603_1608Metric,C23179\n'
        '100nF 50V X7R 0603,C1,C_0603_1608Metric,C14663\n'
        '1N4148W SOD-123,D1,D_SOD-123,C81598\n',
        encoding="utf-8",
    )


def export_fab():
    FAB.mkdir(exist_ok=True)
    pcb = str(ROOT / "midi2ttl.kicad_pcb")
    sch = str(ROOT / "midi2ttl.kicad_sch")

    subprocess.check_call(
        [
            "kicad-cli",
            "pcb",
            "export",
            "gerbers",
            "-o",
            str(FAB) + "/",
            "--layers",
            "F.Cu,B.Cu,F.Paste,B.Paste,F.SilkS,B.SilkS,F.Mask,B.Mask,Edge.Cuts",
            pcb,
        ]
    )
    subprocess.check_call(
        [
            "kicad-cli",
            "pcb",
            "export",
            "drill",
            "-o",
            str(FAB) + "/",
            "--format",
            "excellon",
            "--excellon-zeros-format",
            "decimal",
            "--generate-map",
            "--map-format",
            "pdf",
            pcb,
        ]
    )
    raw_cpl = FAB / "CPL-raw.csv"
    subprocess.check_call(
        [
            "kicad-cli",
            "pcb",
            "export",
            "pos",
            "-o",
            str(raw_cpl),
            "--format",
            "csv",
            "--units",
            "mm",
            "--side",
            "front",
            "--exclude-dnp",
            pcb,
        ]
    )
    # JLCPCB wants SMT only, Mid X/Y, Rotation, Layer
    smt_refs = {"U1", "R1", "R2", "R3", "R4", "C1", "D1"}
    with raw_cpl.open(newline="") as f:
        rows = list(csv.DictReader(f))
    out_rows = []
    for r in rows:
        ref = r.get("Ref") or r.get("Designator")
        if ref not in smt_refs:
            continue
        # KiCad pos Y is often negated vs board; JLCPCB accepts as exported from KiCad with --side front
        x = float(r["PosX"])
        y = float(r["PosY"])
        rot = float(r["Rot"])
        out_rows.append(
            {
                "Designator": ref,
                "Val": r.get("Val") or r.get("Value") or "",
                "Package": r.get("Package") or "",
                "Mid X": f"{x:.4f}",
                "Mid Y": f"{y:.4f}",
                "Rotation": f"{rot:.0f}",
                "Layer": "top",
            }
        )
    with (FAB / "CPL-JLCPCB.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["Designator", "Val", "Package", "Mid X", "Mid Y", "Rotation", "Layer"])
        w.writeheader()
        w.writerows(out_rows)
    raw_cpl.unlink(missing_ok=True)

    subprocess.check_call(["kicad-cli", "sch", "export", "pdf", "-o", str(FAB / "midi2ttl-schematic.pdf"), sch])
    subprocess.check_call(
        [
            "kicad-cli",
            "pcb",
            "drc",
            "-o",
            str(FAB / "drc.rpt"),
            "--severity-error",
            "--severity-warning",
            "--refill-zones",
            pcb,
        ]
    )

    # Zip gerbers for JLCPCB upload
    zpath = FAB / "midi2ttl-gerbers.zip"
    with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in FAB.iterdir():
            if p.suffix.lower() in {".gtl", ".gbl", ".gtp", ".gbp", ".gto", ".gbo", ".gts", ".gbs", ".gm1", ".drl", ".gbrjob"} or "Edge" in p.name:
                zf.write(p, p.name)
            if p.name.endswith("-drl_map.pdf"):
                zf.write(p, p.name)
    print("Exported fab files ->", FAB)


def write_readme():
    (ROOT / "README.md").write_text(
        """# midi2ttl — MIDI IN/OUT interface (monotribe / 3.3V / 5V)

Compact KiCad MIDI interface board: opto-isolated **MIDI IN**, resistor **MIDI OUT**, and a 6-pin host header matching the Korg monotribe internal serial connector. Host VCC may be **3.3 V or 5 V** with no regulator or level shifter.

## Host / monotribe pinout (JST-PH 6P “Serial”)

| Pin | Name | Board pad | Notes |
|-----|------|-----------|--------|
| 1 | /BOOT | `HOST_BOOT` | Not used (pad only) |
| 2 | RXD0 | `HOST_RX` | From optocoupler MIDI IN |
| 3 | TXD0 | `HOST_TX` | To MIDI OUT resistors |
| 4 | VCC | `HOST_VCC` | 3.3 V on monotribe; 3.3/5 V on MCU reuse |
| 5 | GND | `HOST_GND` | |
| 6 | SCK1 | `HOST_SCK` | Not used (pad only) |

Sources: [beatnic / monotribe notes](https://beatnic.jp/takedanotes/vol31/), [Gameboy Genius MIDI mod](https://blog.gg8.se/wordpress/2011/08/14/monotribe-midi-and-me/).

## Circuit

- **MIDI IN:** DIN pins 4/5 → 220 Ω + antiparallel 1N4148W into **H11L1SR2M** Schmitt optocoupler (works 3–15 V). Open-collector VO pulled up with 470 Ω to host VCC → `RX`.
- **MIDI OUT:** `VCC`—220 Ω—DIN4, `TX`—220 Ω—DIN5, DIN2 = GND. 220 Ω is MIDI-standard and works at 3.3 V with modern receivers (H11L1 threshold ~1.6 mA).
- **Why H11L1 (not 6N138):** Reliable at 3.3 V; Schmitt output; no bias resistor. 6N138 is poorly specified at 3.3 V and caused zipper noise on monotribe mods.

Connectors are **off-board**: THT wire pads with dual strain-relief holes. Two **M3** mounting holes.

## JLCPCB PCBA

Files in `fab/`:

| File | Use |
|------|-----|
| `midi2ttl-gerbers.zip` | PCB order (Gerber + drill) |
| `BOM-JLCPCB.csv` | Assembly BOM |
| `CPL-JLCPCB.csv` | Pick-and-place (SMT only) |
| `midi2ttl-schematic.pdf` | Schematic |

### Parts

| Ref | Part | LCSC | Library |
|-----|------|------|---------|
| U1 | H11L1SR2M | **C20082** | Extended (~$3 feeder on Economic) |
| R1,R3,R4 | 220 Ω 0603 1% | **C22962** | Basic |
| R2 | 470 Ω 0603 1% | **C23179** | Basic |
| C1 | 100 nF 0603 | **C14663** | Basic |
| D1 | 1N4148W SOD-123 | **C81598** | Basic |

Only U1 is Extended; passives are Basic (0 feeder fee). THT wire pads / mounting holes are hand-soldered (not in CPL).

## Wiring DIN5 (solder side)

MIDI pin numbering is easy to swap. Solder side with notch up:

- Pin 4 = current source / “+”
- Pin 5 = current sink / signal
- Pin 2 = shield/GND (OUT only)

## Regen

```bash
python3 scripts/generate_project.py
```

Opens in KiCad 10 (`midi2ttl.kicad_pro`).
""",
        encoding="utf-8",
    )


if __name__ == "__main__":
    write_project_meta()
    build_schematic()
    build_pcb()
    write_bom()
    write_readme()
    export_fab()
