"""Compone una scena di prova con gli sprite renderizzati, su un terreno dipinto.

Serve a giudicare la grafica "come in partita" prima che esista la mappa vera.
Uso: python3 tools/studio/anteprima.py <cartella_sprite> <uscita.png>
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SPRITE = Path(sys.argv[1])
USCITA = sys.argv[2]
W, H = 1600, 900
TW, TH = 112, 56
rng = np.random.default_rng(7)


def rumore(scale, peso):
    """Rumore morbido a più scale (somma di griglie casuali ingrandite)."""
    tot = np.zeros((H, W))
    for s, p in zip(scale, peso):
        g = rng.random((H // s + 2, W // s + 2))
        img = Image.fromarray((g * 255).astype(np.uint8)).resize((W + 2 * s, H + 2 * s), Image.BICUBIC)
        tot += np.asarray(img, dtype=float)[s:s + H, s:s + W] / 255 * p
    return tot / sum(peso)


def dipingi(c1, c2, n):
    c1, c2 = np.array(c1, float), np.array(c2, float)
    return c1 + (c2 - c1) * n[..., None]


# ---------------------------------------------------------------- terreno
n_prato = rumore([90, 30, 8, 3], [0.35, 0.3, 0.2, 0.15])
terreno = dipingi((92, 128, 52), (148, 172, 78), n_prato)

# macchie più scure e fiorite
macchie = rumore([140, 40], [0.7, 0.3])
terreno = np.where((macchie > 0.62)[..., None], terreno * 0.88, terreno)
fiori = rng.random((H, W)) > 0.9985
terreno[fiori] = (236, 214, 120)

# costa e mare in basso a destra
diag = (np.arange(W)[None, :] * 0.45 + np.arange(H)[:, None] * 1.0) / (W * 0.45 + H)
costa = diag + (rumore([120, 30], [0.7, 0.3]) - 0.5) * 0.08
sabbia = dipingi((214, 186, 128), (236, 214, 160), rumore([20, 4], [0.6, 0.4]))
mare = dipingi((24, 86, 128), (52, 124, 164), rumore([160, 40, 10], [0.5, 0.3, 0.2]))
t_s = np.clip((costa - 0.80) / 0.015, 0, 1)[..., None]
t_m = np.clip((costa - 0.835) / 0.012, 0, 1)[..., None]
terreno = terreno * (1 - t_s) + sabbia * t_s
schiuma = np.exp(-((costa - 0.838) / 0.004) ** 2)[..., None] * 0.55
terreno = terreno * (1 - t_m) + mare * t_m
terreno = terreno * (1 - schiuma) + np.array((230, 240, 238)) * schiuma

img = Image.fromarray(np.clip(terreno, 0, 255).astype(np.uint8)).convert("RGBA")

# ---------------------------------------------------------------- strade di terra battuta
maschera = Image.new("L", (W, H), 0)
d = ImageDraw.Draw(maschera)
STRADE = [
    [(330, 470), (520, 560), (760, 440), (980, 550), (1180, 650)],
    [(760, 440), (640, 380), (520, 320)],
    [(980, 550), (1100, 490), (1240, 420)],
    [(520, 560), (600, 680), (720, 740)],
]
for s in STRADE:
    d.line(s, fill=255, width=34, joint="curve")
    for p in s:
        d.ellipse((p[0] - 17, p[1] - 17, p[0] + 17, p[1] + 17), fill=255)
maschera = maschera.filter(ImageFilter.GaussianBlur(5))
terra = dipingi((150, 118, 76), (196, 162, 112), rumore([12, 3], [0.5, 0.5]))
terra_img = Image.fromarray(np.clip(terra, 0, 255).astype(np.uint8)).convert("RGBA")
img = Image.composite(terra_img, img, maschera)


# ---------------------------------------------------------------- sprite
def carica(nome):
    info = json.loads((SPRITE / (nome + ".json")).read_text())
    return Image.open(SPRITE / (nome + ".png")).convert("RGBA"), info


oggetti = []  # (y_ancora, immagine, x, y)


def metti(nome, x, y):
    im, info = carica(nome)
    ax, ay = info["ancora"]
    oggetti.append((y, im, int(x - ax), int(y - ay)))


def metti_omino(nome, x, y, direzione, fotogramma):
    im, info = carica(nome)
    cw, ch = info["cella"]
    ax, ay = info["ancora"]
    cella = im.crop((fotogramma * cw, direzione * ch, (fotogramma + 1) * cw, (direzione + 1) * ch))
    oggetti.append((y, cella, int(x - ax), int(y - ay)))


metti("magazzino", 760, 400)
metti("boscaiolo", 330, 430)
metti("segheria", 520, 300)
metti("frantoio", 1240, 380)
metti("casa_greca", 1000, 610)
metti("casa_greca", 690, 760)
metti("casa_greca", 1110, 760)
for (x, y) in [(70, 300), (150, 250), (40, 420), (210, 340), (120, 500), (260, 200), (60, 620), (180, 600), (330, 170), (420, 150)]:
    metti("pino_%d" % (1 + (x + y) % 4), x, y)
for (x, y) in [(1080, 300), (1160, 250), (1330, 280), (1260, 200), (1420, 330), (1380, 450), (880, 250), (940, 180)]:
    metti("ulivo_%d" % (1 + (x + y) % 3), x, y)
for (nome, x, y, dd, f) in [
    ("portatore_tronco", 420, 515, 2, 1), ("portatore_tronco", 470, 540, 2, 5),
    ("portatore_asse", 610, 520, 3, 2), ("portatore_asse", 860, 495, 1, 6),
    ("portatore_anfora", 1060, 515, 5, 3), ("portatore_nessuno", 580, 360, 6, 4),
    ("portatore_nessuno", 1150, 470, 3, 0), ("portatore_anfora", 640, 700, 0, 2),
]:
    metti_omino(nome, x, y, dd, f)

for _, im, x, y in sorted(oggetti, key=lambda o: o[0]):
    img.alpha_composite(im, (x, y))

# leggera vignettatura e luce calda
vig = np.ones((H, W))
yy, xx = np.mgrid[0:H, 0:W]
vig = 1 - 0.25 * (((xx - W / 2) / (W / 2)) ** 2 + ((yy - H / 2) / (H / 2)) ** 2) ** 1.5
arr = np.asarray(img.convert("RGB"), dtype=float) * np.clip(vig, 0.6, 1)[..., None]
arr = arr * np.array((1.03, 1.0, 0.95))
Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)).save(USCITA)
print("scena salvata in", USCITA)
