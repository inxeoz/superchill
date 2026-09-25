extends SceneTree

# Screenshot helper for Faceted Depths.
#
# Requires a real window/display (rendering must actually rasterize):
#   godot --path . --script res://capture_screenshot.gd
#
# In --headless the dummy renderer has no viewport texture, so captures are
# skipped with a clear message instead of crashing.
#
# Grabs the current viewport's texture, converts it to an Image via
# get_image(), and saves PNGs under res://screenshots/: the Level 0 field,
# the crafting table (mixed inventory), and the item pick list.

var game: Variant

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	game = load("res://faceted_depths.tscn").instantiate()
	root.add_child(game as Node)
	DirAccess.make_dir_recursive_absolute("res://screenshots/")
	# Level 0 open field (playing)
	game.load_level(0)
	game.state = "playing"
	await settle(6)
	capture("level0_field")
	# Crafting table with a mixed inventory (max-cases the element grid)
	for s in game.bottle_sources:
		game.bottle_inventory[String(s["kind"])] = 3
	for kind in game.ITEM_ORDER:
		game.item_inventory[String(kind)] = 2
	game.bottle_count = 12
	game.open_craft_table()
	await settle(5)
	capture("crafting_table")
	# Item pick list (several items in reach)
	game.close_craft_table()
	game.state = "playing"
	game.player_position = Vector2(2.5, 1.5)
	game.try_pick_litter()
	await settle(5)
	capture("pickup_select")
	quit(0)

func settle(frames: int) -> void:
	for i in range(frames):
		await process_frame

func capture(label: String) -> void:
	var texture: ViewportTexture = game.get_viewport().get_texture()
	if texture == null:
		push_warning("No viewport texture (headless renderer?) -- skipping " + label)
		return
	var img: Image = texture.get_image()
	if img == null:
		push_warning("get_image() returned null -- skipping " + label)
		return
	var path := "res://screenshots/" + label + ".png"
	img.save_png(path)
	print("saved ", path, "  size=", img.get_size(), "  empty=", img.is_empty())
