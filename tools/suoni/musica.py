"""Brani segnaposto di Terre di Calabria, sintetizzati con la sola libreria standard.

Strumenti imitati in modo semplice: zampogna (bordone + chanter), lira calabrese (corda ad arco),
chitarra battente (corde pizzicate, Karplus-Strong), tamburello, archi d'orchestra (tappeto).
Melodie originali. In attesa della scelta sul modo di produrre la musica vera
(vedi docs/domande-per-il-proprietario.md).

Uso: python tools/suoni/musica.py [cartella di uscita]   (predefinita: assets/musica)
"""

import math
import os
import random
import struct
import sys

FC = 22050
rng = random.Random(1987)


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12.0)


def mescola(dest, src, inizio, vol=1.0):
    i0 = int(inizio * FC)
    fine = min(len(dest), i0 + len(src))
    for i in range(max(0, i0), fine):
        dest[i] += src[i - i0] * vol


# ------------------------------------------------------------------ strumenti

_corde = {}


def corda(midi, durata=0.9, variante=0):
    """Corda pizzicata (Karplus-Strong); le note uguali si riusano."""
    chiave = (midi, durata, variante)
    if chiave in _corde:
        return _corde[chiave]
    periodo = max(2, int(FC / hz(midi)))
    r = random.Random(midi * 31 + variante)
    buf = [r.uniform(-1, 1) for _ in range(periodo)]
    # attacco più morbido: rumore già un po' filtrato
    for i in range(1, periodo):
        buf[i] = 0.6 * buf[i] + 0.4 * buf[i - 1]
    n = int(durata * FC)
    out = [0.0] * n
    smorza = 0.996 if midi < 55 else 0.993
    for i in range(n):
        j = i % periodo
        v = buf[j]
        out[i] = v
        buf[j] = smorza * 0.5 * (v + buf[(j + 1) % periodo])
    for i in range(min(n, 400)):
        out[n - 1 - i] *= i / 400
    _corde[chiave] = out
    return out


def arco(midi, durata, vol=1.0, vibrato=5.5, luminosita=2200.0, attacco=0.08):
    """Corda ad arco (lira calabrese / violino): dente di sega con vibrato e filtro."""
    n = int(durata * FC)
    f0 = hz(midi)
    fase = 0.0
    y1 = y2 = 0.0
    a = 1.0 - math.exp(-2 * math.pi * luminosita / FC)
    out = [0.0] * n
    rilascio = min(0.12, durata * 0.3)
    for i in range(n):
        t = i / FC
        prof = 0.006 * min(1.0, t / 0.3)
        f = f0 * (1.0 + prof * math.sin(2 * math.pi * vibrato * t))
        fase = (fase + f / FC) % 1.0
        v = 2.0 * fase - 1.0 + rng.uniform(-0.08, 0.08)   # fruscio dell'archetto
        y1 += a * (v - y1)
        y2 += a * (y1 - y2)
        env = min(1.0, t / attacco) * min(1.0, (durata - t) / rilascio)
        out[i] = y2 * env * vol
    return out


def ancia(midi, durata, vol=1.0, luminosita=1800.0, vibrato=0.0):
    """Canna della zampogna: onda a impulsi stretti, nasale."""
    n = int(durata * FC)
    f0 = hz(midi)
    fase = 0.0
    y1 = y2 = 0.0
    a = 1.0 - math.exp(-2 * math.pi * luminosita / FC)
    out = [0.0] * n
    for i in range(n):
        t = i / FC
        f = f0 * (1.0 + 0.004 * math.sin(2 * math.pi * vibrato * t)) if vibrato else f0
        fase = (fase + f / FC) % 1.0
        v = 1.0 if fase < 0.28 else -0.39
        y1 += a * (v - y1)
        y2 += a * (y1 - y2)
        env = min(1.0, t / 0.03) * min(1.0, (durata - t) / 0.03)
        out[i] = y2 * env * vol
    return out


def archi(accordo, durata, vol=1.0):
    """Tappeto d'archi: più voci leggermente stonate tra loro, attacco lento."""
    n = int(durata * FC)
    out = [0.0] * n
    for k, midi in enumerate(accordo):
        for stonatura in (-0.12, 0.0, 0.11):
            f0 = hz(midi + stonatura)
            fase = rng.random()
            y = 0.0
            a = 1.0 - math.exp(-2 * math.pi * 1400 / FC)
            for i in range(n):
                fase = (fase + f0 / FC) % 1.0
                y += a * ((2.0 * fase - 1.0) - y)
                out[i] += y
    attacco = min(0.6, durata * 0.4)
    for i in range(n):
        t = i / FC
        out[i] *= vol / (3 * len(accordo)) * min(1.0, t / attacco) * min(1.0, (durata - t) / attacco)
    return out


_colpi = {}


def tamburello(forte):
    """Colpo di tamburello: pelle grave e sonagli."""
    chiave = round(forte, 1)
    if chiave in _colpi:
        return _colpi[chiave]
    n = int(0.35 * FC)
    out = [0.0] * n
    lo = 0.0
    a = 1.0 - math.exp(-2 * math.pi * 4000 / FC)
    for i in range(n):
        t = i / FC
        pelle = math.sin(2 * math.pi * (95 + 60 * math.exp(-t * 40)) * t) * math.exp(-t * 18) * forte
        r = rng.uniform(-1, 1)
        # sonagli: rumore acuto (passa-alto) con decadimento più lungo, un po' tremolante
        lo += a * (r - lo)
        sonagli = (r - lo) * math.exp(-t * 11) * (0.7 + 0.3 * math.sin(t * 190)) * (0.4 + 0.6 * forte)
        out[i] = pelle * 0.9 + sonagli * 0.35
    _colpi[chiave] = out
    return out


def riverbero(x, stanza=0.78, umido=0.22):
    """Riverbero di Schroeder: quattro filtri a pettine e due passa-tutto."""
    n = len(x)
    somma = [0.0] * n
    for ritardo in (1116, 1188, 1277, 1356):
        ritardo = int(ritardo * FC / 44100)
        buf = [0.0] * ritardo
        smorz = 0.0
        for i in range(n):
            j = i % ritardo
            uscita = buf[j]
            smorz = uscita * 0.6 + smorz * 0.4
            buf[j] = x[i] + smorz * stanza
            somma[i] += uscita
    for ritardo in (556, 441):
        ritardo = int(ritardo * FC / 44100)
        buf = [0.0] * ritardo
        for i in range(n):
            j = i % ritardo
            b = buf[j]
            v = somma[i]
            buf[j] = v + b * 0.5
            somma[i] = b - v * 0.5
    return [a * (1 - umido) + b * umido * 0.25 for a, b in zip(x, somma)]


def finisci(x, sfumatura=1.5):
    x = riverbero(x)
    m = max(1e-9, max(abs(v) for v in x))
    n = int(sfumatura * FC)
    out = [v * 0.85 / m for v in x]
    for i in range(min(n, len(out))):
        out[len(out) - 1 - i] *= i / n
    for i in range(200):
        out[i] *= i / 200
    return out


def scrivi(percorso, x):
    dati = struct.pack("<%dh" % len(x), *(int(max(-1.0, min(1.0, v)) * 32767) for v in x))
    fmt = struct.pack("<IHHIIHH", 16, 1, 1, FC, FC * 2, 2, 16)
    with open(percorso, "wb") as f:
        f.write(b"RIFF" + struct.pack("<I", 4 + 8 + 16 + 8 + len(dati)) + b"WAVE")
        f.write(b"fmt " + fmt + b"data" + struct.pack("<I", len(dati)) + dati)


# ------------------------------------------------------------------ aiuti di scrittura

def suona_melodia(dest, melodia, ottavo, inizio, strumento):
    """melodia: lista di (nota midi o None per pausa, durata in ottavi)."""
    t = inizio
    for nota, ottavi in melodia:
        if nota is not None:
            mescola(dest, strumento(nota, ottavi * ottavo), t)
        t += ottavi * ottavo
    return t


ACCORDI = {
    "D": [50, 57, 62, 66, 69], "Dm": [50, 57, 62, 65, 69], "G": [43, 55, 59, 62, 67], "Gm": [43, 55, 58, 62, 67],
    "C": [48, 55, 60, 64, 67], "A": [45, 57, 61, 64, 69], "A7": [45, 55, 61, 64, 69], "Bb": [46, 53, 58, 62, 65],
    "F": [41, 53, 57, 60, 65],
}


# ------------------------------------------------------------------ i brani

def mattino():
    """«Alba sulla costa»: pastorale in 6/8 per zampogna, con archi in sottofondo."""
    ottavo = 0.3
    battuta = 6 * ottavo
    melodia = [
        (66, 2), (67, 1), (69, 3), (71, 1), (69, 1), (67, 1), (66, 3),
        (67, 1), (69, 1), (72, 1), (71, 2), (69, 1), (69, 3), (66, 3),
        (71, 2), (72, 1), (74, 3), (72, 1), (71, 1), (69, 1), (67, 3),
        (66, 1), (67, 1), (69, 1), (71, 1), (69, 1), (67, 1), (66, 3), (62, 3),
    ]
    accordi = ["D", "D", "C", "D", "G", "C", "G", "D"]
    giri = 3
    durata = battuta * (2 + 8 * giri) + 1.5
    x = [0.0] * int(durata * FC)
    # bordone della zampogna per tutto il brano (re e la), entra subito
    corpo = durata - 1.5
    mescola(x, ancia(50, corpo, 0.22, 900), 0.0)
    mescola(x, ancia(57, corpo, 0.16, 1100), 0.0)
    t = 2 * battuta
    for giro in range(giri):
        voce = (lambda n, d: ancia(n + 12, d, 0.32, 2400, 5.0)) if giro != 1 else (lambda n, d: arco(n + 12, d, 0.42))
        suona_melodia(x, melodia, ottavo, t, voce)
        if giro > 0:
            for k, a in enumerate(accordi):
                mescola(x, archi(ACCORDI[a][1:4], battuta + 0.3, 0.5), t + k * battuta)
        if giro == 2:
            # chitarra battente: un accordo arpeggiato a inizio battuta
            for k, a in enumerate(accordi):
                for s, nota in enumerate(ACCORDI[a][:4]):
                    mescola(x, corda(nota, 1.4), t + k * battuta + s * 0.025, 0.25)
        t += 8 * battuta
    return finisci(x)


def lavoro():
    """«Tarantella del bosco»: 6/8 vivace con tamburello, chitarra battente e lira."""
    ottavo = 0.16
    battuta = 6 * ottavo
    tema = [
        (74, 1), (77, 1), (81, 1), (81, 1), (79, 1), (77, 1),
        (76, 1), (79, 1), (82, 1), (81, 1), (79, 1), (76, 1),
        (73, 1), (76, 1), (79, 1), (81, 3),
        (77, 1), (76, 1), (74, 1), (74, 3),
        (81, 1), (82, 1), (81, 1), (79, 1), (77, 1), (76, 1),
        (79, 1), (77, 1), (76, 1), (74, 2), (79, 1),
        (76, 1), (73, 1), (69, 1), (73, 1), (76, 1), (79, 1),
        (77, 3), (74, 3),
    ]
    accordi = ["Dm", "A7", "A7", "Dm", "Dm", "Gm", "A7", "Dm"]
    sezioni = 4
    durata = battuta * (2 + 8 * sezioni + 1) + 1.5
    x = [0.0] * int(durata * FC)
    accenti = [1.0, 0.45, 0.6, 0.9, 0.45, 0.6]
    battute = ["Dm", "A7"] + accordi * sezioni + ["Dm"]
    for b, a in enumerate(battute):
        t0 = b * battuta
        for k in range(6):
            mescola(x, tamburello(accenti[k]), t0 + k * ottavo, 0.5)
            # chitarra battente: accordo battuto su ogni ottavo, in giù e in su
            corde = ACCORDI[a][1:5] if k % 2 == 0 else list(reversed(ACCORDI[a][2:5]))
            for s, nota in enumerate(corde):
                mescola(x, corda(nota, 0.45, k % 2), t0 + k * ottavo + s * 0.012, 0.16 * accenti[k])
        mescola(x, corda(ACCORDI[a][0], 0.9), t0, 0.45)
        mescola(x, corda(ACCORDI[a][0] + 7, 0.6), t0 + 3 * ottavo, 0.3)
    t = 2 * battuta
    for s in range(sezioni):
        if s == 0:
            voce = lambda n, d: arco(n, d, 0.5, 6.0, 2600, 0.03)
        elif s == 1:
            voce = lambda n, d: ancia(n, d, 0.38, 2600, 5.5)
        elif s == 2:
            voce = lambda n, d: arco(n - 12, d, 0.55, 6.0, 2000, 0.03)
        else:
            voce = lambda n, d: arco(n, d, 0.45, 6.0, 2600, 0.03)
        suona_melodia(x, tema, ottavo, t, voce)
        if s == 3:
            suona_melodia(x, tema, ottavo, t, lambda n, d: ancia(n - 12, d, 0.3, 2000))
        t += 8 * battuta
    return finisci(x)


def sera():
    """«Sera alla marina»: 3/4 lento, lira e chitarra arpeggiata, archi."""
    ottavo = 0.28
    battuta = 6 * ottavo
    melodia = [
        (69, 4), (70, 1), (69, 1), (65, 4), (62, 2),
        (64, 2), (67, 2), (72, 2), (69, 6),
        (70, 3), (69, 1), (67, 2), (65, 2), (64, 2), (62, 2),
        (64, 2), (61, 2), (64, 2), (62, 6),
    ]
    accordi = ["Dm", "Bb", "C", "F", "Gm", "Dm", "A", "Dm"]
    giri = 3
    durata = battuta * (1 + 8 * giri) + 2.0
    x = [0.0] * int(durata * FC)
    figura = [0, 2, 3, 2, 4, 2]          # arpeggio: indici nelle note dell'accordo
    for g in range(giri):
        for k, a in enumerate(accordi):
            t0 = battuta * (1 + 8 * g + k)
            for i, idx in enumerate(figura):
                mescola(x, corda(ACCORDI[a][idx] + (12 if idx == 0 else 0), 1.2), t0 + i * ottavo, 0.3)
            if g > 0:
                mescola(x, archi(ACCORDI[a][1:4], battuta + 0.4, 0.55), t0)
    for i, idx in enumerate(figura):
        mescola(x, corda(ACCORDI["Dm"][idx] + (12 if idx == 0 else 0), 1.2), i * ottavo, 0.3)
    t = battuta
    for g in range(giri):
        if g == 1:
            voce = lambda n, d: ancia(n + 12, d, 0.3, 2000, 5.0)
        else:
            voce = lambda n, d: arco(n, d, 0.6, 5.0, 1900, 0.15)
        suona_melodia(x, melodia, ottavo, t, voce)
        t += 8 * battuta
    return finisci(x)


def principale():
    uscita = sys.argv[1] if len(sys.argv) > 1 else os.path.join("assets", "musica")
    os.makedirs(uscita, exist_ok=True)
    for nome, f in (("mattino", mattino), ("lavoro", lavoro), ("sera", sera)):
        x = f()
        scrivi(os.path.join(uscita, nome + ".wav"), x)
        print("scritto %s (%.0f s)" % (nome, len(x) / FC))


if __name__ == "__main__":
    principale()
