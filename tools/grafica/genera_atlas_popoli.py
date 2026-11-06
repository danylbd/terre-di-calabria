"""Genera atlas originali compatti per civili e soldati degli otto popoli."""

from __future__ import annotations

import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GRAFICA = ROOT / "assets" / "grafica"
DEST = GRAFICA / "coloni"

# Tunica, luce, ombra, bordo, copricapo e dettaglio riconoscibile.
POPOLI = {
    "greci": ("#6f8790", "#a9bdba", "#3d555e", "#d8bd83", "#715044", "#4c7f91"),
    "brettii": ("#596b4d", "#95a170", "#354538", "#c69b62", "#493d32", "#8a6348"),
    "romani": ("#854e43", "#c27d63", "#503630", "#d3b379", "#744b37", "#b24e3e"),
    "saraceni": ("#537d79", "#91b6a9", "#35504e", "#d7b66c", "#687e78", "#c58e4e"),
    "normanni": ("#65707a", "#a4acaa", "#404751", "#d1b66f", "#56535a", "#3c6380"),
    "siculi": ("#9a7646", "#cfaa6b", "#5d4933", "#b95745", "#795b3f", "#bd6846"),
    "sicani": ("#667050", "#a4a27b", "#3d4435", "#c3a56b", "#605a43", "#77806a"),
    "cartaginesi": ("#76556e", "#b68aa4", "#493747", "#d2ae68", "#59465a", "#a94e4c"),
}

MERCI = {
    "tronco": ("#93603d", "#d0a16b"), "asse": ("#b07a50", "#e4c18a"),
    "pietra": ("#78858a", "#bec8c6"), "carbone": ("#343a3b", "#777a72"),
    "anfora": ("#b75f47", "#e4a36e"), "armi": ("#78858d", "#cbd3ce"),
    "attrezzi": ("#7b817a", "#d2b779"), "carne": ("#a54f45", "#dfa18a"),
    "pesce": ("#4e8996", "#b0d0d0"), "lana": ("#c9c2ae", "#fff1cd"),
    "olive": ("#617346", "#a9bd71"), "uva": ("#73517c", "#c09acb"),
    "formaggio": ("#c99d43", "#f4d57e"), "lingotti": ("#9d8351", "#e5cf9a"),
    "maiale": ("#b86d72", "#e8b0a0"), "ortaggi": ("#66804a", "#b8ca7e"),
    "agrumi": ("#cf812e", "#ffd16a"), "cipolle": ("#8e6683", "#d2a7c9"),
    "covone": ("#a8813f", "#ead06e"), "cesta": ("#8b6541", "#c89c62"),
    "sacco": ("#927b5c", "#d0b992"), "spada": ("#697982", "#d2dad7"),
}

ATTREZZI = {
    "ascia": ("#704c35", "#abb7b7"), "canna": ("#737a50", "#c1a975"),
    "falce": ("#704b34", "#cad2cc"), "martello": ("#75513a", "#aeb9ba"),
    "pala": ("#75513a", "#a7b1af"), "piccone": ("#704b34", "#adb9b7"),
}

SOLDATI = {
    "guardia": ("greci", "fanteria"), "brettio": ("brettii", "tiratori"),
    "brettio_giocatore": ("brettii", "tiratori"), "legionario": ("romani", "fanteria"),
    "cavaliere_leggero": ("saraceni", "cavalleria_leggera"),
    "cavaliere_pesante": ("normanni", "cavalleria_pesante"),
    "guerriero_siculo": ("siculi", "fanteria"), "arciere_sicano": ("sicani", "arciere"),
    "mercenario_cartaginese": ("cartaginesi", "fanteria"),
}


def _meta(nome: str) -> dict:
    path = GRAFICA / f"{nome}.json"
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return {"cella": [96, 96], "ancora": [42, 80], "fotogrammi": 8,
            "direzioni": ["S", "SE", "E", "NE", "N", "NO", "O", "SO"]}


def _merce(nome: str) -> str:
    if nome.startswith("portatore_"):
        return nome.removeprefix("portatore_")
    return nome.removeprefix("lavoratore_").removesuffix("_lavoro")


def _volto(direzione: int, carnagione: str) -> str:
    if direzione in (3, 4, 5):
        return ""
    if direzione in (2, 6):
        lato = 1 if direzione == 2 else -1
        return (f'<ellipse cx="48" cy="23" rx="6.1" ry="7.0" fill="{carnagione}" stroke="#453d38" stroke-width="1.1"/>'
                f'<path d="M{48+lato*2} 23h1m{lato*1} 2l{lato*1.5} 1" stroke="#453d38" stroke-width="1.1" stroke-linecap="round"/>')
    return (f'<ellipse cx="48" cy="23" rx="6.4" ry="7.1" fill="{carnagione}" stroke="#453d38" stroke-width="1.1"/>'
            '<path d="M45 23h1m5 0h1m-5 3 1 1m-3 2q3 2 6 0" fill="none" stroke="#513c35" stroke-width=".9" stroke-linecap="round"/>')


def _copricapo(popolo: str, hair: str, trim: str) -> str:
    if popolo == "saraceni":
        return (f'<path d="M39 22q-2-11 9-13 12 2 10 14l-3-3-1-5q-8 4-14 0z" fill="{hair}" stroke="#373d3b" stroke-width="1.2"/>'
                f'<path d="M39 17q8 4 19 0m-18 3q8 4 17 0" fill="none" stroke="{trim}" stroke-width="2.2"/>')
    if popolo in ("brettii", "sicani"):
        return (f'<path d="M39 21q-1-10 9-12 10 1 10 12l-3-3-1-5q-7 3-14 1z" fill="{hair}" stroke="#373b32" stroke-width="1.2"/>'
                f'<path d="M40 17q8 3 16 0" fill="none" stroke="{trim}" stroke-width="2.2"/>')
    if popolo == "romani":
        return (f'<path d="M38 19q2-10 10-10 9 0 11 10l-3 3H41z" fill="{hair}" stroke="#373b32" stroke-width="1.2"/>'
                f'<path d="M40 17h16m-8-8v5" stroke="{trim}" stroke-width="1.8"/>')
    if popolo == "normanni":
        return (f'<path d="M38 21q-1-12 10-13 11 1 11 13l-4-3-2-6q-6 3-13 2z" fill="{hair}" stroke="#373b3a" stroke-width="1.2"/>'
                f'<path d="M40 17q8 3 16 0" stroke="{trim}" stroke-width="2"/>')
    if popolo == "cartaginesi":
        return (f'<path d="M38 20q1-10 10-11 10 1 11 11l-4-2-2-5q-7 3-14 1z" fill="{hair}" stroke="#373238" stroke-width="1.2"/>'
                f'<path d="M41 16q7 3 15 0" stroke="{trim}" stroke-width="2"/>')
    return (f'<path d="M39 21q-1-11 9-13 10 1 10 13l-4-3-2-5-9 1-1 5z" fill="{hair}" stroke="#373834" stroke-width="1.2"/>'
            f'<path d="M40 17q8 3 16 0" stroke="{trim}" stroke-width="2"/>')


def _decorazione(popolo: str, trim: str) -> str:
    if popolo == "greci":
        return f'<path d="M39 61h18m-16 2h2m3 0h2m3 0h2m3 0h2" stroke="{trim}" stroke-width="1.4"/>'
    if popolo == "romani":
        return f'<path d="M40 56h16m-14 3h12" stroke="{trim}" stroke-width="1.7"/><rect x="47" y="54" width="4" height="4" rx=".5" fill="#d4b469"/>'
    if popolo == "saraceni":
        return f'<path d="M39 44q9 5 18 0m-15 4q7 4 14 0" fill="none" stroke="{trim}" stroke-width="1.5"/>'
    if popolo == "normanni":
        return f'<path d="M39 62h18m-15 2h12" stroke="{trim}" stroke-width="2"/>'
    if popolo == "siculi":
        return f'<path d="M39 61h18m-16 2 2 2 2-2 2 2 2-2 2 2 2-2 2 2" fill="none" stroke="{trim}" stroke-width="1.2"/>'
    if popolo == "sicani":
        return f'<path d="M40 45q8 4 16 0m-17 16h18" fill="none" stroke="{trim}" stroke-width="1.5"/>'
    return f'<path d="M40 61h16m-13-2v4m5-4v4m5-4v4" stroke="{trim}" stroke-width="1.4"/>'


def _mantello(popolo: str, trim: str) -> str:
    if popolo == "brettii":
        return f'<path d="M40 36q-7 4-8 13l5 13 7-2-4-13 5-7z" fill="#806046" stroke="#473b31" stroke-width="1.2"/><path d="M34 46q3 2 7 1" stroke="{trim}" stroke-width="1.4"/>'
    if popolo == "romani":
        return f'<path d="M40 35q8 4 16 0l4 5q-9 6-23 1z" fill="#8c473f" stroke="#59352f" stroke-width="1.1"/><path d="M41 38q7 4 14 0" stroke="{trim}" stroke-width="1.4"/>'
    if popolo == "saraceni":
        return f'<path d="M40 37q8 6 16 0l4 17q-8 4-17 1l-3-10z" fill="none" stroke="{trim}" stroke-width="2"/><path d="M43 39l11 15" stroke="{trim}" stroke-width="1.4"/>'
    if popolo == "normanni":
        return f'<path d="M40 35q9 5 17 0l5 9-5 15-7 2 3-15-11-5z" fill="#5b6570" stroke="#3f454b" stroke-width="1.2"/><path d="M43 39 56 51" stroke="{trim}" stroke-width="1.5"/>'
    if popolo == "siculi":
        return f'<path d="M40 36q-6 3-6 10l3 11 7 2-3-12 7-8z" fill="#b36f4b" stroke="#654b38" stroke-width="1.1"/><path d="M37 48h5" stroke="{trim}" stroke-width="1.4"/>'
    if popolo == "sicani":
        return f'<path d="M40 36q-5 6-4 16l6 10 5-3-5-11 5-10z" fill="#77745b" stroke="#484538" stroke-width="1.1"/><path d="M38 49q3 2 6 1" stroke="{trim}" stroke-width="1.4"/>'
    if popolo == "cartaginesi":
        return f'<path d="M40 37q8 6 16 0l4 15q-9 5-18 1l-3-10z" fill="none" stroke="{trim}" stroke-width="2.1"/><path d="M41 40l15 12" stroke="{trim}" stroke-width="1.4"/>'
    return ""


def _uomo(nome: str, popolo: str, direzione: int, frame: int, combattimento: bool = False) -> str:
    cloth, light, dark, trim, hair, accento = POPOLI[popolo]
    key = _merce(nome)
    carico = nome.startswith("portatore_") and key != "nessuno"
    lavoro = nome.endswith("_lavoro")
    passo = [0, -1, -2, -1, 0, 1, 2, 1][frame]
    gamba1, gamba2 = 46 + passo * 2, 51 - passo * 2
    braccio = 1 if direzione in (1, 2, 3) else -1 if direzione in (5, 6, 7) else 0
    if combattimento:
        braccio = 1
    pelle = "#d5a27c" if popolo in ("greci", "brettii", "romani", "normanni", "siculi", "sicani") else "#bd8967"
    cargo = ""
    if carico:
        c1, c2 = MERCI.get(key, ("#aa8050", "#d8bb82"))
        if key in ("tronco", "asse"):
            cargo = f'<g transform="rotate(-25 61 39)"><rect x="57" y="28" width="8" height="25" rx="3" fill="{c1}" stroke="#49392f" stroke-width="1.3"/><ellipse cx="61" cy="29" rx="4" ry="2" fill="{c2}"/><path d="M58 38h6m-6 7h6" stroke="#604631"/></g>'
        elif key in ("pietra", "carbone", "lingotti"):
            cargo = f'<path d="m57 39 3-7 6 2 2 6-6 4zm-1 8 4-5 7 2-1 6-6 2z" fill="{c1}" stroke="#49443c" stroke-width="1.2"/><path d="m60 33 4 1" stroke="{c2}" stroke-width="1.3"/>'
        else:
            cargo = f'<path d="M57 35q0-4 5-4t5 4l2 13q-7 5-14 0z" fill="{c1}" stroke="#514238" stroke-width="1.3"/><path d="M57 39h10m-8 6h7" stroke="{c2}" stroke-width="1.4"/>'
    tool = ""
    if not carico and key in ATTREZZI:
        t1, t2 = ATTREZZI[key]
        angolo = [-10, -18, -30, -18, -8, 4, 13, 3][frame] if lavoro else -5
        tool = f'<g transform="rotate({angolo} {59+braccio*2} 47)"><path d="M{59+braccio*2} 36v27" stroke="{t1}" stroke-width="3.5" stroke-linecap="round"/><path d="M{55+braccio*2} 37h9" stroke="{t2}" stroke-width="4.4" stroke-linecap="round"/></g>'
    oscillazione = [0, 2, 3, 1, 0, -2, -3, -1][frame]
    mano_sx = 51 + oscillazione
    mano_dx = 51 - oscillazione
    arm_pose = f"M39 40q-5 3-5 8l0 {mano_sx-48}q0 4 5 4l2-3-2-5 5-4z"
    arm2 = f"M57 40q5 3 5 8l0 {mano_dx-48}q0 4-5 4l-2-3 2-5-5-4z"
    if combattimento:
        arm_pose = "M39 40q-5 0-9-6l2-4q7 5 12 4l2 5z"
    dx = -5 if direzione == 6 else 4 if direzione == 2 else 0
    face = _volto(direzione, pelle)
    return f'''<g transform="translate(0 {-0.8 if frame in (1,2,5,6) else 0})">
      <ellipse cx="48" cy="82" rx="11" ry="2.8" fill="#25302e" opacity=".25"/>
      <path d="M43 59l-2 10 {gamba1-46} 9 4 1 5-7 2-12m1-2 1 11 {gamba2-51} 7 4 1 3-8-1-12" fill="{dark}" stroke="#393a34" stroke-width="1.4" stroke-linejoin="round"/>
      <path d="M40 78l-2 2q0 2 3 2h8l1-2-5-3m8 1-2 2q0 2 3 2h7l1-2-5-3" fill="#52463c" stroke="#393630" stroke-width="1.1"/>
      <path d="M39 35q9-5 18 0l4 18q-2 8-13 9-11-1-13-8z" fill="{cloth}" stroke="{dark}" stroke-width="1.6" stroke-linejoin="round"/>
      <path d="M40 38q8 3 16 0l3 13q-8 4-20 1z" fill="{light}" opacity=".4"/>
      {_mantello(popolo, trim)}
      <path d="M45 36l2 6-1 18m7-24-3 5 2 18" fill="none" stroke="{trim}" stroke-width="1" opacity=".75"/>
      {_decorazione(popolo, trim)}
      <path d="{arm_pose}" fill="{cloth}" stroke="{dark}" stroke-width="1.6"/>
      <path d="{arm2}" fill="{cloth}" stroke="{dark}" stroke-width="1.6"/>
      <path d="M37 {mano_sx}q2-2 4 0m15 {mano_dx}q2-2 4 0" fill="none" stroke="{pelle}" stroke-width="2.2" stroke-linecap="round"/>
      <path d="M40 33q8 4 16 0l2 4q-9 5-19 0z" fill="{pelle}" stroke="#6b5140" stroke-width=".8"/>
      <ellipse cx="48" cy="23" rx="7.2" ry="8.2" fill="{hair}" opacity=".95"/><g transform="translate({dx} 0)">{face}{_copricapo(popolo, hair, trim)}</g>
      {cargo}{tool}
      <path d="M40 60q8 3 16 0" fill="none" stroke="{trim}" stroke-width="1.2"/>
    </g>'''


def _soldato(nome: str, popolo: str, tipo: str, direzione: int, frame: int, lotta: bool) -> str:
    cloth, light, dark, trim, hair, accento = POPOLI[popolo]
    cavalry = tipo.startswith("cavalleria")
    arciere = tipo == "arciere"
    tiratore = tipo == "tiratori"
    passo = [0, -1, -2, -1, 0, 1, 2, 1][frame]
    if cavalry:
        horse = f'''<g stroke="#493c32" stroke-width="1.6" stroke-linejoin="round">
          <path d="M29 57q-2-8 6-12l10-1q7 2 10 8l-1 9-8 5-15-2z" fill="{'#493c32' if popolo == 'normanni' else '#926a4b'}"/>
          <path d="M49 49q6-8 10-7l5 5-5 5-7 1m-1 10-2 12m-8-12-2 12m-8-15-2 13m16-10 3 11" fill="none" stroke-width="3.2"/>
          <path d="M58 43q-2-5 1-7l5 3 1 6m-34 4q-5-2-7-6" fill="none" stroke-width="1.7"/>
          <path d="M36 48q8 3 16 0l2 8q-9 4-17 0z" fill="{trim}" stroke="#4e4036"/></g>
          <path d="M35 44q7-4 15 0l3 6q-9 4-19 0z" fill="{dark}" stroke="#373733" stroke-width="1.5"/>'''
        rider_top = 34
    else:
        horse = ""
        rider_top = 37
    shield = ""
    if not arciere:
        shield_shape = {
            "romani": "M57 42q7-3 13 0v15q-1 6-7 8-6-2-6-8z",
            "normanni": "M57 42q6-3 11 0l-1 13-5 11-5-11z",
            "greci": "M57 43q7-4 11 0l-1 14-5 5-5-5z",
            "siculi": "M57 43q7-4 11 0l-1 14-5 5-5-5z",
        }.get(popolo, "M57 43q7-4 11 0l-1 15-5 5-5-5z")
        shield = f'<path d="{shield_shape}" fill="{accento}" stroke="#403a33" stroke-width="1.6"/><path d="M62 44v17m-4-10h7" stroke="{trim}" stroke-width="1.4"/>'
    weapon = ""
    if arciere:
        weapon = f'<path d="M31 32q12 13 0 28m1-28 0 28" fill="none" stroke="{trim}" stroke-width="2"/><path d="M32 35 32 57" stroke="#eee2c7" stroke-width=".8"/><path d="m29 43 12 2" stroke="#604d3b" stroke-width="1.5"/>'
        if lotta:
            weapon += '<path d="m32 44 15-3m-3-2 4 2-4 2" fill="none" stroke="#e3d5bb" stroke-width="1.1"/>'
    elif tiratore:
        weapon = f'<path d="M29 35q11 10 2 24m1-23q-2 12 0 22" fill="none" stroke="{dark}" stroke-width="2.2"/><path d="M29 45q8 0 13 7m-4-1 4 1-2 4" fill="none" stroke="{trim}" stroke-width="1.4" stroke-linecap="round"/>'
        if lotta:
            weapon += '<path d="m41 52 8-6 3 2-8 6z" fill="#d4bc80" stroke="#564636" stroke-width=".8"/>'
    elif popolo in ("romani", "saraceni"):
        blade = "M31 60V34q5-2 5-8l-3 4-5 1v29" if popolo == "romani" else "M31 61V39q6-5 5-12-2 6-8 8v26"
        weapon = f'<path d="M31 62V39" stroke="#725235" stroke-width="2.8"/><path d="{blade}" fill="#c8d0cd" stroke="#4e5654" stroke-width="1.3"/><path d="M27 40h9" stroke="{trim}" stroke-width="2"/>'
    else:
        angle = [-15, -28, -42, -28, -12, 6, 18, 4][frame] if lotta else -8 + math.sin(frame * math.pi / 4) * 7
        weapon = f'<g transform="rotate({angle:.1f} 31 47)"><path d="M31 61V25" stroke="#765437" stroke-width="2.6"/><path d="m27 29 4-11 4 11z" fill="#c5cdca" stroke="#535b5a" stroke-width="1.1"/></g>'
    armor = ""
    if popolo in ("greci", "romani", "normanni", "cartaginesi"):
        armor = f'<path d="M39 38q9-5 18 0l3 14q-9 5-22 0z" fill="{accento}" stroke="#373b39" stroke-width="1.4"/><path d="M41 42h16m-15 4h15m-13 4h12" stroke="{trim}" stroke-width="1.4"/>'
    elif popolo == "brettii":
        armor = f'<path d="M39 38q9-4 18 0l3 13q-9 5-22 0z" fill="#73563f" stroke="#40372f" stroke-width="1.4"/><path d="M41 39l14 13m-14-7 8 7" stroke="{trim}" stroke-width="1.5"/>'
    elif popolo == "saraceni":
        armor = f'<path d="M40 40q8 4 16 0m-15 5q7 4 14 0" fill="none" stroke="{trim}" stroke-width="1.8"/><path d="M42 39l12 14" stroke="{accento}" stroke-width="1.6"/>'
    elif popolo == "siculi":
        armor = f'<path d="M41 41q7-3 14 0l2 11q-8 4-18 0z" fill="#946044" stroke="#544331" stroke-width="1.2"/><path d="M42 44h13m-12 4h12" stroke="{trim}" stroke-width="1.5"/>'
    elif popolo == "sicani":
        armor = f'<path d="M40 39q8-4 16 0l3 13q-8 4-20 0z" fill="#77745b" stroke="#484538" stroke-width="1.2"/><path d="M42 40l12 11m-13-3h13" stroke="{trim}" stroke-width="1.3"/>'
    helmet = f'<path d="M38 24q0-12 10-13 11 1 11 13l-4-3-1-6q-6 3-12 1l-1 6z" fill="{hair}" stroke="#343938" stroke-width="1.6"/><path d="M40 18h16m-8-7v8" stroke="{trim}" stroke-width="2"/>'
    if popolo == "greci":
        helmet += f'<path d="M43 12q4-9 10-1m-8 0q4-10 9-1m-5-1q4-8 6-1" fill="none" stroke="{accento}" stroke-width="2"/>'
    if popolo == "romani":
        helmet += f'<path d="M43 14q5-12 11 0" fill="none" stroke="{accento}" stroke-width="3"/><path d="M40 22v7m16-7v7" stroke="{trim}" stroke-width="2"/>'
    if popolo == "brettii":
        helmet = f'<path d="M38 23q1-12 11-13 10 2 11 13l-4-2-3-7q-7 2-12 7z" fill="#584435" stroke="#39332d" stroke-width="1.6"/><path d="M39 20q9-4 19 0" stroke="{trim}" stroke-width="2.4"/>'
    if popolo == "normanni":
        helmet += '<path d="M49 17v12" stroke="#c9c2ae" stroke-width="1.5"/><path d="M49 17l-1 7" stroke="#373b3a" stroke-width=".8"/>'
    if popolo == "saraceni":
        helmet = f'<path d="M38 23q-2-12 10-14 12 2 11 14l-4-4-1-6q-8 3-14 1z" fill="{hair}" stroke="#343938" stroke-width="1.6"/><path d="M39 17q8 3 18 0m-17 4q8 3 16 0" stroke="{trim}" stroke-width="2" fill="none"/>'
    if popolo == "sicani":
        helmet = f'<path d="M38 21q8-9 20 0v4H38z" fill="{hair}" stroke="#343938" stroke-width="1.5"/><path d="M39 21h18" stroke="{trim}" stroke-width="2"/>'
    if nome == "brettio_giocatore":
        helmet += '<path d="M62 45v15m-3-13 3-4 3 4" stroke="#61a8a1" stroke-width="2"/>'
    else:
        helmet += '<path d="M62 45v15m-3-13 3-4 3 4" stroke="#b95346" stroke-width="2"/>'
    yhead = 27 if cavalry else 25
    barba = ""
    if popolo in ("brettii", "normanni", "cartaginesi"):
        barba = f'<path d="M43 32q5 3 10 0l-1 4-4 2-4-2z" fill="{hair}" stroke="#433a34" stroke-width=".8"/>'
    volto = f'<path d="M44 {yhead+4}h1m5 0h1m-4 2 1 1m-3 2q2 1 4 0" fill="none" stroke="#493a33" stroke-width=".9" stroke-linecap="round"/>{barba}'
    legs = "" if cavalry else f'<path d="M43 57l-2 12 {45+passo*2-45} 9m8-21 2 12 {51-passo*2-51} 8" fill="none" stroke="{dark}" stroke-width="4.2" stroke-linecap="round"/><path d="M40 78h8m5 0h8" stroke="#51453b" stroke-width="3" stroke-linecap="round"/>'
    return f'''{horse}<ellipse cx="48" cy="82" rx="12" ry="2.8" fill="#202b2b" opacity=".26"/>{legs}
      <path d="M39 {rider_top}q9-5 18 0l4 18q-3 7-13 8-10-1-13-7z" fill="{cloth}" stroke="{dark}" stroke-width="1.8"/>
      <path d="M40 {rider_top+3}q8 3 16 0l3 13q-8 4-20 1z" fill="{light}" opacity=".4"/>{armor}
      {shield}<path d="M42 {yhead}q6-3 12 0v8q-6 4-12 0z" fill="#c98f6c" stroke="#544038" stroke-width="1"/>{volto}{helmet}{weapon}
      <path d="M37 36q-4 8-4 15m23-14q6 5 7 12" fill="none" stroke="{cloth}" stroke-width="5" stroke-linecap="round"/>
      <path d="M34 50h5m18-1h5" stroke="#c79170" stroke-width="2.7" stroke-linecap="round"/>'''


def _atlas(nome: str, genera_cella) -> None:
    meta = _meta(nome)
    cw, ch = (int(x) for x in meta["cella"])
    frames = int(meta.get("fotogrammi", 8))
    parts = []
    for direction in range(8):
        for frame in range(frames):
            sx = 0.76 if direction in (2, 6) else 0.9 if direction in (1, 3, 5, 7) else 1.0
            sx *= min(cw, ch) / 96.0
            tx = frame * cw + cw * 0.5
            ty = direction * ch
            art = genera_cella(direction, frame)
            parts.append(f'<g transform="translate({tx} {ty}) scale({sx} {min(cw,ch)/96.0}) translate(-48 0)">{art}</g>')
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{cw*frames}" height="{ch*8}" viewBox="0 0 {cw*frames} {ch*8}">{"".join(parts)}</svg>'
    (DEST / f"{nome}.svg").write_text(svg, encoding="utf-8")
    metadati = GRAFICA / f"{nome}.json"
    if not metadati.exists():
        metadati.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    DEST.mkdir(parents=True, exist_ok=True)
    bases = sorted(p.stem for p in GRAFICA.glob("*.json") if p.stem.startswith(("portatore_", "lavoratore_")) and not any(p.stem.endswith("_" + popolo) for popolo in POPOLI))
    for base in bases:
        for popolo in POPOLI:
            nome = f"{base}_{popolo}"
            _atlas(nome, lambda d, f, n=base, p=popolo: _uomo(n, p, d, f))
    for base, (popolo, tipo) in SOLDATI.items():
        for suffisso, lotta in (("", False), ("_lotta", True)):
            nome = base + suffisso
            if not (GRAFICA / f"{nome}.json").exists():
                raise FileNotFoundError(f"Manca il metadato del soldato {nome}")
            _atlas(nome, lambda d, f, n=base, p=popolo, t=tipo, l=lotta: _soldato(n, p, t, d, f, l))
    print(f"Creati {len(bases) * len(POPOLI)} atlanti civili e {len(SOLDATI) * 2} atlanti di soldati")


if __name__ == "__main__":
    main()
