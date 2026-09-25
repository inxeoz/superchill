extends SceneTree

var game: Variant
var expected_kinds := ["shardling", "mireling", "forge_golem", "astral_sentry"]

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	game = load("res://faceted_depths.tscn").instantiate()
	root.add_child(game as Node)
	if load("res://assets/icon.svg") == null:
		quit(1)
		return
	if game.state != "level_select":
		quit(1)
		return
	game.move_level_selection(1)
	if game.selected_level != 1:
		quit(1)
		return
	game.move_level_selection(3)
	if game.selected_level != 0:
		quit(1)
		return
	game.selected_level = 2
	game.confirm_level_selection()
	if game.state != "playing" or game.level_index != 2:
		quit(1)
		return
	game.reset_camera()
	game.set_camera_offset(Vector2(999.0, 999.0))
	if game.camera_offset != Vector2(420.0, 280.0):
		quit(1)
		return
	game.reset_camera()
	var projected_before: Vector2 = game.iso_to_screen(Vector2(3.0, 4.0))
	game.camera_zoom = 1.25
	game.camera_angle = PI * 0.25
	game.camera_offset = Vector2(100.0, -40.0)
	if game.camera_zoom != 1.25 or game.camera_angle != PI * 0.25 or game.camera_offset != Vector2(100.0, -40.0):
		quit(1)
		return
	if game.iso_to_screen(Vector2(3.0, 4.0)) == projected_before:
		quit(1)
		return
	game.reset_camera()
	for direction in ["ne", "se", "sw", "nw"]:
		if not game.player_frames.has(direction) or game.player_frames[direction].size() != 4:
			quit(1)
			return
		for frame in game.player_frames[direction]:
			if frame == null:
				quit(1)
				return
		if game.sword_frames[direction] == null:
			quit(1)
			return
	for level_index in range(4):
		if not validate_level(level_index):
			quit(1)
			return
	game.load_level(0)
	var enemy_count: int = game.enemies.size()
	game.enemies[0]["position"] = game.player_position + game.player_facing * 0.8
	game.enemies[0]["health"] = 1
	game.attack_cooldown = 0.0
	game.attack()
	if game.enemies.size() != enemy_count - 1:
		quit(1)
		return
	game.load_level(0)
	for shard in game.shards:
		shard["taken"] = true
	game.shards_collected = game.shard_cells.size()
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.collect_shards()
	if game.level_index != 1 or game.level_name != "MOSSGLASS CISTERN":
		quit(1)
		return
	game.load_level(3)
	for shard in game.shards:
		shard["taken"] = true
	game.shards_collected = game.shard_cells.size()
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.collect_shards()
	if game.state != "won":
		quit(1)
		return
	print("game_test: ok")
	quit(0)

func validate_level(index: int) -> bool:
	game.load_level(index)
	if game.level_index != index or game.map_rows.size() != 9:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	if game.enemies.size() != 5 or game.shards.size() != 3:
		return false
	if String(game.enemy_kind) != String(expected_kinds[index]):
		return false
	for row in game.map_rows:
		if String(row).length() != 12:
			return false
	for cell in game.enemy_spawns:
		var spawn: Vector2i = cell
		if not game.walkable.has(spawn) or not game.flow.has(spawn):
			return false
	for cell in game.shard_cells:
		var shard_cell: Vector2i = cell
		if not game.walkable.has(shard_cell) or not game.flow.has(shard_cell):
			return false
	for enemy in game.enemies:
		var enemy_cell: Vector2i = game.cell_at(enemy["position"])
		if not game.walkable.has(enemy_cell) or not game.flow.has(enemy_cell):
			return false
	return true
