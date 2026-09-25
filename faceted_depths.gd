extends Node2D

const TILE_WIDTH := 96.0
const TILE_HEIGHT := 48.0
const WALL_HEIGHT := 58.0
const MAP_ORIGIN := Vector2(640.0, 248.0)
const PLAYER_SPEED := 3.8
const ENEMY_SPEED := 1.45
const ATTACK_COOLDOWN := 0.34
const MAX_HEALTH := 5
const START_CELL := Vector2i(1, 7)
const EXIT_CELL := Vector2i(10, 1)
const SHARD_CELLS := [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)]
const ENEMY_SPAWNS := [Vector2i(3, 6), Vector2i(4, 2), Vector2i(6, 4), Vector2i(8, 6), Vector2i(10, 3)]
const MAP := [
	"############",
	"#....#.....#",
	"#....#.....#",
	"#.##.##.##.#",
	"#......#...#",
	"#.####.#.#.#",
	"#....#...#.#",
	"#..........#",
	"############",
]

const COLOR_VOID := Color("060914")
const COLOR_DEEP := Color("0b1020")
const COLOR_INK := Color("111629")
const COLOR_INK_SOFT := Color("1b2238")
const COLOR_SLATE := Color("26334d")
const COLOR_SLATE_LIGHT := Color("364765")
const COLOR_AMETHYST := Color("6e4b8b")
const COLOR_TEAL := Color("2a7d7b")
const COLOR_AMBER := Color("f0ad4e")
const COLOR_CYAN := Color("6de5df")
const COLOR_OXBLOOD := Color("c04a5d")
const COLOR_PAPER := Color("e8edf5")
const COLOR_MUTED := Color("9aa8bd")

var walkable: Dictionary = {}
var flow: Dictionary = {}
var shards: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var player_frames: Dictionary = {}
var sword_frames: Dictionary = {}
var player_position := Vector2.ZERO
var player_facing := Vector2(1.0, 1.0).normalized()
var health := MAX_HEALTH
var shards_collected := 0
var state := "playing"
var message := ""
var message_timer := 0.0
var elapsed := 0.0
var walk_animation := 0.0
var attack_cooldown := 0.0
var invulnerability := 0.0
var shake_strength := 0.0
var screen_shake := Vector2.ZERO
var last_player_cell := Vector2i(-999, -999)
var ui_font: Font
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.seed = 260925
	ui_font = SystemFont.new()
	ui_font.font_names = PackedStringArray(["DejaVu Sans", "sans-serif"])
	load_player_assets()
	reset_game()

func load_player_assets() -> void:
	var base_path := "res://assets/player/isometric/"
	var frame_counts := {"ne": 4, "se": 4, "sw": 4, "nw": 4}
	for face in frame_counts:
		var frames: Array[Texture2D] = []
		for frame_index in range(int(frame_counts[face])):
			var texture := load(base_path + face + "/" + face + str(frame_index + 1) + ".png") as Texture2D
			frames.append(texture)
		player_frames[face] = frames
	for direction in ["ne", "se", "sw", "nw"]:
		sword_frames[direction] = load(base_path + "sword_" + direction + ".png") as Texture2D

func reset_game() -> void:
	build_walkable()
	player_position = Vector2(START_CELL) + Vector2(0.5, 0.5)
	player_facing = Vector2(1.0, 1.0).normalized()
	health = MAX_HEALTH
	shards_collected = 0
	state = "playing"
	message = "Recover the three light shards"
	message_timer = 3.0
	elapsed = 0.0
	walk_animation = 0.0
	attack_cooldown = 0.0
	invulnerability = 0.0
	shake_strength = 0.0
	screen_shake = Vector2.ZERO
	last_player_cell = Vector2i(-999, -999)
	shards.clear()
	enemies.clear()
	effects.clear()
	for index in range(SHARD_CELLS.size()):
		var cell: Vector2i = SHARD_CELLS[index]
		shards.append({
			"position": Vector2(cell) + Vector2(0.5, 0.5),
			"taken": false,
			"phase": index * 1.7,
		})
	rebuild_flow()
	for index in range(ENEMY_SPAWNS.size()):
		var cell: Vector2i = ENEMY_SPAWNS[index]
		if not walkable.has(cell) or not flow.has(cell):
			continue
		var enemy_index := enemies.size()
		enemies.append({
			"position": Vector2(cell) + Vector2(0.5, 0.5),
			"health": 2,
			"hit_flash": 0.0,
			"attack_cooldown": 0.45 + enemy_index * 0.08,
			"phase": enemy_index * 0.9,
		})

func build_walkable() -> void:
	walkable.clear()
	for y in range(MAP.size()):
		var row: String = MAP[y]
		for x in range(row.length()):
			if row[x] != "#":
				walkable[Vector2i(x, y)] = true

func _process(delta: float) -> void:
	elapsed += delta
	message_timer = maxf(0.0, message_timer - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	invulnerability = maxf(0.0, invulnerability - delta)
	if shake_strength > 0.0:
		shake_strength = maxf(0.0, shake_strength - delta * 2.2)
		screen_shake = Vector2(random.randf_range(-1.0, 1.0), random.randf_range(-1.0, 1.0)) * shake_strength * 7.0
	else:
		screen_shake = Vector2.ZERO
	if state == "playing":
		update_player(delta)
		update_enemies(delta)
		collect_shards()
	update_effects(delta)
	queue_redraw()

func update_player(delta: float) -> void:
	var input_direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	if input_direction.length_squared() > 0.0:
		input_direction = input_direction.normalized()
		var world_direction := Vector2(
			input_direction.x + input_direction.y,
			input_direction.y - input_direction.x
		).normalized()
		player_position = move_with_collisions(player_position, world_direction * PLAYER_SPEED * delta, 0.22)
		player_facing = world_direction
		walk_animation += delta * 8.0
		var current_cell := cell_at(player_position)
		if current_cell != last_player_cell:
			last_player_cell = current_cell
			rebuild_flow()
	if Input.is_physical_key_pressed(KEY_SPACE):
		attack()

func move_with_collisions(current: Vector2, movement: Vector2, radius: float) -> Vector2:
	var candidate := current + movement
	if can_occupy(candidate, radius):
		return candidate
	var horizontal := Vector2(candidate.x, current.y)
	if can_occupy(horizontal, radius):
		return horizontal
	var vertical := Vector2(current.x, candidate.y)
	if can_occupy(vertical, radius):
		return vertical
	return current

func can_occupy(position: Vector2, radius: float) -> bool:
	for offset: Vector2 in [Vector2(-radius, -radius), Vector2(radius, -radius), Vector2(-radius, radius), Vector2(radius, radius)]:
		var probe: Vector2 = position + offset
		if not walkable.has(cell_at(probe)):
			return false
	return true

func cell_at(position: Vector2) -> Vector2i:
	return Vector2i(int(floor(position.x)), int(floor(position.y)))

func rebuild_flow() -> void:
	flow.clear()
	var start := cell_at(player_position)
	if not walkable.has(start):
		return
	flow[start] = 0
	var queue: Array[Vector2i] = [start]
	var directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		for direction in directions:
			var neighbor: Vector2i = current + direction
			if walkable.has(neighbor) and not flow.has(neighbor):
				flow[neighbor] = int(flow[current]) + 1
				queue.append(neighbor)

func best_flow_step(current: Vector2i) -> Vector2i:
	var best := current
	var best_distance := int(flow.get(current, 9999))
	for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var neighbor: Vector2i = current + direction
		if flow.has(neighbor) and int(flow[neighbor]) < best_distance:
			best = neighbor
			best_distance = int(flow[neighbor])
	return best

func update_enemies(delta: float) -> void:
	for enemy in enemies:
		enemy["hit_flash"] = maxf(0.0, float(enemy["hit_flash"]) - delta)
		enemy["attack_cooldown"] = maxf(0.0, float(enemy["attack_cooldown"]) - delta)
		var enemy_position: Vector2 = enemy["position"]
		var distance := enemy_position.distance_to(player_position)
		if distance < 0.72:
			if float(enemy["attack_cooldown"]) <= 0.0:
				enemy["attack_cooldown"] = 0.9
				hurt_player()
			continue
		var current := cell_at(enemy_position)
		var next := best_flow_step(current)
		if next == current:
			continue
		var target := Vector2(next) + Vector2(0.5, 0.5)
		var movement := (target - enemy_position).normalized() * ENEMY_SPEED * delta
		var candidate := move_with_collisions(enemy_position, movement, 0.2)
		if can_occupy(candidate, 0.2):
			enemy["position"] = candidate

func attack() -> void:
	if state != "playing" or attack_cooldown > 0.0:
		return
	attack_cooldown = ATTACK_COOLDOWN
	effects.append({
		"kind": "slash",
		"position": player_position,
		"direction": player_facing,
		"age": 0.0,
		"life": 0.2,
		"phase": 0.0,
		"color": COLOR_AMBER,
	})
	var connected := false
	for index in range(enemies.size() - 1, -1, -1):
		var enemy := enemies[index]
		var enemy_position: Vector2 = enemy["position"]
		var offset := enemy_position - player_position
		var distance := offset.length()
		var in_facing := distance < 0.001 or player_facing.dot(offset / distance) > 0.05
		if distance <= 1.2 and in_facing:
			connected = true
			enemy["health"] = int(enemy["health"]) - 1
			enemy["hit_flash"] = 0.18
			spawn_burst(enemy_position, COLOR_CYAN)
			if int(enemy["health"]) <= 0:
				spawn_burst(enemy_position, COLOR_OXBLOOD, 10)
				enemies.remove_at(index)
	if connected:
		add_shake(0.28)

func hurt_player() -> void:
	if state != "playing" or invulnerability > 0.0:
		return
	health = maxi(0, health - 1)
	invulnerability = 0.85
	add_shake(0.5)
	spawn_burst(player_position, COLOR_OXBLOOD)
	if health <= 0:
		state = "lost"
		message = "The depths reclaimed the light"
		message_timer = 99.0

func collect_shards() -> void:
	for shard in shards:
		if not bool(shard["taken"]) and player_position.distance_to(shard["position"]) < 0.62:
			shard["taken"] = true
			shards_collected += 1
			health = mini(MAX_HEALTH, health + 1)
			spawn_burst(shard["position"], COLOR_CYAN, 12)
			add_shake(0.22)
			if shards_collected >= SHARD_CELLS.size():
				message = "The gate is open — find the northern seal"
				message_timer = 4.0
			else:
				message = "Light shard " + str(shards_collected) + " / " + str(SHARD_CELLS.size())
				message_timer = 2.2
	var exit_position := Vector2(EXIT_CELL) + Vector2(0.5, 0.5)
	if shards_collected >= SHARD_CELLS.size() and player_position.distance_to(exit_position) < 0.56:
		state = "won"
		message = "The light is free"
		message_timer = 99.0

func spawn_burst(position: Vector2, color: Color, count := 8) -> void:
	effects.append({
		"kind": "burst",
		"position": position,
		"direction": Vector2.ZERO,
		"age": 0.0,
		"life": 0.34,
		"phase": count * 0.37,
		"color": color,
	})

func add_shake(strength: float) -> void:
	shake_strength = maxf(shake_strength, strength)

func update_effects(delta: float) -> void:
	for index in range(effects.size() - 1, -1, -1):
		var effect := effects[index]
		effect["age"] = float(effect["age"]) + delta
		if float(effect["age"]) >= float(effect["life"]):
			effects.remove_at(index)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if keycode == KEY_R:
			reset_game()
			get_viewport().set_input_as_handled()

func iso_to_screen(world_position: Vector2) -> Vector2:
	var projected := MAP_ORIGIN + Vector2(
		(world_position.x - world_position.y) * TILE_WIDTH * 0.5,
		(world_position.x + world_position.y) * TILE_HEIGHT * 0.5
	) + screen_shake
	return Vector2(round(projected.x * 0.5) * 2.0, round(projected.y * 0.5) * 2.0)

func player_face_name() -> String:
	if player_facing.x >= 0.0:
		return "ne" if player_facing.y < 0.0 else "se"
	return "nw" if player_facing.y < 0.0 else "sw"

func floor_color(cell: Vector2i) -> Color:
	var value := posmod(cell.x * 3 + cell.y * 5 + cell.x * cell.y, 5)
	match value:
		0:
			return COLOR_SLATE
		1:
			return COLOR_SLATE_LIGHT
		2:
			return Color("303a54")
		3:
			return Color("294654")
		_:
			return Color("40344f")

func _draw() -> void:
	var viewport := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport), COLOR_VOID, true)
	draw_atmosphere(viewport)
	draw_floors()
	draw_front_boundary()
	draw_depth_sorted()
	draw_effects()
	draw_hud(viewport)

func draw_atmosphere(viewport: Vector2) -> void:
	var cavern := PackedVector2Array([
		Vector2(92, 270),
		Vector2(640, 8),
		Vector2(1190, 270),
		Vector2(640, 708),
	])
	draw_colored_polygon(cavern, COLOR_DEEP)
	for index in range(9):
		var start := Vector2(90 + index * 142, 36 + posmod(index * 83, 180))
		draw_line(start, start + Vector2(86, 118), Color(0.16, 0.2, 0.3, 0.16), 1.0)
	for index in range(34):
		var dust := Vector2(fposmod(index * 193.0 + 31.0, viewport.x), fposmod(index * 271.0 + 19.0, viewport.y))
		var pulse := 0.18 + sin(elapsed * 1.4 + index) * 0.08
		draw_circle(dust, 1.0 + float(index % 3) * 0.35, Color(COLOR_CYAN, pulse))

func tile_diamond(center: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0, -TILE_HEIGHT * 0.5),
		center + Vector2(TILE_WIDTH * 0.5, 0),
		center + Vector2(0, TILE_HEIGHT * 0.5),
		center + Vector2(-TILE_WIDTH * 0.5, 0),
		center + Vector2(0, -TILE_HEIGHT * 0.5),
	])

func draw_floors() -> void:
	for key in walkable:
		var cell: Vector2i = key
		var center := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
		var diamond := tile_diamond(center)
		var base := floor_color(cell)
		draw_colored_polygon(diamond, base)
		draw_colored_polygon(PackedVector2Array([
			center,
			diamond[1],
			diamond[2],
		]), base.lightened(0.07))
		draw_colored_polygon(PackedVector2Array([
			center,
			diamond[3],
			diamond[2],
		]), base.darkened(0.12))
		draw_polyline(diamond, Color(COLOR_INK, 0.78), 1.0, true)

func draw_depth_sorted() -> void:
	var drawables: Array[Dictionary] = []
	for y in range(MAP.size()):
		var row: String = MAP[y]
		for x in range(row.length()):
			var cell := Vector2i(x, y)
			var front_boundary := y == MAP.size() - 1 or x == row.length() - 1
			if not walkable.has(cell) and not front_boundary:
				drawables.append({
					"depth": iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5)).y,
					"kind": "wall",
					"cell": cell,
				})
	for shard in shards:
		if not bool(shard["taken"]):
			drawables.append({
				"depth": iso_to_screen(shard["position"]).y,
				"kind": "shard",
				"shard": shard,
			})
	drawables.append({
		"depth": iso_to_screen(Vector2(EXIT_CELL) + Vector2(0.5, 0.5)).y,
		"kind": "gate",
	})
	drawables.append({
		"depth": iso_to_screen(player_position).y,
		"kind": "player",
		"index": -1,
	})
	for index in range(enemies.size()):
		drawables.append({
			"depth": iso_to_screen(enemies[index]["position"]).y,
			"kind": "enemy",
			"index": index,
		})
	drawables.sort_custom(func(a, b): return float(a["depth"]) < float(b["depth"]))
	for drawable in drawables:
		match String(drawable["kind"]):
			"wall":
				var wall_cell: Vector2i = drawable["cell"]
				draw_wall(wall_cell)
			"shard":
				var shard: Dictionary = drawable["shard"]
				draw_shard(shard)
			"gate":
				draw_gate()
			"player":
				draw_player()
			"enemy":
				var enemy_index: int = drawable["index"]
				draw_enemy(enemy_index)

func draw_front_boundary() -> void:
	var bottom_row := MAP.size() - 1
	for x in range(MAP[bottom_row].length()):
		draw_wall(Vector2i(x, bottom_row), 16.0)
	for y in range(bottom_row):
		draw_wall(Vector2i(MAP[y].length() - 1, y), 16.0)

func draw_wall(cell: Vector2i, height := WALL_HEIGHT) -> void:
	var floor_center := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
	var top_center := floor_center - Vector2(0, height)
	var top := tile_diamond(top_center)
	var right_face := PackedVector2Array([
		top[1],
		top[2],
		top[2] + Vector2(0, height),
		top[1] + Vector2(0, height),
	])
	var left_face := PackedVector2Array([
		top[2],
		top[3],
		top[3] + Vector2(0, height),
		top[2] + Vector2(0, height),
	])
	var top_color := COLOR_INK_SOFT if posmod(cell.x + cell.y, 2) == 0 else Color("202840")
	draw_colored_polygon(right_face, COLOR_INK.darkened(0.16))
	draw_colored_polygon(left_face, COLOR_INK)
	draw_colored_polygon(top, top_color)
	draw_colored_polygon(PackedVector2Array([
		top_center,
		top[1],
		top[2],
	]), top_color.lightened(0.08))
	draw_polyline(top, Color("0a0d18"), 1.5, true)
	draw_line(right_face[0], right_face[3], Color("0a0d18"), 1.0)
	draw_line(left_face[0], left_face[3], Color("0a0d18"), 1.0)

func draw_gate() -> void:
	var position := iso_to_screen(Vector2(EXIT_CELL) + Vector2(0.5, 0.5))
	var open := shards_collected >= SHARD_CELLS.size()
	var color := COLOR_CYAN if open else Color("6b5268")
	var pulse := 0.5 + sin(elapsed * 3.0) * 0.5
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-38, 4),
		position + Vector2(0, -32),
		position + Vector2(38, 4),
		position + Vector2(0, 40),
	]), Color(color, 0.07 + pulse * 0.06))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-27, -4),
		position + Vector2(-14, -4),
		position + Vector2(-14, -67),
		position + Vector2(-27, -54),
	]), color.darkened(0.28))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(14, -4),
		position + Vector2(27, -4),
		position + Vector2(27, -54),
		position + Vector2(14, -67),
	]), color.darkened(0.12))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-32, -58),
		position + Vector2(0, -82),
		position + Vector2(32, -58),
		position + Vector2(0, -40),
	]), color)
	draw_circle(position + Vector2(0, -58), 4.0 + pulse * 2.0, COLOR_PAPER)
	if not open:
		for offset in range(3):
			draw_line(position + Vector2(-15 + offset * 15, -58), position + Vector2(-15 + offset * 15, -12), Color(COLOR_OXBLOOD, 0.55), 3.0)

func draw_shard(shard: Dictionary) -> void:
	var position := iso_to_screen(shard["position"])
	var bob := sin(elapsed * 3.0 + float(shard["phase"])) * 5.0
	var center := position + Vector2(0, -24 + bob)
	draw_shadow(position, 22.0, 0.28)
	draw_crystal(center, 15.0, COLOR_CYAN)
	for index in range(3):
		var angle := elapsed * 1.8 + float(shard["phase"]) + index * TAU / 3.0
		var orbit := center + Vector2(cos(angle), sin(angle) * 0.42) * 25.0
		draw_circle(orbit, 1.8, Color(COLOR_PAPER, 0.8))

func draw_player() -> void:
	var position := iso_to_screen(player_position)
	draw_shadow(position, 24.0, 0.38)
	var face := player_face_name()
	var frames: Array = player_frames.get(face, [])
	var frame_index := int(walk_animation) % maxi(1, frames.size())
	var body_texture: Texture2D = frames[frame_index] if not frames.is_empty() else null
	var sword_texture: Texture2D = sword_frames.get(face, null)
	var tint := Color.WHITE
	if invulnerability > 0.0 and int(elapsed * 18.0) % 2 == 0:
		tint = Color(1.0, 0.72, 0.76, 0.46)
	if face == "nw" and sword_texture:
		draw_player_texture(sword_texture, position, Color(COLOR_AMBER, tint.a))
	if body_texture:
		draw_player_texture(body_texture, position, tint)
	else:
		draw_crystal(position + Vector2(0, -36), 26.0, COLOR_AMETHYST)
	if face != "nw" and sword_texture:
		draw_player_texture(sword_texture, position, Color(COLOR_AMBER, tint.a))

func draw_player_texture(texture: Texture2D, position: Vector2, tint: Color) -> void:
	var scale := 2.0
	var size := texture.get_size() * scale
	var rect := Rect2(position - Vector2(size.x * 0.5, 45.0 * scale), size)
	draw_texture_rect(texture, rect, false, tint)

func draw_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy := enemies[index]
	var position := iso_to_screen(enemy["position"])
	var bob := sin(elapsed * 5.0 + float(enemy["phase"])) * 3.0
	var body_center := position + Vector2(0, -28 + bob)
	var color := COLOR_OXBLOOD if float(enemy["hit_flash"]) <= 0.0 else COLOR_PAPER
	draw_shadow(position, 21.0, 0.32)
	draw_crystal(body_center, 23.0, color)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-18, -9),
		body_center + Vector2(-12, -28),
		body_center + Vector2(-5, -17),
	]), color.lightened(0.12))
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(18, -9),
		body_center + Vector2(12, -28),
		body_center + Vector2(5, -17),
	]), color.lightened(0.12))
	draw_circle(body_center + Vector2(-7, -4), 2.4, COLOR_AMBER)
	draw_circle(body_center + Vector2(7, -4), 2.4, COLOR_AMBER)
	if int(enemy["health"]) == 1:
		draw_crystal(position + Vector2(0, -65), 6.0, COLOR_AMBER)

func draw_shadow(position: Vector2, radius: float, alpha: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-radius, 0),
		position + Vector2(0, -radius * 0.38),
		position + Vector2(radius, 0),
		position + Vector2(0, radius * 0.38),
	]), Color(0.01, 0.015, 0.03, alpha))

func draw_crystal(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.72, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.72, 0),
		center + Vector2(0, -radius),
	])
	draw_colored_polygon(points, color)
	draw_colored_polygon(PackedVector2Array([
		center,
		points[1],
		points[2],
	]), color.darkened(0.2))
	draw_polyline(points, color.lightened(0.38), 1.5, true)
	draw_line(center, points[0], color.lightened(0.2), 1.0)

func draw_effects() -> void:
	for effect in effects:
		var progress := clampf(float(effect["age"]) / float(effect["life"]), 0.0, 1.0)
		var position := iso_to_screen(effect["position"])
		var color: Color = effect["color"]
		color.a *= 1.0 - progress
		if effect["kind"] == "slash":
			var direction: Vector2 = effect["direction"]
			var screen_direction := Vector2(direction.x - direction.y, direction.x + direction.y).normalized()
			var start_angle := atan2(screen_direction.y, screen_direction.x) - 0.85
			draw_arc(position + Vector2(0, -22), 34.0 + progress * 18.0, start_angle, start_angle + 1.7, 24, color, 7.0 * (1.0 - progress) + 1.0, true)
		else:
			var count := int(effect["phase"])
			for index in range(count):
				var angle := index * TAU / float(count) + float(effect["phase"])
				var from := position + Vector2(cos(angle), sin(angle) * 0.55) * (8.0 + progress * 13.0)
				var to := position + Vector2(cos(angle), sin(angle) * 0.55) * (18.0 + progress * 42.0)
				draw_line(from, to, color, 2.5)

func draw_hud(viewport: Vector2) -> void:
	draw_plaque(Rect2(30, 24, 330, 76), COLOR_AMBER)
	draw_string(ui_font, Vector2(50, 57), "FACETED DEPTHS", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, COLOR_PAPER)
	var objective := "Find the light shards"
	if shards_collected >= SHARD_CELLS.size():
		objective = "Reach the northern seal"
	draw_string(ui_font, Vector2(51, 83), objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, COLOR_AMBER)
	var shard_rect := Rect2(viewport.x - 244, 24, 214, 76)
	draw_plaque(shard_rect, COLOR_CYAN)
	draw_string(ui_font, shard_rect.position + Vector2(18, 26), "LIGHT SHARDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COLOR_MUTED)
	for index in range(SHARD_CELLS.size()):
		var center := shard_rect.position + Vector2(32 + index * 58, 52)
		if index < shards_collected:
			draw_hud_diamond(center, 13.0, COLOR_CYAN)
		else:
			draw_hud_diamond(center, 13.0, Color(COLOR_MUTED, 0.25))
	var health_rect := Rect2(30, viewport.y - 82, 280, 54)
	draw_plaque(health_rect, COLOR_OXBLOOD)
	draw_string(ui_font, health_rect.position + Vector2(18, 24), "VITALITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COLOR_MUTED)
	for index in range(MAX_HEALTH):
		var center := health_rect.position + Vector2(112 + index * 29, 27)
		if index < health:
			draw_hud_diamond(center, 10.0, COLOR_OXBLOOD.lightened(0.08))
		else:
			draw_hud_diamond(center, 10.0, Color(COLOR_MUTED, 0.2))
	var controls := "WASD / ARROWS  MOVE     SPACE  STRIKE     R  RESTART"
	var controls_size := ui_font.get_string_size(controls, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	var controls_rect := Rect2(viewport.x - controls_size.x - 68, viewport.y - 54, controls_size.x + 38, 30)
	draw_plaque(controls_rect, COLOR_SLATE_LIGHT)
	draw_string(ui_font, controls_rect.position + Vector2(19, 20), controls, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, COLOR_MUTED)
	if message_timer > 0.0:
		draw_message(viewport)
	if state != "playing":
		draw_state_overlay(viewport)

func draw_plaque(rect: Rect2, accent: Color) -> void:
	draw_rect(Rect2(rect.position + Vector2(5, 7), rect.size), Color(0.0, 0.0, 0.0, 0.25), true)
	draw_rect(rect, Color(0.025, 0.04, 0.075, 0.94), true)
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), accent, 2.0)
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, Color(accent, 0.28), 1.0)

func draw_hud_diamond(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.72, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.72, 0),
	])
	draw_colored_polygon(points, color)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), color.lightened(0.3), 1.0, true)

func draw_message(viewport: Vector2) -> void:
	var alpha := clampf(message_timer * 2.0, 0.0, 1.0)
	var text_size := ui_font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	var rect := Rect2((viewport.x - text_size.x) * 0.5 - 22, 108, text_size.x + 44, 42)
	draw_rect(Rect2(rect.position + Vector2(3, 5), rect.size), Color(0, 0, 0, 0.22 * alpha), true)
	draw_rect(rect, Color(0.035, 0.055, 0.095, 0.92 * alpha), true)
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color(COLOR_CYAN, alpha), 2.0)
	draw_string(ui_font, rect.position + Vector2(22, 28), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(COLOR_PAPER, alpha))

func draw_state_overlay(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.015, 0.02, 0.045, 0.82), true)
	var center := Vector2(viewport.x * 0.5, viewport.y * 0.48)
	var accent := COLOR_CYAN if state == "won" else COLOR_OXBLOOD
	draw_crystal(center + Vector2(0, -76), 42.0 + sin(elapsed * 2.2) * 2.0, accent)
	var title := "THE GATE OPENS" if state == "won" else "THE LIGHT FADES"
	var subtitle := "The shards return to the deep" if state == "won" else "Press R to descend again"
	draw_string(ui_font, Vector2(0, center.y + 18), title, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 42, COLOR_PAPER)
	draw_string(ui_font, Vector2(0, center.y + 58), subtitle, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 17, Color(accent, 0.9))
