"""Esporta tavole leggibili per l'audit visivo degli atlas C in uso."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
ASSET = ROOT / "assets" / "grafica"
OUTPUT = ROOT / "docs" / "immagini"
POPOLI = ("greci", "romani", "brettii", "saraceni", "normanni", "siculi", "sicani", "cartaginesi")
SOLDATI = (
	"guardia", "legionario", "brettio", "cavaliere_leggero", "cavaliere_pesante",
	"guerriero_siculo", "arciere_sicano", "mercenario_cartaginese",
)
SFONDO = (239, 231, 215, 255)


def metadati(nome: str) -> tuple[int, int, int]:
	data = json.loads((ASSET / f"{nome}.json").read_text(encoding="utf-8"))
	return int(data["cella"][0]), int(data["cella"][1]), int(data["fotogrammi"])


def frame(nome: str, direzione: int, indice: int, lato: int) -> Image.Image:
	w, h, _ = metadati(nome)
	texture = Image.open(ASSET / f"{nome}.png").convert("RGBA")
	area = texture.crop((indice * w, direzione * h, (indice + 1) * w, (direzione + 1) * h))
	return area.resize((lato, lato), Image.Resampling.LANCZOS)


def tavola_coloni() -> None:
	lato = 112
	passo_x, passo_y = 4 * lato, 168
	immagine = Image.new("RGBA", (passo_x * 4, passo_y * 2), SFONDO)
	disegno = ImageDraw.Draw(immagine)
	for indice, popolo in enumerate(POPOLI):
		x, y = (indice % 4) * passo_x, (indice // 4) * passo_y
		disegno.text((x + 8, y + 6), popolo.upper(), fill=(55, 38, 23, 255))
		for fotogramma in range(4):
			immagine.alpha_composite(frame(f"portatore_nessuno_{popolo}", 2, fotogramma, lato), (x + fotogramma * lato, y + 38))
	immagine.convert("RGB").save(OUTPUT / "atlanti-C9-coloni-contact.png", quality=95)


def tavola_coloni_c10() -> None:
	lato = 112
	passo_x, passo_y = 4 * lato, 168
	immagine = Image.new("RGBA", (passo_x * 4, passo_y * 2), SFONDO)
	disegno = ImageDraw.Draw(immagine)
	for indice, popolo in enumerate(POPOLI):
		x, y = (indice % 4) * passo_x, (indice // 4) * passo_y
		disegno.text((x + 8, y + 6), popolo.upper(), fill=(55, 38, 23, 255))
		for fotogramma in range(4):
			immagine.alpha_composite(frame(f"c10_portatore_{popolo}", 2, fotogramma, lato), (x + fotogramma * lato, y + 38))
	immagine.convert("RGB").save(OUTPUT / "atlanti-C10-coloni-contact.png", quality=95)


def tavola_soldati_c10() -> None:
	lato = 84
	passo_x, passo_y = 4 * lato + 12, 2 * lato + 30
	immagine = Image.new("RGBA", (passo_x * 4, passo_y * 2), SFONDO)
	disegno = ImageDraw.Draw(immagine)
	for indice, soldato in enumerate(SOLDATI):
		x, y = (indice % 4) * passo_x, (indice // 4) * passo_y
		disegno.text((x + 4, y + 2), soldato.replace("_", " ").upper(), fill=(55, 38, 23, 255))
		for fotogramma in range(4):
			immagine.alpha_composite(frame(f"c10_soldato_{soldato}", 2, fotogramma, lato), (x + fotogramma * lato, y + 24))
	immagine.convert("RGB").save(OUTPUT / "atlanti-C10-soldati-contact.png", quality=95)


def tavola_soldati_c10_lotta() -> None:
	lato = 84
	passo_x, passo_y = 4 * lato + 12, 2 * lato + 30
	immagine = Image.new("RGBA", (passo_x * 4, passo_y * 2), SFONDO)
	disegno = ImageDraw.Draw(immagine)
	for indice, soldato in enumerate(SOLDATI):
		x, y = (indice % 4) * passo_x, (indice // 4) * passo_y
		disegno.text((x + 4, y + 2), soldato.replace("_", " ").upper(), fill=(55, 38, 23, 255))
		for fotogramma in range(4):
			immagine.alpha_composite(frame(f"c10_soldato_{soldato}_lotta", 2, fotogramma, lato), (x + fotogramma * lato, y + 24))
	immagine.convert("RGB").save(OUTPUT / "atlanti-C10-soldati-lotta-contact.png", quality=95)


def tavola_soldati() -> None:
	lato = 72
	passo_x, passo_y = 4 * lato + 12, 2 * lato + 30
	immagine = Image.new("RGBA", (passo_x * 4, passo_y * 2), SFONDO)
	disegno = ImageDraw.Draw(immagine)
	for indice, soldato in enumerate(SOLDATI):
		x, y = (indice % 4) * passo_x, (indice // 4) * passo_y
		disegno.text((x + 4, y + 2), soldato.replace("_", " ").upper(), fill=(55, 38, 23, 255))
		for riga, azione in enumerate(("cammino", "lotta")):
			nome = f"{soldato}_{'lotta' if azione == 'lotta' else ''}".rstrip("_")
			for fotogramma in range(4):
				immagine.alpha_composite(frame(nome, 2, fotogramma, lato), (x + fotogramma * lato, y + 24 + riga * (lato + 2)))
	immagine.convert("RGB").save(OUTPUT / "atlanti-C8-soldati-prima-posa.png", quality=95)


def tavola_direzioni() -> None:
	lato = 96
	passo_x, passo_y = lato * 4 + 28, lato + 8
	nomi = ("portatore_nessuno_greci", "guardia", "guardia_lotta")
	titoli = ("CIVILE GRECO · MARCIA", "GUARDIA · MARCIA", "GUARDIA · COMBATTIMENTO")
	immagine = Image.new("RGBA", (passo_x * 3, 34 + passo_y * 8), SFONDO)
	disegno = ImageDraw.Draw(immagine)
	for pannello, (nome, titolo) in enumerate(zip(nomi, titoli)):
		x0 = pannello * passo_x
		disegno.text((x0 + 8, 8), titolo, fill=(55, 38, 23, 255))
		for direzione in range(8):
			y = 34 + direzione * passo_y
			disegno.text((x0 + 3, y + 3), str(direzione), fill=(55, 38, 23, 255))
			for fotogramma in range(4):
				immagine.alpha_composite(frame(nome, direzione, fotogramma, lato), (x0 + 28 + fotogramma * lato, y))
	immagine.convert("RGB").save(OUTPUT / "atlanti-C-direzioni-e-animazioni.png", quality=95)


def main() -> None:
	OUTPUT.mkdir(parents=True, exist_ok=True)
	tavola_coloni()
	tavola_coloni_c10()
	tavola_soldati_c10()
	tavola_soldati_c10_lotta()
	tavola_soldati()
	tavola_direzioni()
	print("Tavole di audit C9 e C8 aggiornate da atlanti e metadati di produzione.")


if __name__ == "__main__":
	main()
