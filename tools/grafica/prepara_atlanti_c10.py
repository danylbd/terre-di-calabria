"""Build C10 compact toy-like people atlas variants from cleaned AI source sheets."""

from __future__ import annotations

import json
from pathlib import Path

from normalizza_atlas_sprite import normalizza_griglia


ROOT = Path(__file__).resolve().parents[2]
SOURCES = Path(__file__).resolve().parent / "sorgenti_direzione_c"
DESTINATION = ROOT / "assets" / "grafica"
PEOPLES = ("greci", "romani", "brettii", "saraceni", "normanni", "siculi", "sicani", "cartaginesi")
SOLDIERS = (
    "guardia", "legionario", "brettio", "cavaliere_leggero", "cavaliere_pesante",
    "guerriero_siculo", "arciere_sicano", "mercenario_cartaginese",
)
CELL = 160
META = {
    "cella": [CELL, CELL],
    "ancora": [CELL // 2, CELL - 4],
    "fotogrammi": 4,
    "direzioni": ["S", "SE", "E", "NE", "N", "NO", "O", "SO"],
    "fps": 8,
}


def _prepara(sorgente: Path, nome: str) -> None:
    if not sorgente.is_file():
        raise FileNotFoundError(f"Manca il sorgente C10: {sorgente}")
    png = DESTINATION / f"{nome}.png"
    normalizza_griglia(sorgente, png, colonne=4, righe=8, cella=CELL)
    png.with_suffix(".json").write_text(json.dumps(META, indent=2) + "\n", encoding="utf-8")
    print(f"{nome}: atlas 4x8, celle {CELL}px")


def prepara() -> None:
    for popolo in PEOPLES:
        _prepara(SOURCES / f"c10_portatore_{popolo}.png", f"c10_portatore_{popolo}")
    for tipo in SOLDIERS:
        sorgente = SOURCES / f"c10_soldato_{tipo}.png"
        if sorgente.is_file():
            _prepara(sorgente, f"c10_soldato_{tipo}")
        else:
            print(f"In attesa del sorgente C10 soldato: {tipo}")
        lotta = SOURCES / f"c10_soldato_{tipo}_lotta.png"
        if lotta.is_file():
            _prepara(lotta, f"c10_soldato_{tipo}_lotta")
        else:
            print(f"In attesa del sorgente C10 combattimento: {tipo}")


if __name__ == "__main__":
    prepara()
