class_name GlowFX
## Shared look for "this holds materials": one white-grey colour, and one fire-like flicker
## used by the material spheres (light + emission) and the pile outlines, so they breathe
## together. The flicker is layered sines (no per-frame random popping), same idea as the torch.

const COLOR := Color(0.86, 0.86, 0.82)          # white-grey glow
const LIGHT_COLOR := Color(0.90, 0.90, 0.86)

## Fire-like multiplier around 1.0: slow swell + quicker flutter, in [1-amount, 1+amount].
static func fire(t: float, seed_offset: float, amount: float = 0.35) -> float:
	var f := sin(t * 1.7 + seed_offset) * 0.5 \
		+ sin(t * 3.9 + seed_offset * 1.3) * 0.3 \
		+ sin(t * 8.3 + seed_offset * 0.7) * 0.2
	return 1.0 + f * amount

## Ease-in for the "fades up" on spawn: 0 -> 1 over `rise` seconds, fire-shaped (fast then soft).
static func rise(age: float, rise_time: float = 0.7) -> float:
	var x := clampf(age / maxf(rise_time, 0.001), 0.0, 1.0)
	return 1.0 - pow(1.0 - x, 2.2)
