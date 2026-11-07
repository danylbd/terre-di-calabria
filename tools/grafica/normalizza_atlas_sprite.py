"""Pulisce e uniforma un atlas 8x8 generato come concept per il gioco."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter, ImageOps


def _rimuovi_isole_minori(frame: Image.Image, area_minima: int) -> Image.Image:
    """Elimina residui isolati della griglia AI senza tagliare armi e mantelli."""
    alpha = frame.getchannel("A")
    larghezza, altezza = frame.size
    maschera = bytearray(1 if valore >= 96 else 0 for valore in alpha.getdata())
    visitati = bytearray(len(maschera))
    componenti: list[list[int]] = []
    for inizio, acceso in enumerate(maschera):
        if not acceso or visitati[inizio]:
            continue
        pila = [inizio]
        visitati[inizio] = 1
        componente: list[int] = []
        while pila:
            indice = pila.pop()
            componente.append(indice)
            x = indice % larghezza
            if x > 0:
                vicino = indice - 1
                if maschera[vicino] and not visitati[vicino]:
                    visitati[vicino] = 1
                    pila.append(vicino)
            if x + 1 < larghezza:
                vicino = indice + 1
                if maschera[vicino] and not visitati[vicino]:
                    visitati[vicino] = 1
                    pila.append(vicino)
            if indice >= larghezza:
                vicino = indice - larghezza
                if maschera[vicino] and not visitati[vicino]:
                    visitati[vicino] = 1
                    pila.append(vicino)
            if indice + larghezza < len(maschera):
                vicino = indice + larghezza
                if maschera[vicino] and not visitati[vicino]:
                    visitati[vicino] = 1
                    pila.append(vicino)
        componenti.append(componente)
    if not componenti:
        return frame
    principale = max(componenti, key=len)
    nucleo = bytearray(len(maschera))
    for indice in principale:
        nucleo[indice] = 255
    nucleo_img = Image.frombytes("L", frame.size, bytes(nucleo))
    vicino_alla_figura = nucleo_img.filter(ImageFilter.MaxFilter(19)).tobytes()
    sporco: list[int] = []
    for componente in componenti:
        if componente is principale:
            continue
        adiacente = any(vicino_alla_figura[indice] for indice in componente)
        if not adiacente or len(componente) < area_minima:
            sporco.extend(componente)
    if not sporco:
        return frame
    alpha_bytes = bytearray(alpha.tobytes())
    for indice in sporco:
        alpha_bytes[indice] = 0
    frame.putalpha(Image.frombytes("L", frame.size, bytes(alpha_bytes)))
    return frame


def normalizza(ingresso: Path, uscita: Path, cella: int = 128) -> None:
    immagine = Image.open(ingresso).convert("RGBA")
    if abs(immagine.width - immagine.height) > 2:
        raise ValueError(f"L'atlas deve essere quadrato: {immagine.size}")

    # I fogli generati riportano talvolta residui semitrasparenti dello sfondo.
    # Conserva l'antialias attorno ai personaggi e azzera il rumore distante.
    alpha = immagine.getchannel("A")
    maschera_figure = alpha.point(lambda valore: 255 if valore >= 128 else 0)
    contorno = maschera_figure.filter(ImageFilter.MaxFilter(5))
    alpha_pulito = Image.composite(alpha, Image.new("L", immagine.size, 0), contorno)
    immagine.putalpha(alpha_pulito)

    lato = cella * 8
    immagine = immagine.resize((lato, lato), Image.Resampling.LANCZOS)
    alpha = immagine.getchannel("A").point(lambda valore: 0 if valore < 12 else valore)
    immagine.putalpha(alpha)

    # Lascia margine trasparente attorno alla sagoma: alcuni render AI mettono i piedi
    # quasi a filo del frame, e il ridimensionamento li farebbe apparire tagliati in gioco.
    margine = max(2, round(cella * 0.03))
    ingombro = cella - margine * 2
    atlas = Image.new("RGBA", (lato, lato), (0, 0, 0, 0))
    for riga in range(8):
        for colonna in range(8):
            area = immagine.crop((colonna * cella, riga * cella,
                                  (colonna + 1) * cella, (riga + 1) * cella))
            area = area.resize((ingombro, ingombro), Image.Resampling.LANCZOS)
            atlas.alpha_composite(area, (colonna * cella + margine, riga * cella + margine))
    immagine = atlas
    alpha = immagine.getchannel("A")

    # Ogni riquadro deve contenere la figura intera, separata dai bordi del frame.
    for riga in range(8):
        for colonna in range(8):
            regione = alpha.crop((colonna * cella, riga * cella,
                                  (colonna + 1) * cella, (riga + 1) * cella))
            limiti = regione.getbbox()
            if limiti is None:
                raise ValueError(f"Frame vuoto alla riga {riga + 1}, colonna {colonna + 1}")
            x0, y0, x1, y1 = limiti
            if min(x0, y0, cella - x1, cella - y1) < 1:
                raise ValueError(f"Figura tagliata al bordo: riga {riga + 1}, colonna {colonna + 1}")

    uscita.parent.mkdir(parents=True, exist_ok=True)
    immagine.save(uscita, optimize=True)


def normalizza_griglia(ingresso: Path, uscita: Path, colonne: int, righe: int,
                       cella: int = 96) -> None:
    """Estrae una griglia di pose e le centra in celle quadrate senza deformarle."""
    if colonne < 1 or righe < 1 or cella < 16:
        raise ValueError("Colonne, righe e cella devono essere positive")
    sorgente = Image.open(ingresso).convert("RGBA")
    alpha = sorgente.getchannel("A")
    maschera = alpha.point(lambda valore: 255 if valore >= 128 else 0)
    contorno = maschera.filter(ImageFilter.MaxFilter(5))
    alpha_pulito = Image.composite(alpha, Image.new("L", sorgente.size, 0), contorno)
    sorgente.putalpha(alpha_pulito)

    atlas = Image.new("RGBA", (colonne * cella, righe * cella), (0, 0, 0, 0))
    margine = max(2, round(cella * 0.03))
    ingombro = cella - margine * 2
    for riga in range(righe):
        y0 = round(riga * sorgente.height / righe)
        y1 = round((riga + 1) * sorgente.height / righe)
        for colonna in range(colonne):
            x0 = round(colonna * sorgente.width / colonne)
            x1 = round((colonna + 1) * sorgente.width / colonne)
            frame = sorgente.crop((x0, y0, x1, y1))
            r, g, b, alpha = frame.split()
            # Alcuni fogli aggiungono un alone rosso saturo attorno alle figure.
            # Rimuovi solo i pixel neon scollegati dal personaggio, preservando
            # mantelli e bordi rossi che toccano la sagoma.
            rosso_neon = ImageChops.darker(
                ImageChops.darker(
                    r.point(lambda valore: 255 if valore > 210 else 0),
                    g.point(lambda valore: 255 if valore < 95 else 0),
                ),
                b.point(lambda valore: 255 if valore < 95 else 0),
            )
            rosso_neon = ImageChops.darker(
                rosso_neon,
                ImageChops.darker(
                    ImageChops.subtract(r, g).point(lambda valore: 255 if valore > 110 else 0),
                    ImageChops.subtract(r, b).point(lambda valore: 255 if valore > 110 else 0),
                ),
            )
            rosso_neon = ImageChops.darker(rosso_neon, alpha.point(lambda valore: 255 if valore > 32 else 0))
            nucleo = ImageChops.subtract(alpha.point(lambda valore: 255 if valore > 80 else 0), rosso_neon)
            rosso_vicino = nucleo.filter(ImageFilter.MaxFilter(11))
            alpha_pulito = ImageChops.subtract(alpha, ImageChops.subtract(rosso_neon, rosso_vicino))
            solidi = alpha_pulito.point(lambda valore: 255 if valore > 96 else 0)
            alpha_pulito = ImageChops.multiply(alpha_pulito, solidi.filter(ImageFilter.MaxFilter(5)))
            frame.putalpha(alpha_pulito)
            frame = _rimuovi_isole_minori(frame, max(32, cella * cella // 420))
            regione = frame.getchannel("A").point(lambda valore: 255 if valore >= 128 else 0)
            limiti = regione.getbbox()
            if limiti is None:
                raise ValueError(f"Frame vuoto: riga {riga + 1}, colonna {colonna + 1}")
            bx0, by0, bx1, by1 = limiti
            padding = max(2, round(cella * 0.025))
            bx0 = max(0, bx0 - padding)
            by0 = max(0, by0 - padding)
            bx1 = min(frame.width, bx1 + padding)
            by1 = min(frame.height, by1 + padding)
            figura = frame.crop((bx0, by0, bx1, by1))
            figura = ImageOps.contain(figura, (ingombro, ingombro), Image.Resampling.LANCZOS)
            x = colonna * cella + (cella - figura.width) // 2
            y = riga * cella + cella - margine - figura.height
            atlas.alpha_composite(figura, (x, y))

    uscita.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(uscita, optimize=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ingresso", type=Path)
    parser.add_argument("uscita", type=Path)
    parser.add_argument("--cella", type=int, default=128)
    parser.add_argument("--colonne", type=int, default=8)
    parser.add_argument("--righe", type=int, default=8)
    args = parser.parse_args()
    if args.colonne == 8 and args.righe == 8:
        normalizza(args.ingresso, args.uscita, args.cella)
    else:
        normalizza_griglia(args.ingresso, args.uscita, args.colonne, args.righe, args.cella)
    print(f"Atlas pulito: {args.uscita} ({args.cella}x{args.cella} per {args.colonne}x{args.righe} frame)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
