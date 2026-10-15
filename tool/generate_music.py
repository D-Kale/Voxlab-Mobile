"""Generates the app's background music loops (assets/music/*.m4a).

Synthesized from scratch (no third-party samples), so there is nothing to
license. Each track is a seamless loop: the reverb tail wraps to the start.
Needs macOS `afconvert` for the AAC encode. Run from the repo root:

    python3 tool/generate_music.py
"""
import math
import os
import random
import struct
import subprocess
import wave

RATE = 22050
OUT = "assets/music"

NOTE = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7,
        "G#": 8, "A": 9, "A#": 10, "B": 11}


def hz(name):
    """'A4' -> 440.0"""
    pitch, octave = name[:-1], int(name[-1])
    return 440.0 * 2 ** ((NOTE[pitch] + 12 * (octave + 1) - 69) / 12)


class Track:
    def __init__(self, seconds):
        self.n = int(RATE * seconds)
        self.buf = [0.0] * self.n

    def add(self, start, samples, gain=1.0):
        i0 = int(start * RATE)
        for i, s in enumerate(samples):
            self.buf[(i0 + i) % self.n] += s * gain  # wraps: seamless loop


def env(i, n, attack, release):
    a = min(1.0, i / max(1, attack * RATE))
    r = min(1.0, (n - i) / max(1, release * RATE))
    return a * r


def pad(freq, dur, vol=0.12, attack=1.5, release=1.8, detune=0.004):
    """Soft pad: two slightly detuned sines plus a quiet octave."""
    n = int(dur * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        s = (math.sin(2 * math.pi * freq * (1 - detune) * t)
             + math.sin(2 * math.pi * freq * (1 + detune) * t)
             + 0.3 * math.sin(2 * math.pi * freq * 2 * t))
        out.append(vol * env(i, n, attack, release) * s / 2.3)
    return out


def pluck(freq, dur=0.9, vol=0.2, decay=5.0, bright=0.35):
    """Bell / soft key: a few harmonics with exponential decay."""
    n = int(dur * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        e = math.exp(-decay * t) * min(1.0, i / (RATE * 0.005))
        s = (math.sin(2 * math.pi * freq * t)
             + bright * math.sin(2 * math.pi * freq * 2 * t)
             + bright * 0.4 * math.sin(2 * math.pi * freq * 3.01 * t))
        out.append(vol * e * s)
    return out


def bass(freq, dur, vol=0.22):
    n = int(dur * RATE)
    return [vol * env(i, n, 0.01, 0.08)
            * (math.sin(2 * math.pi * freq * i / RATE)
               + 0.25 * math.sin(2 * math.pi * freq * 2 * i / RATE))
            for i in range(n)]


def kick(vol=0.5):
    n = int(0.28 * RATE)
    out, phase = [], 0.0
    for i in range(n):
        t = i / RATE
        f = 45 + 95 * math.exp(-t * 28)
        phase += 2 * math.pi * f / RATE
        out.append(vol * math.exp(-t * 11) * math.sin(phase))
    return out


def hat(vol=0.06, dur=0.05, seed=1):
    rnd = random.Random(seed)
    n = int(dur * RATE)
    out, prev = [], 0.0
    for i in range(n):
        x = rnd.uniform(-1, 1)
        out.append(vol * math.exp(-i / n * 6) * (x - prev))  # crude highpass
        prev = x
    return out


def clap(vol=0.12):
    return hat(vol, 0.14, seed=7)


def chord(names):
    return [hz(n) for n in names]


def ambience(track, delay=0.42, feedback=0.38, mix=0.35):
    """Feedback delay plus a gentle one-pole lowpass, wrapping around."""
    d = int(delay * RATE)
    buf = track.buf
    wet = [0.0] * track.n
    for _ in range(2):  # two passes so the wrap-around tail settles
        for i in range(track.n):
            wet[i] = buf[i - d] * mix + wet[i - d] * feedback
    lp, a = 0.0, 0.35
    for i in range(track.n):
        lp += a * ((buf[i] + wet[i]) - lp)
        buf[i] = lp


def save(name, track, peak=0.5):
    os.makedirs(OUT, exist_ok=True)
    top = max(1e-9, max(abs(s) for s in track.buf))
    gain = peak / top
    wav = f"{OUT}/{name}.wav"
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s * gain * 32767))
                               for s in track.buf))
    subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "-b", "64000",
                    wav, f"{OUT}/{name}.m4a"], check=True)
    os.remove(wav)
    print(f"{name}.m4a  {os.path.getsize(f'{OUT}/{name}.m4a') // 1024} KB")


# ── Tracks ───────────────────────────────────────────────────────────────

def map_garden():
    """Map: warm and calm, soft keys over a pad (80 BPM)."""
    beat = 60 / 80
    prog = [["C3", "E3", "G3", "B3"], ["A2", "C3", "E3", "G3"],
            ["F2", "A2", "C3", "E3"], ["G2", "B2", "D3", "A3"]]
    bar = beat * 4
    t = Track(bar * len(prog) * 2)
    rnd = random.Random(3)
    for rep in range(2):
        for c, names in enumerate(prog):
            start = (rep * len(prog) + c) * bar
            for f in chord(names):
                t.add(start, pad(f, bar + 0.6, vol=0.07))
            tones = [f * 2 for f in chord(names)]
            for step in range(8):
                if rnd.random() < 0.7:
                    t.add(start + step * beat / 2,
                          pluck(rnd.choice(tones), 1.6, 0.11, decay=3.2))
    ambience(t, 0.56, 0.4)
    return t


def focus_drift():
    """Concentration: slow drone and sparse pentatonic bells (60 BPM)."""
    beat = 1.0
    t = Track(48)
    for start, names in [(0, ["D2", "A2", "F3", "E4"]),
                         (12, ["A#1", "F2", "D3", "A3"]),
                         (24, ["G1", "D2", "A#2", "F3"]),
                         (36, ["A1", "E2", "C3", "E3"])]:
        for f in chord(names):
            t.add(start, pad(f, 13, vol=0.08, attack=3, release=3.5))
    scale = ["D4", "F4", "G4", "A4", "C5", "D5"]
    rnd = random.Random(11)
    for step in range(48):
        if rnd.random() < 0.35:
            t.add(step * beat, pluck(hz(rnd.choice(scale)), 2.5, 0.08, decay=1.6, bright=0.2))
    ambience(t, 0.75, 0.45, 0.4)
    return t


def focus_tide():
    """Concentration: steady soft arpeggio, like a metronome for the mind (70 BPM)."""
    beat = 60 / 70
    bar = beat * 4
    prog = [["A2", "E3", "C4"], ["F2", "C3", "A3"], ["C3", "G3", "E4"], ["G2", "D3", "B3"]]
    t = Track(bar * len(prog) * 2)
    for rep in range(2):
        for c, names in enumerate(prog):
            start = (rep * len(prog) + c) * bar
            for f in chord(names):
                t.add(start, pad(f, bar + 0.5, vol=0.05))
            arp = chord(names) + [chord(names)[1] * 2]
            for step in range(8):
                f = arp[step % len(arp)] * 2
                t.add(start + step * beat / 2, pluck(f, 0.9, 0.07, decay=4.5, bright=0.15))
    ambience(t, beat * 0.75, 0.35)
    return t


def focus_glass():
    """Concentration: glassy bells over an open fifth (90 BPM, sparse)."""
    beat = 60 / 90
    t = Track(beat * 64)
    for start, names in [(0, ["E2", "B2", "F#3"]), (beat * 32, ["C2", "G2", "D3"])]:
        for f in chord(names):
            t.add(start, pad(f, beat * 32 + 0.4, vol=0.07, attack=2.5, release=2.5))
    melody = ["B4", "E5", "F#5", "G5", "B5", "D5", "E5", "A4"]
    rnd = random.Random(5)
    for step in range(64):
        if step % 3 == 0 or rnd.random() < 0.15:
            t.add(step * beat, pluck(hz(melody[step % len(melody)]), 2.0, 0.07, decay=2.4, bright=0.6))
    ambience(t, beat * 1.5, 0.42, 0.4)
    return t


def upbeat_bounce():
    """Quick games: bouncy pop groove, I-V-vi-IV in F (118 BPM)."""
    beat = 60 / 118
    bar = beat * 4
    prog = [(["F3", "A3", "C4"], "F2"), (["C3", "E3", "G3"], "C2"),
            (["D3", "F3", "A3"], "D2"), (["A#2", "D3", "F3"], "A#1")]
    t = Track(bar * len(prog) * 2)
    for rep in range(2):
        for c, (names, root) in enumerate(prog):
            start = (rep * len(prog) + c) * bar
            for b in range(4):
                t.add(start + b * beat, kick(0.4) if b % 2 == 0 else clap(0.09))
                t.add(start + b * beat + beat / 2, hat(0.05))
                t.add(start + b * beat, bass(hz(root), beat * 0.45))
                t.add(start + b * beat + beat * 0.75, bass(hz(root) * 2, beat * 0.2, 0.12))
            for step in (1, 3, 5, 7):
                for f in chord(names):
                    t.add(start + step * beat / 2, pluck(f * 2, 0.35, 0.06, decay=9))
    ambience(t, beat * 0.75, 0.2, 0.2)
    return t


def upbeat_spark():
    """Quick games: energetic synth arpeggio in G (128 BPM)."""
    beat = 60 / 128
    bar = beat * 4
    prog = [(["G3", "B3", "D4"], "G1"), (["E3", "G3", "B3"], "E1"),
            (["C3", "E3", "G3"], "C2"), (["D3", "F#3", "A3"], "D2")]
    t = Track(bar * len(prog) * 2)
    for rep in range(2):
        for c, (names, root) in enumerate(prog):
            start = (rep * len(prog) + c) * bar
            for b in range(4):
                t.add(start + b * beat, kick(0.42))
                if b % 2 == 1:
                    t.add(start + b * beat, clap(0.1))
                for h in (0.5, 0.75):
                    t.add(start + b * beat + beat * h, hat(0.04, seed=b))
                t.add(start + b * beat + beat / 2, bass(hz(root) * 2, beat * 0.4))
            arp = chord(names) + [chord(names)[0] * 2]
            for step in range(16):
                t.add(start + step * beat / 4,
                      pluck(arp[step % 4] * 2, 0.22, 0.05, decay=14, bright=0.5))
    ambience(t, beat * 0.75, 0.25, 0.25)
    return t


if __name__ == "__main__":
    for name, fn in [("map_garden", map_garden), ("focus_drift", focus_drift),
                     ("focus_tide", focus_tide), ("focus_glass", focus_glass),
                     ("upbeat_bounce", upbeat_bounce), ("upbeat_spark", upbeat_spark)]:
        save(name, fn())
