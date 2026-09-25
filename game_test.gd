extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game: Variant = load("res://s.tscn").instantiate()
	root.add_child(game as Node)
	if game.walkable.is_empty():
		quit(1)
		return
	if not game.flow.has(Vector2i(2, 1)) or not game.flow.has(Vector2i(10, 1)):
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
