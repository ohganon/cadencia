---
name: Cadencia
description: Dominó Pop. Juicy casual mobile-game UI built out of dominoes.
colors:
  pool-blue: "#1f63d8"
  pool-blue-deep: "#1149b8"
  ink: "#142554"
  ice: "#eaf3ff"
  ice-dot: "#cfe0ff"
  ivory: "#fffdf6"
  play-green: "#3ddc6b"
  play-green-lip: "#1e9e48"
  star-yellow: "#ffc83d"
  star-yellow-lip: "#d9921a"
  bell-coral: "#ff5470"
  bell-coral-lip: "#c42a48"
  helper-cyan: "#29d3f5"
  helper-cyan-lip: "#0d8fb5"
  locked-blue: "#9db4e6"
  fallen-tile: "#c9d6f2"
  white: "#ffffff"
typography:
  display:
    fontFamily: "Lilita One, Arial Rounded MT Bold, sans-serif"
    fontSize: "3.2rem"
    fontWeight: 400
    lineHeight: 1.05
    letterSpacing: "0.01em"
  headline:
    fontFamily: "Lilita One, Arial Rounded MT Bold, sans-serif"
    fontSize: "1.6rem"
    fontWeight: 400
    lineHeight: 1.05
  button:
    fontFamily: "Lilita One, Arial Rounded MT Bold, sans-serif"
    fontSize: "1.35rem"
    fontWeight: 400
    letterSpacing: "0.02em"
  body:
    fontFamily: "Nunito, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 700
    lineHeight: 1.45
  label:
    fontFamily: "Nunito, system-ui, sans-serif"
    fontSize: "0.85rem"
    fontWeight: 900
    lineHeight: 1.2
rounded:
  pill: "999px"
  button: "20px"
  panel: "22px"
  window: "26px"
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
    textColor: "{colors.white}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
    padding: "12px 22px 16px"
  button-reward:
    backgroundColor: "{colors.star-yellow}"
    textColor: "{colors.white}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
  button-bell:
    backgroundColor: "{colors.bell-coral}"
    textColor: "{colors.white}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
  button-secondary:
    backgroundColor: "{colors.helper-cyan}"
    textColor: "{colors.white}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
  button-disabled:
    backgroundColor: "#a7b6d6"
    textColor: "{colors.white}"
    rounded: "{rounded.button}"
  hud-pill:
    backgroundColor: "rgba(8,22,70,.5)"
    textColor: "{colors.white}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
  window:
    backgroundColor: "{colors.ivory}"
    textColor: "{colors.ink}"
    rounded: "{rounded.window}"
    padding: "56px 16px 18px"
  board:
    backgroundColor: "{colors.ice}"
    rounded: "{rounded.panel}"
  level-node-done:
    backgroundColor: "{colors.star-yellow}"
    textColor: "{colors.ink}"
    size: "52px"
  level-node-current:
    backgroundColor: "{colors.play-green}"
    textColor: "{colors.white}"
    size: "66px"
  level-node-locked:
    backgroundColor: "{colors.locked-blue}"
    textColor: "{colors.ink}"
    size: "52px"
---

# Design System: Cadencia

## Overview

**Creative North Star: «Dominó Pop».** It is the chunky, juicy UI of casual mobile games (thick outlines, buttons that sink when pressed, headlines in white with an outline), the language a 15–55 audience already reads on TikTok and in Royal Match or Block Blast. It adds one move of its own: **the interface is built from dominoes**. The logo is tiles toppling, the map path between levels is a row of tiles, and the tile counter is a tile.

Origin: the client rejected the previous direction and pinned this method, a redesign inspired by 222 Pinterest pins for "mobile game ui design inspo" (docs/fase6/rediseno/INSPIRACION_PINTEREST.md). Reference build: `docs/fase6/tablero/index.html`.

Anti-references: medieval wood and stone panels (RPG), dark esports neon, and violet gradients with a radial halo. The violet palette was replaced with blue in this same build because it reads as "AI-made".

## Colors

- **Pool Blue (#1F63D8 → #1149B8)** is the ground of every screen, as a vertical gradient with no halo. White text over it reads at 5.5:1 or better.
- **Ink (#142554)** is every outline, the shadow under headlines and the text on light surfaces. It is the glue of the whole look.
- **Ice (#EAF3FF)** is the board, with **Ice Dot (#CFE0FF)** dots every 24 px.
- **Ivory (#FFFDF6)** is the standing tile, popup windows and cards.
- Every colour has **one job**, and its darker lip (`-lip`) sits underneath:
  - **Play Green**: play and move forward.
  - **Star Yellow**: stars, rewards, cord, and **the tile currently falling (the only yellow tile on the board)**.
  - **Bell Coral**: bells and title ribbons.
  - **Helper Cyan**: secondary actions (repeat, back, undo).
- **Fallen Tile (#C9D6F2)** and **Locked Blue (#9DB4E6)** cover what has already happened or is not open yet.

## Typography

- **Lilita One** (SIL OFL) carries headlines, buttons and big figures. It is **always white with an ink outline and an ink shadow**: CSS `paint-order: stroke fill; -webkit-text-stroke: .16em ink; text-shadow: 0 .09em 0 ink`; in Godot, a Label with outline + shadow. That outline is what gives white text on green, yellow and cyan its contrast.
- **Nunito** (SIL OFL, 600–900) carries service copy, help and prices. Minimum 15 px in game; weight 700 or heavier on dark backgrounds.
- Short sentences, action verbs, no false urgency ("¡A TUMBAR!", "¡NIVEL SUPERADO!", "¡Casi! Prueba otra vez, es gratis.").

## Layout

- Phone, single column, one-handed. HUD at the top (cord with its timer and a "+", stars), content in the centre, **a single large primary action** at the bottom, and a 5-tab bottom nav whose active tab rises.
- Map: a vertical path of nodes linked by tiles. Done = yellow with stars, current = larger green with Pío, locked = muted blue.
- Popups centred over a translucent dark-blue veil, with the coral ribbon overlapping the top edge.

## Elevation & Depth

Depth is drawn the cartoon way, not with soft blur: **a solid ink shadow 4–6 px straight down** under buttons, panels and windows, plus **an inner lip at the bottom** in the darker shade of each colour. That is the native material of this world (casual chunky UI). It is not a decorative neo-brutalist shadow. Phone mockups only get a soft shadow, as presentation.

## Shapes

- Large, consistent radii: buttons 20 px, panels 22 px, windows 26 px, pills 999 px.
- 3 px ink outline on every interactive or informative element.
- Tiles are rounded rectangles (5 px) with two pips, and are the brand's recognisable form.

## Components

- **Pressable button**: colour + bottom lip + top highlight + ink outline + ink shadow. On press it sinks 4 px and the lip narrows (spring curve `cubic-bezier(.34,1.56,.64,1)`, 120 ms). Disabled = grey-blue, no change on press.
- **HUD pill**: round icon in a colour, a number in Nunito 900, and an optional green "+" for getting more (free ad first, never a paid currency).
- **Result window**: ivory, coral ribbon, 3 stars (the centre one larger), the stat that matters (tiles used against the level target), a reward and two buttons (Repeat / Next).
- **Decision popup** (no cord, paywall): **options at the same size**, price always visible, "Ahora no" as a visible link, and no countdowns (legal framework LR-06/LR-12).
- **Board**: ice with dots. Ivory tile with two pips → yellow while falling → lying flat in fallen grey-blue. Count markers every 4 tiles as small ink circles with a white number.

## Do's and Don'ts

- **Do** keep a single primary action per screen, in green.
- **Do** keep yellow for whatever is falling or being won. Never use it for a button that spends money.
- **Do** use dominoes as UI material (paths, counters, logo) when it helps people understand the game.
- **Don't** use violet gradients or radial halos on the background. They were rejected for reading as generic.
- **Don't** add "¡OFERTA!" ribbons, countdowns, or bundles with a paid currency (legal framework).
- **Don't** use white text without the ink outline on light colours.
