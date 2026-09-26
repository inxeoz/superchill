extends SceneTree

var game: Variant

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	game = load("res://faceted_depths.tscn").instantiate()
	root.add_child(game as Node)
	DirAccess.make_dir_recursive_absolute("res://screenshots/")
	# Radio level (SEND HELP MESSAGE), player walked east like the report shot.
	var radio_index := -1
	for i in range(game.LEVELS.size()):
		if String(game.LEVELS[i].get("theme", "")) == "radio_jungle":
			radio_index = i
	game.load_level(radio_index)
	game.state = "playing"
	game.player_position = Vector2(20.5, 12.5)
	await settle(8)
	capture("radio_east")
	# Also from spawn, looking at the receiver.
	game.player_position = Vector2(game.start_cell) + Vector2(0.5, 0.5)
	await settle(8)
	capture("radio_spawn")
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
	print("saved ", path, "  size=", img.get_size(), "  empty=", img.is_empty())
