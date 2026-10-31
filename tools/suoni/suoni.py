"""Sintetizza i suoni di lavoro, natura e interfaccia di Terre di Calabria.

Solo libreria standard (wave, math, random): niente campioni registrati, tutto generato.
Uso: python tools/suoni/suoni.py [cartella_uscita] [nomi...]
I suoni d'ambiente in loop hanno il blocco "smpl" nel WAV, così Godot li importa già in loop.
"""

import math
import os
import random
import struct
import sys
import wave

FC = 44100  # frequenza di campionamento
DUE_PI = 2.0 * math.pi


# ------------------------------------------------------------------ mattoni

def silenzio(secondi):
    return [0.0] * int(secondi * FC)


def rumore(n, rng):
    return [rng.uniform(-1.0, 1.0) for _ in range(n)]


def passa_basso(x, taglio):
    a = 1.0 - math.exp(-DUE_PI * taglio / FC)
    y, s = [], 0.0
    for v in x:
        s += a * (v - s)
        y.append(s)
    return y


def passa_alto(x, taglio):
    basso = passa_basso(x, taglio)
    return [a - b for a, b in zip(x, basso)]


def passa_banda(x, centro, q):
    """Biquad passa-banda (guadagno 0 dB al centro)."""
    w = DUE_PI * centro / FC
    alfa = math.sin(w) / (2.0 * q)
    b0, b2 = alfa, -alfa
    a0, a1, a2 = 1.0 + alfa, -2.0 * math.cos(w), 1.0 - alfa
    b0, b2, a1, a2 = b0 / a0, b2 / a0, a1 / a0, a2 / a0
    y = []
    x1 = x2 = y1 = y2 = 0.0
    for v in x:
        u = b0 * v + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1 = x1, v
        y2, y1 = y1, u
        y.append(u)
    return y


def inviluppo(n, attacco, decadimento):
    """Attacco lineare e decadimento esponenziale (tempi in secondi)."""
    na = max(1, int(attacco * FC))
    k = 1.0 / max(1e-4, decadimento * FC)
    return [i / na if i < na else math.exp(-(i - na) * k) for i in range(n)]


def per(x, env):
    return [a * b for a, b in zip(x, env)]


def mescola(dest, src, inizio=0.0, vol=1.0):
    i0 = int(inizio * FC)
    if len(dest) < i0 + len(src):
        dest.extend([0.0] * (i0 + len(src) - len(dest)))
    for i, v in enumerate(src):
        dest[i0 + i] += v * vol
    return dest


def risonanza(n, freq, decadimento, fase=0.0):
    k = 1.0 / (decadimento * FC)
    return [math.sin(DUE_PI * freq * i / FC + fase) * math.exp(-i * k) for i in range(n)]


def normalizza(x, picco=0.85):
    m = max(1e-9, max(abs(v) for v in x))
    return [v * picco / m for v in x]


def dissolvi_bordi(x, entrata=0.003, uscita=0.02):
    ne, nu = int(entrata * FC), int(uscita * FC)
    for i in range(min(ne, len(x))):
        x[i] *= i / ne
    for i in range(min(nu, len(x))):
        x[-1 - i] *= i / nu
    return x


def chiudi_loop(x, sovrapposizione):
    """Rende il suono ciclico: la coda sfuma dentro l'inizio."""
    n = int(sovrapposizione * FC)
    corpo = x[n:]
    for i in range(n):
        t = i / n
        corpo[-n + i] = corpo[-n + i] * math.cos(t * math.pi / 2) + x[i] * math.sin(t * math.pi / 2)
    return corpo


def salva(cartella, nome, x, loop=False):
    os.makedirs(cartella, exist_ok=True)
    percorso = os.path.join(cartella, nome + ".wav")
    dati = b"".join(struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32767)) for v in x)
    with wave.open(percorso, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FC)
        w.writeframes(dati)
    if loop:
        _aggiungi_smpl(percorso, len(x))
    print(f"{nome}.wav  {len(x) / FC:.2f}s{'  (loop)' if loop else ''}")


def _aggiungi_smpl(percorso, campioni):
    """Aggiunge il blocco "smpl" con un loop su tutto il file (letto dall'import di Godot)."""
    smpl = struct.pack("<9I", 0, 0, int(1e9 / FC), 60, 0, 0, 0, 1, 0)
    smpl += struct.pack("<6I", 0, 0, 0, campioni - 1, 0, 0)
    with open(percorso, "rb") as f:
        b = bytearray(f.read())
    b += b"smpl" + struct.pack("<I", len(smpl)) + smpl
    b[4:8] = struct.pack("<I", len(b) - 8)
    with open(percorso, "wb") as f:
        f.write(b)


# ------------------------------------------------------------------ suoni di lavoro

def ascia(rng):
    """Colpo d'ascia nel tronco: schiocco secco, legno che risuona basso."""
    n = int(0.45 * FC)
    x = per(passa_banda(rumore(n, rng), 1800 + rng.uniform(-200, 200), 1.2), inviluppo(n, 0.001, 0.018))
    legno = [0.0] * n
    for f, a, d in ((180 + rng.uniform(-15, 15), 1.0, 0.09), (410, 0.5, 0.05), (760, 0.25, 0.03)):
        mescola(legno, risonanza(n, f, d), 0.0, a)
    x = [a * 1.3 + b * 0.8 for a, b in zip(x, legno)]
    tonfo = per(passa_basso(rumore(n, rng), 300), inviluppo(n, 0.002, 0.05))
    x = [a + b * 1.5 for a, b in zip(x, tonfo)]
    return dissolvi_bordi(normalizza(x))


def piccone(rng):
    """Piccone sulla roccia: tintinnio metallico acuto e sassolini."""
    n = int(0.6 * FC)
    x = [0.0] * n
    base = 2300 + rng.uniform(-150, 150)
    for k, a in ((1.0, 1.0), (2.76, 0.5), (5.4, 0.3), (8.9, 0.15)):
        mescola(x, risonanza(n, base * k, 0.12 / k ** 0.5), 0.0, a)
    schiocco = per(passa_alto(rumore(n, rng), 2500), inviluppo(n, 0.0005, 0.012))
    x = [a * 0.6 + b * 1.4 for a, b in zip(x, schiocco)]
    for _ in range(rng.randint(3, 6)):  # sassolini che cadono
        t = rng.uniform(0.08, 0.4)
        m = int(0.03 * FC)
        sasso = per(passa_banda(rumore(m, rng), rng.uniform(2500, 5000), 3.0), inviluppo(m, 0.0005, 0.006))
        mescola(x, sasso, t, rng.uniform(0.15, 0.4))
    return dissolvi_bordi(normalizza(x[:n]))


def sega(rng):
    """Una passata di sega a mano: andata e ritorno, rumore con denti che grattano."""
    durata = 1.4
    n = int(durata * FC)
    x = rumore(n, rng)
    denti = [0.55 + 0.45 * math.sin(DUE_PI * 95 * i / FC) ** 2 for i in range(n)]
    x = per(x, denti)
    x = [a * 0.6 + b for a, b in zip(passa_banda(x, 3200, 0.9), passa_banda(x, 1300, 1.5))]
    corsa = [math.sin(math.pi * ((i / n * 2) % 1.0)) ** 0.7 for i in range(n)]  # due passate
    return dissolvi_bordi(normalizza(per(x, corsa), 0.7), 0.01, 0.05)


def vanga(rng):
    """Il guardaboschi pianta: vanga nella terra e terra smossa."""
    n = int(0.5 * FC)
    x = per(passa_basso(rumore(n, rng), 1200), inviluppo(n, 0.004, 0.08))
    crunch = per(passa_banda(rumore(n, rng), 700, 0.8), [rng.random() ** 6 for _ in range(n)])
    x = [a + b * 0.6 for a, b in zip(x, per(crunch, inviluppo(n, 0.01, 0.15)))]
    return dissolvi_bordi(normalizza(x, 0.7))


def martello(rng):
    """Martello sul cantiere: chiodo nel legno."""
    n = int(0.35 * FC)
    x = [0.0] * n
    mescola(x, risonanza(n, 1250 + rng.uniform(-80, 80), 0.04), 0.0, 0.7)
    mescola(x, risonanza(n, 3400, 0.015), 0.0, 0.3)
    mescola(x, risonanza(n, 220, 0.06), 0.0, 0.8)
    x = [a + b for a, b in zip(x, per(passa_banda(rumore(n, rng), 2000, 0.8), inviluppo(n, 0.0005, 0.01)))]
    return dissolvi_bordi(normalizza(x))


def albero_cade(rng):
    """Scricchiolio, fronde che frusciano e tonfo a terra."""
    x = silenzio(2.6)
    # scricchiolii del legno che cede
    for i in range(14):
        t = 0.05 + i * 0.045 + rng.uniform(0, 0.02)
        m = int(0.05 * FC)
        cr = per(passa_banda(rumore(m, rng), rng.uniform(600, 1400), 6.0), inviluppo(m, 0.002, 0.012))
        mescola(x, cr, t, 0.5 + i * 0.04)
    # fruscio delle fronde che cadono
    m = int(1.3 * FC)
    fr = passa_banda(rumore(m, rng), 3000, 0.6)
    fr = per(fr, [math.sin(math.pi * i / m) ** 2 for i in range(m)])
    mescola(x, fr, 0.7, 0.5)
    # tonfo
    m = int(1.0 * FC)
    tonfo = per(passa_basso(rumore(m, rng), 180), inviluppo(m, 0.003, 0.18))
    mescola(tonfo, risonanza(m, 70, 0.2), 0.0, 0.6)
    mescola(x, tonfo, 1.65, 2.2)
    rimbalzo = per(passa_basso(rumore(m, rng), 400), inviluppo(m, 0.002, 0.08))
    mescola(x, rimbalzo, 1.95, 0.7)
    return dissolvi_bordi(normalizza(x), 0.003, 0.2)


# ------------------------------------------------------------------ interfaccia

def clic(rng):
    """Clic di legno per i pulsanti."""
    n = int(0.08 * FC)
    x = [0.0] * n
    mescola(x, risonanza(n, 1700, 0.012), 0.0, 1.0)
    mescola(x, risonanza(n, 2900, 0.006), 0.0, 0.5)
    x = [a + b for a, b in zip(x, per(passa_alto(rumore(n, rng), 3000), inviluppo(n, 0.0003, 0.003)))]
    return dissolvi_bordi(normalizza(x, 0.5))


def posa(rng):
    """Edificio piazzato: colpo sordo di paletto nel terreno."""
    n = int(0.4 * FC)
    x = per(passa_basso(rumore(n, rng), 500), inviluppo(n, 0.002, 0.05))
    mescola(x, risonanza(n, 140, 0.08), 0.0, 0.7)
    mescola(x, risonanza(n, 520, 0.03), 0.0, 0.3)
    return dissolvi_bordi(normalizza(x, 0.7))


def nota(freq, durata, rng, vol=1.0):
    """Nota pizzicata (Karplus-Strong): una corda di chitarra battente."""
    n = int(durata * FC)
    periodo = max(2, int(FC / freq))
    buf = [rng.uniform(-1, 1) for _ in range(periodo)]
    y = []
    for i in range(n):
        v = buf[i % periodo]
        buf[i % periodo] = 0.996 * 0.5 * (v + buf[(i + 1) % periodo])
        y.append(v * vol)
    return y


def completato(rng):
    """Edificio finito: due corde pizzicate in quinta, piccolo segnale allegro."""
    x = silenzio(1.2)
    mescola(x, nota(392.0, 1.1, rng), 0.0, 0.8)    # sol
    mescola(x, nota(587.3, 1.0, rng), 0.12, 0.7)   # re
    mescola(x, nota(784.0, 0.9, rng), 0.24, 0.5)   # sol acuto
    return dissolvi_bordi(normalizza(passa_basso(x, 5000), 0.6), 0.002, 0.3)


def errore(rng):
    """Azione impossibile: tonfo smorzato in due tempi verso il grave."""
    x = silenzio(0.35)
    for t, f in ((0.0, 330.0), (0.12, 247.0)):
        m = int(0.2 * FC)
        mescola(x, per(nota(f, 0.2, rng), inviluppo(m, 0.002, 0.06)), t, 0.8)
    return dissolvi_bordi(normalizza(passa_basso(x, 2500), 0.5))


# ------------------------------------------------------------------ ambiente (in loop)

def vento(rng):
    durata = 16.0
    n = int(durata * FC)
    x = passa_basso(rumore(n, rng), 900)
    x = passa_alto(x, 120)
    # raffiche lente: somma di sinusoidi a frequenze basse
    raffiche = [0.55 + 0.25 * math.sin(DUE_PI * 0.07 * i / FC) + 0.2 * math.sin(DUE_PI * 0.19 * i / FC + 1.3)
                for i in range(n)]
    x = per(x, raffiche)
    fischio = passa_banda(rumore(n, rng), 650, 4.0)
    fischio = per(fischio, [max(0.0, math.sin(DUE_PI * 0.11 * i / FC)) ** 3 for i in range(n)])
    x = [a + b * 0.25 for a, b in zip(x, fischio)]
    return normalizza(chiudi_loop(x, 2.0), 0.6)


def mare(rng):
    """Onde sulla riva: risacca che sale e si ritira."""
    durata = 18.0
    n = int(durata * FC)
    x = [0.0] * n
    base = passa_basso(rumore(n, rng), 2500)
    t = 0.0
    while t < durata - 1.0:
        lung = rng.uniform(4.0, 6.0)
        i0, m = int(t * FC), int(lung * FC)
        for i in range(m):
            if i0 + i >= n:
                break
            f = i / m
            amp = (f / 0.3) ** 2 if f < 0.3 else math.exp(-(f - 0.3) * 4.0)
            x[i0 + i] += base[i0 + i] * amp
        t += lung * rng.uniform(0.6, 0.8)
    schiuma = per(passa_alto(rumore(n, rng), 4000), [abs(v) for v in passa_basso(x, 2)])
    x = [a + b * 0.8 for a, b in zip(x, schiuma)]
    return normalizza(chiudi_loop(x, 2.5), 0.6)


def cinguettio(rng, t0, x):
    """Un uccellino: serie di fischi con glissando."""
    f0 = rng.uniform(2800, 4500)
    note = rng.randint(2, 6)
    t = t0
    for _ in range(note):
        d = rng.uniform(0.05, 0.12)
        m = int(d * FC)
        su = rng.choice((-1, 1)) * rng.uniform(300, 1200)
        fase, y = 0.0, []
        for i in range(m):
            f = f0 + su * (i / m)
            fase += DUE_PI * f / FC
            y.append(math.sin(fase) * math.sin(math.pi * i / m) ** 2)
        mescola(x, y, t, rng.uniform(0.3, 0.6))
        t += d + rng.uniform(0.02, 0.07)
    return t


def uccelli(rng):
    durata = 20.0
    x = silenzio(durata)
    t = 0.5
    while t < durata - 2.5:
        t = cinguettio(rng, t, x) + rng.uniform(0.4, 2.5)
    # un uccello lontano che risponde (più piano e più basso)
    lontano = silenzio(durata)
    t = 1.7
    while t < durata - 2.5:
        t = cinguettio(rng, t, lontano) + rng.uniform(1.5, 4.0)
    x = [a + b * 0.35 for a, b in zip(x[:int(durata * FC)], passa_basso(lontano, 3000)[:int(durata * FC)])]
    return normalizza(chiudi_loop(x, 1.0), 0.45)


# ------------------------------------------------------------------ elenco

VARIANTI = {"ascia": (ascia, 3), "piccone": (piccone, 3), "sega": (sega, 2), "vanga": (vanga, 2),
            "martello": (martello, 3), "albero_cade": (albero_cade, 1),
            "clic": (clic, 1), "posa": (posa, 1), "completato": (completato, 1), "errore": (errore, 1)}
LOOP = {"vento": vento, "mare": mare, "uccelli": uccelli}


def main():
    cartella = sys.argv[1] if len(sys.argv) > 1 else os.path.join("assets", "suoni")
    scelti = set(sys.argv[2:])
    for nome, (funz, quante) in VARIANTI.items():
        if scelti and nome not in scelti:
            continue
        for k in range(quante):
            rng = random.Random(sum(map(ord, nome)) * 100 + k)  # seme fisso: stessi suoni a ogni rigenerazione
            salva(cartella, nome if quante == 1 else f"{nome}_{k + 1}", funz(rng))
    for nome, funz in LOOP.items():
        if scelti and nome not in scelti:
            continue
        salva(cartella, nome, funz(random.Random(sum(map(ord, nome)))), loop=True)


if __name__ == "__main__":
    main()
