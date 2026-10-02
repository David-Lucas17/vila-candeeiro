extends Node2D

const FLAME_X := 300.0
const FLAME_Y := 392.0
const TABLE_TOP := 440.0
const BODY_X0 := 158.0
const BODY_X1 := 556.0
const BODY_STRIPS := 72

var energy : float = 0.7
var dread : float = 0.2
var flicker : float = 1.0

var _t : float = 0.0
var _shiver : float = 0.0

func _process(delta):
	_t += delta

	var base = 0.86 + 0.14 * sin(_t * 7.3) + 0.08 * sin(_t * 17.1 + 1.3)
	if randf() < 0.02 * (1.0 + dread * 2.0):
		base -= randf() * 0.30
	flicker = lerp(flicker, clampf(base, 0.35, 1.15), 0.25)

	_shiver = dread * 1.6 * sin(_t * 23.0) * (0.5 + 0.5 * sin(_t * 3.1))

	queue_redraw()

func _flame_pos() -> Vector2:
	return Vector2(FLAME_X + _shiver, FLAME_Y)

func _lit(base_color: Color, dist: float, extra: float = 0.0) -> Color:
	var fall = 1.0 / (1.0 + 0.000040 * dist * dist)
	var k = clampf(0.09 + fall * (0.50 + energy * 1.15) * flicker + extra, 0.0, 1.7)
	return Color(base_color.r * k, base_color.g * k * 0.96, base_color.b * k * 0.86, base_color.a)

func _draw():
	_draw_table()
	_draw_body()
	_draw_lamp()
	_draw_halo()

func _draw_table():
	var sx = _shiver
	var top = TABLE_TOP

	for px in [136.0, 572.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(px + sx, top + 18), Vector2(px + 26 + sx, top + 18),
			Vector2(px + 21 + sx, 520), Vector2(px + 5 + sx, 520),
		]), _lit(Color(0.26, 0.16, 0.09), _dist(Vector2(px + 13, 490))))

	draw_colored_polygon(PackedVector2Array([
		Vector2(74 + sx, top + 18), Vector2(646 + sx, top + 18),
		Vector2(604 + sx, top), Vector2(116 + sx, top),
	]), _lit(Color(0.40, 0.26, 0.15), _dist(Vector2(360, top + 8))))

	draw_colored_polygon(PackedVector2Array([
		Vector2(74 + sx, top + 18), Vector2(646 + sx, top + 18),
		Vector2(646 + sx, top + 32), Vector2(74 + sx, top + 32),
	]), _lit(Color(0.22, 0.13, 0.07), _dist(Vector2(360, top + 25))))

func _dist(p: Vector2) -> float:
	return p.distance_to(_flame_pos())

func _body_height(x: float) -> float:
	var h = 13.0
	h += 31.0 * _bump(x, 200.0, 30.0)
	h += 21.0 * _bump(x, 296.0, 54.0)
	h += 12.0 * _bump(x, 374.0, 44.0)
	h += 19.0 * _bump(x, 448.0, 38.0)
	h += 12.0 * _bump(x, 524.0, 27.0)

	h += 1.1 * sin(x * 0.085) + 0.7 * sin(x * 0.23 + 1.7)

	var edge = clampf(minf((x - BODY_X0) / 26.0, (BODY_X1 - x) / 26.0), 0.0, 1.0)
	return h * edge

func _bump(x: float, center: float, width: float) -> float:
	var t = (x - center) / width
	return exp(-t * t)

func _draw_body():
	var sx = _shiver
	var base_y = TABLE_TOP + 1
	var pano = Color(0.75, 0.70, 0.60)
	var flame = _flame_pos()
	var step = (BODY_X1 - BODY_X0) / float(BODY_STRIPS)

	var hs := []
	var cols := []
	for i in range(BODY_STRIPS + 1):
		var x = BODY_X0 + i * step
		var h = _body_height(x)
		hs.append(h)

		var slope = (_body_height(x + 2.0) - _body_height(x - 2.0)) / 4.0
		var normal = Vector2(-slope, -1.0).normalized()
		var p = Vector2(x, base_y - h)
		var lambert = clampf(normal.dot((flame - p).normalized()), 0.0, 1.0)
		cols.append(_lit(pano, p.distance_to(flame), lambert * 0.40 - 0.05))

	for i in range(BODY_STRIPS):
		var x0 = BODY_X0 + i * step + sx
		var x1 = x0 + step + 0.5
		draw_polygon(
			PackedVector2Array([
				Vector2(x0, base_y), Vector2(x0, base_y - hs[i]),
				Vector2(x1, base_y - hs[i + 1]), Vector2(x1, base_y),
			]),
			PackedColorArray([
				_dim(cols[i], 0.62), cols[i], cols[i + 1], _dim(cols[i + 1], 0.62),
			]))

	var hands = Vector2(352 + sx, base_y - _body_height(352.0) + 3)
	draw_circle(hands, 6.0, _lit(Color(0.56, 0.50, 0.41), _dist(hands), 0.10))
	for i in range(9):
		var ang = -PI * 0.12 + i * 0.20
		var bead = hands + Vector2(cos(ang), sin(ang)) * (10.0 + i * 1.6)
		draw_circle(bead, 1.7, _lit(Color(0.47, 0.33, 0.20), _dist(bead), 0.14))

func _dim(c: Color, k: float) -> Color:
	return Color(c.r * k, c.g * k, c.b * k, c.a)

func _draw_lamp():
	var cx = FLAME_X + _shiver
	var base_y = TABLE_TOP + 2

	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 30, base_y), Vector2(cx + 30, base_y),
		Vector2(cx + 23, base_y - 6), Vector2(cx - 23, base_y - 6),
	]), _lit(Color(0.44, 0.28, 0.14), 46.0, 0.10))

	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 23, base_y - 6), Vector2(cx - 26, base_y - 15),
		Vector2(cx - 20, base_y - 26), Vector2(cx - 8, base_y - 31),
		Vector2(cx + 8, base_y - 31), Vector2(cx + 20, base_y - 26),
		Vector2(cx + 26, base_y - 15), Vector2(cx + 23, base_y - 6),
	]), _lit(Color(0.50, 0.33, 0.16), 34.0, 0.16))

	draw_arc(Vector2(cx + 27, base_y - 18), 9.0, -PI * 0.5, PI * 0.5, 10,
		_lit(Color(0.38, 0.26, 0.14), 36.0, 0.1), 2.0)

	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 6, base_y - 31), Vector2(cx + 6, base_y - 31),
		Vector2(cx + 4, base_y - 39), Vector2(cx - 4, base_y - 39),
	]), _lit(Color(0.56, 0.38, 0.19), 24.0, 0.2))

	var h = (11.0 + 20.0 * energy) * flicker
	var w = (3.4 + 3.0 * energy) * (0.9 + 0.18 * sin(_t * 11.0))
	var lean = sin(_t * 5.1) * 1.8 * (1.0 + dread)
	var root_y = base_y - 39
	var tip = Vector2(cx + lean, root_y - h)

	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - w, root_y), Vector2(cx - w * 0.55, root_y - h * 0.55),
		tip, Vector2(cx + w * 0.55, root_y - h * 0.55), Vector2(cx + w, root_y),
	]), Color(1.0, 0.70, 0.26, 0.90))

	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - w * 0.45, root_y), Vector2(tip.x * 0.5 + cx * 0.5, root_y - h * 0.62),
		Vector2(cx + w * 0.45, root_y),
	]), Color(1.0, 0.95, 0.78, 0.95))

func _draw_halo():
	var c = _flame_pos()
	var reach = (90.0 + 210.0 * energy) * flicker
	for i in range(9):
		var k = float(i) / 8.0
		var r = reach * (0.16 + k * 0.84)
		var a = (0.055 * (1.0 - k)) * (0.30 + energy * 0.70) * flicker
		draw_circle(c, r, Color(1.0, 0.63, 0.23, a))
