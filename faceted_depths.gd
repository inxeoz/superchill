extends Node2D

const TILE_WIDTH := 96.0
const TILE_HEIGHT := 48.0
const WALL_HEIGHT := 58.0
const MAP_ORIGIN := Vector2(640.0, 248.0)
const CAMERA_PIVOT := Vector2(640.0, 420.0)
const PLAYER_SPEED := 3.8
const ENEMY_SPEED := 1.45
const ATTACK_COOLDOWN := 0.34
const MAX_HEALTH := 5
const LIFE_JACKET_BOTTLES := 8
const SOURCE_REACH := 1.35
const DEFAULT_CAMERA_ZOOM := 1.08
const CAMERA_FOLLOW_RATE := 2.4
const LEVELS := [
	{
		"name": "RIVER RUN",
		"kind": "surface",
		"map": [
			"############",
			"#.....~....#",
			"#..#..~#...#",
			"#.....~....#",
			"#..#..~..#.#",
			"#.....~....#",
			"#.##..~..#.#",
			"#.....~....#",
			"############",
		],
		"shards": [],
		"spawns": [],
		"sources": [
			{"kind": "dustbin", "name": "GARBAGE DUSTBIN", "cell": Vector2i(4, 6), "charges": 3, "bottles": 2},
			{"kind": "recycling", "name": "RECYCLING BIN", "cell": Vector2i(1, 3), "charges": 1, "bottles": 3},
			{"kind": "crate", "name": "BOTTLE CRATE", "cell": Vector2i(4, 1), "charges": 1, "bottles": 2},
			{"kind": "cooler", "name": "PICNIC COOLER", "cell": Vector2i(2, 4), "charges": 1, "bottles": 3},
		],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"void": "102f3a",
		"deep": "79bee3",
		"ink": "294f59",
		"ink_soft": "3c6b68",
		"wall_alt": "557f5f",
		"slate": "79a96f",
		"slate_light": "9bc47a",
		"floor_mist": "b4d489",
		"floor_petrol": "70a77c",
		"floor_plum": "d4c887",
		"accent": "f2b84b",
		"safe": "45d9d2",
		"danger": "cf4f5e",
		"enemy": "cf4f5e",
		"enemy_accent": "f2b84b",
		"gate": "70594a",
		"paper": "fffdf0",
		"muted": "b7d0d0",
	},
	{
		"name": "FACETED DEPTHS",
		"map": [
			"############",
			"#....#.....#",
			"#....#.....#",
			"#.##.##.##.#",
			"#......#...#",
			"#.####.#.#.#",
			"#....#...#.#",
			"#..........#",
			"############",
		],
		"shards": [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)],
		"spawns": [Vector2i(3, 6), Vector2i(4, 2), Vector2i(6, 4), Vector2i(8, 6), Vector2i(10, 3)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "shardling",
		"enemy_health": 2,
		"enemy_speed": 1.45,
		"void": "060914",
		"deep": "0b1020",
		"ink": "111629",
		"ink_soft": "1b2238",
		"wall_alt": "202840",
		"slate": "26334d",
		"slate_light": "364765",
		"floor_mist": "303a54",
		"floor_petrol": "294654",
		"floor_plum": "40344f",
		"accent": "f0ad4e",
		"safe": "6de5df",
		"danger": "c04a5d",
		"enemy": "c04a5d",
		"enemy_accent": "f0ad4e",
		"gate": "6b5268",
		"paper": "e8edf5",
		"muted": "9aa8bd",
	},
	{
		"name": "MOSSGLASS CISTERN",
		"map": [
			"############",
			"#.#...#....#",
			"#.##....#..#",
			"#.#..###.#.#",
			"#....##...##",
			"##.........#",
			"#..##.#...##",
			"#...##..#.##",
			"############",
		],
		"shards": [Vector2i(3, 1), Vector2i(7, 4), Vector2i(9, 6)],
		"spawns": [Vector2i(4, 2), Vector2i(5, 5), Vector2i(8, 5), Vector2i(2, 6), Vector2i(10, 3)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "mireling",
		"enemy_health": 3,
		"enemy_speed": 1.1,
		"void": "041512",
		"deep": "0b241e",
		"ink": "12352d",
		"ink_soft": "1c4a3d",
		"wall_alt": "28624b",
		"slate": "245648",
		"slate_light": "32765b",
		"floor_mist": "2a6750",
		"floor_petrol": "3c8060",
		"floor_plum": "456d45",
		"accent": "b7e36b",
		"safe": "7ef0c1",
		"danger": "d77955",
		"enemy": "4f9e69",
		"enemy_accent": "d9f27c",
		"gate": "477b68",
		"paper": "eaf6dc",
		"muted": "a6c4aa",
	},
	{
		"name": "EMBER VAULT",
		"map": [
			"############",
			"##....#..#.#",
			"###..#.....#",
			"#..#...#...#",
			"#...#....#.#",
			"#...###....#",
			"#.#.....##.#",
			"#..#.###...#",
			"############",
		],
		"shards": [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)],
		"spawns": [Vector2i(3, 6), Vector2i(4, 2), Vector2i(6, 4), Vector2i(8, 5), Vector2i(10, 5)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "forge_golem",
		"enemy_health": 4,
		"enemy_speed": 0.9,
		"void": "140b08",
		"deep": "26130b",
		"ink": "321a13",
		"ink_soft": "4a281b",
		"wall_alt": "6b3422",
		"slate": "5a3020",
		"slate_light": "81452a",
		"floor_mist": "6b3422",
		"floor_petrol": "8a4526",
		"floor_plum": "3a2420",
		"accent": "f7c45b",
		"safe": "74d4c4",
		"danger": "e0523d",
		"enemy": "d85a32",
		"enemy_accent": "f7c45b",
		"gate": "8a4934",
		"paper": "ffeed2",
		"muted": "c7a58a",
	},
	{
		"name": "STARFALL RELIQUARY",
		"map": [
			"############",
			"#.......#..#",
			"#.#..###...#",
			"#.......#..#",
			"##.#...#...#",
			"##..#...#..#",
			"##.#.##...##",
			"#.......#..#",
			"############",
		],
		"shards": [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)],
		"spawns": [Vector2i(3, 7), Vector2i(4, 2), Vector2i(6, 5), Vector2i(8, 6), Vector2i(10, 4)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "astral_sentry",
		"enemy_health": 3,
		"enemy_speed": 1.7,
		"void": "08091b",
		"deep": "111333",
		"ink": "1b1e3b",
		"ink_soft": "292651",
		"wall_alt": "353565",
		"slate": "353565",
		"slate_light": "4a4a7d",
		"floor_mist": "3e3d70",
		"floor_petrol": "314f72",
		"floor_plum": "563b70",
		"accent": "e6a6ff",
		"safe": "7de7ff",
		"danger": "e05c9b",
		"enemy": "7656b8",
		"enemy_accent": "e6a6ff",
		"gate": "5b4a86",
		"paper": "f3edff",
		"muted": "a9a6cf",
	},
]

var void_color := Color("060914")
var deep_color := Color("0b1020")
var ink_color := Color("111629")
var ink_soft_color := Color("1b2238")
var wall_alt_color := Color("202840")
var slate_color := Color("26334d")
var slate_light_color := Color("364765")
var floor_mist_color := Color("303a54")
var floor_petrol_color := Color("294654")
var floor_plum_color := Color("40344f")
var accent_color := Color("f0ad4e")
var safe_color := Color("6de5df")
var danger_color := Color("c04a5d")
var enemy_color := Color("c04a5d")
var enemy_accent_color := Color("f0ad4e")
var gate_color := Color("6b5268")
var paper_color := Color("e8edf5")
var muted_color := Color("9aa8bd")
var fallback_color := Color("6e4b8b")

var walkable: Dictionary = {}
var water_cells: Dictionary = {}
var solid_cells: Dictionary = {}
var flow: Dictionary = {}
var shards: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var bottle_sources: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var player_frames: Dictionary = {}
var sword_frames: Dictionary = {}
var player_position := Vector2.ZERO
var player_facing := Vector2(1.0, 1.0).normalized()
var health := MAX_HEALTH
var shards_collected := 0
var bottle_count := 0
var bottle_inventory: Dictionary = {}
var has_life_jacket := false
var craft_selected := 0
var craft_slots: Array[int] = []
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
var map_rows: Array = []
var shard_cells: Array = []
var enemy_spawns: Array = []
var start_cell := Vector2i.ZERO
var exit_cell := Vector2i.ZERO
var level_index := 0
var selected_level := 0
var level_kind := "surface"
var level_name := "RIVER RUN"
var enemy_kind := "shardling"
var enemy_health := 2
var enemy_speed := ENEMY_SPEED
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0
var camera_angle := 0.0
var camera_target := Vector2.ZERO
var camera_dragging := false
var camera_drag_origin := Vector2.ZERO
var camera_drag_start := Vector2.ZERO

func _ready() -> void:
	random.seed = 260925
	ui_font = SystemFont.new()
	ui_font.font_names = PackedStringArray(["DejaVu Sans", "sans-serif"])
	load_player_assets()
	reset_game()
	open_level_select()

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
	level_index = 0
	load_level(level_index)

func open_level_select() -> void:
	selected_level = level_index
	state = "level_select"
	message_timer = 0.0

func move_level_selection(step: int) -> void:
	selected_level = posmod(selected_level + step, LEVELS.size())

func confirm_level_selection() -> void:
	load_level(selected_level)

func close_level_select() -> void:
	state = "playing"

func load_level(index: int) -> void:
	level_index = clampi(index, 0, LEVELS.size() - 1)
	selected_level = level_index
	var level: Dictionary = LEVELS[level_index]
	level_name = String(level["name"])
	level_kind = String(level.get("kind", "dungeon"))
	var rows: Array = level["map"]
	map_rows = rows
	var configured_shards: Array = level["shards"]
	shard_cells = configured_shards
	var configured_spawns: Array = level["spawns"]
	enemy_spawns = configured_spawns
	start_cell = Vector2i(level["start"])
	exit_cell = Vector2i(level["exit"])
	enemy_kind = String(level.get("enemy_kind", "shardling"))
	enemy_health = int(level.get("enemy_health", 2))
	enemy_speed = float(level.get("enemy_speed", ENEMY_SPEED))
	apply_level_colors(level)
	build_walkable()
	player_position = Vector2(start_cell) + Vector2(0.5, 0.5)
	player_facing = Vector2(1.0, 1.0).normalized()
	health = MAX_HEALTH
	shards_collected = 0
	bottle_count = 0
	has_life_jacket = false
	state = "playing"
	if level_kind == "surface":
		message = "Search bins with F • press B to craft"
	elif level_index == 1:
		message = "Recover the three light shards"
	else:
		message = "Descend to " + level_name
	message_timer = 3.0
	elapsed = 0.0
	walk_animation = 0.0
	attack_cooldown = 0.0
	invulnerability = 0.0
	shake_strength = 0.0
	screen_shake = Vector2.ZERO
	camera_offset = Vector2.ZERO
	camera_zoom = DEFAULT_CAMERA_ZOOM
	camera_angle = 0.0
	camera_target = player_position
	camera_dragging = false
	last_player_cell = Vector2i(-999, -999)
	shards.clear()
	enemies.clear()
	bottle_sources.clear()
	bottle_inventory.clear()
	solid_cells.clear()
	effects.clear()
	craft_selected = 0
	craft_slots.clear()
	for source_data in level.get("sources", []):
		var source: Dictionary = source_data
		bottle_sources.append(source.duplicate(true))
		bottle_inventory[String(source["kind"])] = 0
		solid_cells[Vector2i(source["cell"])] = true
	for shard_index in range(shard_cells.size()):
		var cell: Vector2i = shard_cells[shard_index]
		shards.append({
			"position": Vector2(cell) + Vector2(0.5, 0.5),
			"taken": false,
			"phase": shard_index * 1.7,
		})
	rebuild_flow()
	for spawn_index in range(enemy_spawns.size()):
		var cell: Vector2i = enemy_spawns[spawn_index]
		if not walkable.has(cell) or not flow.has(cell):
			continue
		var enemy_index := enemies.size()
		enemies.append({
			"position": Vector2(cell) + Vector2(0.5, 0.5),
			"kind": enemy_kind,
			"health": enemy_health,
			"speed": enemy_speed,
			"hit_flash": 0.0,
			"attack_cooldown": 0.45 + enemy_index * 0.08,
			"phase": enemy_index * 0.9,
		})

func apply_level_colors(level: Dictionary) -> void:
	void_color = Color(String(level["void"]))
	deep_color = Color(String(level["deep"]))
	ink_color = Color(String(level["ink"]))
	ink_soft_color = Color(String(level["ink_soft"]))
	wall_alt_color = Color(String(level["wall_alt"]))
	slate_color = Color(String(level["slate"]))
	slate_light_color = Color(String(level["slate_light"]))
	floor_mist_color = Color(String(level["floor_mist"]))
	floor_petrol_color = Color(String(level["floor_petrol"]))
	floor_plum_color = Color(String(level["floor_plum"]))
	accent_color = Color(String(level["accent"]))
	safe_color = Color(String(level["safe"]))
	danger_color = Color(String(level["danger"]))
	enemy_color = Color(String(level["enemy"]))
	enemy_accent_color = Color(String(level["enemy_accent"]))
	gate_color = Color(String(level["gate"]))
	paper_color = Color(String(level["paper"]))
	muted_color = Color(String(level["muted"]))
	fallback_color = floor_plum_color.lightened(0.15)

func build_walkable() -> void:
	walkable.clear()
	water_cells.clear()
	for y in range(map_rows.size()):
		var row: String = map_rows[y]
		for x in range(row.length()):
			var cell := Vector2i(x, y)
			if row[x] != "#":
				walkable[cell] = true
			if row[x] == "~":
				water_cells[cell] = true

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
		if level_kind == "surface":
			update_surface_level()
		else:
			update_enemies(delta)
			collect_shards()
		update_camera(delta)
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
		).normalized().rotated(-camera_angle)
		var before_move := player_position
		player_position = move_with_collisions(player_position, world_direction * PLAYER_SPEED * delta, 0.22)
		if level_kind == "surface" and not has_life_jacket and player_position == before_move and message_timer <= 0.0:
			if water_cells.has(cell_at(player_position + world_direction * 0.55)):
				message = "The river is too deep — find a life jacket"
				message_timer = 2.4
		player_facing = world_direction
		walk_animation += delta * 8.0
		var current_cell := cell_at(player_position)
		if current_cell != last_player_cell:
			last_player_cell = current_cell
			rebuild_flow()
	if level_kind != "surface" and Input.is_physical_key_pressed(KEY_SPACE):
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
		var cell := cell_at(probe)
		if not walkable.has(cell):
			return false
		if solid_cells.has(cell):
			return false
		if water_cells.has(cell) and not has_life_jacket:
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
		var movement := (target - enemy_position).normalized() * float(enemy["speed"]) * delta
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
		"color": accent_color,
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
			spawn_burst(enemy_position, safe_color)
			if int(enemy["health"]) <= 0:
				spawn_burst(enemy_position, danger_color, 10)
				enemies.remove_at(index)
	if connected:
		add_shake(0.28)

func hurt_player() -> void:
	if state != "playing" or invulnerability > 0.0:
		return
	health = maxi(0, health - 1)
	invulnerability = 0.85
	add_shake(0.5)
	spawn_burst(player_position, danger_color)
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
			spawn_burst(shard["position"], safe_color, 12)
			add_shake(0.22)
			if shards_collected >= shard_cells.size():
				message = "The gate is open — find the exit"
				message_timer = 4.0
			else:
				message = "Light shard " + str(shards_collected) + " / " + str(shard_cells.size())
				message_timer = 2.2
	var exit_position := Vector2(exit_cell) + Vector2(0.5, 0.5)
	if shards_collected >= shard_cells.size() and player_position.distance_to(exit_position) < 0.56:
		if level_index < LEVELS.size() - 1:
			load_level(level_index + 1)
		else:
			state = "won"
			message = "All depths are clear"
			message_timer = 99.0

func search_bottle_source() -> void:
	if state != "playing" or level_kind != "surface":
		return
	var nearest_index := -1
	var nearest_distance := SOURCE_REACH
	for index in range(bottle_sources.size()):
		var source: Dictionary = bottle_sources[index]
		if int(source["charges"]) <= 0:
			continue
		var source_position := Vector2(source["cell"]) + Vector2(0.5, 0.5)
		var distance := player_position.distance_to(source_position)
		if distance <= nearest_distance:
			nearest_index = index
			nearest_distance = distance
	if nearest_index < 0:
		for source_data in bottle_sources:
			var nearby_source: Dictionary = source_data
			var nearby_position := Vector2(nearby_source["cell"]) + Vector2(0.5, 0.5)
			if player_position.distance_to(nearby_position) <= SOURCE_REACH:
				message = "This source is empty — find another"
				message_timer = 2.0
				return
		message = "Move closer to a bottle source"
		message_timer = 2.0
		return
	var source: Dictionary = bottle_sources[nearest_index]
	var source_kind := String(source["kind"])
	var found_bottles := int(source["bottles"])
	bottle_count += found_bottles
	bottle_inventory[source_kind] = int(bottle_inventory.get(source_kind, 0)) + found_bottles
	source["charges"] = int(source["charges"]) - 1
	var source_position := Vector2(source["cell"]) + Vector2(0.5, 0.5)
	var found_message := "You find " + str(found_bottles) + " empty bottles"
	if String(source["kind"]) == "dustbin":
		found_message = "You sift through leaves and find " + str(found_bottles) + " empty bottles"
	message = found_message + " — " + str(bottle_count) + " / " + str(LIFE_JACKET_BOTTLES)
	message_timer = 2.8
	spawn_burst(source_position, safe_color, 10)
	add_shake(0.16)

func open_craft_table() -> void:
	if state != "playing" or level_kind != "surface":
		return
	craft_slots.clear()
	craft_selected = 0
	for index in range(bottle_sources.size()):
		if craft_element_available(index) > 0:
			craft_selected = index
			break
	state = "crafting"
	message_timer = 0.0

func close_craft_table() -> void:
	if state != "crafting":
		return
	craft_slots.clear()
	state = "playing"
	message_timer = 0.0

func craft_element_available(index: int) -> int:
	if index < 0 or index >= bottle_sources.size():
		return 0
	var source: Dictionary = bottle_sources[index]
	var kind := String(source["kind"])
	var reserved := 0
	for slot in craft_slots:
		if slot == index:
			reserved += 1
	return maxi(0, int(bottle_inventory.get(kind, 0)) - reserved)

func add_craft_element() -> void:
	if state != "crafting":
		return
	if has_life_jacket:
		message = "The life jacket is already complete"
		message_timer = 2.0
		return
	if craft_slots.size() >= LIFE_JACKET_BOTTLES:
		message = "The jacket already has eight bottles"
		message_timer = 2.0
		return
	if craft_element_available(craft_selected) <= 0:
		message = "No bottles left in that element"
		message_timer = 2.0
		return
	craft_slots.append(craft_selected)
	message_timer = 0.0

func remove_last_craft_element() -> void:
	if state != "crafting" or craft_slots.is_empty():
		return
	craft_slots.pop_back()
	message_timer = 0.0

func combine_craft_elements() -> void:
	if state != "crafting":
		return
	if has_life_jacket:
		close_craft_table()
		message = "Your bottle life jacket is ready"
		message_timer = 2.0
		return
	if craft_slots.size() < LIFE_JACKET_BOTTLES:
		message = "Add " + str(LIFE_JACKET_BOTTLES - craft_slots.size()) + " more empty bottles"
		message_timer = 2.0
		return
	for slot in craft_slots:
		var source: Dictionary = bottle_sources[slot]
		var kind := String(source["kind"])
		bottle_inventory[kind] = maxi(0, int(bottle_inventory.get(kind, 0)) - 1)
	bottle_count = maxi(0, bottle_count - LIFE_JACKET_BOTTLES)
	has_life_jacket = true
	craft_slots.clear()
	state = "playing"
	message = "Life jacket woven — the river is passable"
	message_timer = 3.0
	spawn_burst(player_position, safe_color, 18)
	add_shake(0.32)

func update_surface_level() -> void:
	if state != "playing":
		return
	var exit_position := Vector2(exit_cell) + Vector2(0.5, 0.5)
	if player_position.distance_to(exit_position) >= 0.56:
		return
	if not has_life_jacket and message_timer <= 0.0:
		message = "The river is too deep — find a life jacket"
		message_timer = 2.4
		return
	if has_life_jacket:
		load_level(level_index + 1)

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

func update_camera(delta: float) -> void:
	var follow_weight := 1.0 - exp(-CAMERA_FOLLOW_RATE * delta)
	camera_target = camera_target.lerp(player_position, follow_weight)

func reset_camera() -> void:
	camera_offset = Vector2.ZERO
	camera_zoom = DEFAULT_CAMERA_ZOOM
	camera_angle = 0.0
	camera_target = player_position
	camera_dragging = false

func set_camera_offset(value: Vector2) -> void:
	camera_offset = Vector2(clampf(value.x, -420.0, 420.0), clampf(value.y, -280.0, 280.0))

func handle_camera_button(event: InputEventMouseButton) -> void:
	if state != "playing":
		return
	if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
		camera_dragging = event.pressed
		camera_drag_origin = event.position
		camera_drag_start = camera_offset
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera_zoom = clampf(camera_zoom + 0.08, 0.65, 1.35)
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera_zoom = clampf(camera_zoom - 0.08, 0.65, 1.35)

func handle_camera_motion(event: InputEventMouseMotion) -> void:
	if state == "playing" and camera_dragging:
		set_camera_offset(camera_drag_start + event.position - camera_drag_origin)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		handle_camera_button(event)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		handle_camera_motion(event)
		if camera_dragging:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if state == "level_select":
			if keycode == KEY_UP or keycode == KEY_W:
				move_level_selection(-1)
			elif keycode == KEY_DOWN or keycode == KEY_S:
				move_level_selection(1)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE:
				confirm_level_selection()
			elif keycode == KEY_ESCAPE or keycode == KEY_L:
				close_level_select()
		elif state == "crafting":
			if keycode == KEY_UP or keycode == KEY_W:
				craft_selected = posmod(craft_selected - 1, bottle_sources.size())
			elif keycode == KEY_DOWN or keycode == KEY_S:
				craft_selected = posmod(craft_selected + 1, bottle_sources.size())
			elif keycode == KEY_SPACE:
				add_craft_element()
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
				combine_craft_elements()
			elif keycode == KEY_X or keycode == KEY_BACKSPACE or keycode == KEY_DELETE:
				remove_last_craft_element()
			elif keycode == KEY_B or keycode == KEY_ESCAPE:
				close_craft_table()
		else:
			if level_kind == "surface" and keycode == KEY_F:
				search_bottle_source()
			elif level_kind == "surface" and keycode == KEY_B:
				open_craft_table()
			elif keycode == KEY_Q:
				camera_angle = clampf(camera_angle + deg_to_rad(15.0), -PI, PI)
			elif keycode == KEY_E:
				camera_angle = clampf(camera_angle - deg_to_rad(15.0), -PI, PI)
			elif keycode == KEY_C:
				reset_camera()
			elif keycode == KEY_L:
				open_level_select()
			elif keycode == KEY_R:
				if state == "won" and level_index == LEVELS.size() - 1:
					reset_game()
				else:
					load_level(level_index)
		get_viewport().set_input_as_handled()

func iso_to_screen(world_position: Vector2) -> Vector2:
	var relative := world_position - camera_target
	var rotated := relative.rotated(camera_angle)
	var projected := Vector2(
		(rotated.x - rotated.y) * TILE_WIDTH * 0.5,
		(rotated.x + rotated.y) * TILE_HEIGHT * 0.5
	)
	return Vector2(round(projected.x * 0.5) * 2.0, round(projected.y * 0.5) * 2.0)

func player_face_name() -> String:
	var facing := player_facing.rotated(-camera_angle)
	if facing.x >= 0.0:
		return "ne" if facing.y < 0.0 else "se"
	return "nw" if facing.y < 0.0 else "sw"

func floor_color(cell: Vector2i) -> Color:
	var value := posmod(cell.x * 3 + cell.y * 5 + cell.x * cell.y, 5)
	match value:
		0:
			return slate_color
		1:
			return slate_light_color
		2:
			return floor_mist_color
		3:
			return floor_petrol_color
		_:
			return floor_plum_color

func _draw() -> void:
	var viewport := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport), void_color, true)
	draw_atmosphere(viewport)
	draw_set_transform(CAMERA_PIVOT + camera_offset + screen_shake, 0.0, Vector2(camera_zoom, camera_zoom))
	draw_floors()
	draw_depth_sorted()
	draw_effects()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_hud(viewport)

func draw_atmosphere(viewport: Vector2) -> void:
	if level_kind == "surface":
		draw_surface_atmosphere(viewport)
		return
	var cavern := PackedVector2Array([
		Vector2(92, 270),
		Vector2(640, 8),
		Vector2(1190, 270),
		Vector2(640, 708),
	])
	draw_colored_polygon(cavern, deep_color)
	for index in range(9):
		var start := Vector2(90 + index * 142, 36 + posmod(index * 83, 180))
		draw_line(start, start + Vector2(86, 118), Color(accent_color, 0.08), 1.0)
	for index in range(34):
		var dust := Vector2(fposmod(index * 193.0 + 31.0, viewport.x), fposmod(index * 271.0 + 19.0, viewport.y))
		var pulse := 0.18 + sin(elapsed * 1.4 + index) * 0.08
		draw_circle(dust, 1.0 + float(index % 3) * 0.35, Color(safe_color, pulse))

func draw_surface_atmosphere(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), deep_color, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 338),
		Vector2(190, 248),
		Vector2(360, 326),
		Vector2(548, 220),
		Vector2(752, 326),
		Vector2(958, 238),
		Vector2(viewport.x, 330),
		Vector2(viewport.x, viewport.y),
		Vector2(0, viewport.y),
	]), Color(floor_petrol_color, 0.58))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 404),
		Vector2(260, 310),
		Vector2(520, 408),
		Vector2(796, 300),
		Vector2(viewport.x, 410),
		Vector2(viewport.x, viewport.y),
		Vector2(0, viewport.y),
	]), Color(wall_alt_color, 0.72))
	var sun_center := Vector2(916.0, 96.0)
	draw_colored_polygon(PackedVector2Array([
		sun_center + Vector2(0, -36),
		sun_center + Vector2(30, -21),
		sun_center + Vector2(36, 18),
		sun_center + Vector2(0, 36),
		sun_center + Vector2(-36, 18),
		sun_center + Vector2(-30, -21),
	]), Color(accent_color, 0.92))
	for index in range(3):
		var origin := Vector2(132.0 + index * 304.0, 92.0 + float(index % 2) * 72.0)
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(-66, 12),
			origin + Vector2(-28, -10),
			origin + Vector2(0, 2),
			origin + Vector2(34, -18),
			origin + Vector2(78, 10),
			origin + Vector2(24, 24),
			origin + Vector2(-34, 26),
		]), Color(paper_color, 0.48))
	for index in range(4):
		var origin := Vector2(310.0 + index * 176.0, 172.0 + float(index % 2) * 34.0)
		draw_line(origin, origin + Vector2(10, -6), Color(ink_color, 0.58), 2.0)
		draw_line(origin + Vector2(10, -6), origin + Vector2(20, 1), Color(ink_color, 0.58), 2.0)

func tile_polygon(cell: Vector2i, height := 0.0) -> PackedVector2Array:
	var center := Vector2(cell) + Vector2(0.5, 0.5)
	var points := PackedVector2Array()
	for corner: Vector2 in [
		center + Vector2(-0.5, -0.5),
		center + Vector2(0.5, -0.5),
		center + Vector2(0.5, 0.5),
		center + Vector2(-0.5, 0.5),
	]:
		var point := iso_to_screen(corner)
		point.y -= height
		points.append(point)
	points.append(points[0])
	return points

func wall_faces(floor: PackedVector2Array, top: PackedVector2Array) -> Array[PackedVector2Array]:
	return [
		PackedVector2Array([top[0], top[1], floor[1], floor[0]]),
		PackedVector2Array([top[1], top[2], floor[2], floor[1]]),
		PackedVector2Array([top[2], top[3], floor[3], floor[2]]),
		PackedVector2Array([top[3], top[0], floor[0], floor[3]]),
	]

func draw_floors() -> void:
	for key in walkable:
		var cell: Vector2i = key
		var center := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
		var diamond := tile_polygon(cell)
		if water_cells.has(cell):
			draw_river_tile(cell, center, diamond)
			continue
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
		draw_polyline(diamond, Color(ink_color, 0.78), 1.0, true)

func draw_river_tile(cell: Vector2i, center: Vector2, diamond: PackedVector2Array) -> void:
	var water := safe_color.darkened(0.38)
	draw_colored_polygon(diamond, water)
	draw_colored_polygon(PackedVector2Array([center, diamond[1], diamond[2]]), water.lightened(0.1))
	draw_colored_polygon(PackedVector2Array([center, diamond[3], diamond[2]]), water.darkened(0.12))
	var drift := fposmod(elapsed * 18.0 + float(cell.y) * 11.0, 34.0) - 17.0
	draw_line(center + Vector2(-27.0 + drift, -3.0), center + Vector2(-5.0 + drift, -3.0), Color(paper_color, 0.52), 2.0)
	draw_line(center + Vector2(2.0 - drift, 7.0), center + Vector2(22.0 - drift, 7.0), Color(paper_color, 0.32), 1.5)
	draw_polyline(diamond, Color(safe_color.lightened(0.22), 0.72), 1.0, true)

func border_cells() -> Dictionary:
	var cells: Dictionary = {}
	var bottom_row := map_rows.size() - 1
	var right_column: int = int(map_rows[0].length()) - 1
	for x in range(map_rows[0].length()):
		cells[Vector2i(x, 0)] = true
		cells[Vector2i(x, bottom_row)] = true
	for y in range(map_rows.size()):
		cells[Vector2i(0, y)] = true
		cells[Vector2i(right_column, y)] = true
	return cells

func wall_render_height(cell: Vector2i) -> float:
	if level_kind == "surface" and border_cells().has(cell):
		return 16.0
	if front_boundary_cells().has(cell):
		return 16.0
	return WALL_HEIGHT

func front_boundary_cells() -> Dictionary:
	var normals := [Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(-1.0, 0.0), Vector2(0.0, -1.0)]
	var depths: Array[float] = []
	for normal: Vector2 in normals:
		var rotated := normal.rotated(camera_angle)
		depths.append((rotated.x + rotated.y) * TILE_HEIGHT * 0.5)
	var primary := 0
	for index in range(1, normals.size()):
		if depths[index] > depths[primary]:
			primary = index
	var previous := posmod(primary - 1, normals.size())
	var next := posmod(primary + 1, normals.size())
	var secondary := previous if depths[previous] >= depths[next] else next
	var cells: Dictionary = {}
	var bottom_row := map_rows.size() - 1
	var right_column: int = int(map_rows[0].length()) - 1
	for edge: int in [primary, secondary]:
		if edge == 0:
			for y in range(map_rows.size()):
				cells[Vector2i(right_column, y)] = true
		elif edge == 1:
			for x in range(map_rows[bottom_row].length()):
				cells[Vector2i(x, bottom_row)] = true
		elif edge == 2:
			for y in range(map_rows.size()):
				cells[Vector2i(0, y)] = true
		else:
			for x in range(map_rows[0].length()):
				cells[Vector2i(x, 0)] = true
	return cells

func wall_drawables() -> Array[Dictionary]:
	var drawables: Array[Dictionary] = []
	for y in range(map_rows.size()):
		var row: String = map_rows[y]
		for x in range(row.length()):
			var cell := Vector2i(x, y)
			if not walkable.has(cell):
				drawables.append({
					"depth": iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5)).y,
					"kind": "wall",
					"cell": cell,
					"height": wall_render_height(cell),
				})
	drawables.sort_custom(func(a, b): return float(a["depth"]) < float(b["depth"]))
	return drawables

func draw_depth_sorted() -> void:
	var drawables := wall_drawables()
	for shard in shards:
		if not bool(shard["taken"]):
			drawables.append({
				"depth": iso_to_screen(shard["position"]).y,
				"kind": "shard",
				"shard": shard,
			})
	for source in bottle_sources:
		drawables.append({
			"depth": iso_to_screen(Vector2(source["cell"]) + Vector2(0.5, 0.5)).y,
			"kind": "source",
			"source": source,
		})
	drawables.append({
		"depth": iso_to_screen(Vector2(exit_cell) + Vector2(0.5, 0.5)).y,
		"kind": "exit" if level_kind == "surface" else "gate",
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
				draw_wall(wall_cell, float(drawable["height"]))
			"shard":
				var shard: Dictionary = drawable["shard"]
				draw_shard(shard)
			"source":
				var source: Dictionary = drawable["source"]
				draw_bottle_source(source)
			"exit":
				draw_surface_exit()
			"gate":
				draw_gate()
			"player":
				draw_player()
			"enemy":
				var enemy_index: int = drawable["index"]
				draw_enemy(enemy_index)

func draw_wall(cell: Vector2i, height := WALL_HEIGHT) -> void:
	if level_kind == "surface":
		height = minf(height, 32.0)
	var floor := tile_polygon(cell)
	var top := tile_polygon(cell, height)
	var top_center := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
	top_center.y -= height
	var faces := wall_faces(floor, top)
	var top_color := ink_soft_color if posmod(cell.x + cell.y, 2) == 0 else wall_alt_color
	draw_colored_polygon(faces[0], ink_color.darkened(0.28))
	draw_colored_polygon(faces[3], ink_color.darkened(0.08))
	draw_colored_polygon(faces[1], ink_color.darkened(0.16))
	draw_colored_polygon(faces[2], ink_color)
	draw_colored_polygon(top, top_color)
	draw_colored_polygon(PackedVector2Array([
		top_center,
		top[1],
		top[2],
	]), top_color.lightened(0.08))
	draw_polyline(top, Color("0a0d18"), 1.5, true)
	draw_line(faces[1][0], faces[1][3], Color("0a0d18"), 1.0)
	draw_line(faces[2][0], faces[2][3], Color("0a0d18"), 1.0)

func draw_bottle_source(source: Dictionary) -> void:
	var cell: Vector2i = source["cell"]
	var position := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
	var charges := int(source["charges"])
	var kind := String(source["kind"])
	draw_shadow(position, 34.0, 0.3)
	if kind == "dustbin" or kind == "recycling":
		for index in range(3 + charges):
			var leaf_position := position + Vector2(-22.0 + float(index % 4) * 14.0, -30.0 - float(index / 4) * 9.0)
			draw_leaf(leaf_position, 0.72 + float(index % 2) * 0.12, accent_color if index % 2 == 0 else floor_petrol_color)
		for index in range(1 + charges):
			draw_bottle(position + Vector2(-15.0 + float(index) * 15.0, -39.0 - float(index % 2) * 5.0), 0.72, safe_color)
		var body := gate_color if kind == "dustbin" else safe_color.darkened(0.52)
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-28, -24),
			position + Vector2(28, -24),
			position + Vector2(23, 29),
			position + Vector2(-23, 29),
		]), body)
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-28, -24),
			position + Vector2(0, -35),
			position + Vector2(28, -24),
			position + Vector2(0, -13),
		]), body.lightened(0.12))
		draw_polyline(PackedVector2Array([
			position + Vector2(-28, -24),
			position + Vector2(28, -24),
			position + Vector2(23, 29),
			position + Vector2(-23, 29),
			position + Vector2(-28, -24),
		]), ink_color, 1.5, true)
		draw_line(position + Vector2(-8, -31), position + Vector2(-8, -17), ink_color, 3.0)
		draw_line(position + Vector2(8, -31), position + Vector2(8, -17), ink_color, 3.0)
		if kind == "recycling":
			draw_colored_polygon(PackedVector2Array([
				position + Vector2(0, -12),
				position + Vector2(11, 0),
				position + Vector2(0, 18),
				position + Vector2(-11, 0),
			]), safe_color)
	else:
		var crate_color := floor_plum_color if kind == "crate" else muted_color
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-31, -18),
			position + Vector2(0, -36),
			position + Vector2(31, -18),
			position + Vector2(0, 0),
		]), crate_color.lightened(0.12))
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-31, -18),
			position + Vector2(0, 0),
			position + Vector2(0, 34),
			position + Vector2(-31, 16),
		]), crate_color.darkened(0.18))
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(31, -18),
			position + Vector2(0, 0),
			position + Vector2(0, 34),
			position + Vector2(31, 16),
		]), crate_color)
		for index in range(1 + charges):
			draw_bottle(position + Vector2(-17.0 + float(index) * 17.0, -28.0 - float(index % 2) * 4.0), 0.72, safe_color)
		if kind == "crate":
			draw_line(position + Vector2(-20, 8), position + Vector2(-3, 24), crate_color.darkened(0.35), 3.0)
			draw_line(position + Vector2(3, 8), position + Vector2(20, 24), crate_color.darkened(0.35), 3.0)
		else:
			draw_colored_polygon(PackedVector2Array([
				position + Vector2(-32, -19),
				position + Vector2(0, -38),
				position + Vector2(32, -19),
				position + Vector2(0, 1),
			]), paper_color)
	var source_position := Vector2(cell) + Vector2(0.5, 0.5)
	if charges > 0 and player_position.distance_to(source_position) <= SOURCE_REACH:
		var prompt := Rect2(position + Vector2(-47, -79), Vector2(94, 23))
		draw_rect(Rect2(prompt.position + Vector2(3, 4), prompt.size), Color(0.0, 0.0, 0.0, 0.2), true)
		draw_rect(prompt, Color(void_color, 0.9), true)
		draw_line(prompt.position, prompt.position + Vector2(prompt.size.x, 0), accent_color, 1.5)
		draw_string(ui_font, prompt.position + Vector2(12, 16), "F  SEARCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, paper_color)

func draw_bottle(center: Vector2, scale: float, color: Color) -> void:
	var body := PackedVector2Array([
		center + Vector2(-5.0, -14.0) * scale,
		center + Vector2(5.0, -14.0) * scale,
		center + Vector2(6.0, -4.0) * scale,
		center + Vector2(9.0, 3.0) * scale,
		center + Vector2(8.0, 15.0) * scale,
		center + Vector2(-8.0, 15.0) * scale,
		center + Vector2(-9.0, 3.0) * scale,
		center + Vector2(-6.0, -4.0) * scale,
	])
	draw_colored_polygon(body, Color(paper_color, 0.7))
	draw_colored_polygon(PackedVector2Array([body[0], body[1], body[2], body[3], center]), Color(color, 0.34))
	draw_polyline(body, color, maxf(1.0, 1.4 * scale), true)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-4.0, -19.0) * scale,
		center + Vector2(4.0, -19.0) * scale,
		center + Vector2(4.0, -13.0) * scale,
		center + Vector2(-4.0, -13.0) * scale,
	]), color)
	draw_line(center + Vector2(-3.0, 4.0) * scale, center + Vector2(4.0, 4.0) * scale, Color(color, 0.72), maxf(1.0, scale))

func draw_leaf(center: Vector2, scale: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -10.0) * scale,
		center + Vector2(8.0, 0) * scale,
		center + Vector2(0, 10.0) * scale,
		center + Vector2(-8.0, 0) * scale,
	])
	draw_colored_polygon(points, color)
	draw_line(center, points[0], color.lightened(0.24), maxf(1.0, scale))

func draw_surface_exit() -> void:
	var position := iso_to_screen(Vector2(exit_cell) + Vector2(0.5, 0.5))
	var glow := safe_color if has_life_jacket else gate_color
	draw_shadow(position, 42.0, 0.34)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-43, 18),
		position + Vector2(-34, -43),
		position + Vector2(-15, -70),
		position + Vector2(18, -67),
		position + Vector2(41, -33),
		position + Vector2(46, 18),
	]), gate_color)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-26, 16),
		position + Vector2(-22, -34),
		position + Vector2(0, -52),
		position + Vector2(24, -31),
		position + Vector2(28, 16),
	]), Color(glow, 0.22 + (0.08 if has_life_jacket else 0.0)))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-18, 16),
		position + Vector2(-15, -28),
		position + Vector2(0, -43),
		position + Vector2(17, -26),
		position + Vector2(20, 16),
	]), ink_color)
	draw_line(position + Vector2(0, -42), position + Vector2(0, 12), Color(glow, 0.8), 2.0)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-47, 18),
		position + Vector2(-34, -43),
		position + Vector2(-15, -70),
		position + Vector2(-5, -38),
		position + Vector2(-16, 16),
	]), gate_color.lightened(0.12))

func draw_gate() -> void:
	var position := iso_to_screen(Vector2(exit_cell) + Vector2(0.5, 0.5))
	var open := shards_collected >= shard_cells.size()
	var color := safe_color if open else gate_color
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
	draw_circle(position + Vector2(0, -58), 4.0 + pulse * 2.0, paper_color)
	if not open:
		for offset in range(3):
			draw_line(position + Vector2(-15 + offset * 15, -58), position + Vector2(-15 + offset * 15, -12), Color(danger_color, 0.55), 3.0)

func draw_shard(shard: Dictionary) -> void:
	var position := iso_to_screen(shard["position"])
	var bob := sin(elapsed * 3.0 + float(shard["phase"])) * 5.0
	var center := position + Vector2(0, -24 + bob)
	draw_shadow(position, 22.0, 0.28)
	draw_crystal(center, 15.0, safe_color)
	for index in range(3):
		var angle := elapsed * 1.8 + float(shard["phase"]) + index * TAU / 3.0
		var orbit := center + Vector2(cos(angle), sin(angle) * 0.42) * 25.0
		draw_circle(orbit, 1.8, Color(paper_color, 0.8))

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
		draw_player_texture(sword_texture, position, Color(accent_color, tint.a))
	if body_texture:
		draw_player_texture(body_texture, position, tint)
	else:
		draw_crystal(position + Vector2(0, -36), 26.0, fallback_color)
	if face != "nw" and sword_texture:
		draw_player_texture(sword_texture, position, Color(accent_color, tint.a))
	if has_life_jacket:
		draw_life_jacket(position)

func draw_life_jacket(position: Vector2) -> void:
	for side: float in [-1.0, 1.0]:
		var center := position + Vector2(side * 15.0, -37.0)
		var points := PackedVector2Array([
			center + Vector2(-8, -18),
			center + Vector2(8, -18),
			center + Vector2(10, 17),
			center + Vector2(0, 22),
			center + Vector2(-10, 17),
		])
		draw_colored_polygon(points, safe_color)
		draw_colored_polygon(PackedVector2Array([points[0], center + Vector2(0, -18), points[1], center + Vector2(0, 20)]), safe_color.lightened(0.2))
		draw_polyline(points, ink_color, 1.5, true)
		draw_line(center + Vector2(-8, -8), center + Vector2(8, -8), ink_color, 2.0)

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
	match String(enemy["kind"]):
		"mireling":
			draw_mireling(enemy, position, bob)
		"forge_golem":
			draw_forge_golem(enemy, position, bob)
		"astral_sentry":
			draw_astral_sentry(enemy, position, bob)
		_:
			draw_shardling(enemy, position, bob)

func draw_shardling(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -28 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
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
	draw_circle(body_center + Vector2(-7, -4), 2.4, enemy_accent_color)
	draw_circle(body_center + Vector2(7, -4), 2.4, enemy_accent_color)
	if int(enemy["health"]) == 1:
		draw_crystal(position + Vector2(0, -65), 6.0, enemy_accent_color)

func draw_mireling(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -25 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 22.0, 0.34)
	draw_crystal(body_center, 22.0, color)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-21, -5),
		body_center + Vector2(-10, -29),
		body_center + Vector2(-3, -14),
	]), enemy_accent_color)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(21, -5),
		body_center + Vector2(10, -29),
		body_center + Vector2(3, -14),
	]), enemy_accent_color)
	for index in range(3):
		var angle := elapsed * 1.6 + float(index) * TAU / 3.0 + float(enemy["phase"])
		var bubble := body_center + Vector2(cos(angle) * 22.0, sin(angle) * 11.0 - 15.0)
		draw_circle(bubble, 3.0 + float(index % 2), Color(safe_color, 0.72))
	draw_circle(body_center + Vector2(-6, -3), 2.2, paper_color)
	draw_circle(body_center + Vector2(6, -3), 2.2, paper_color)

func draw_forge_golem(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -27 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 25.0, 0.38)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-20, -22),
		body_center + Vector2(20, -22),
		body_center + Vector2(24, 17),
		body_center + Vector2(0, 25),
		body_center + Vector2(-24, 17),
	]), color.darkened(0.12))
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-13, -15),
		body_center + Vector2(13, -15),
		body_center + Vector2(16, 11),
		body_center + Vector2(0, 18),
		body_center + Vector2(-16, 11),
	]), color.lightened(0.08))
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(0, -10),
		body_center + Vector2(9, 0),
		body_center + Vector2(0, 10),
		body_center + Vector2(-9, 0),
	]), enemy_accent_color)
	draw_line(body_center + Vector2(-18, -25), body_center + Vector2(-25, -39), color, 4.0)
	draw_line(body_center + Vector2(18, -25), body_center + Vector2(25, -39), color, 4.0)
	draw_circle(body_center + Vector2(-7, -2), 2.4, paper_color)
	draw_circle(body_center + Vector2(7, -2), 2.4, paper_color)

func draw_astral_sentry(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -29 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 22.0, 0.32)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(0, -28),
		body_center + Vector2(9, -8),
		body_center + Vector2(25, 0),
		body_center + Vector2(9, 8),
		body_center + Vector2(0, 28),
		body_center + Vector2(-9, 8),
		body_center + Vector2(-25, 0),
		body_center + Vector2(-9, -8),
	]), color)
	draw_crystal(body_center, 11.0, enemy_accent_color)
	draw_arc(body_center, 28.0, elapsed * 0.8, elapsed * 0.8 + PI * 1.4, 24, Color(safe_color, 0.78), 2.0, true)
	draw_circle(body_center + Vector2(-5, -2), 2.0, paper_color)
	draw_circle(body_center + Vector2(5, -2), 2.0, paper_color)
	if int(enemy["health"]) == 1:
		draw_crystal(position + Vector2(0, -70), 6.0, enemy_accent_color)

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
			var rotated_direction := direction.rotated(camera_angle)
			var screen_direction := Vector2(rotated_direction.x - rotated_direction.y, rotated_direction.x + rotated_direction.y).normalized()
			var start_angle := atan2(screen_direction.y, screen_direction.x) - 0.85
			draw_arc(position + Vector2(0, -22), 34.0 + progress * 18.0, start_angle, start_angle + 1.7, 24, color, 7.0 * (1.0 - progress) + 1.0, true)
		else:
			var count := int(effect["phase"])
			for index in range(count):
				var angle := index * TAU / float(count) + float(effect["phase"])
				var from := position + Vector2(cos(angle), sin(angle) * 0.55) * (8.0 + progress * 13.0)
				var to := position + Vector2(cos(angle), sin(angle) * 0.55) * (18.0 + progress * 42.0)
				draw_line(from, to, color, 2.5)

func enemy_display_name(kind: String) -> String:
	match kind:
		"mireling":
			return "MIRELING"
		"forge_golem":
			return "FORGE GOLEM"
		"astral_sentry":
			return "ASTRAL SENTRY"
		_:
			return "SHARDLING"

func draw_level_select(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.9), true)
	var panel := Rect2(170, 42, 940, 636)
	draw_rect(Rect2(panel.position + Vector2(7, 9), panel.size), Color(0.0, 0.0, 0.0, 0.3), true)
	draw_rect(panel, Color(void_color, 0.98), true)
	draw_line(panel.position, panel.position + Vector2(panel.size.x, 0), accent_color, 2.0)
	draw_line(panel.position + Vector2(0, panel.size.y), panel.position + panel.size, Color(accent_color, 0.35), 1.0)
	draw_string(ui_font, Vector2(0, 104), "SELECT LEVEL", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 40, paper_color)
	draw_string(ui_font, Vector2(0, 138), "Choose a remembered path", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 16, muted_color)
	for index in range(LEVELS.size()):
		var level: Dictionary = LEVELS[index]
		var selected := index == selected_level
		var surface_level := String(level.get("kind", "dungeon")) == "surface"
		var row := Rect2(220, 180 + index * 88, 840, 68)
		var row_color := accent_color if selected else muted_color
		var row_fill := Color(void_color, 0.98) if selected else Color(ink_color, 0.96)
		draw_rect(Rect2(row.position + Vector2(4, 5), row.size), Color(0.0, 0.0, 0.0, 0.22), true)
		draw_rect(row, row_fill, true)
		draw_line(row.position, row.position + Vector2(row.size.x, 0), row_color if selected else Color(muted_color, 0.35), 2.0 if selected else 1.0)
		draw_hud_diamond(row.position + Vector2(32, 34), 12.0 if selected else 8.0, row_color if selected else Color(muted_color, 0.45))
		draw_string(ui_font, row.position + Vector2(62, 27), "%02d" % index, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, row_color)
		draw_string(ui_font, row.position + Vector2(112, 31), String(level["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, paper_color if selected else muted_color)
		var detail := "RIVER CROSSING" if surface_level else enemy_display_name(String(level["enemy_kind"]))
		var summary := "BOTTLES  •  CRAFT  •  RIVER" if surface_level else "3 SHARDS  •  5 ENEMIES"
		draw_string(ui_font, row.position + Vector2(112, 52), detail, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, row_color if selected else muted_color)
		draw_string(ui_font, row.position + Vector2(600, 40), summary, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, row_color if selected else muted_color)
	var footer := "W / S or arrows select     ENTER / SPACE play     L / ESC close"
	draw_string(ui_font, Vector2(0, 632), footer, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 14, muted_color)

func craft_element_label(index: int) -> String:
	var source: Dictionary = bottle_sources[index]
	match String(source["kind"]):
		"dustbin":
			return "GARBAGE BOTTLES"
		"recycling":
			return "RECYCLED BOTTLES"
		"crate":
			return "RETURNED BOTTLES"
		"cooler":
			return "COOLER BOTTLES"
		_:
			return "EMPTY BOTTLES"

func draw_craft_table(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.82), true)
	var panel := Rect2(230, 52, 820, 616)
	draw_rect(Rect2(panel.position + Vector2(7, 9), panel.size), Color(0.0, 0.0, 0.0, 0.34), true)
	draw_rect(panel, Color(void_color, 0.98), true)
	draw_line(panel.position, panel.position + Vector2(panel.size.x, 0), accent_color, 2.0)
	draw_line(panel.position + Vector2(0, panel.size.y), panel.position + panel.size, Color(accent_color, 0.35), 1.0)
	draw_string(ui_font, Vector2(0, 100), "CRAFTING TABLE", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 34, paper_color)
	draw_string(ui_font, Vector2(0, 132), "SELECT EMPTY BOTTLES  •  BUILD A FLOTATION JACKET", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 14, muted_color)
	draw_line(Vector2(270, 158), Vector2(1010, 158), Color(slate_light_color, 0.45), 1.0)
	draw_string(ui_font, Vector2(278, 193), "ELEMENT SOURCES", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	for index in range(bottle_sources.size()):
		var row := Rect2(278, 210 + index * 64, 350, 50)
		var selected := index == craft_selected
		var row_color := accent_color if selected else safe_color
		draw_rect(Rect2(row.position + Vector2(4, 5), row.size), Color(0.0, 0.0, 0.0, 0.24), true)
		draw_rect(row, Color(ink_color, 0.96) if not selected else Color(void_color, 0.98), true)
		draw_line(row.position, row.position + Vector2(row.size.x, 0), row_color if selected else Color(muted_color, 0.3), 2.0 if selected else 1.0)
		draw_bottle(row.position + Vector2(28, 31), 0.52, row_color)
		draw_string(ui_font, row.position + Vector2(54, 30), craft_element_label(index), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, paper_color if selected else muted_color)
		draw_string(ui_font, row.position + Vector2(0, 31), "×%02d" % craft_element_available(index), HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 14, 16, row_color)
	draw_string(ui_font, Vector2(676, 193), "JACKET BUILD", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	for index in range(LIFE_JACKET_BOTTLES):
		var column := index % 4
		var row_index := index / 4
		var slot := Rect2(680 + column * 74, 214 + row_index * 82, 58, 66)
		draw_rect(Rect2(slot.position + Vector2(3, 4), slot.size), Color(0.0, 0.0, 0.0, 0.24), true)
		draw_rect(slot, Color(ink_color, 0.96), true)
		var slot_color := safe_color if index < craft_slots.size() else Color(muted_color, 0.35)
		draw_polyline(PackedVector2Array([slot.position, slot.position + Vector2(slot.size.x, 0), slot.position + slot.size, slot.position + Vector2(0, slot.size.y), slot.position]), slot_color, 1.5, true)
		if index < craft_slots.size():
			draw_bottle(slot.get_center() + Vector2(0, 8), 0.78, safe_color)
	var progress_text := str(craft_slots.size()) + " / " + str(LIFE_JACKET_BOTTLES) + " EMPTY BOTTLES"
	var progress_color := safe_color if craft_slots.size() >= LIFE_JACKET_BOTTLES else accent_color
	draw_string(ui_font, Vector2(676, 420), progress_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, progress_color)
	if has_life_jacket:
		draw_string(ui_font, Vector2(676, 456), "LIFE JACKET COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, safe_color)
	elif craft_slots.size() >= LIFE_JACKET_BOTTLES:
		draw_string(ui_font, Vector2(676, 456), "PRESS ENTER TO COMBINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, paper_color)
	else:
		draw_string(ui_font, Vector2(676, 456), "CHOOSE AN ELEMENT AND PRESS SPACE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	if message_timer > 0.0:
		draw_string(ui_font, Vector2(0, 526), message, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 15, paper_color)
	var controls_rect := Rect2(300, 574, 680, 56)
	draw_plaque(controls_rect, slate_light_color)
	draw_string(ui_font, Vector2(0, 608), "W/S SELECT     SPACE ADD     X REMOVE     ENTER COMBINE     B/ESC CLOSE", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 13, muted_color)

func draw_hud(viewport: Vector2) -> void:
	if state == "level_select":
		draw_level_select(viewport)
		return
	if state == "crafting":
		draw_craft_table(viewport)
		return
	draw_plaque(Rect2(30, 24, 330, 76), accent_color)
	var title := "RIVER RUN" if level_kind == "surface" else "FACETED DEPTHS"
	draw_string(ui_font, Vector2(50, 57), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, paper_color)
	var level_text := "LEVEL 00 / %02d  •  %s" % [LEVELS.size(), level_name] if level_kind == "surface" else "DEPTH %02d / %02d  •  %s" % [level_index, LEVELS.size() - 1, level_name]
	draw_string(ui_font, Vector2(51, 83), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, accent_color)
	var shard_rect := Rect2(viewport.x - 244, 24, 214, 76)
	if level_kind == "surface":
		draw_bottle_plaque(shard_rect)
	else:
		draw_plaque(shard_rect, safe_color)
		draw_string(ui_font, shard_rect.position + Vector2(18, 26), "LIGHT SHARDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, muted_color)
		for index in range(shard_cells.size()):
			var center := shard_rect.position + Vector2(32 + index * 58, 52)
			if index < shards_collected:
				draw_hud_diamond(center, 13.0, safe_color)
			else:
				draw_hud_diamond(center, 13.0, Color(muted_color, 0.25))
	var health_rect := Rect2(30, viewport.y - 82, 280, 54)
	draw_plaque(health_rect, danger_color)
	draw_string(ui_font, health_rect.position + Vector2(18, 24), "VITALITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, muted_color)
	for index in range(MAX_HEALTH):
		var center := health_rect.position + Vector2(112 + index * 29, 27)
		if index < health:
			draw_hud_diamond(center, 10.0, danger_color.lightened(0.08))
		else:
			draw_hud_diamond(center, 10.0, Color(muted_color, 0.2))
	var controls := "WASD MOVE  F SEARCH  B TABLE  DRAG PAN  WHEEL ZOOM  Q/E YAW  C RESET  L LEVELS  R RESTART" if level_kind == "surface" else "WASD MOVE  SPACE STRIKE  DRAG PAN  WHEEL ZOOM  Q/E YAW  C RESET  L LEVELS  R RESTART"
	var controls_size := ui_font.get_string_size(controls, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	var controls_rect := Rect2(viewport.x - controls_size.x - 68, viewport.y - 54, controls_size.x + 38, 30)
	draw_plaque(controls_rect, slate_light_color)
	draw_string(ui_font, controls_rect.position + Vector2(19, 20), controls, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	if message_timer > 0.0:
		draw_message(viewport)
	if state != "playing":
		draw_state_overlay(viewport)

func draw_bottle_plaque(rect: Rect2) -> void:
	draw_plaque(rect, safe_color)
	draw_string(ui_font, rect.position + Vector2(18, 25), "BOTTLES", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, muted_color)
	draw_bottle(rect.position + Vector2(29, 54), 0.58, safe_color)
	draw_string(ui_font, rect.position + Vector2(47, 59), "%02d" % bottle_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, paper_color)
	draw_line(rect.position + Vector2(94, 17), rect.position + Vector2(94, 59), Color(muted_color, 0.4), 1.0)
	draw_string(ui_font, rect.position + Vector2(108, 29), "JACKET", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, muted_color)
	var jacket_color := safe_color if has_life_jacket else accent_color
	var jacket_text := str(LIFE_JACKET_BOTTLES - bottle_count) + " MORE"
	if bottle_count >= LIFE_JACKET_BOTTLES:
		jacket_text = "CAN CRAFT"
	if has_life_jacket:
		jacket_text = "READY"
	draw_string(ui_font, rect.position + Vector2(108, 55), jacket_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, jacket_color)

func draw_plaque(rect: Rect2, accent: Color) -> void:
	draw_rect(Rect2(rect.position + Vector2(5, 7), rect.size), Color(0.0, 0.0, 0.0, 0.25), true)
	draw_rect(rect, Color(void_color, 0.94), true)
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
	draw_rect(rect, Color(void_color, 0.92 * alpha), true)
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color(safe_color, alpha), 2.0)
	draw_string(ui_font, rect.position + Vector2(22, 28), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(paper_color, alpha))

func draw_state_overlay(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.82), true)
	var center := Vector2(viewport.x * 0.5, viewport.y * 0.48)
	var accent := safe_color if state == "won" else danger_color
	draw_crystal(center + Vector2(0, -76), 42.0 + sin(elapsed * 2.2) * 2.0, accent)
	var title := "THE DEPTHS ARE CLEARED" if state == "won" else "THE LIGHT FADES"
	var subtitle := "All four depths are clear" if state == "won" else "Press R to restart this depth"
	draw_string(ui_font, Vector2(0, center.y + 18), title, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 42, paper_color)
	draw_string(ui_font, Vector2(0, center.y + 58), subtitle, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 17, Color(accent, 0.9))
