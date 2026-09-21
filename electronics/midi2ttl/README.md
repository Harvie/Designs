# midi2ttl — MIDI IN/OUT interface (monotribe / 3.3V / 5V)

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
