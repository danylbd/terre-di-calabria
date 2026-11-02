"""La musica di Terre di Calabria (decisione 1 del 2026-11-02): brani originali scritti qui in codice come
MIDI e suonati con FluidSynth e il soundfont libero GeneralUser GS (licenza: uso libero, anche commerciale).

Brani: «mattino» (menu e mattina: ciaramella e archi), «lavoro» (tarantella del villaggio: mandolino,
fisarmonica, tamburello), «sera» (lenta: clarinetto, arpa, archi), «guerra» (timpani, ottoni, tamburi).
Melodie originali: motivi scritti a mano, sviluppati sugli accordi di ogni sezione.

Programmi esterni (solo sul computer di sviluppo, non nel gioco):
  FLUIDSYNTH = percorso di fluidsynth.exe   (predefinito C:/Users/User/Tools/fluidsynth/.../bin/fluidsynth.exe)
  SOUNDFONT  = percorso del file .sf2        (predefinito C:/Users/User/Tools/soundfont/GeneralUser-GS.sf2)
Uso: python tools/suoni/musica_fluid.py [cartella di uscita] [brani...]   (predefinita: assets/musica)
"""

import os
import random
import struct
import subprocess
import sys
import tempfile

FLUIDSYNTH = os.environ.get("FLUIDSYNTH", "C:/Users/User/Tools/fluidsynth/fluidsynth-v2.6.2-win10-x64-cpp11/bin/fluidsynth.exe")
SOUNDFONT = os.environ.get("SOUNDFONT", "C:/Users/User/Tools/soundfont/GeneralUser-GS.sf2")
TPB = 480                          # tick per battito (semiminima)

NOTE = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
# accordi: nome -> intervalli dalla fondamentale
QUALITA = {"": [0, 4, 7], "m": [0, 3, 7], "7": [0, 4, 7, 10], "m7": [0, 3, 7, 10], "sus": [0, 5, 7]}


def nota(s):
    """«F#4» -> numero MIDI."""
    n = NOTE[s[0]]
    i = 1
    while i < len(s) and s[i] in "#b":
        n += 1 if s[i] == "#" else -1
        i += 1
    return n + 12 * (int(s[i:]) + 1)


def accordo(nome, ottava=3):
    radice = nome[0]
    i = 1
    if i < len(nome) and nome[i] in "#b":
        radice += nome[i]
        i += 1
    base = nota(radice + str(ottava))
    return [base + k for k in QUALITA[nome[i:]]]


# ------------------------------------------------------------------ MIDI

class Brano:
    def __init__(self, bpm):
        self.bpm = bpm
        self.eventi = []           # (tick, ordine, bytes)
        self.programmi = {}

    def strumento(self, canale, programma, volume=100, pan=64, riverbero=60):
        self.eventi.append((0, 0, bytes([0xC0 | canale, programma])))
        self.eventi.append((0, 0, bytes([0xB0 | canale, 7, volume])))
        self.eventi.append((0, 0, bytes([0xB0 | canale, 10, pan])))
        self.eventi.append((0, 0, bytes([0xB0 | canale, 91, riverbero])))

    def suona(self, canale, altezza, inizio, durata, forza=90):
        t0 = int(inizio * TPB)
        t1 = int((inizio + durata) * TPB) - 2
        self.eventi.append((t0, 2, bytes([0x90 | canale, altezza, max(1, min(127, forza))])))
        self.eventi.append((max(t0 + 1, t1), 1, bytes([0x80 | canale, altezza, 0])))

    def salva(self, percorso):
        tempo = int(60_000_000 / self.bpm)
        dati = b"\x00\xff\x51\x03" + tempo.to_bytes(3, "big")
        ora = 0
        for t, _, b in sorted(self.eventi, key=lambda e: (e[0], e[1])):
            dati += _vlq(t - ora) + b
            ora = t
        dati += b"\x00\xff\x2f\x00"
        with open(percorso, "wb") as f:
            f.write(b"MThd" + struct.pack(">IHHH", 6, 0, 1, TPB))
            f.write(b"MTrk" + struct.pack(">I", len(dati)) + dati)


def _vlq(n):
    out = [n & 0x7F]
    n >>= 7
    while n:
        out.append((n & 0x7F) | 0x80)
        n >>= 7
    return bytes(reversed(out))


# ------------------------------------------------------------------ scrittura

def melodia(b, canale, frasi, inizio, battuta, forza=92, umano=None):
    """frasi: lista di battute, ognuna una lista di (nota o None, durata). Torna la fine."""
    t = inizio
    for bat in frasi:
        tt = t
        for n, d in bat:
            if n:
                f = forza + (umano.randint(-8, 8) if umano else 0)
                b.suona(canale, nota(n), tt, d * 0.95, f)
            tt += d
        t += battuta
    return t


def tappeto(b, canale, accordi, inizio, battuta, ottava=4, forza=60):
    """Accordi tenuti (archi, fisarmonica)."""
    for k, a in enumerate(accordi):
        for n in accordo(a, ottava):
            b.suona(canale, n, inizio + k * battuta, battuta, forza)


def basso(b, canale, accordi, inizio, battuta, schema, ottava=2, forza=85):
    """schema: lista di (battito, intervallo: 0 fondamentale, 1 quinta, 2 ottava, durata)."""
    for k, a in enumerate(accordi):
        f = accordo(a, ottava)
        for bt, iv, d in schema:
            n = [f[0], f[0] + 7, f[0] + 12][iv]
            b.suona(canale, n, inizio + k * battuta + bt, d, forza)


def arpeggio(b, canale, accordi, inizio, battuta, passo, ottava=4, forza=70, figura=(0, 1, 2, 1)):
    for k, a in enumerate(accordi):
        f = accordo(a, ottava) + [accordo(a, ottava + 1)[0]]
        t = 0.0
        i = 0
        while t < battuta - 1e-6:
            b.suona(canale, f[figura[i % len(figura)] % len(f)], inizio + k * battuta + t, passo * 1.6, forza)
            t += passo
            i += 1


def tamburi(b, schema, battute, inizio, battuta, forza=80, umano=None):
    """schema: lista di (battito, nota di batteria GM, forza relativa) su canale 9."""
    for k in range(battute):
        for bt, n, fr in schema:
            f = int(forza * fr) + (umano.randint(-6, 6) if umano else 0)
            b.suona(9, n, inizio + k * battuta + bt, 0.2, f)


def frase(testo):
    """«A4:1.5 F#4:.5 - :1» -> [(nota, durata)...]; «-» è una pausa."""
    out = []
    for p in testo.replace("- :", "-:").split():
        n, d = p.split(":")
        out.append((None if n == "-" else n, float(d)))
    return out


def battute(testo):
    return [frase(x) for x in testo.split("|")]


# ------------------------------------------------------------------ i brani

def mattino():
    """Re maggiore, 4/4, 84: la ciaramella (oboe) sopra archi e arpa; poi il flauto riprende il tema."""
    b = Brano(84)
    b.strumento(0, 68, 105, 52)          # oboe: la ciaramella
    b.strumento(1, 48, 70, 64, 80)       # archi
    b.strumento(2, 46, 85, 80)           # arpa
    b.strumento(3, 32, 85, 64)           # basso acustico
    b.strumento(4, 73, 95, 76)           # flauto
    b.strumento(5, 109, 45, 40, 70)      # bordone di zampogna
    A = ["D", "G", "D", "A", "D", "G", "A", "D", "Bm", "G", "D", "A", "G", "A", "D", "D"]
    B = ["G", "D", "Em", "A", "G", "D", "A", "D", "Bm", "F#m", "G", "D", "Em", "A7", "D", "D"]
    tema_a = battute("A4:1.5 F#4:.5 A4:1 D5:1|B4:1.5 A4:.5 G4:1 B4:1|A4:1 F#4:1 E4:1 D4:1|E4:3 - :1|"
                     "A4:1.5 F#4:.5 A4:1 D5:1|D5:1 B4:1 G4:1 B4:1|A4:1 C#5:1 E5:1.5 C#5:.5|D5:3 - :1|"
                     "F#5:1.5 E5:.5 D5:1 B4:1|B4:1 D5:1 G5:1.5 F#5:.5|F#5:1 E5:1 D5:1 A4:1|C#5:1 E5:1 A4:2|"
                     "B4:1 D5:1 G5:1 B4:1|A4:1 C#5:1 E5:1 G5:1|F#5:1.5 E5:.5 D5:1 A4:1|D5:4")
    tema_b = battute("B4:1 D5:1 G5:2|A5:1.5 F#5:.5 D5:2|G5:1 E5:1 B4:1 E5:1|C#5:3 - :1|"
                     "B4:1 D5:1 G5:1.5 F#5:.5|F#5:1 A5:1 F#5:1 D5:1|E5:1 C#5:1 A4:1 C#5:1|D5:3 - :1|"
                     "D5:1 F#5:1 B5:1.5 A5:.5|A5:1 F#5:1 C#5:2|B4:1 D5:1 G5:1 D5:1|F#5:2 D5:2|"
                     "G5:1.5 F#5:.5 E5:1 B4:1|C#5:1 E5:1 G5:1 E5:1|F#5:1.5 E5:.5 D5:1 A4:1|D5:4")
    t = 0.0
    for giro in range(2):
        voce = 0 if giro == 0 else 4
        for acc, tema in ((A, tema_a), (B, tema_b)):
            melodia(b, voce, tema, t, 4, 95 if voce == 0 else 88, random.Random(len(acc) + giro))
            tappeto(b, 1, acc, t, 4, 4, 52)
            arpeggio(b, 2, acc, t, 4, 0.5, 4, 62, (0, 1, 2, 3, 2, 1, 0, 1))
            basso(b, 3, acc, t, 4, [(0, 0, 1.8), (2, 1, 1.8)], 2, 80)
            for k in range(len(acc)):
                b.suona(5, nota("D3"), t + k * 4, 4, 40)
                b.suona(5, nota("A3"), t + k * 4, 4, 35)
            t += 4 * len(acc)
    for n in accordo("D", 4):
        b.suona(1, n, t, 6, 50)
    b.suona(0, nota("D5"), t, 6, 80)
    return b


def lavoro():
    """La minore, 6/8 (tre semiminime puntate per battuta, qui battuta = 3 battiti), 132: una tarantella
    del villaggio con mandolino, fisarmonica, chitarra e tamburello."""
    b = Brano(132)
    b.strumento(0, 25, 100, 50)          # mandolino (chitarra d'acciaio, pizzicata svelta)
    b.strumento(1, 21, 72, 78)           # fisarmonica
    b.strumento(2, 24, 85, 64)           # chitarra battente (nylon)
    b.strumento(3, 33, 85, 64)           # basso
    b.strumento(4, 71, 85, 70)           # clarinetto nella seconda parte
    A = ["Am", "Am", "E7", "Am", "Dm", "Am", "E7", "Am"]
    B = ["C", "G7", "C", "Am", "Dm", "Am", "E7", "Am"]
    terzine = lambda s: battute(s)
    tema_a = terzine("E5:.5 A5:.5 B5:.5 C6:.5 B5:.5 A5:.5|E5:.5 A5:.5 B5:.5 C6:1.5|"
                     "B5:.5 G#5:.5 E5:.5 B5:.5 G#5:.5 E5:.5|A5:1.5 E5:1.5|"
                     "F5:.5 A5:.5 D6:.5 C6:.5 B5:.5 A5:.5|E5:.5 A5:.5 C6:.5 B5:.5 A5:.5 G5:.5|"
                     "G#5:.5 B5:.5 E6:.5 D6:.5 C6:.5 B5:.5|A5:1.5 - :1.5")
    tema_b = terzine("G5:.5 E5:.5 C5:.5 G5:.5 E5:.5 C5:.5|F5:.5 D5:.5 B4:.5 G5:1.5|"
                     "E5:.5 G5:.5 C6:.5 B5:.5 C6:.5 D6:.5|C6:.5 B5:.5 A5:.5 E5:1.5|"
                     "D5:.5 F5:.5 A5:.5 D6:.5 C6:.5 A5:.5|C6:.5 B5:.5 A5:.5 E5:.5 C5:.5 A4:.5|"
                     "B4:.5 E5:.5 G#5:.5 B5:.5 D6:.5 B5:.5|A5:1.5 A4:1.5")
    tamburello = [(0, 54, 1.0), (0.5, 54, 0.5), (1, 54, 0.6), (1.5, 54, 0.9), (2, 54, 0.5), (2.5, 54, 0.6)]
    t = 0.0
    umano = random.Random(7)
    for giro in range(3):
        for acc, tema in ((A, tema_a), (B, tema_b), (A, tema_a)):
            voce = 4 if giro == 1 and acc is B else 0
            melodia(b, voce, tema, t, 3, 96, umano)
            tappeto(b, 1, acc, t, 3, 4, 48)
            arpeggio(b, 2, acc, t, 3, 0.5, 3, 66, (0, 1, 2, 1, 2, 1))
            basso(b, 3, acc, t, 3, [(0, 0, 1.4), (1.5, 1, 1.4)], 2, 82)
            tamburi(b, tamburello, len(acc), t, 3, 70, umano)
            t += 3 * len(acc)
    b.suona(0, nota("A5"), t, 3, 90)
    for n in accordo("Am", 3):
        b.suona(2, n, t, 3, 80)
    b.suona(3, nota("A2"), t, 3, 85)
    b.suona(9, 54, t, 0.3, 90)
    return b


def sera():
    """Fa maggiore, 3/4, 66: il clarinetto canta sopra l'arpa e gli archi, la sera sul villaggio."""
    b = Brano(66)
    b.strumento(0, 71, 95, 56)           # clarinetto
    b.strumento(1, 49, 62, 64, 90)       # archi lenti
    b.strumento(2, 46, 80, 82)           # arpa
    b.strumento(3, 42, 70, 46)           # violoncello
    b.strumento(4, 73, 80, 72)           # flauto (eco)
    A = ["F", "Dm", "Bb", "C", "F", "Am", "Bb", "C7", "Dm", "Am", "Bb", "F", "Gm", "C7", "F", "F"]
    tema = battute("C5:2 A4:1|D5:2 F5:1|D5:1.5 C5:.5 Bb4:1|C5:3|"
                   "C5:2 A4:1|E5:2 C5:1|D5:1 F5:1 D5:1|C5:2 - :1|"
                   "A5:2 F5:1|E5:2 C5:1|D5:1 F5:1 Bb5:1|A5:3|"
                   "G5:1.5 F5:.5 D5:1|E5:1 G5:1 Bb5:1|A5:1.5 G5:.5 C5:1|F5:3")
    t = 0.0
    for giro in range(3):
        melodia(b, 0 if giro != 1 else 4, tema, t, 3, 84, random.Random(giro))
        tappeto(b, 1, A, t, 3, 4, 46)
        arpeggio(b, 2, A, t, 3, 0.5, 3, 58, (0, 1, 2, 3, 2, 1))
        for k, a in enumerate(A):
            b.suona(3, accordo(a, 2)[0], t + k * 3, 3, 70)
        t += 3 * len(A)
    for n in accordo("F", 4):
        b.suona(1, n, t, 6, 45)
    b.suona(2, nota("F3"), t, 6, 60)
    return b


def guerra():
    """Re minore, 4/4, 112: tamburi di guerra, timpani, corni e tromboni, archi in tremolo."""
    b = Brano(112)
    b.strumento(0, 60, 100, 50)          # corni
    b.strumento(1, 57, 92, 78)           # tromboni
    b.strumento(2, 44, 72, 64, 70)       # archi in tremolo
    b.strumento(3, 47, 100, 64, 40)      # timpani
    b.strumento(4, 48, 80, 40)           # archi (ostinato)
    b.strumento(5, 56, 90, 60)           # trombe nella ripresa
    A = ["Dm", "Dm", "Bb", "C", "Dm", "Dm", "Gm", "A7"]
    B = ["Gm", "Dm", "Bb", "A", "Gm", "Dm", "Eb", "A7"]
    tema_a = battute("D4:1.5 D4:.5 F4:1 A4:1|D5:2 C5:1 A4:1|Bb4:1.5 A4:.5 G4:1 F4:1|E4:2 C4:2|"
                     "D4:1.5 D4:.5 F4:1 A4:1|D5:1 F5:1 E5:1 D5:1|D5:1 Bb4:1 G4:1 Bb4:1|A4:3 - :1")
    tema_b = battute("G4:1 Bb4:1 D5:2|F5:1.5 E5:.5 D5:2|D5:1 C5:1 Bb4:1 F4:1|A4:2 C#5:2|"
                     "G4:1 Bb4:1 D5:1 G5:1|F5:1 E5:1 D5:1 A4:1|Bb4:1.5 C5:.5 Eb5:1 G5:1|A5:2 C#5:2")
    tamburo = [(0, 36, 1.0), (1, 38, 0.6), (1.5, 36, 0.7), (2, 36, 0.9), (2.5, 36, 0.6), (3, 38, 0.8), (3.5, 38, 0.5),
               (3.75, 38, 0.6)]
    t = 0.0
    umano = random.Random(11)
    for giro in range(3):
        for acc, tema in ((A, tema_a), (B, tema_b)):
            voce = 5 if giro == 2 else 0
            melodia(b, voce, tema, t, 4, 104, umano)
            if giro > 0:
                melodia(b, 1, [[(n.replace("5", "4").replace("4", "3", 1) if n else None, d) for n, d in bat] for bat in tema], t, 4, 80)
            tappeto(b, 2, acc, t, 4, 4, 50 + 10 * giro)
            arpeggio(b, 4, acc, t, 4, 0.5, 3, 70, (0, 0, 1, 0, 2, 0, 1, 0))
            for k, a in enumerate(acc):
                f = accordo(a, 2)[0]
                b.suona(3, f, t + k * 4, 0.5, 100)
                b.suona(3, f + 7, t + k * 4 + 2, 0.5, 85)
                b.suona(3, f, t + k * 4 + 3, 0.25, 70)
                b.suona(3, f, t + k * 4 + 3.5, 0.25, 90)
            tamburi(b, tamburo, len(acc), t, 4, 70 + 8 * giro, umano)
            t += 4 * len(acc)
    for n in accordo("Dm", 3) + accordo("Dm", 4):
        b.suona(2, n, t, 4, 80)
    b.suona(0, nota("D4"), t, 4, 100)
    b.suona(3, nota("D2"), t, 1, 110)
    b.suona(9, 49, t, 1, 100)
    return b


BRANI = {"mattino": mattino, "lavoro": lavoro, "sera": sera, "guerra": guerra}
## guadagno di FluidSynth per brano (picco intorno a 0,7, senza saturare)
GUADAGNO = {"mattino": 1.6, "lavoro": 2.2, "sera": 2.2, "guerra": 1.1}


def rendi(nome, cartella):
    b = BRANI[nome]()
    with tempfile.TemporaryDirectory() as tmp:
        mid = os.path.join(tmp, nome + ".mid")
        b.salva(mid)
        uscita = os.path.join(tmp, nome + ".oga")
        subprocess.run([FLUIDSYNTH, "-ni", "-q", "-g", str(GUADAGNO[nome]), "-r", "44100", "-T", "oga", "-F", uscita, SOUNDFONT, mid],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        destinazione = os.path.join(cartella, nome + ".ogg")
        with open(uscita, "rb") as f, open(destinazione, "wb") as g:
            g.write(f.read())
    print("%s.ogg  %d KB" % (nome, os.path.getsize(destinazione) // 1024))


def main():
    cartella = sys.argv[1] if len(sys.argv) > 1 else os.path.join("assets", "musica")
    scelti = sys.argv[2:] or list(BRANI)
    os.makedirs(cartella, exist_ok=True)
    for nome in scelti:
        rendi(nome, cartella)


if __name__ == "__main__":
    main()
