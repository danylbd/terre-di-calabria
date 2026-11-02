"""Sintetizza la voce di re Italo (Rocco della Lira): un «grammelot», sillabe senza parole vere
con il tono di un vecchio cantastorie, da far suonare sotto le battute scritte dei dialoghi.

Tutto generato in codice (sintesi a formanti: impulsi della glottide filtrati come la bocca
quando dice a, e, i, o, u), niente registrazioni: la voce è originale e libera da diritti.
Uso: python tools/suoni/voce.py [cartella_uscita]
Scrive voce_italo_1.wav ... voce_italo_N.wav (l'audio del gioco le tratta come varianti di "voce_italo").
"""

import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(__file__))
from suoni import FC, DUE_PI, passa_alto, passa_basso, normalizza, dissolvi_bordi, salva  # noqa: E402

# formanti (Hz) e ampiezze relative di una voce maschile anziana
VOCALI = {
    "a": [(700, 1.0), (1100, 0.55), (2450, 0.18)],
    "e": [(500, 1.0), (1750, 0.45), (2450, 0.2)],
    "i": [(300, 1.0), (2200, 0.35), (2950, 0.18)],
    "o": [(520, 1.0), (850, 0.6), (2400, 0.12)],
    "u": [(320, 1.0), (760, 0.45), (2300, 0.08)],
}
BANDA = [80, 95, 120]                     # larghezza dei formanti
INTONAZIONE = 98.0                        # Hz: voce bassa
SILLABE = ["ta", "lo", "ri", "ma", "sa", "nu", "de", "ko", "ve", "la", "ro", "pi",
           "mo", "na", "te", "lu", "do", "ga", "si", "ba"]


def risonatore(x, freq, banda):
    """Filtro a due poli: un formante della bocca."""
    r = math.exp(-math.pi * banda / FC)
    c = 2.0 * r * math.cos(DUE_PI * freq / FC)
    d = -r * r
    g = 1.0 - r
    y1 = y2 = 0.0
    out = []
    for v in x:
        y = g * v + c * y1 + d * y2
        out.append(y)
        y2, y1 = y1, y
    return out


def glottide(n, f0_inizio, f0_fine, rng):
    """Impulsi della glottide con vibrato, tremolio d'anziano e un filo di fiato."""
    out = []
    fase = 0.0
    vib = rng.uniform(0, DUE_PI)
    for i in range(n):
        t = i / n
        f0 = f0_inizio + (f0_fine - f0_inizio) * t
        f0 *= 1.0 + 0.018 * math.sin(DUE_PI * 5.2 * i / FC + vib)        # vibrato
        f0 *= 1.0 + rng.uniform(-0.012, 0.012)                            # tremolio
        fase += f0 / FC
        if fase >= 1.0:
            fase -= 1.0
        # onda della glottide: salita morbida, chiusura rapida
        g = (math.sin(math.pi * fase / 0.6) if fase < 0.6 else 0.0) ** 2
        out.append(g - 0.3 + rng.uniform(-0.08, 0.08))
    return passa_alto(out, 60)


def vocale(lettera, durata, f0a, f0b, rng):
    n = int(durata * FC)
    sorgente = glottide(n, f0a, f0b, rng)
    voce = [0.0] * n
    for (f, a), b in zip(VOCALI[lettera], BANDA):
        f *= rng.uniform(0.97, 1.03)
        for i, v in enumerate(risonatore(sorgente, f, b)):
            voce[i] += a * v
    # attacco e coda morbidi
    for i in range(n):
        t = i / n
        voce[i] *= min(1.0, t / 0.12) * min(1.0, (1.0 - t) / 0.3)
    return voce


def consonante(lettera, rng):
    if lettera in "tkp":                                   # occlusiva sorda: piccolo scoppio
        n = int(0.035 * FC)
        x = [rng.uniform(-1, 1) * math.exp(-i / (0.006 * FC)) for i in range(n)]
        taglio = {"t": 3500, "k": 1800, "p": 900}[lettera]
        return [v * 0.35 for v in passa_alto(passa_basso(x, taglio * 2), taglio * 0.5)]
    if lettera == "s":                                     # sibilante
        n = int(0.08 * FC)
        x = passa_alto(passa_basso([rng.uniform(-1, 1) for _ in range(n)], 9000), 4000)
        return [v * 0.25 * math.sin(math.pi * i / n) for i, v in enumerate(x)]
    if lettera in "mnlrdbgv":                              # sonora: un mormorio basso
        n = int(0.05 * FC)
        x = glottide(n, INTONAZIONE, INTONAZIONE, rng)
        x = passa_basso(x, 400 if lettera in "mn" else 700)
        if lettera == "r":                                 # vibrata
            x = [v * (0.6 + 0.4 * math.sin(DUE_PI * 28 * i / FC)) for i, v in enumerate(x)]
        return [v * 0.5 * math.sin(math.pi * i / n) for i, v in enumerate(x)]
    return []


def sillaba(testo, rng):
    durata = rng.uniform(0.13, 0.2)
    f0 = INTONAZIONE * rng.uniform(0.95, 1.08)
    x = consonante(testo[0], rng) + vocale(testo[1], durata, f0 * 1.04, f0 * 0.96, rng)
    return dissolvi_bordi(normalizza(x, 0.7), 0.002, 0.015)


def main():
    cartella = sys.argv[1] if len(sys.argv) > 1 else os.path.join("assets", "suoni")
    for k, s in enumerate(SILLABE):
        salva(cartella, "voce_italo_%d" % (k + 1), sillaba(s, random.Random(7000 + k)))


if __name__ == "__main__":
    main()
