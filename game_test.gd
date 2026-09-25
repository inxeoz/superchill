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
	game.move_level_selection(4)
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
	for level_index in range(5):
		var valid := validate_surface_level() if level_index == 0 else validate_dungeon_level(level_index)
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
	if border.size() != 50:
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
	if game.level_index != 0 or game.level_kind != "surface" or game.map_rows.size() != 11:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	if not game.enemies.is_empty() or not game.shards.is_empty() or game.bottle_sources.size() < 4:
		return false
	for row in game.map_rows:
		if String(row).length() != 16:
			return false
	for y in range(1, 10):
		if not game.water_cells.has(Vector2i(6, y)):
			return false
	var available_bottles := 0
	var dustbin: Dictionary = {}
	for source_data in game.bottle_sources:
		var source: Dictionary = source_data
		var cell: Vector2i = source["cell"]
		if not game.walkable.has(cell) or game.water_cells.has(cell) or not game.flow.has(cell):
			return false
		if game.can_occupy(Vector2(cell) + Vector2(0.5, 0.5), 0.22):
			return false
		available_bottles += int(source["charges"]) * int(source["bottles"])
		if String(source["kind"]) == "dustbin":
			dustbin = source
	if available_bottles < game.LIFE_JACKET_BOTTLES or dustbin.is_empty():
		return false
	var water_position := Vector2(6.5, 4.5)
	if game.can_occupy(water_position, 0.22):
		return false
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.level_index != 1:
		return false
	game.load_level(0)
	game.open_craft_table()
	if game.state != "crafting" or not game.craft_visible_elements().is_empty():
		return false
	game.close_craft_table()
	var pickup_item: Dictionary = game.litter[0]
	var pickup_position: Vector2 = pickup_item["position"]
	if not game.walkable.has(game.cell_at(pickup_position)) or game.water_cells.has(game.cell_at(pickup_position)):
		return false
	game.player_position = pickup_position
	game.update_surface_level()
	if game.item_count != 0 or game.litter.size() != 12 or game.level_index != 0:
		return false
	# several items in reach -> F opens the item list
	game.try_pick_litter()
	if game.state != "pickup_select" or game.pickup_selected != 0:
		return false
	# closing the list without picking leaves everything as is
	game.close_pickup_select()
	if game.state != "playing" or game.item_count != 0 or game.litter.size() != 12:
		return false
	# reopen and confirm -> picks all of the selected kind at once
	game.try_pick_litter()
	if game.state != "pickup_select":
		return false
	game.confirm_pickup_selection()
	if game.state != "playing" or game.item_count != 2 or game.litter.size() != 10:
		return false
	if int(game.item_inventory.get(String(pickup_item["kind"]), 0)) != 2:
		return false
	if game.total_collected_items() != 2:
		return false
	# single item in reach -> direct pickup, no list
	game.player_position = Vector2(4.5, 3.5)
	game.try_pick_litter()
	if game.state != "playing" or game.item_count != 3 or int(game.item_inventory.get("plastic wrapper", 0)) != 1:
		return false
	game.open_craft_table()
	if game.state != "crafting":
		return false
	var first_visible: Array = game.craft_visible_elements()
	if first_visible.size() != 2 or first_visible[0] != game.bottle_sources.size() or first_visible[1] != game.bottle_sources.size() + 1:
		return false
	if game.craft_element_kind(first_visible[0]) != "leaves" or game.craft_element_kind(first_visible[1]) != "plastic wrapper":
		return false
	game.close_craft_table()
	for source_data in game.bottle_sources:
		if String(source_data["kind"]) == "dustbin":
			dustbin = source_data
	var dustbin_position := Vector2(dustbin["cell"]) + Vector2(0.5, 0.5)
	var dustbin_charges := int(dustbin["charges"])
	game.player_position = dustbin_position
	game.search_bottle_source()
	if game.bottle_count != int(dustbin["bottles"]) or int(dustbin["charges"]) != dustbin_charges - 1:
		return false
	if int(game.bottle_inventory.get("dustbin", 0)) != game.bottle_count:
		return false
	game.open_craft_table()
	var dustbin_visible: Array = game.craft_visible_elements()
	if game.state != "crafting" or dustbin_visible.size() != 3 or dustbin_visible[0] != 0:
		return false
	game.add_craft_element()
	game.add_craft_element()
	game.combine_craft_elements()
	if game.has_life_jacket or game.state != "crafting" or game.craft_slots.size() != 2 or game.bottle_count != 2:
		return false
	game.close_craft_table()
	for source_data in game.bottle_sources:
		var source: Dictionary = source_data
		game.bottle_inventory[String(source["kind"])] = 2
	game.bottle_count = game.LIFE_JACKET_BOTTLES
	game.open_craft_table()
	var all_visible: Array = game.craft_visible_elements()
	if all_visible.size() != game.bottle_sources.size() + 2:
		return false
	for slot_index in range(game.LIFE_JACKET_BOTTLES):
		game.craft_selected = slot_index % game.bottle_sources.size()
		game.add_craft_element()
	if game.craft_slots.size() != game.LIFE_JACKET_BOTTLES:
		return false
	game.combine_craft_elements()
	if not game.has_life_jacket or game.state != "playing" or game.bottle_count != 0 or not game.craft_slots.is_empty() or game.life_jacket_on_ground:
		return false
	var drop_position: Vector2 = game.player_position
	game.toggle_life_jacket()
	if game.has_life_jacket or not game.life_jacket_on_ground or game.life_jacket_position != drop_position:
		return false
	if game.can_occupy(water_position, 0.22):
		return false
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
	if not game.can_occupy(water_position, 0.22):
		return false
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.level_index != 1 or game.level_name != "FACETED DEPTHS":
		return false
	# jacket is bottles-only: debris cannot be added, combine needs 8 bottles
	game.load_level(0)
	game.bottle_inventory["dustbin"] = 4
	game.item_inventory["leaves"] = 4
	game.bottle_count = 4
	game.open_craft_table()
	for slot_index in range(4):
		game.craft_selected = 0
		game.add_craft_element()
	if game.craft_slots.size() != 4:
		return false
	game.craft_selected = 1
	game.add_craft_element()
	if game.craft_slots.size() != 4:
		return false
	game.combine_craft_elements()
	if game.has_life_jacket or game.state != "crafting" or game.craft_slots.size() != 4:
		return false
	game.bottle_inventory["dustbin"] = 8
	game.bottle_count = 8
	game.craft_slots.clear()
	for slot_index in range(8):
		game.craft_selected = 0
		game.add_craft_element()
	if game.craft_slots.size() != game.LIFE_JACKET_BOTTLES:
		return false
	game.combine_craft_elements()
	if not game.has_life_jacket or game.bottle_count != 0 or int(game.item_inventory.get("leaves", 0)) != 4:
		return false
	# fishing catcher recipe: Tab to it, add its materials, build
	game.load_level(0)
	game.item_inventory["rope"] = 2
	game.item_inventory["wood scrap"] = 1
	game.item_inventory["plastic wrapper"] = 1
	game.item_inventory["coiled spring"] = 1
	game.open_craft_table()
	game.switch_recipe(1)
	if game.recipe_index != 1:
		return false
	# Tab cycles: switch again from the last recipe wraps back to the first
	game.switch_recipe(1)
	if game.recipe_index != 0:
		return false
	game.switch_recipe(1)
	if game.recipe_index != 1:
		return false
	var cat_visible: Array = game.craft_visible_elements()
	for need_kind in ["rope", "wood scrap", "plastic wrapper", "coiled spring"]:
		var pos := -1
		for i in range(cat_visible.size()):
			if game.craft_element_kind(cat_visible[i]) == need_kind:
				pos = i
		if pos < 0:
			return false
		game.craft_selected = pos
		var need_count: int = game.recipe_needs(1)[need_kind]
		for add_i in range(need_count):
			game.add_craft_element()
	if game.craft_slots.size() != 5:
		return false
	game.combine_craft_elements()
	if not game.has_fishing_catcher or game.state != "playing":
		return false
	if int(game.item_inventory.get("rope", 0)) != 0:
		return false
	game.load_level(0)
	if game.has_life_jacket:
		return false
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	return game.level_index == 1 and game.level_name == "FACETED DEPTHS"

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
