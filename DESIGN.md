---
name: Dingfall
description: Dominó Pop (default theme, calmer v2) plus ten player-selectable themes on one shared component system.
colors:
  page-blue: "#1a4fb8"
  pool-blue: "#2462d6"
  ink: "#142554"
  ink-soft: "#3a4f86"
  light-text: "#e8f0ff"
  ice: "#eaf3ff"
  ice-dot: "#cfe0ff"
  ivory: "#fffdf6"
  ivory-lip: "#d9e2f2"
  play-green: "#3ddc6b"
  play-green-lip: "#22a552"
  star-yellow: "#ffc83d"
  bell-coral: "#ff5470"
  pio-cyan: "#29d3f5"
  locked-blue: "#9db4e6"
  fallen-tile: "#c9d6f2"
  white: "#ffffff"
typography:
  display:
    fontFamily: "Lilita One, Arial Rounded MT Bold, sans-serif"
    fontSize: "3rem"
    fontWeight: 400
    lineHeight: 1.08
    letterSpacing: "0.005em"
  headline:
    fontFamily: "Lilita One, Arial Rounded MT Bold, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 400
    lineHeight: 1.08
  button:
    fontFamily: "Lilita One, Arial Rounded MT Bold, sans-serif"
    fontSize: "1.2rem"
    fontWeight: 400
    letterSpacing: "0.01em"
  body:
    fontFamily: "Nunito, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 600
    lineHeight: 1.5
  label:
    fontFamily: "Nunito, system-ui, sans-serif"
    fontSize: "0.8rem"
    fontWeight: 800
    lineHeight: 1.2
rounded:
  pill: "999px"
  button: "16px"
  panel: "18px"
  window: "22px"
  tile: "5px"
  phone: "35px"
spacing:
  xs: "6px"
  sm: "10px"
  md: "16px"
  lg: "24px"
components:
  button-primary:
    backgroundColor: "{colors.play-green}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
    padding: "11px 20px 14px"
  button-secondary:
    backgroundColor: "{colors.ivory}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
  button-disabled:
    backgroundColor: "#b7c4df"
    textColor: "#43557f"
    rounded: "{rounded.button}"
  hud-pill:
    backgroundColor: "rgba(20,37,84,.38)"
    textColor: "{colors.white}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
  window:
    backgroundColor: "{colors.ivory}"
    textColor: "{colors.ink}"
    rounded: "{rounded.window}"
    padding: "22px 16px 18px"
  board:
    backgroundColor: "{colors.ice}"
    rounded: "{rounded.panel}"
  level-node-done:
    backgroundColor: "{colors.star-yellow}"
    textColor: "{colors.ink}"
    size: "48px"
  level-node-current:
    backgroundColor: "{colors.play-green}"
    textColor: "{colors.ink}"
    size: "60px"
  level-node-locked:
    backgroundColor: "{colors.locked-blue}"
    textColor: "{colors.ink}"
    size: "48px"
---

# Design System: Dingfall

## Overview

**Default theme: «Dominó Pop», version 2.** A casual puzzle game with character: pool blue, ivory domino tiles, buttons that sink slightly when pressed, and Pío the tin bird pointing the way. **The interface is built from dominoes**: the logo is a row of tiles with the last one starting to fall, the map path between levels is a row of tiles, and the tile counter is a tile.

Version 2 (17/11/2026) is a deliberate *quieter* pass. The client found version 1 overwhelming and "very AI-looking". Removed:

- the ink outline and drop shadow on every white headline;
- the coral ribbons on titles;
- the tilted logo tiles with strike lines;
- the cyan and yellow buttons;
- the stars above every map node;
- gradients;
- the uppercase shouting.

Strong colour is now reserved for meaning.

**Player-selectable themes.** The player can change the look in *Ajustes › Apariencia*. Dominó Pop is the default. The other ten themes share the same screens, components and game rules, and change only tokens (colour, type, radius, borders, shadows), one canvas palette and the tone of the copy:

- Mesa de juego
- Calma premium
- Gráfico y limpio
- Cine negro
- Tinta japonesa
- Bauhaus
- Brutalista
- Risografía
- Nocturno
- Nórdico

A theme never changes levels, difficulty, prices or progress. The reference build for all eleven is `docs/fase6/temas/index.html`, and the full Dominó Pop board is `docs/fase6/tablero/index.html`.

Discarded directions, kept only in Git history and in `docs/fase6/CATALOGO_DISENOS.pdf`: La Banda del Pueblo, Art déco, Terracota mediterránea and Cuaderno.

Anti-references:

- RPG wood and stone panels;
- esports neon;
- violet gradients with radial halos;
- the over-saturated "every element shouts" casual-game template (Dominó Pop v1).

## Colors

These are the Dominó Pop colours.

**Base colours**

- **Pool Blue (#2462D6)** is the flat ground of every screen. Page Blue (#1A4FB8) sits around the phones. There are no gradients.
- **Ink (#142554)** is used for thin 2 px outlines and for text on light surfaces. **Ink Soft (#3A4F86)** is for secondary text on ivory.
- **Light Text (#E8F0FF)** is secondary text on blue, at 4.5:1 or better on Pool Blue.
- **Ivory (#FFFDF6)** is the standing tile, popup windows, secondary buttons and the objective card.
- **Ice (#EAF3FF)** is the board, with Ice Dot (#CFE0FF) dots every 24 px.

**Strong colours.** Each has one job only:

- **Play Green**: the single primary action on each screen, plus the current map node.
- **Star Yellow**: stars, completed nodes, and **the tile currently falling**. It is never used on a button that spends money.
- **Bell Coral**: bells only.
- **Pío Cyan**: only the mascot.

**State colours.** Fallen Tile (#C9D6F2) and Locked Blue (#9DB4E6) mark what has already happened or is not open yet. The Club option is ink with ivory text: a calm, honest money option.

## Typography

- **Lilita One** (SIL OFL) is used for headlines, buttons and big figures.
  - Sentence case, with no outline and no shadow.
  - White on blue; ink on ivory and on green.
  - In Godot, a plain Label with no outline.
- **Nunito** (SIL OFL, 600–900) is used for service copy, help and prices. The minimum in game is 15 px.
- Copy: short sentences, action verbs and no false urgency.
  - «¡A tumbar!»
  - «¡Nivel superado!»
  - «¡Casi! Prueba otra vez, es gratis.»
  - «Sin cuerda. Pío necesita un respiro.»

## Layout

- The game is a single column on a phone, playable with one hand.
  - The HUD sits at the top: cord (a wind-up key icon) with its timer and a green "+", and stars.
  - The content sits in the centre, with a single large primary action at the bottom.
  - A 5-tab bottom nav marks the active tab with an ivory pill. The tab does not rise.
- Map: a vertical path of nodes linked by tiles.
  - Done nodes are yellow.
  - The current node is larger and green, with a soft white ring and Pío.
  - Locked nodes are muted blue with no shadow.
- Popups sit centred over a translucent blue veil, with the real screen visible underneath. A popup is never drawn over an empty screen.

## Elevation & Depth

Depth is a small cartoon offset: **a solid ink shadow 3 px straight down** under buttons, nodes, windows and cards, plus a **4 px inner lip** at the bottom of buttons. This is the material of this world, scaled down from v1 (which used 4–6 px shadows and 7 px lips). Phone mockups get only a soft neutral presentation shadow.

## Shapes

- Radii: buttons 16 px, panels 18 px, windows 22 px, pills 999 px.
- 2 px ink outlines on interactive elements.
- Tiles are rounded rectangles (5 px) with two pips, and are the brand's recognisable form.

## Components

- **Pressable button.** There are only two kinds:
  - green for the primary action;
  - ivory for everything else.

  On press the button moves down 3 px and its lip narrows, over 140 ms with `cubic-bezier(.22,1,.36,1)` (no spring overshoot). Disabled is grey-blue and does not move: the button's own colour loses its saturation and blends 40 % into what is behind it, the shadow goes and the text dims but stays legible. With a mouse (web and desktop) the button lightens slightly on hover and shows a hand cursor; on touch screens there is no hover. A theme with transparent secondary buttons and a solid shadow (Risografía) paints the body in the colour behind it, so the offset shadow never covers the label.
- **Setting row** (Ajustes, Juego responsable). Rows are grouped in a card with a very soft ink tint and 2 px hairlines between rows. Each row is at least 76 px tall and the whole row is the target. There are three kinds:
  - switch: name on the left, a 76 × 44 sliding switch on the right (track in the theme's primary colour when on, with a check inside the knob, so the state never depends on colour alone);
  - value: name, current value in the soft ink and a chevron; tapping moves to the next value and the value lights up briefly;
  - link: name and a chevron; it opens another window, whose button reads «Volver a Ajustes».

  Group titles are small headline type with more space above than below.
- **HUD pill.** A small coloured icon and a Nunito 800 number on translucent ink.
- **Result window.** An ivory window with:
  - a Lilita title;
  - 3 outlined stars, the centre one larger;
  - the stat that matters;
  - a quiet line for the reward;
  - Repeat (ivory) and Next (green).
- **Decision popup** (no cord, paywall):
  - **options at the same size**;
  - the price always visible;
  - "Ahora no" as a visible link with a touch target of at least 44 px;
  - no countdowns (legal framework LR-06/LR-12).
- **Board.** Ice with dots. A tile goes ivory with two pips, then yellow while falling, then lies flat in fallen grey-blue. Count markers every 4 tiles are small ink circles.
- **Theme picker (Ajustes › Apariencia).**
  - A 2-column list of the 11 themes.
  - Each item has a preview strip: the theme's screen colour, "Aa" in its display font, a tile and a primary-colour bar.
  - The theme name sits under the strip, with "Por defecto" under Dominó Pop.
  - The selected item has a 2 px accent ring and a check.
  - Club themes carry a small «Club» tag. Dominó Pop reads «Gratis · por defecto».
  - It is a radio group. The change applies instantly and is saved locally.
  - Trying a Club theme without the Club shows the try-out notice at the bottom (see Monetisation).

## Theme system (for Godot)

Every theme is one data file holding the same keys:

- **Screen:** `fondo`, `pantalla`, `texto`, `suave`, `acento`, `linea`, `marco`.
- **Panels and chips:** `panel`, `panel-t`, `chip`.
- **Buttons:** `prim`, `prim-t`, `prim-borde`, `prim-sombra`, `sec`, `sec-t`, `sec-borde`, `sec-sombra`.
- **Map nodes:** `nodo-h`, `nodo-a`, `nodo-c`.
- **Messages and veil:** `aviso`, `velo`.
- **Windows:** `ventana`, `ventana-t`, `ventana-s`.
- **Option cards:** `op`, `op-club`.
- **Radii:** `rb`, `rpanel`, `rventana`, `rnodo`.
- **Type:** the display font, the UI font and the button font, with their weights, case and tracking.
- **Canvas palette (`L`):** board, dot, tile, pip, falling, fallen, outline, shadow, bell, clapper, halo, start, count marker.
- **Copy overrides:** a small set, such as the primary button, the success title, the failure line and the no-cord title.

Components read only these keys, so adding a theme never touches layout. Textures are allowed per theme only as screen background layers:

- Gráfico: grid paper.
- Risografía: halftone.
- Nocturno: star field.
- Cine negro: film grain.

Fonts for every theme are SIL OFL from Google Fonts and are recorded in `docs/legal/REGISTRO_ASSETS.md`.

**Monetisation (decided 17/11/2026).**
- Dominó Pop is free. The other ten themes are part of Dingclub.
- A non-subscriber can **try any Club theme for free**. While trying it, a notice shows the price and two buttons of equal size: «Unirme al Club» and «Ahora no». «Ahora no» returns the game to Dominó Pop.
- If a subscription ends, the game returns to Dominó Pop and nothing else is lost.
- The one-time «Sin anuncios» purchase was removed: the Club is the only way to remove ads.
- Themes are never sold through a paid currency or in random packs (legal framework LR-04, LR-06, LR-07).

## Do's and Don'ts

- **Do** keep a single primary action per screen, in green (or each theme's `prim`).
- **Do** keep yellow for whatever is falling or being won.
- **Do** show the real screen under every popup.
- **Do** keep themes cosmetic: the same rules, prices and progress in all of them.
- **Don't** bring back outlined white headlines, ribbons, gradients or rainbow buttons in Dominó Pop. Those were the "overwhelming / AI-looking" tells of v1.
- **Don't** add "¡OFERTA!" ribbons, countdowns, or bundles with a paid currency (legal framework).
- **Don't** let a theme reduce contrast below 4.5:1 for body text or 3:1 for large text.
