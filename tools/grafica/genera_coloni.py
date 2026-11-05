"""Genera gli atlas vettoriali dettagliati per portatori e lavoratori."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GRAFICA = ROOT / "assets" / "grafica"
DEST = GRAFICA / "coloni"
DEST.mkdir(parents=True, exist_ok=True)

MATERIALI = {
    "tronco": ("#9a5d32", "#d29a58"), "asse": ("#bb8050", "#e0b77e"),
    "pietra": ("#85909a", "#c2c9cc"), "carbone": ("#383b40", "#777a7d"),
    "anfora": ("#bb6243", "#e3a16d"), "armi": ("#7e8791", "#d0d5d7"),
    "attrezzi": ("#87939b", "#d5b275"), "carne": ("#aa5146", "#e0a077"),
    "pesce": ("#4f92a5", "#b4d7d8"), "lana": ("#d7d0bc", "#fff4d2"),
    "olive": ("#647448", "#a9b868"), "uva": ("#74568b", "#baa0ce"),
    "formaggio": ("#d6ad4d", "#f7dc82"), "lingotti": ("#a88b54", "#ead394"),
    "maiale": ("#c87979", "#f1b7a6"), "ortaggi": ("#68864d", "#b7c971"),
    "agrumi": ("#d28a37", "#ffd274"), "cipolle": ("#926484", "#d7aacd"),
    "covone": ("#b28a42", "#ead06f"), "cesta": ("#986b43", "#c79a5c"),
    "sacco": ("#997d57", "#d0b58a"), "spada": ("#78858c", "#d0d7d6"),
}
ATTREZZI = {
    "ascia": ("#805333", "#aeb8bb"), "canna": ("#77804c", "#b6a16d"),
    "falce": ("#765033", "#c8d0cb"), "martello": ("#795333", "#acb5b8"),
    "pala": ("#795333", "#9da8aa"), "piccone": ("#755034", "#aeb8bb"),
}


def item(nome: str) -> str:
    if nome.startswith("portatore_"):
        return nome.removeprefix("portatore_")
    if nome.startswith("lavoratore_"):
        return nome.removeprefix("lavoratore_").removesuffix("_lavoro")
    return "nessuno"


def person(nome: str, direction: int, frame: int, scale: float) -> str:
    cargo = nome.startswith("portatore_") and not nome.endswith("nessuno")
    work = nome.endswith("_lavoro")
    key = item(nome)
    cloth = "#315d70" if cargo else "#536b5a"
    light = "#5b8790" if cargo else "#85906b"
    dark = "#283d40" if cargo else "#465044"
    hidden_face = direction in (3, 4, 5)
    stride = [-2, -1, 0, 1, 2, 1, 0, -1][frame]
    arm = 1 if direction in (1, 2, 3) else -1 if direction in (5, 6, 7) else 0
    equip = ATTREZZI.get(key, ("#765033", "#b8c0be"))
    goods = MATERIALI.get(key, ("#aa8050", "#d8bb82"))
    cx = 48
    if hidden_face:
        face = ""
    elif direction in (2, 6):
        lato = 1 if direction == 2 else -1
        face = f'''<ellipse cx="{cx}" cy="22" rx="5.8" ry="7.6" fill="#e8b78d" stroke="#654b3e" stroke-width="1.2"/>
          <path d="M{48 + lato*1.8} 22h1" stroke="#503b34" stroke-width="1.1" stroke-linecap="round"/><path d="M{48 + lato*4} 24l{lato*2} 1-1 1" fill="none" stroke="#a36a52" stroke-width=".9" stroke-linecap="round"/>'''
    elif direction in (1, 7):
        lato = 1 if direction == 1 else -1
        face = f'''<ellipse cx="{cx}" cy="22" rx="6.6" ry="7.7" fill="#e8b78d" stroke="#654b3e" stroke-width="1.2"/>
          <path d="M{48 + lato*1.5} 23h1" stroke="#503b34" stroke-width="1.1" stroke-linecap="round"/><path d="M{48 + lato*3.5} 24l{lato*1.5} 1" fill="none" stroke="#a36a52" stroke-width=".9" stroke-linecap="round"/>'''
    else:
        face = f'''<ellipse cx="{cx}" cy="22" rx="6.6" ry="7.7" fill="#e8b78d" stroke="#654b3e" stroke-width="1.2"/>
          <path d="M44 23q2-1 3 0m4 0q2-1 3 0" fill="none" stroke="#503b34" stroke-width="1.1" stroke-linecap="round"/>
          <path d="M47.5 24l-.5 2 2 .2" fill="none" stroke="#a36a52" stroke-width=".8" stroke-linecap="round"/>
          <path d="M45 28q3 2 6 0" fill="none" stroke="#8d5145" stroke-width=".9" stroke-linecap="round"/>'''
    headcover = ("<path d=\"M40 21q-1-10 8-12 9 1 9 11l-3-2-2-5-9 1-1 5z\" fill=\"#493d36\" stroke=\"#302e2a\" stroke-width=\"1.2\"/>"
                 "<path d=\"M40 16q8 3 17 0\" fill=\"none\" stroke=\"#d5b36d\" stroke-width=\"2\"/>")
    leg_a = 47 + stride * 2
    leg_b = 51 - stride * 2
    carry = ""
    if cargo:
        if key in ("tronco", "asse"):
            carry = f'''<g transform="rotate(-25 59 39)"><rect x="56" y="28" width="8" height="24" rx="3" fill="{goods[0]}" stroke="#513a2e" stroke-width="1.4"/><ellipse cx="60" cy="29" rx="4" ry="2" fill="{goods[1]}"/><path d="M57 37h6m-6 7h6" stroke="#66452e" stroke-width="1"/></g>'''
        elif key in ("pietra", "carbone", "lingotti"):
            carry = f'''<g stroke="#51483e" stroke-width="1.2"><path d="M57 39l3-6 5 2 1 6-5 3z" fill="{goods[0]}"/><path d="M56 47l4-5 6 2-1 6-5 2z" fill="{goods[1]}"/></g>'''
        elif key == "pesce":
            carry = f'''<path d="M56 41q6-8 12 0-6 8-12 0l-4-4v8z" fill="{goods[0]}" stroke="#42616a" stroke-width="1.2"/><circle cx="64" cy="40" r=".8" fill="#fff4d2"/>'''
        else:
            carry = f'''<path d="M56 35q0-4 5-4t5 4l2 13q-7 5-14 0z" fill="{goods[0]}" stroke="#584533" stroke-width="1.4"/><path d="M57 39h9M58 45h7" stroke="{goods[1]}" stroke-width="1.4"/><path d="M58 31q3-5 6 0" fill="none" stroke="#584533" stroke-width="1.4"/>'''
    tool = ""
    if not cargo and key in ATTREZZI:
        tool = f'''<g transform="rotate({-12 + arm * 13} {58 + arm*4} 46)"><path d="M{58+arm*4} 37v25" stroke="{equip[0]}" stroke-width="3.2" stroke-linecap="round"/><path d="M{54+arm*4} 37h9" stroke="{equip[1]}" stroke-width="4.3" stroke-linecap="round"/><path d="M{55+arm*4} 37h8" stroke="#e1d5ba" stroke-width=".7"/></g>'''
    if work:
        tool += '<path d="M35 62q3-5 8 0m10 0q4-4 7 0" fill="none" stroke="#e5c878" stroke-width="1.5" stroke-linecap="round"/><circle cx="34" cy="58" r="1.5" fill="#f5df9d"/>'
    motion = [0, -0.8, -1.3, -0.8, 0, -0.8, -1.3, -0.8][frame]
    return f'''<g transform="translate(0 {motion}) scale({scale})">
      <ellipse cx="48" cy="81" rx="12" ry="3.4" fill="#24322f" opacity=".28"/>
      <path d="M43 60q-2 8 {leg_a-47} 18l4 1q5-8 6-17m1-2q1 8 {leg_b-51} 17l4 1q3-9 0-19" fill="#695247" stroke="#3f3933" stroke-width="1.7" stroke-linejoin="round"/>
      <path d="M43 77l-3 2q-1 2 2 2h8l1-2-4-2m7 0-2 2q0 2 3 2h7l1-2-5-2" fill="#533a2f" stroke="#332f2b" stroke-width="1.3"/>
      <path d="M39 34q9-5 18 0l4 19q-2 9-13 10-10-1-12-9z" fill="{cloth}" stroke="{dark}" stroke-width="1.8" stroke-linejoin="round"/>
      <path d="M40 36q8 4 16 0l3 14q-8 5-20 1z" fill="{light}" opacity=".54"/>
      <path d="M43 36l3 4-1 20m7-24-3 5 2 19" fill="none" stroke="#d7c99b" stroke-width="1" opacity=".72"/>
      <path d="M37 53q11 3 23 0l1 4q-11 4-25 0z" fill="#9d7044" stroke="#554632" stroke-width="1.2"/>
      <rect x="47" y="54" width="4" height="3.5" rx=".6" fill="#e1c476" stroke="#5b4934" stroke-width=".7"/>
      <path d="M39 38q-4 6-5 14l4 2 5-11m15-5q5 4 7 12l-4 3-6-9" fill="{cloth}" stroke="{dark}" stroke-width="1.8" stroke-linejoin="round"/>
      <path d="M34 52l4 1m22-1 4-2" stroke="#e8b78d" stroke-width="3.1" stroke-linecap="round"/>
      <path d="M43 32q5 4 11 0l2 5q-7 5-15 0z" fill="#e4b28a" stroke="#654b3e" stroke-width="1"/>
      <ellipse cx="48" cy="22" rx="8" ry="9" fill="#4a3b33" opacity=".96"/>{face}{headcover}
      <path d="M40 17q8-3 16 0" fill="none" stroke="#d5b36d" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M39 38q9 6 19 0" fill="none" stroke="#f0d99e" stroke-width="1.3" opacity=".8"/>
      {carry}{tool}
      <path d="M42 61q5 2 11 0" fill="none" stroke="#efe2bb" stroke-width="1.2" opacity=".75"/>
    </g>'''


def build(name: str) -> None:
    meta = json.loads((GRAFICA / f"{name}.json").read_text(encoding="utf-8"))
    cw, ch = meta["cella"]
    frames = int(meta["fotogrammi"])
    width, height = cw * frames, ch * 8
    # Scale the common 96-unit design into each existing sprite cell and preserve its anchor.
    scale = min(cw, ch) / 96.0
    cells = []
    for direction in range(8):
        for frame in range(frames):
            tx, ty = frame * cw, direction * ch
            sx = 0.7 if direction in (2, 6) else 0.88 if direction in (1, 3, 5, 7) else 1.0
            # L'orientamento cambia il profilo, mantenendo sempre il colono in piedi sul terreno.
            cells.append(f'<g transform="translate({tx - 6},{ty}) scale({scale}) translate(48,0) scale({sx},1) translate(-48,0)">{person(name, direction, frame, 1.0)}</g>')
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
      <defs><linearGradient id="tunica" x2="0" y2="1"><stop stop-color="#fff" stop-opacity=".16"/><stop offset="1" stop-color="#111" stop-opacity=".1"/></linearGradient></defs>
      {''.join(cells)}</svg>'''
    (DEST / f"{name}.svg").write_text(svg, encoding="utf-8")


if __name__ == "__main__":
    aliases = [p.stem for p in GRAFICA.glob("*.json") if p.stem.startswith(("portatore_", "lavoratore_"))]
    for alias in aliases:
        build(alias)
    print(f"Generati {len(aliases)} atlas vettoriali in {DEST}")
