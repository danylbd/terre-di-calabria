"""Dipinge le texture del terreno (ripetibili senza giunture) in assets/terreno/.

Ogni texture è costruita con rumore periodico a più scale (quindi si ripete
perfettamente) e poi "dipinta" con colori, macchie e piccoli segni
(fili d'erba, aghi di pino, sassi, crepe) come nei classici isometrici.

Uso: python3 tools/terreno/texture.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

N = 512
USCITA = Path(__file__).resolve().parents[2] / "assets" / "terreno"
USCITA.mkdir(parents=True, exist_ok=True)


def rumore(seme, scale, pesi, n=N):
    """Rumore periodico: filtro passa-banda sullo spettro di un rumore bianco."""
    rng = np.random.default_rng(seme)
    fx = np.fft.fftfreq(n)[None, :]
    fy = np.fft.fftfreq(n)[:, None]
    f = np.sqrt(fx * fx + fy * fy) * n
    tot = np.zeros((n, n))
    for s, p in zip(scale, pesi):
        bianco = np.fft.fft2(rng.standard_normal((n, n)))
        centro = n / s
        filtro = np.exp(-((f - centro) / (centro * 0.6 + 1e-6)) ** 2)
        filtro[0, 0] = 0
        c = np.real(np.fft.ifft2(bianco * filtro))
        c = (c - c.mean()) / (c.std() + 1e-9)
        tot += c * p
    tot = (tot - tot.min()) / (tot.max() - tot.min())
    return tot


def colora(n, tappe):
    """Mappa 0..1 su una scala di colori [(posizione, (r,g,b)), ...]."""
    pos = np.array([t[0] for t in tappe])
    col = np.array([t[1] for t in tappe], float)
    out = np.zeros(n.shape + (3,))
    for c in range(3):
        out[..., c] = np.interp(n, pos, col[:, c])
    return out


def tratti(img, seme, quanti, lung, colori, spessore=1, angolo=None, variazione=0.6):
    """Piccoli segni (fili d'erba, aghi) disegnati con avvolgimento ai bordi."""
    rng = np.random.default_rng(seme)
    h, w, _ = img.shape
    for _ in range(quanti):
        x, y = rng.random() * w, rng.random() * h
        a = angolo if angolo is not None else rng.random() * np.pi
        a += (rng.random() - 0.5) * variazione
        l = lung * (0.6 + rng.random() * 0.8)
        col = np.array(colori[rng.integers(len(colori))], float)
        alfa = 0.35 + rng.random() * 0.5
        passi = int(l * 2) + 1
        for t in np.linspace(0, 1, passi):
            px = int(x + np.cos(a) * l * t) % w
            py = int(y - np.sin(a) * l * t) % h
            for dx in range(spessore):
                img[py, (px + dx) % w] = img[py, (px + dx) % w] * (1 - alfa) + col * alfa
    return img


def macchie(img, seme, quanti, raggio, colore, alfa=0.5):
    rng = np.random.default_rng(seme)
    h, w, _ = img.shape
    yy, xx = np.mgrid[-raggio:raggio + 1, -raggio:raggio + 1]
    for _ in range(quanti):
        x, y = rng.integers(w), rng.integers(h)
        r = raggio * (0.4 + rng.random() * 0.6)
        m = np.clip(1 - (xx ** 2 + yy ** 2) / (r * r + 1e-6), 0, 1) * alfa
        for (dy, dx), v in np.ndenumerate(m):
            if v > 0:
                py, px = (y + dy - raggio) % h, (x + dx - raggio) % w
                img[py, px] = img[py, px] * (1 - v) + np.array(colore) * v
    return img


def salva(nome, img):
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8)).save(USCITA / f"{nome}.png")
    print("  ✓", nome)


# ---------------------------------------------------------------- prato
n = rumore(1, [128, 48, 16, 5], [0.35, 0.3, 0.2, 0.15])
img = colora(n, [(0, (78, 112, 44)), (0.45, (104, 140, 56)), (0.7, (128, 160, 66)), (1, (152, 176, 80))])
img = tratti(img, 11, 5200, 5, [(62, 96, 36), (84, 124, 46), (150, 178, 84), (120, 156, 60)], angolo=np.pi / 2, variazione=0.9)
img = macchie(img, 12, 30, 3, (226, 204, 96), 0.8)    # fiori gialli
img = macchie(img, 13, 22, 2, (240, 236, 222), 0.8)   # fiori bianchi
salva("prato", img)

# ---------------------------------------------------------------- prato secco (estate calabrese)
n = rumore(2, [128, 40, 12, 4], [0.35, 0.3, 0.2, 0.15])
img = colora(n, [(0, (128, 122, 58)), (0.5, (164, 150, 76)), (1, (194, 176, 98))])
img = tratti(img, 21, 4200, 5, [(118, 104, 50), (186, 166, 92), (140, 132, 64)], angolo=np.pi / 2, variazione=1.0)
img = macchie(img, 22, 18, 4, (96, 112, 50), 0.4)
salva("prato_secco", img)

# ---------------------------------------------------------------- sottobosco della Sila
n = rumore(3, [96, 32, 10, 3], [0.3, 0.3, 0.25, 0.15])
img = colora(n, [(0, (44, 52, 26)), (0.5, (66, 72, 36)), (1, (92, 90, 48))])
img = tratti(img, 31, 6000, 4, [(96, 70, 40), (120, 92, 52), (58, 76, 34)], variazione=3.2)  # aghi
img = macchie(img, 32, 40, 3, (110, 84, 52), 0.5)  # pigne e terra
salva("bosco", img)

# ---------------------------------------------------------------- sabbia
n = rumore(4, [128, 24, 6, 2], [0.35, 0.25, 0.25, 0.15])
img = colora(n, [(0, (196, 166, 112)), (0.5, (220, 194, 140)), (1, (238, 218, 170))])
y = np.arange(N)[:, None] + rumore(41, [64], [1])[..., ] * 40
onde = (np.sin(y * 2 * np.pi / 16) * 0.5 + 0.5) * 10
img = img - onde[..., None]
img = macchie(img, 42, 80, 1, (150, 128, 96), 0.6)  # sassolini
img = macchie(img, 43, 10, 2, (246, 240, 228), 0.8)  # conchiglie
salva("sabbia", img)

# ---------------------------------------------------------------- terra battuta
n = rumore(5, [96, 24, 6, 2], [0.3, 0.3, 0.25, 0.15])
img = colora(n, [(0, (112, 84, 54)), (0.5, (146, 114, 76)), (1, (178, 146, 102))])
img = macchie(img, 51, 160, 1, (92, 72, 50), 0.6)
img = macchie(img, 52, 60, 2, (186, 170, 140), 0.6)
salva("terra", img)

# ---------------------------------------------------------------- roccia
n = rumore(6, [160, 48, 14, 4], [0.35, 0.3, 0.2, 0.15])
img = colora(n, [(0, (92, 84, 74)), (0.4, (122, 112, 98)), (0.75, (152, 142, 124)), (1, (176, 166, 148))])
strati = (np.sin((np.arange(N)[:, None] + rumore(61, [80], [1]) * 90) * 2 * np.pi / 22) > 0.85)
img[strati] *= 0.88
crepe = rumore(62, [40, 12], [0.6, 0.4])
img[np.abs(crepe - 0.5) < 0.005] *= 0.75
img = tratti(img, 63, 90, 5, [(70, 64, 56), (190, 180, 160)], variazione=3.2)
salva("roccia", img)

# ---------------------------------------------------------------- neve
n = rumore(7, [128, 32, 8], [0.4, 0.35, 0.25])
img = colora(n, [(0, (196, 208, 222)), (0.5, (226, 234, 242)), (1, (250, 252, 255))])
img = macchie(img, 71, 30, 2, (150, 150, 150), 0.4)
salva("neve", img)

# ---------------------------------------------------------------- acqua (il movimento lo aggiunge lo shader)
n = rumore(8, [160, 48, 12], [0.45, 0.35, 0.2])
img = colora(n, [(0, (18, 70, 108)), (0.5, (30, 96, 138)), (1, (56, 128, 166))])
salva("acqua", img)

# ---------------------------------------------------------------- rumore per i bordi tra terreni (canali R,G,B,A indipendenti)
canali = [rumore(90 + k, [64, 20, 6], [0.5, 0.3, 0.2], n=256) for k in range(4)]
Image.fromarray((np.stack(canali, -1) * 255).astype(np.uint8), "RGBA").save(USCITA / "rumore_bordi.png")
print("  ✓ rumore_bordi")

# ---------------------------------------------------------------- strada di terra battuta (striscia con bordi sfumati)
L, A = 256, 48
n = rumore(120, [64, 16, 4], [0.4, 0.35, 0.25], n=L)[:A, :]
strada = colora(n, [(0, (104, 78, 50)), (0.5, (138, 106, 70)), (1, (170, 138, 96))])
strada = macchie(strada, 121, 50, 1, (100, 80, 56), 0.6)
strada = macchie(strada, 122, 25, 1, (200, 190, 168), 0.6)
v = np.abs(np.arange(A) - (A - 1) / 2) / (A / 2)
bordo = rumore(123, [24, 6], [0.6, 0.4], n=L)[:A, :] * 0.35
alfa = np.clip((1.0 - v[:, None] - bordo + 0.12) * 2.2, 0, 1)
solchi = (np.abs(v - 0.42) < 0.07)[:, None] & (n > 0.35)
strada[solchi] *= 0.85
rgba = np.dstack([np.clip(strada, 0, 255), alfa * 255]).astype(np.uint8)
Image.fromarray(rgba, "RGBA").save(USCITA / "strada.png")
print("  ✓ strada")
