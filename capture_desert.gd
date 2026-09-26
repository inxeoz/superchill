extends SceneTree

# Desert Storm screenshot helper. Run WITHOUT --headless so it can rasterize:
#   godot --path . --script res://capture_desert.gd

var game: Variant

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	game = load("res://faceted_depths.tscn").instantiate()
	root.add_child(game as Node)
	DirAccess.make_dir_recursive_absolute("res://screenshots/")
	var desert_index := -1
	for i in range(game.LEVELS.size()):
		if String(game.LEVELS[i].get("theme", "")) == "desert_storm":
			desert_index = i
	game.load_level(desert_index)
	game.state = "playing"
	# Blinded: player near the start, hyenas invisible around them.
	game.player_position = Vector2(6.5, 14.5)
	await settle(8)
	capture("desert_storm_blind")
	# A spirit sits on-screen but far outside the blind sight pool: its beacon
	# must still burn through the storm.
	game.player_position = Vector2(8.5, 4.5)
	game.player_frame_last = game.player_position
	game.rebuild_flow()
	await settle(8)
	capture("desert_storm_beacon")
	# Collect spirits, gather materials, craft the goggles.
	for s in game.spirits:
		game.player_position = s["position"]
		game.try_collect_spirit()
	game.item_inventory["cloth"] = 2
	game.item_inventory["metal scrap"] = 1
	game.item_inventory["wine glass"] = 1
	game.open_craft_table()
	var vis: Array = game.craft_visible_elements()
	var cloth_pos := -1
	for i in range(vis.size()):
		if game.craft_element_kind(vis[i]) == "cloth":
			cloth_pos = i
	game.craft_selected = cloth_pos
	game.refresh_recipe_index()
	game.build_selected()
	# With goggles: hyenas visible, storm partly parted.
	game.player_position = Vector2(6.5, 14.5)
	game.enemies[0]["position"] = Vector2(7.5, 13.5)
	await settle(8)
	capture("desert_storm_goggles")
	quit(0)

func settle(frames: int) -> void:
	for i in range(frames):
		await process_frame

func capture(label: String) -> void:
	var texture: ViewportTexture = game.get_viewport().get_texture()
	if texture == null:
		push_warning("No viewport texture -- skipping " + label)
		return
	var img: Image = texture.get_image()
	if img == null:
		push_warning("get_image() returned null -- skipping " + label)
		return
	var path := "res://screenshots/" + label + ".png"
	img.save_png(path)
	print("saved ", path, "  size=", img.get_size())
