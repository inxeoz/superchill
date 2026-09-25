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
	game.move_level_selection(game.LEVELS.size() - 1)
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
	if not is_equal_approx(game.camera_zoom, game.DEFAULT_CAMERA_ZOOM):
		quit(1)
		return
	var camera_target_before: Vector2 = game.camera_target
	game.player_position += Vector2(1.0, 0.0)
	game.update_camera(0.25)
	if game.camera_target.is_equal_approx(camera_target_before) or game.camera_target.is_equal_approx(game.player_position):
		quit(1)
		return
	game.reset_camera()
	var input_rotation_valid := await validate_input_rotation()
	if not input_rotation_valid:
		quit(1)
		return
	game.reset_camera()
	if not validate_player_facing():
		quit(1)
		return
	game.reset_camera()
	if not await validate_attack_and_jump():
		quit(1)
		return
	game.reset_camera()
	if not validate_restart_confirm():
		quit(1)
		return
	game.reset_camera()
	if not validate_wall_faces():
		quit(1)
		return
	game.reset_camera()
	if not validate_rotated_border():
		quit(1)
		return
	game.reset_camera()
	# player is procedural now (no PNG asset load); ensure it renders without error
	if game.has_method("draw_player") == false or game.has_method("draw_pixel_sprite") == false:
		quit(1)
		return
	for level_index in range(6):
		var valid := validate_surface_level() if level_index == 0 else (validate_jungle_level() if level_index == game.LEVELS.size() - 1 else validate_dungeon_level(level_index))
		if not valid:
			quit(1)
			return
	game.load_level(1)
	var enemy_count: int = game.enemies.size()
	game.enemies[0]["position"] = game.player_position + game.player_facing * 0.8
	game.enemies[0]["health"] = 1
	game.attack_cooldown = 0.0
	game.attack()
	if game.enemies.size() != enemy_count - 1:
		quit(1)
		return
	game.load_level(1)
	for shard in game.shards:
		shard["taken"] = true
	game.shards_collected = game.shard_cells.size()
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.collect_shards()
	if game.level_index != 2 or game.level_name != "MOSSGLASS CISTERN":
		quit(1)
		return
	game.load_level(4)
	for shard in game.shards:
		shard["taken"] = true
	game.shards_collected = game.shard_cells.size()
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.collect_shards()
	if game.level_index != game.LEVELS.size() - 1 or game.state != "playing":
		quit(1)
		return
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.state != "won":
		quit(1)
		return
	print("game_test: ok")
	quit(0)

func validate_input_rotation() -> bool:
	game.set_process(false)
	game.walkable = {}
	for x in range(-10, 11):
		for y in range(-10, 11):
			game.walkable[Vector2i(x, y)] = true
	await process_frame
	var results: Array[Vector2] = []
	for angle in [0.0, PI * 0.5]:
		game.player_position = Vector2(5.5, 5.5)
		game.camera_target = game.player_position
		game.camera_angle = angle
		var key_down := InputEventKey.new()
		key_down.physical_keycode = KEY_D
		key_down.keycode = KEY_D
		key_down.pressed = true
		Input.parse_input_event(key_down)
		await process_frame
		var before: Vector2 = game.player_position
		game.update_player(0.25)
		results.append((game.player_position - before).normalized())
		var key_up := InputEventKey.new()
		key_up.physical_keycode = KEY_D
		key_up.keycode = KEY_D
		key_up.pressed = false
		Input.parse_input_event(key_up)
		await process_frame
	game.set_process(true)
	var base_direction := Vector2(1.0, -1.0).normalized()
	var expected_rotated := base_direction.rotated(-PI * 0.5)
	var valid := results.size() == 2
	if valid:
		valid = results[0].is_equal_approx(base_direction) and results[1].is_equal_approx(expected_rotated)
	return valid

func validate_player_facing() -> bool:
	# The walk/facing sprite must follow the camera-relative (on-screen) movement
	# direction, so for a fixed input key the sprite must be invariant to camera
	# yaw. Each cardinal move resolves to an oblique world direction (no axis
	# boundary), which keeps this regression check deterministic.
	var screen_inputs := {
		"left": Vector2(-1, 0),
		"right": Vector2(1, 0),
		"top": Vector2(0, -1),
		"down": Vector2(0, 1),
	}
	var expected := {"left": "sw", "right": "ne", "top": "nw", "down": "se"}
	for angle in [0.0, PI * 0.25, PI * 0.5, -PI * 0.5]:
		game.camera_angle = angle
		for key in screen_inputs:
			var inp: Vector2 = screen_inputs[key]
			game.player_facing = Vector2(inp.x + inp.y, inp.y - inp.x).normalized().rotated(-game.camera_angle)
			if game.player_face_name() != String(expected[key]):
				return false
	return true

func validate_attack_and_jump() -> bool:
	# Level 0 is a surface level: the blade strike must be allowed there, and
	# Space must jump rather than strike.
	game.load_level(0)
	if game.level_kind != "surface":
		return false
	# Direct strike works on a surface level.
	game.attack_cooldown = 0.0
	var before: int = game.effects.size()
	game.attack()
	if game.effects.size() != before + 1 or String(game.effects[game.effects.size() - 1]["kind"]) != "slash":
		return false
	# Enter routes to attack() in the playing state (all levels).
	var before2: int = game.effects.size()
	game.attack_cooldown = 0.0
	var enter_event := InputEventKey.new()
	enter_event.physical_keycode = KEY_ENTER
	enter_event.keycode = KEY_ENTER
	enter_event.pressed = true
	game._unhandled_input(enter_event)
	if game.effects.size() != before2 + 1:
		return false
	# Space triggers jump on a surface level.
	game.player_jumping = false
	var space_down := InputEventKey.new()
	space_down.physical_keycode = KEY_SPACE
	space_down.keycode = KEY_SPACE
	space_down.pressed = true
	Input.parse_input_event(space_down)
	await process_frame
	game.player_jumping = false
	game.update_player(0.25)
	if not game.player_jumping:
		return false
	var space_up := InputEventKey.new()
	space_up.physical_keycode = KEY_SPACE
	space_up.keycode = KEY_SPACE
	space_up.pressed = false
	Input.parse_input_event(space_up)
	await process_frame
	return true

func validate_restart_confirm() -> bool:
	game.load_level(1)
	if game.state != "playing":
		return false
	var r_down := InputEventKey.new()
	r_down.physical_keycode = KEY_R
	r_down.keycode = KEY_R
	r_down.pressed = true
	game._unhandled_input(r_down)
	if game.state != "restart_confirm" or game.restart_selected != 1:
		return false
	# R while the dialog is open must not reopen/close it.
	game._unhandled_input(r_down)
	if game.state != "restart_confirm":
		return false
	# Default is NO: confirming returns to playing without reloading.
	var level_before: int = game.level_index
	var enter := InputEventKey.new()
	enter.physical_keycode = KEY_ENTER
	enter.keycode = KEY_ENTER
	enter.pressed = true
	game._unhandled_input(enter)
	if game.state != "playing" or game.level_index != level_before:
		return false
	# Mark progress so a real reload is detectable.
	for shard in game.shards:
		shard["taken"] = true
	game.shards_collected = game.shard_cells.size()
	# ESC closes the dialog without restarting.
	game._unhandled_input(r_down)
	var esc := InputEventKey.new()
	esc.physical_keycode = KEY_ESCAPE
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	game._unhandled_input(esc)
	if game.state != "playing" or game.shards_collected != game.shard_cells.size():
		return false
	# Reopen, select RESTART, confirm: level reloads and progress resets.
	game._unhandled_input(r_down)
	if game.state != "restart_confirm" or game.restart_selected != 1:
		return false
	var down := InputEventKey.new()
	down.physical_keycode = KEY_DOWN
	down.keycode = KEY_DOWN
	down.pressed = true
	game._unhandled_input(down)
	if game.restart_selected != 0:
		return false
	game._unhandled_input(enter)
	return game.state == "playing" and game.shards_collected == 0 and not bool(game.shards[0]["taken"])

func validate_wall_faces() -> bool:
	game.camera_angle = PI * 0.5
	var floor: PackedVector2Array = game.tile_polygon(Vector2i(1, 1))
	var top: PackedVector2Array = game.tile_polygon(Vector2i(1, 1), 58.0)
	var faces: Array[PackedVector2Array] = game.wall_faces(floor, top)
	if faces.size() != 4:
		return false
	var face: PackedVector2Array = faces[3]
	var center := (face[0] + face[1] + face[2] + face[3]) * 0.25
	return Geometry2D.is_point_in_polygon(center, face)

func validate_rotated_border() -> bool:
	game.load_level(0)
	var border: Dictionary = game.border_cells()
	if border.size() != 128:
		return false
	var expected_walls := 0
	for y in range(game.map_rows.size()):
		var row := String(game.map_rows[y])
		for x in range(row.length()):
			if not game.walkable.has(Vector2i(x, y)):
				expected_walls += 1
	for angle in [0.0, deg_to_rad(15.0), PI * 0.5, PI, PI * 1.5]:
		game.camera_angle = angle
		var walls: Array[Dictionary] = game.wall_drawables()
		if walls.size() != expected_walls:
			return false
		var previous_depth := -INF
		var seen: Dictionary = {}
		for wall in walls:
			var depth := float(wall["depth"])
			var cell: Vector2i = wall["cell"]
			if depth < previous_depth or seen.has(cell):
				return false
			previous_depth = depth
			seen[cell] = true
			if border.has(cell) and float(wall["height"]) != 16.0:
				return false
	return true

func validate_surface_level() -> bool:
	game.load_level(0)
	if game.level_index != 0 or game.level_kind != "surface" or game.map_rows.size() != 26:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	if not game.enemies.is_empty() or not game.shards.is_empty() or not game.bottle_sources.is_empty():
		return false
	for row in game.map_rows:
		if String(row).length() != 40:
			return false
	# River is four tiles wide: columns 19-22 are water, and the banks are land.
	for y in range(1, 25):
		if not game.water_cells.has(Vector2i(19, y)) or not game.water_cells.has(Vector2i(20, y)) or not game.water_cells.has(Vector2i(21, y)) or not game.water_cells.has(Vector2i(22, y)):
			return false
		if game.water_cells.has(Vector2i(18, y)) or game.water_cells.has(Vector2i(23, y)):
			return false
	# Loose items: distinct, on reachable on-foot land, and collectible.
	var seen_cells: Dictionary = {}
	var counts: Dictionary = {}
	var bottle_total := 0
	for item in game.litter:
		var item_cell: Vector2i = game.cell_at(item["position"])
		if not game.walkable.has(item_cell) or game.water_cells.has(item_cell) or not game.flow.has(item_cell):
			return false
		if seen_cells.has(item_cell):
			return false
		seen_cells[item_cell] = true
		if not game.can_occupy(item["position"], 0.22):
			return false
		var kind := String(item["kind"])
		counts[kind] = int(counts.get(kind, 0)) + 1
		if kind == "empty bottle":
			bottle_total += 1
	if game.litter.size() == 0 or bottle_total < game.LIFE_JACKET_BOTTLES:
		return false
	# The fishing-catcher materials must all be present somewhere on the bank.
	# "bottles" is the shared need key that maps to the empty-bottle sources.
	for need_kind in game.recipe_needs(1):
		var need_key := String(need_kind)
		var have_count := bottle_total if need_key == "bottles" else int(counts.get(need_key, 0))
		if have_count < int(game.recipe_needs(1)[need_key]):
			return false
	# No item spawns on the player's start tile.
	if seen_cells.has(game.start_cell):
		return false
	# Trees are solid landmarks on land, and never on water or the exit tile.
	if game.tree_cells.size() < 2:
		return false
	for tree_cell: Vector2i in game.tree_cells:
		if not game.walkable.has(tree_cell) or game.water_cells.has(tree_cell) or seen_cells.has(tree_cell):
			return false
		if game.can_occupy(Vector2(tree_cell) + Vector2(0.5, 0.5), 0.22):
			return false
	# Spirits (stars) sit on reachable land, off waters/trees/items/start/exit.
	if game.spirits.size() < 2:
		return false
	for spirit: Dictionary in game.spirits:
		var spirit_cell: Vector2i = game.cell_at(spirit["position"])
		if not game.walkable.has(spirit_cell) or game.water_cells.has(spirit_cell) or game.solid_cells.has(spirit_cell):
			return false
		if seen_cells.has(spirit_cell) or spirit_cell == game.start_cell or spirit_cell == game.exit_cell:
			return false
		if not game.can_occupy(spirit["position"], 0.22):
			return false
	# Every spirit is unique: no two on the same tile, and each unlocks a distinct recipe.
	var seen_spirit_cells: Dictionary = {}
	var seen_spirit_recipes: Dictionary = {}
	for spirit: Dictionary in game.spirits:
		var sc: Vector2i = game.cell_at(spirit["position"])
		if seen_spirit_cells.has(sc):
			return false
		seen_spirit_cells[sc] = true
		var rid := String(spirit["recipe"])
		if seen_spirit_recipes.has(rid):
			return false
		seen_spirit_recipes[rid] = true
	# Water is enterable, but wading in without a life jacket drowns you.
	var water_position := Vector2(20.5, 12.5)
	if not game.can_occupy(water_position, 0.22):
		return false
	var health0: int = game.health
	game.player_position = water_position
	game.update_drowning(0.5)
	if game.health != health0 - 1:
		return false
	game.update_drowning(1.0)
	if game.health != health0 - 2:
		return false
	# The right bank is reached once a jacket lets you cross.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.level_index != 1:
		return false
	game.load_level(0)
	# With no ideas yet, a material cannot be crafted into anything.
	game.bottle_count = game.LIFE_JACKET_BOTTLES
	game.open_craft_table()
	game.craft_selected = 0
	game.refresh_recipe_index()
	if game.recipe_index != -1:
		return false
	game.build_selected()
	if game.has_life_jacket or game.state != "crafting" or game.bottle_count != game.LIFE_JACKET_BOTTLES:
		return false
	game.close_craft_table()
	game.bottle_count = 0
	# Collecting the star spirits unlocks the hidden recipe ideas.
	for spirit: Dictionary in game.spirits:
		game.player_position = spirit["position"]
		if not game.try_collect_spirit():
			return false
	if not game.unlocked_ideas.has("life_jacket") or not game.unlocked_ideas.has("fishing_catcher"):
		return false
	game.open_craft_table()
	if game.state != "crafting" or not game.craft_visible_elements().is_empty():
		return false
	game.close_craft_table()
	# A lone item is picked straight up (no list), removing exactly it.
	var lone: Dictionary = {}
	for item in game.litter:
		if String(item["kind"]) == "wood scrap":
			lone = item
			break
	game.player_position = lone["position"]
	game.pick_litter_kind("wood scrap")
	if game.item_inventory.get("wood scrap", 0) != 1 or game.item_count != 1 or game.litter.size() != 36:
		return false
	if game.total_collected_items() != 1:
		return false
	# Life jacket builds from eight collected bottles (craft element 0).
	game.load_level(0)
	game.bottle_count = game.LIFE_JACKET_BOTTLES
	game.open_craft_table()
	var bottle_visible: Array = game.craft_visible_elements()
	if bottle_visible.size() != 1 or bottle_visible[0] != 0:
		return false
	if game.craft_element_kind(0) != "bottles" or game.craft_build_kind(0) != "bottles":
		return false
	game.craft_selected = 0
	game.refresh_recipe_index()
	if game.recipe_index != 0:
		return false
	game.build_selected()
	if not game.has_life_jacket or game.state != "playing" or game.bottle_count != 0 or game.life_jacket_on_ground:
		return false
	# With the jacket, wading in the river does not drown you.
	var health1: int = game.health
	game.player_position = water_position
	game.update_drowning(0.5)
	game.update_drowning(1.0)
	if game.health != health1:
		return false
	game.player_position = Vector2(game.start_cell) + Vector2(0.5, 0.5)
	# Drop / re-equip the jacket; water is blocked again while it is on the ground.
	var drop_position: Vector2 = game.player_position
	game.toggle_life_jacket()
	if game.has_life_jacket or not game.life_jacket_on_ground or game.life_jacket_position != drop_position:
		return false
	# Dropped jacket: the river drowns you again.
	var health2: int = game.health
	game.player_position = water_position
	game.update_drowning(0.5)
	if game.health != health2 - 1:
		return false
	game.player_position = drop_position
	game.player_position = drop_position + Vector2(2.0, 0.0)
	game.toggle_life_jacket()
	if game.has_life_jacket or not game.life_jacket_on_ground:
		return false
	game.player_position = drop_position
	game.open_craft_table()
	if not game.pick_up_life_jacket() or game.state != "playing" or not game.has_life_jacket or game.life_jacket_on_ground:
		return false
	game.drop_life_jacket()
	game.toggle_life_jacket()
	if not game.has_life_jacket or game.life_jacket_on_ground:
		return false
	# Re-equipped: the river is safe to wade again.
	var health3: int = game.health
	game.player_position = water_position
	game.update_drowning(0.5)
	if game.health != health3:
		return false
	# Jacket is bottles-only: debris (leaves) is not in any recipe, so it cannot help
	# build; building fails until eight bottles are present.
	game.load_level(0)
	game.item_inventory["leaves"] = 4
	game.bottle_count = 4
	game.open_craft_table()
	var debris_visible: Array = game.craft_visible_elements()
	if debris_visible.size() != 2 or debris_visible[0] != 0 or debris_visible[1] != 1:
		return false
	game.craft_selected = 0
	game.refresh_recipe_index()
	if game.recipe_index != 0:
		return false
	game.build_selected()
	if game.has_life_jacket or game.state != "crafting" or game.bottle_count != 4:
		return false
	# leaves map to no recipe -> cannot build from them
	game.craft_selected = 1
	game.refresh_recipe_index()
	if game.recipe_index != -1:
		return false
	game.build_selected()
	if game.has_life_jacket or game.state != "crafting" or int(game.item_inventory.get("leaves", 0)) != 4:
		return false
	# now give enough bottles and the jacket builds, consuming only bottles
	game.bottle_count = game.LIFE_JACKET_BOTTLES
	game.craft_selected = 0
	game.refresh_recipe_index()
	game.build_selected()
	if not game.has_life_jacket or game.bottle_count != 0 or int(game.item_inventory.get("leaves", 0)) != 4:
		return false
	# Fishing catcher: selecting its material auto-picks the recipe and builds it
	# from one bottle and one rope.
	game.load_level(0)
	game.bottle_count = 1
	game.item_inventory["rope"] = 1
	game.open_craft_table()
	var cat_visible: Array = game.craft_visible_elements()
	var rope_pos := -1
	for i in range(cat_visible.size()):
		if game.craft_element_kind(cat_visible[i]) == "rope":
			rope_pos = i
	if rope_pos < 0:
		return false
	game.craft_selected = rope_pos
	game.refresh_recipe_index()
	if game.recipe_index != 1:
		return false
	game.build_selected()
	if not game.has_fishing_catcher or game.state != "playing":
		return false
	if int(game.item_inventory.get("rope", 0)) != 0 or game.bottle_count != 0:
		return false

	game.load_level(0)
	if game.has_life_jacket:
		return false
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	return game.level_index == 1 and game.level_name == "FACETED DEPTHS"


func validate_jungle_level() -> bool:
	game.load_level(game.LEVELS.size() - 1)
	if game.level_index != game.LEVELS.size() - 1 or game.level_kind != "surface" or game.level_theme != "jungle" or game.map_rows.size() != 14:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	for row in game.map_rows:
		if String(row).length() != 22:
			return false
	# River is 4 tiles wide (cols 16-19) with a waterfall ('F') at its head.
	var has_fall := false
	for y in range(1, game.map_rows.size() - 1):
		if not game.water_cells.has(Vector2i(16, y)) or not game.water_cells.has(Vector2i(17, y)) or not game.water_cells.has(Vector2i(18, y)) or not game.water_cells.has(Vector2i(19, y)):
			return false
		if game.water_cells.has(Vector2i(15, y)) or game.water_cells.has(Vector2i(20, y)):
			return false
	for c in game.water_cells:
		var cell: Vector2i = c
		if game.is_fall_cell(cell):
			has_fall = true
	if not has_fall:
		return false
	# Lush terrain is kept reachable: items scatter on the bank.
	if game.litter.size() < 20:
		return false
	# Solid trees on land, off water.
	if game.tree_cells.size() < 8:
		return false
	for tree_cell: Vector2i in game.tree_cells:
		if not game.walkable.has(tree_cell) or game.water_cells.has(tree_cell):
			return false
		if game.can_occupy(Vector2(tree_cell) + Vector2(0.5, 0.5), 0.22):
			return false
	# One spirit grants the fishing-catcher recipe on reachable land.
	var catcher_found := false
	for spirit: Dictionary in game.spirits:
		if String(spirit["recipe"]) != "fishing_catcher":
			continue
		catcher_found = true
		var sc: Vector2i = game.cell_at(spirit["position"])
		if not game.walkable.has(sc) or game.water_cells.has(sc) or game.solid_cells.has(sc):
			return false
		if sc == game.start_cell or sc == game.exit_cell:
			return false
		if not game.can_occupy(spirit["position"], 0.22):
			return false
	if not catcher_found:
		return false
	return true

func validate_dungeon_level(index: int) -> bool:
	game.load_level(index)
	if game.level_index != index or game.level_kind != "dungeon" or game.map_rows.size() != 9:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size() or not game.water_cells.is_empty() or not game.solid_cells.is_empty():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	if game.enemies.size() != 5 or game.shards.size() != 3:
		return false
	if String(game.enemy_kind) != String(expected_kinds[index - 1]):
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
