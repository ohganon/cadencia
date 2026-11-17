# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Stack

Godot 4 (MIT), exported natively to iOS and Android at the same time (confirmed by the client, 16/11/2026). No custom backend in the MVP. HTML is used only for style boards and mockups during design; the game itself is not a web app.

## Users

A broad audience, confirmed by the client: from teenagers of 15–16 who are on TikTok to adults of 50–55 who enjoy mobile puzzle games. Play happens in short moments of 1–15 minutes (commute, coffee, sofa), mostly on phones, often one-handed and sometimes with the sound off. Spain and the US are the priority markets; the game needs no text to be played.

## Product Purpose

Dingfall is a free-to-play mobile puzzle game about dominoes. The player draws the path of the tiles with a finger, pushes the first one and watches the chain fall, ringing bells and setting off mechanisms. Success means players who come back because of curiosity, challenge and progress (never fear of losing something), who share their falls on social media, and a business funded by optional ads, a subscription (Dingclub) and cosmetic packs.

## Positioning

**The length of the path is the time.** Every tile takes the same time to fall, so a longer route arrives later. Easy at first ("reach the bell"), deep later: synchronising branches, ringing bells in order, arriving inside a gate's window. The simulation is discrete and deterministic, so what you plan is exactly what happens. Every play is a video worth sharing.

## Operating Context

- Core loop: draw → push → watch the fall → succeed, or see exactly where and why it stopped → retry for free.
- Daily loop: "La Caída del Día", the same level for everyone, with a result that can be shared as text or emoji without revealing the solution.
- Long-term loop: the campaign is told in neighbourhoods of the fictional town of Villa Cadencia. Every chapter adds a stretch to the festival's Great Chain, and the whole chain falls in a cinematic at the end of each chapter.
- Other modes: Taller (a level editor shared through text codes; a level must be beaten by its author before it can be published), Modo Libre (a sandbox for drawing and toppling), timed events.
- Energy ("Cuerda"): 1 per new campaign level, retries are free, max 5, 1 every 30 minutes, +3 per optional rewarded ad.

## Capabilities and Constraints

- The game uses its own visual language inside a Godot canvas rather than native iOS or Android components. It must still honour OS guarantees on both platforms: safe-area insets, system Back on Android, Reduce Motion, minimum touch targets (44 pt / 48 dp), and system purchase and permission sheets.
- 0 € budget: no paid assets and no hired artists. Every font, sound, music track and graphic must carry a commercially compatible licence, recorded in an asset register.
- It must run smoothly on mid-range phones while hundreds of tiles fall at once.
- No paid virtual currency, no paid randomness, no difficulty manipulation, no fake scarcity, no dark patterns (legal framework LR-01 to LR-15, docs/legal/MARCO_CUMPLIMIENTO_LEGAL.md).
- The commercial name is "Dingfall" (chosen 17/11/2026; "Cadencia" was dropped after a trademark conflict). The subscription is "Dingclub". Still provisional: "Tilde" (the apprentice clockmaker protagonist) and "Pío" (a tin wind-up bird who guides the player). A search for similar trademarks is still pending.

## Brand Commitments

No logo, colours or visual references are fixed yet; the client delegated the visual identity (16/11/2026). Already decided at concept level: the fictional clockmaker-and-toymaker town of Villa Cadencia and its domino festival, the characters Tilde and Pío, a friendly tone with no villains, and storytelling without dialogue text.

## Evidence on Hand

Market research only (docs/fase1, docs/fase2, docs/fase3). There are no players, screenshots, testimonials, press or sales yet, and none must be fabricated.

## Product Principles

1. Fun first: the drawing and the fall must be satisfying with no rewards attached.
2. Discoverable depth: every mechanism hides a technique worth mastering.
3. Positive retention: people come back for curiosity and challenge, never fear of loss.
4. Honest and clean: every level is solvable, randomness is free, prices are shown in euros.
5. Made to be shared: what happens on screen should be worth watching even for someone who is not playing.

## Accessibility & Inclusion

The audience spans 15 to 55, so readability has to work for older eyes too. Colour must never be the only cue (symbols alongside colour). Required: a high-contrast mode, adjustable interface size, everything playable with one hand, Reduce Motion respected, and a game fully playable with sound off.
