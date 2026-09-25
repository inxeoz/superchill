extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game: Variant = load("res://faceted_depths.tscn").instantiate()
	root.add_child(game as Node)
	if game.walkable.is_empty():
		quit(1)
		return
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
	game.player_facing = Vector2(1.0, -1.0).normalized()
	if game.player_face_name() != "ne":
		quit(1)
		return
	game.player_facing = Vector2(1.0, 1.0).normalized()
	if game.player_face_name() != "se":
		quit(1)
		return
	game.player_facing = Vector2(-1.0, 1.0).normalized()
	if game.player_face_name() != "sw":
		quit(1)
		return
	game.player_facing = Vector2(-1.0, -1.0).normalized()
	if game.player_face_name() != "nw":
		quit(1)
		return
	if not game.flow.has(Vector2i(2, 1)) or not game.flow.has(Vector2i(10, 1)):
		quit(1)
		return
	if game.enemies.size() != 5:
		quit(1)
		return
	for enemy in game.enemies:
		var enemy_cell: Vector2i = game.cell_at(enemy["position"])
		if not game.walkable.has(enemy_cell) or not game.flow.has(enemy_cell):
			quit(1)
			return
	if game.can_occupy(Vector2(0.5, 0.5), 0.22):
		quit(1)
		return
	var enemy_count: int = game.enemies.size()
	game.enemies[0]["position"] = game.player_position + game.player_facing * 0.8
	game.enemies[0]["health"] = 1
	game.attack_cooldown = 0.0
	game.attack()
	if game.enemies.size() != enemy_count - 1:
		quit(1)
		return
	for shard in game.shards:
		shard["taken"] = true
	game.shards_collected = 3
	game.player_position = Vector2(10.5, 1.5)
	game.collect_shards()
	if game.state != "won":
		quit(1)
		return
	print("game_test: ok")
	quit(0)
