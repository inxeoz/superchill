extends SceneTree
var game: Variant
var px := 10.5
var py := 14.5
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--px="):
			px = float(a.get_slice("=", 1))
		if a.begins_with("--py="):
			py = float(a.get_slice("=", 1))
	call_deferred("run")
func run() -> void:
	game = load("res://faceted_depths.tscn").instantiate()
	root.add_child(game as Node)
	DirAccess.make_dir_recursive_absolute("res://screenshots/")
	var radio_index := -1
	for i in range(game.LEVELS.size()):
		if String(game.LEVELS[i].get("theme", "")) == "radio_jungle":
			radio_index = i
	game.load_level(radio_index)
	game.state = "playing"
	game.player_position = Vector2(px, py)
	await settle(8)
	var texture: ViewportTexture = game.get_viewport().get_texture()
	var img: Image = texture.get_image()
	img.save_png("res://screenshots/probe_p.png")
	print("saved probe_p ", px, ",", py)
	quit(0)
func settle(frames: int) -> void:
	for i in range(frames):
		await process_frame
