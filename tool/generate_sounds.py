"""Generates the app's UI sound effects as small 16-bit mono WAV files.

Synthesized from scratch (no third-party samples), so there is nothing to
license. Run from the repo root:  python3 tool/generate_sounds.py
"""
import math
import struct
import wave

RATE = 44100


def tone(freq, ms, vol=0.5, decay=6.0, harmonics=(1.0, 0.35, 0.12), sweep=0.0):
    """A plucked note: a few harmonics with an exponential decay.

    `sweep` glides the pitch by that ratio over the note (0.3 = +30 %).
    """
    n = int(RATE * ms / 1000)
    out = []
    phase = [0.0] * len(harmonics)
    for i in range(n):
        t = i / n
        f = freq * (1 + sweep * t)
        env = math.exp(-decay * t) * min(1.0, i / (RATE * 0.004))
        s = 0.0
        for k, amp in enumerate(harmonics):
            phase[k] += 2 * math.pi * f * (k + 1) / RATE
            s += amp * math.sin(phase[k])
        out.append(vol * env * s / sum(harmonics))
    return out


def silence(ms):
    return [0.0] * int(RATE * ms / 1000)


def write(name, samples):
    peak = max(1e-9, max(abs(s) for s in samples))
    gain = min(1.0, 0.9 / peak)
    with wave.open(f"assets/sounds/{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(
            b"".join(struct.pack("<h", int(s * gain * 32767)) for s in samples)
        )


def mix(*parts):
    length = max(len(p) for p in parts)
    return [sum(p[i] if i < len(p) else 0.0 for p in parts) for i in range(length)]


C5, E5, G5, C6, E6, G6 = 523.25, 659.25, 783.99, 1046.5, 1318.5, 1568.0

write("tap", tone(1400, 35, vol=0.35, decay=14, harmonics=(1.0, 0.2)))
write("pop", tone(620, 90, vol=0.5, decay=7, sweep=0.45))
write("correct", tone(C6, 95, decay=5) + tone(E6, 230, decay=5))
write(
    "wrong",
    tone(233, 140, vol=0.45, decay=3, harmonics=(1.0, 0.5, 0.3, 0.2))
    + tone(196, 220, vol=0.45, decay=4, harmonics=(1.0, 0.5, 0.3, 0.2)),
)
write(
    "complete",
    tone(C5, 110, decay=4)
    + tone(E5, 110, decay=4)
    + tone(G5, 110, decay=4)
    + mix(tone(C6, 520, decay=3.5), tone(G6, 520, vol=0.2, decay=3.5)),
)
write("record_start", tone(600, 140, vol=0.45, decay=4, sweep=0.5))
write("record_stop", tone(900, 140, vol=0.45, decay=4, sweep=-0.33))
write("unlock", tone(E5, 80, decay=5) + silence(20) + tone(C6, 200, decay=4))
