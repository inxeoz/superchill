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
	for level_index in range(game.LEVELS.size()):
		var valid := false
		if level_index == 0:
			valid = validate_surface_level()
		elif level_index == radio_level_index():
			valid = validate_radio_level()
		elif level_index == desert_level_index():
			valid = validate_desert_level()
		elif level_index == grassland_level_index():
			valid = validate_distract_level()
		elif level_index == game.LEVELS.size() - 2:
			valid = validate_jungle_level()
		elif level_index == game.LEVELS.size() - 1:
			valid = validate_night_jungle_level()
		else:
			valid = validate_dungeon_level(level_index)
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
	if game.level_index != radio_level_index() or game.state != "playing" or game.level_theme != "radio_jungle":
		quit(1)
		return
	# The radio level is crossed by helicopter; the old jungle chain continues from itself.
	game.load_level(game.LEVELS.size() - 2)
	# Cross the old jungle into the night jungle.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.level_index != game.LEVELS.size() - 1 or game.state != "playing" or game.level_theme != "night_jungle":
		quit(1)
		return
	# Without the fire mashal the night exit stays sealed.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.state != "playing" or game.level_index != game.LEVELS.size() - 1:
		quit(1)
		return
	# The material spirits must be collected before the night recipes open.
	for spirit in game.spirits:
		game.player_position = spirit["position"]
		if not game.try_collect_spirit():
			quit(1)
			return
	if not game.unlocked_ideas.has("flint_stone") or not game.unlocked_ideas.has("wood") or not game.unlocked_ideas.has("leaves"):
		quit(1)
		return
	# Without the mashal the deepest point is fatally dark.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	if game.night_darkness() < game.NIGHT_LOST_THRESHOLD:
		quit(1)
		return
	var health_before_dark: int = game.health
	game.update_night_darkness(game.NIGHT_DARKNESS_INTERVAL)
	if game.health != health_before_dark - 1:
		quit(1)
		return
	# Craft the fire mashal from wood, flint stone and leaves.
	game.item_inventory["wood"] = 1
	game.item_inventory["flint stone"] = 1
	game.item_inventory["leaves"] = 2
	game.open_craft_table()
	var mashal_visible: Array = game.craft_visible_elements()
	var mashal_pos := -1
	for i in range(mashal_visible.size()):
		if game.craft_element_kind(mashal_visible[i]) == "flint stone":
			mashal_pos = i
	if mashal_pos < 0 or game.recipe_index_for_id("fire_mashal") < 0:
		quit(1)
		return
	game.craft_selected = mashal_pos
	game.refresh_recipe_index()
	if game.recipe_index != game.recipe_index_for_id("fire_mashal"):
		quit(1)
		return
	game.build_selected()
	if not game.has_fire_mashal or game.state != "playing" or int(game.item_inventory.get("wood", 0)) != 0:
		quit(1)
		return
	# The mashal holds the night back: darkness stays below the fatal line.
	if game.night_darkness() >= game.NIGHT_LOST_THRESHOLD:
		quit(1)
		return
	# The mashal is wearable gear: drop it and the night returns.
	game._drop_gear("fire_mashal")
	if game.has_fire_mashal or not game.fire_mashal_on_ground or int(game.item_inventory.get("fire mashal", 0)) != 0:
		quit(1)
		return
	if game.night_darkness() < game.NIGHT_LOST_THRESHOLD:
		quit(1)
		return
	# Walk back onto it and the gear key picks it up again.
	game.player_position = game.fire_mashal_position
	game.handle_gear_key()
	if not game.has_fire_mashal or game.fire_mashal_on_ground or int(game.item_inventory.get("fire mashal", 0)) != 1:
		quit(1)
		return
	# Like the sword or gun, the mashal can be set as the main gear.
	if not game._is_weapon("fire_mashal") or game.active_weapon != "fire_mashal":
		quit(1)
		return
	if game.night_darkness() >= game.NIGHT_LOST_THRESHOLD:
		quit(1)
		return
	# A secondary mashal loses its light: switch the sword to primary and the
	# darkness returns, sealing the exit again.
	game.handle_gear_key()
	var sword_menu_index: int = game.drop_gear_ids.find("sword")
	if sword_menu_index < 0 or game.state != "drop_select":
		quit(1)
		return
	game.drop_selected = sword_menu_index
	game.set_main_gear()
	game.close_drop_select()
	if game.active_weapon != "sword" or game.night_darkness() < game.NIGHT_LOST_THRESHOLD:
		quit(1)
		return
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.state != "playing" or game.level_index != game.LEVELS.size() - 1:
		quit(1)
		return
	# Set the mashal back as primary: the light returns and the crossing opens.
	game.handle_gear_key()
	var mashal_menu_index: int = game.drop_gear_ids.find("fire_mashal")
	if mashal_menu_index < 0 or game.state != "drop_select":
		quit(1)
		return
	game.drop_selected = mashal_menu_index
	game.set_main_gear()
	game.close_drop_select()
	if game.active_weapon != "fire_mashal" or game.night_darkness() >= game.NIGHT_LOST_THRESHOLD:
		quit(1)
		return
	# With light in hand the deepest crossing completes the level.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.state != "won":
		quit(1)
		return
	if not validate_hard_reset():
		quit(1)
		return
	if not validate_drop_select():
		quit(1)
		return
	if not validate_throw_item():
		quit(1)
		return
	if not validate_shotgun():
		quit(1)
		return
	if not validate_gear_switch():
		quit(1)
		return
	if not validate_jungle_craft():
		quit(1)
		return
	if not validate_jungle_shovel():
		quit(1)
		return
	if not validate_fishing_catcher():
		quit(1)
		return
	if not validate_occlusion_reveal():
		quit(1)
		return
	print("game_test: ok")
	quit(0)

func radio_level_index() -> int:
	for index in range(game.LEVELS.size()):
		if String(game.LEVELS[index].get("theme", "")) == "radio_jungle":
			return index
	return -1

func desert_level_index() -> int:
	for index in range(game.LEVELS.size()):
		if String(game.LEVELS[index].get("theme", "")) == "desert_storm":
			return index
	return -1

func grassland_level_index() -> int:
	for index in range(game.LEVELS.size()):
		if String(game.LEVELS[index].get("theme", "")) == "grassland":
			return index
	return -1

func validate_distract_level() -> bool:
	var level := grassland_level_index()
	if level < 0:
		return false
	game.load_level(level)
	if game.level_index != level or game.level_kind != "surface" or game.level_theme != "grassland":
		return false
	if game.walkable.is_empty() or not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	# Two beasts guard the meadow: one roams, one waits at the exit.
	var roamer: Dictionary = {}
	var ambusher: Dictionary = {}
	for enemy in game.enemies:
		if String(enemy.get("role", "")) == "roamer":
			roamer = enemy
		elif String(enemy.get("role", "")) == "ambusher":
			ambusher = enemy
	if roamer.is_empty() or ambusher.is_empty():
		return false
	if ambusher["home"].distance_to(Vector2(game.exit_cell) + Vector2(0.5, 0.5)) > 0.01:
		return false
	# The spirit unlocks the noise-maker recipe, not before.
	if game.recipe_index_for_id("noise_maker") < 0:
		return false
	if game.recipe_available(game.recipe_index_for_id("noise_maker")):
		return false
	for spirit in game.spirits:
		game.player_position = spirit["position"]
		if not game.try_collect_spirit():
			return false
	if not game.unlocked_ideas.has("noise_maker"):
		return false
	if not game.recipe_available(game.recipe_index_for_id("noise_maker")):
		return false
	# Craft it from a bottle, a pebble and a rope.
	game.item_inventory["pebble"] = 1
	game.item_inventory["rope"] = 1
	game.bottle_count = 1
	game.open_craft_table()
	var recipe_i: int = game.recipe_index_for_id("noise_maker")
	game.craft_selected = 0
	game.recipe_index = recipe_i
	game.build_selected()
	if not game.has_noise_maker or game.state != "playing":
		return false
	if int(game.item_inventory.get("pebble", 0)) != 0 or int(game.item_inventory.get("rope", 0)) != 0 or game.bottle_count != 0:
		return false
	# A beast that reaches the player is a guaranteed kill: game over, no buffer.
	var bite_beast: Dictionary = {
		"position": game.player_position + Vector2(0.3, 0.0),
		"kind": "roamer",
		"role": "roamer",
		"health": game.BEAST_HEALTH,
		"speed": game.ROAMER_SPEED,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
		"chase": 0.0,
		"mode": "roam",
		"home": game.player_position,
		"home_flow": {},
		"roam_target": Vector2.ZERO,
	}
	game.enemies.clear()
	game.enemies.append(bite_beast)
	game.update_enemies(0.1)
	if game.state != "lost" or game.health != 0:
		return false
	# Detection: a clear line chases (full speed) and a blocked line does not.
	if not game.beast_can_see(Vector2i(5, 5), Vector2i(5, 8), false):
		return false
	if game.sight_visible_fraction(Vector2i(5, 5), Vector2i(5, 8)) < game.BEAST_SIGHT_CHASE:
		return false
	# Hysteresis: once hunting, a marginally-blocked line (visible fraction under
	# the fresh-spot threshold but over the keep threshold) still holds the chase.
	var edge_seen: float = game.sight_visible_fraction(Vector2i(5, 5), Vector2i(5, 8))
	if game.beast_can_see(Vector2i(5, 5), Vector2i(5, 8), true) and edge_seen < game.BEAST_SIGHT_KEEP:
		return false
	game.load_level(grassland_level_index())
	# A shot of the sight check: with a solid prop dropped between the beast and
	# the player, at least one sample must read blocked.
	var blocked_seen := false
	if game.walkable.has(Vector2i(5, 6)):
		var was_solid: bool = game.solid_cells.has(Vector2i(5, 6))
		game.solid_cells[Vector2i(5, 6)] = true
		blocked_seen = game.sight_visible_fraction(Vector2i(5, 5), Vector2i(5, 8)) < 1.0
		if not was_solid:
			game.solid_cells.erase(Vector2i(5, 6))
	if not blocked_seen:
		return false
	# Charging and releasing a throw lands the noise and lures both beasts: they
	# stop chasing the player and head for the sound instead.
	game.player_position = Vector2(6.5, 8.5)
	game.player_facing = Vector2(1.0, 0.0)
	game.has_noise_maker = true
	game.begin_noise_throw()
	if not game.throwing_noise:
		return false
	game.update_noise(game.THROW_CHARGE_TIME)
	if game.noise_throw_distance() <= game.THROW_MIN_RANGE:
		return false
	game.release_noise_throw()
	if game.has_noise_maker or game.noise_timer <= 0.0 or game.noise_flow.is_empty():
		return false
	var noise_before: Vector2 = game.noise_position
	game.enemies.clear()
	# Put the player off the beast -> noise lane, then spawn the beasts on the
	# noise's row so the lure carries them straight to the sound.
	game.player_position = Vector2(6.5, 10.5)
	var lure_spawn := Vector2(5.5, 8.5)
	for role in ["roamer", "ambusher"]:
		game.enemies.append({
			"position": lure_spawn,
			"kind": role,
			"role": role,
			"health": game.BEAST_HEALTH,
			"speed": game.ROAMER_SPEED,
			"hit_flash": 0.0,
			"attack_cooldown": 0.0,
			"phase": 0.0,
			"chase": 0.0,
			"mode": "roam",
			"home": Vector2(game.exit_cell) + Vector2(0.5, 0.5),
			"home_flow": {},
			"roam_target": Vector2.ZERO,
		})
	var start_distance: float = game.enemies[0]["position"].distance_to(noise_before)
	game.update_enemies(0.5)
	if String(game.enemies[0]["mode"]) != "lured" or String(game.enemies[1]["mode"]) != "lured":
		return false
	if game.enemies[0]["position"].distance_to(noise_before) >= start_distance:
		return false
	# Given time, both beasts leave the player and gather at the noise itself.
	for step in range(80):
		game.update_enemies(0.1)
	if game.enemies[0]["position"].distance_to(noise_before) > 1.3 or game.enemies[1]["position"].distance_to(noise_before) > 1.3:
		return false
	# Once the noise dies the ambusher heads home and the roamer resumes roaming.
	game.noise_timer = 0.0
	game.noise_flow.clear()
	game.player_position = Vector2(0.5, 0.5)
	game.enemies[1]["position"] = game.enemies[1]["home"] + Vector2(3.0, 0.0)
	game.enemies[1]["home_flow"] = game.build_flow_from(game.cell_at(game.enemies[1]["home"]))
	game.update_beast(game.enemies[0], 0.1)
	if String(game.enemies[0]["mode"]) != "roam":
		return false
	game.update_beast(game.enemies[1], 0.1)
	if String(game.enemies[1]["mode"]) != "return":
		return false
	# Reaching the exit moves on to the next level.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	return game.state == "playing" and game.level_index == level + 1

func validate_desert_level() -> bool:
	var desert_index := desert_level_index()
	if desert_index < 0:
		return false
	game.load_level(desert_index)
	if game.level_index != desert_index or game.level_kind != "surface" or game.level_theme != "desert_storm" or game.map_rows.size() != 18:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	if game.water_cells.size() != 0 or not game.shards.is_empty() or not game.bottle_sources.is_empty():
		return false
	for row in game.map_rows:
		if String(row).length() != 30:
			return false
	# A sparse desert: a few trees, plenty of rocks, old bones.
	if game.tree_cells.size() < 2 or game.tree_cells.size() > 8:
		return false
	if game.stone_cells.size() < 8 or game.skeleton_cells.size() < 3:
		return false
	for stone_cell: Vector2i in game.stone_cells:
		if not game.walkable.has(stone_cell) or not game.solid_cells.has(stone_cell):
			return false
		if game.can_occupy(Vector2(stone_cell) + Vector2(0.5, 0.5), 0.22):
			return false
	for skeleton_cell: Vector2i in game.skeleton_cells:
		if not game.walkable.has(skeleton_cell) or game.solid_cells.has(skeleton_cell):
			return false
	for tree_cell: Vector2i in game.tree_cells:
		if not game.walkable.has(tree_cell) or not game.solid_cells.has(tree_cell):
			return false
	# Every enemy is a hyena prowling on reachable ground, spawned far from
	# the start so the pack is not on top of the player at the outset.
	if game.enemies.is_empty() or String(game.enemy_kind) != "hyena":
		return false
	for spawn_cell in game.enemy_spawns:
		var sc: Vector2i = spawn_cell
		if not game.walkable.has(sc) or not game.flow.has(sc):
			return false
		if Vector2(sc).distance_to(Vector2(game.start_cell)) < 6.0:
			return false
	for enemy in game.enemies:
		if String(enemy["kind"]) != "hyena":
			return false
		if not game.walkable.has(game.cell_at(enemy["position"])) or not game.flow.has(game.cell_at(enemy["position"])):
			return false
	# Cloth, scrap and glass scatter on reachable, non-solid sand.
	var desert_counts: Dictionary = {}
	var seen_cells: Dictionary = {}
	for item in game.litter:
		var item_cell: Vector2i = game.cell_at(item["position"])
		if not game.walkable.has(item_cell) or game.water_cells.has(item_cell) or game.solid_cells.has(item_cell) or not game.flow.has(item_cell):
			return false
		if seen_cells.has(item_cell):
			return false
		seen_cells[item_cell] = true
		var kind := String(item["kind"])
		desert_counts[kind] = int(desert_counts.get(kind, 0)) + 1
	if int(desert_counts.get("cloth", 0)) < 4 or int(desert_counts.get("metal scrap", 0)) < 2 or int(desert_counts.get("wine glass", 0)) < 2:
		return false
	# Three material spirits, one per goggle ingredient, on unique tiles.
	if game.spirits.size() != 3:
		return false
	var seen_spirits: Dictionary = {}
	for spirit: Dictionary in game.spirits:
		var rid := String(spirit["recipe"])
		if not ["cloth", "metal_scrap", "wine_glass"].has(rid) or seen_spirits.has(rid):
			return false
		seen_spirits[rid] = true
		var sc: Vector2i = game.cell_at(spirit["position"])
		if not game.walkable.has(sc) or game.solid_cells.has(sc) or game.water_cells.has(sc):
			return false
		if sc == game.start_cell or sc == game.exit_cell:
			return false
		if not game.can_occupy(spirit["position"], 0.22):
			return false
	# Without the spirits the goggle materials unlock nothing.
	game.item_inventory["cloth"] = 2
	game.item_inventory["metal scrap"] = 1
	game.item_inventory["wine glass"] = 1
	if not game.recipes_for_item("cloth").is_empty() or game.recipe_for_build_kind("cloth") != -1:
		return false
	# The storm reveals a hyena only once it is inside the sight pool: a
	# nearby hyena becomes a visible, fightable target even without goggles.
	if game.has_desert_goggles or game.goggles_on():
		return false
	if game.storm_visibility_radius() != game.STORM_VISIBILITY_BASE:
		return false
	var far_hyena: Dictionary = {
		"position": game.player_position + Vector2(3.5, 3.5),
		"kind": "hyena",
		"health": 3,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
		"chase": 0.0,
	}
	# Far outside the tiny pool the storm still hides it.
	if game.hyena_revealed(far_hyena):
		return false
	var near_hyena: Dictionary = far_hyena.duplicate()
	near_hyena["position"] = game.player_position + game.player_facing * 0.8
	near_hyena["health"] = 1
	if not game.hyena_revealed(near_hyena):
		return false
	# The revealed hyena can be fought and killed with the sword.
	game.enemies.clear()
	game.enemies.append(near_hyena)
	game.attack_cooldown = 0.0
	game.attack()
	if game.enemies.size() != 0:
		return false
	# The hidden far hyena is still untouchable by the swing.
	game.enemies.clear()
	game.enemies.append(far_hyena)
	game.attack_cooldown = 0.0
	game.attack()
	if game.enemies.size() != 1:
		return false
	# A revealed bite is an ordinary wound: the player can win the fight or
	# be worn down and die.
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position + Vector2(0.4, 0.0),
		"kind": "hyena",
		"health": 3,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
		"chase": 0.0,
	})
	var blind_health_before: int = game.health
	game.update_enemies(0.1)
	if game.state != "playing" or game.health != blind_health_before - 1:
		return false
	var bites := 0
	while game.state == "playing" and bites < 12:
		game.invulnerability = 0.0
		game.enemies[0]["attack_cooldown"] = 0.0
		game.update_enemies(0.1)
		bites += 1
	if game.state != "lost" or game.health != 0:
		return false
	# The exit stays hidden while blinded.
	game.load_level(desert_index)
	# The gate storm guards the exit band: blind inside it there is no
	# visibility at all, and a bite there kills outright.
	var gate_cell := Vector2i((game.STORM_GATE_MIN.x + game.STORM_GATE_MAX.x) / 2, (game.STORM_GATE_MIN.y + game.STORM_GATE_MAX.y) / 2)
	if game.in_gate_storm(Vector2(game.start_cell) + Vector2(0.5, 0.5)):
		return false
	if not game.in_gate_storm(Vector2(game.exit_cell) + Vector2(0.5, 0.5)):
		return false
	if not game.in_gate_storm(Vector2(gate_cell) + Vector2(0.5, 0.5)):
		return false
	game.player_position = Vector2(gate_cell) + Vector2(0.5, 0.5)
	if not game.gate_storm_blind() or game.storm_visibility_radius() != 0.0:
		return false
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position + Vector2(0.3, 0.0),
		"kind": "hyena",
		"health": 3,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
		"chase": 0.0,
	})
	if game.hyena_revealed(game.enemies[0]):
		return false
	game.update_enemies(0.1)
	if game.state != "lost" or game.health != 0:
		return false
	game.load_level(desert_index)
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	if game.state != "playing" or game.level_index != desert_index:
		return false
	# Collect the spirits: the goggle idea opens.
	for spirit in game.spirits:
		game.player_position = spirit["position"]
		if not game.try_collect_spirit():
			return false
	if not game.unlocked_ideas.has("cloth") or not game.unlocked_ideas.has("metal_scrap") or not game.unlocked_ideas.has("wine_glass"):
		return false
	# Craft the goggles from the three storm materials.
	var goggles_recipe: int = game.recipe_index_for_id("desert_goggles")
	if goggles_recipe < 0 or not game.recipe_available(goggles_recipe):
		return false
	game.item_inventory["cloth"] = 2
	game.item_inventory["metal scrap"] = 1
	game.item_inventory["wine glass"] = 1
	game.open_craft_table()
	var craft_visible: Array = game.craft_visible_elements()
	var cloth_pos := -1
	for i in range(craft_visible.size()):
		if game.craft_element_kind(craft_visible[i]) == "cloth":
			cloth_pos = i
	if cloth_pos < 0:
		return false
	game.craft_selected = cloth_pos
	game.refresh_recipe_index()
	if game.recipe_index != goggles_recipe:
		return false
	game.build_selected()
	if not game.has_desert_goggles or game.state != "playing" or game.active_weapon != "sword":
		return false
	# With goggles the gate storm is passable: visibility returns and a bite
	# is an ordinary wound, not an execution.
	game.player_position = Vector2(gate_cell) + Vector2(0.5, 0.5)
	if game.gate_storm_blind() or game.storm_visibility_radius() <= 0.0:
		return false
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position + Vector2(0.3, 0.0),
		"kind": "hyena",
		"health": 3,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
		"chase": 0.0,
	})
	var goggle_health: int = game.health
	game.update_enemies(0.1)
	if game.state != "playing" or game.health != goggle_health - 1:
		return false
	game.invulnerability = 0.0
	if int(game.item_inventory.get("cloth", 0)) != 0 or int(game.item_inventory.get("metal scrap", 0)) != 0 or int(game.item_inventory.get("wine glass", 0)) != 0:
		return false
	# The goggles triple the sight pool and reveal the storm hyenas.
	if not is_equal_approx(game.storm_visibility_radius(), game.STORM_VISIBILITY_BASE * game.STORM_GOGGLE_BOOST):
		return false
	far_hyena["position"] = game.player_position + Vector2(3.5, 3.5)
	if not game.goggles_on() or not game.hyena_revealed(far_hyena):
		return false
	# A revealed hyena can be fought and killed with the sword.
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position + game.player_facing * 0.8,
		"kind": "hyena",
		"health": 1,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
	})
	game.attack_cooldown = 0.0
	game.attack()
	if game.enemies.size() != 0:
		return false
	# A revealed hyena bite is a normal wound, not a hidden death.
	game.enemies.append({
		"position": game.player_position + Vector2(0.4, 0.0),
		"kind": "hyena",
		"health": 3,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
	})
	var health_before: int = game.health
	game.update_enemies(0.1)
	if game.state != "playing" or game.health != health_before - 1:
		return false
	# Hyenas follow the player, and take in speed the longer the player
	# lingers in one place.
	var hunt_spot := Vector2(10.5, 8.5)
	game.player_position = hunt_spot
	game.player_linger = game.HUNT_LINGER_TIME  # the player stood still too long
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position + Vector2(3.5, 3.5),
		"kind": "hyena",
		"health": 3,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
		"chase": 0.0,
	})
	game.update_enemies(0.5)
	var chase_lingering: float = float(game.enemies[0].get("chase", 0.0))
	if chase_lingering <= 0.0:
		return false
	# Keep moving again and the pack's speed bleeds off.
	game.player_linger = 0.0
	game.enemies[0]["chase"] = chase_lingering
	game.enemies[0]["position"] = game.player_position + Vector2(3.5, 3.5)
	game.update_enemies(0.5)
	if float(game.enemies[0].get("chase", 0.0)) >= chase_lingering:
		return false
	# In bite range the attack cooldown holds and the chase loses steam.
	game.enemies[0]["position"] = game.player_position
	game.enemies[0]["attack_cooldown"] = 5.0
	game.update_enemies(0.25)
	if float(game.enemies[0].get("chase", 0.0)) >= chase_lingering:
		return false
	# With goggles worn the exit appears; crossing moves to the next level.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	return game.state == "playing" and game.level_index == desert_index + 1

func validate_occlusion_reveal() -> bool:
	game.load_level(1)
	# The player starts right against the south boundary wall; it must be
	# flagged as occluding so it renders translucent.
	var occluding: Dictionary = game.compute_player_occlusion(game.wall_drawables())
	if occluding.is_empty():
		return false
	# Only the front walls hide the player, not the whole boundary.
	if occluding.size() > 4:
		return false
	return true

func validate_shotgun() -> bool:
	game.load_level(1)
	if not game.has_sword:
		return false
	if game.has_shotgun or game.shotgun_drops.size() != 1:
		return false
	var drop_cell: Vector2i = game.cell_at(game.shotgun_drops[0])
	if not game.walkable.has(drop_cell):
		return false
	# Pick the shotgun up with the gear pickup.
	game.player_position = game.shotgun_drops[0]
	if not game._pickup_gear("shotgun"):
		return false
	if not game.has_shotgun or game.shotgun_drops.size() != 0:
		return false
	# A shotgun blast deals SHOTGUN_DAMAGE (4x the sword) to an enemy ahead.
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position + game.player_facing * 1.5,
		"kind": game.enemy_kind,
		"health": 6,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
	})
	game.attack_cooldown = 0.0
	game.attack()
	if int(game.enemies[0]["health"]) != 6 - game.SHOTGUN_DAMAGE:
		return false
	if game.SHOTGUN_DAMAGE != game.SWORD_DAMAGE * 4:
		return false
	# An enemy behind the player is outside the blast cone.
	game.enemies.clear()
	game.enemies.append({
		"position": game.player_position - game.player_facing * 1.5,
		"kind": game.enemy_kind,
		"health": 6,
		"speed": 1.0,
		"hit_flash": 0.0,
		"attack_cooldown": 0.0,
		"phase": 0.0,
	})
	game.attack_cooldown = 0.0
	game.attack()
	if int(game.enemies[0]["health"]) != 6:
		return false
	# Drop it and pick it back up.
	game._drop_gear("shotgun")
	if game.has_shotgun or game.shotgun_drops.size() != 1:
		return false
	game.player_position = game.shotgun_drops[0]
	if not game._pickup_gear("shotgun"):
		return false
	# Every dungeon level drops a single reachable gun on a walkable cell.
	for level_index in [1, 2, 3, 4]:
		game.load_level(level_index)
		if game.has_shotgun or game.shotgun_drops.size() != 1:
			return false
		if not game.walkable.has(game.cell_at(game.shotgun_drops[0])):
			return false
	# The jungle and night-jungle levels each drop two guns on walkable cells.
	for gun_level_index in [game.LEVELS.size() - 2, game.LEVELS.size() - 1]:
		game.load_level(gun_level_index)
		if game.has_shotgun or game.shotgun_drops.size() != 2:
			return false
		for drop in game.shotgun_drops:
			if not game.walkable.has(game.cell_at(drop)):
				return false
	# Picking one night-jungle gun leaves the other on the ground.
	game.load_level(game.LEVELS.size() - 1)
	game.player_position = game.shotgun_drops[0]
	if not game._pickup_gear("shotgun"):
		return false
	if not game.has_shotgun or game.shotgun_drops.size() != 1:
		return false
	return true

func validate_gear_switch() -> bool:
	game.load_level(1)
	if game.active_weapon != "sword":
		return false
	# Picking up the level's shotgun makes it the main weapon.
	game.player_position = game.shotgun_drops[0]
	if not game._pickup_gear("shotgun"):
		return false
	if game.active_weapon != "shotgun":
		return false
	# ENTER fires the shotgun: it adds a muzzle + pellet burst effect pair.
	game.attack_cooldown = 0.0
	var before_shotgun: int = game.effects.size()
	game.attack()
	if game.effects.size() != before_shotgun + 2:
		return false
	if String(game.effects[game.effects.size() - 1]["kind"]) != "pellets":
		return false
	# Open the gear menu and set SWORD back as the main weapon.
	game.handle_gear_key()
	if game.state != "drop_select":
		return false
	var sword_index := -1
	for i in range(game.drop_gear_ids.size()):
		if String(game.drop_gear_ids[i]) == "sword":
			sword_index = i
	if sword_index < 0:
		return false
	game.drop_selected = sword_index
	game.set_main_gear()
	if game.state != "drop_select" or game.active_weapon != "sword":
		return false
	# Close the menu; ENTER now slashes (a single slash effect).
	game.close_drop_select()
	game.attack_cooldown = 0.0
	var before_slash: int = game.effects.size()
	game.attack()
	if game.effects.size() != before_slash + 1:
		return false
	if String(game.effects[game.effects.size() - 1]["kind"]) != "slash":
		return false
	return true

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

func validate_hard_reset() -> bool:
	game.unlocked_ideas["life_jacket"] = true
	game.unlocked_ideas["fishing_catcher"] = true
	if game.unlocked_ideas.is_empty():
		return false
	game.hard_reset()
	return game.level_index == 0 and game.unlocked_ideas.is_empty() and game.state == "level_select"

func validate_drop_select() -> bool:
	game.load_level(0)
	if not game.has_sword:
		return false
	# The sword is default gear: without it carried, the strike does nothing.
	game.attack_cooldown = 0.0
	var before_no_sword: int = game.effects.size()
	game.has_sword = false
	game.sword_on_ground = true
	game.sword_position = game.player_position
	game.attack()
	if game.effects.size() != before_no_sword:
		return false
	# Stand away so G doesn't auto-pick the sword; nothing worn remains.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.handle_gear_key()
	if game.state != "playing":
		return false
	# Walk onto the dropped sword and press G to re-equip it.
	game.player_position = game.sword_position
	game.handle_gear_key()
	if game.state != "playing" or not game.has_sword or game.sword_on_ground:
		return false
	# Sword re-equipped: the strike adds exactly one slash.
	game.attack_cooldown = 0.0
	var before_sword: int = game.effects.size()
	game.attack()
	if game.effects.size() != before_sword + 1:
		return false
	# Multiple worn gear → the drop dialog lists every wearable.
	game.has_life_jacket = true
	game.has_fishing_catcher = true
	game.handle_gear_key()
	if game.state != "drop_select":
		return false
	var ids: Array = game.drop_gear_ids
	if ids.size() != 3 or String(ids[0]) != "life_jacket" or String(ids[1]) != "fishing_catcher" or String(ids[2]) != "sword":
		return false
	game.confirm_drop_selection()
	return game.state == "playing" and not game.has_life_jacket and game.life_jacket_on_ground and game.has_fishing_catcher and game.has_sword

func press_key(code: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	game._unhandled_input(event)

func find_valid_throw_cell() -> Vector2i:
	var origin: Vector2i = game.cell_at(game.player_position)
	for radius in range(1, int(game.THROW_PLACE_RANGE) + 1):
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				var cell := origin + Vector2i(dx, dy)
				if game.throw_target_valid(cell):
					return cell
	return Vector2i(-1, -1)

func throw_entry_index(kind: String, gear: bool) -> int:
	var entries: Array = game.throw_entries()
	for index in range(entries.size()):
		if String(entries[index]["kind"]) == kind and bool(entries[index]["gear"]) == gear:
			return index
	return -1

func validate_throw_item() -> bool:
	game.load_level(0)
	game.item_inventory["leaves"] = 3
	game.item_inventory["pebble"] = 1
	game.bottle_count = 2
	game.has_life_jacket = true
	# N opens the throw list with both loose items and worn gear.
	press_key(KEY_N)
	if game.state != "throw_select":
		return false
	var leaves_index := throw_entry_index("leaves", false)
	var pebble_index := throw_entry_index("pebble", false)
	var bottle_index := throw_entry_index("empty bottle", false)
	var jacket_index := throw_entry_index("life_jacket", true)
	if leaves_index < 0 or pebble_index < 0 or bottle_index < 0 or jacket_index < 0:
		return false
	# Choosing an item drops into aim mode with the cursor on the player's tile.
	game.throw_selected = leaves_index
	press_key(KEY_ENTER)
	if game.state != "throw_aim":
		return false
	if game.throw_target_cell != game.cell_at(game.player_position):
		return false
	# The cursor steps with the movement keys, camera-relative: yawing with Q/E
	# changes which cell a key selects so the cursor tracks the player's view.
	game.camera_angle = 0.0
	game.throw_target_cell = game.cell_at(game.player_position)
	press_key(KEY_RIGHT)
	var straight_step: Vector2i = game.throw_target_cell - game.cell_at(game.player_position)
	if straight_step == Vector2i.ZERO:
		return false
	game.camera_angle = PI * 0.5
	game.throw_target_cell = game.cell_at(game.player_position)
	press_key(KEY_RIGHT)
	var turned_step: Vector2i = game.throw_target_cell - game.cell_at(game.player_position)
	if turned_step == Vector2i.ZERO or turned_step == straight_step:
		return false
	game.camera_angle = 0.0
	# Throwing onto solid/out-of-range ground is refused.
	game.throw_target_cell = game.cell_at(game.player_position) + Vector2i(100, 100)
	game.throw_item_at_target()
	if game.state != "throw_aim" or int(game.item_inventory["leaves"]) != 3:
		return false
	# A valid landing spot consumes one leaf and drops it there.
	var landing := find_valid_throw_cell()
	if landing.x < 0:
		return false
	game.throw_target_cell = landing
	game.throw_item_at_target()
	if game.state != "playing" or int(game.item_inventory["leaves"]) != 2:
		return false
	var dropped: Dictionary = game.litter[game.litter.size() - 1]
	if String(dropped["kind"]) != "leaves" or not dropped["position"].is_equal_approx(Vector2(landing) + Vector2(0.5, 0.5)):
		return false
	# Worn gear can be thrown too: it leaves the body and lands on the tile.
	press_key(KEY_N)
	if game.state != "throw_select":
		return false
	game.throw_selected = throw_entry_index("life_jacket", true)
	press_key(KEY_ENTER)
	if game.state != "throw_aim" or game.throw_selected < 0:
		return false
	game.throw_target_cell = find_valid_throw_cell()
	game.throw_item_at_target()
	if game.state != "playing" or game.has_life_jacket or not game.life_jacket_on_ground:
		return false
	if not game.life_jacket_position.is_equal_approx(Vector2(game.throw_target_cell) + Vector2(0.5, 0.5)):
		return false
	# ESC backs out of the list without throwing anything.
	press_key(KEY_N)
	if game.state != "throw_select":
		return false
	press_key(KEY_ESCAPE)
	return game.state == "playing"

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
	# The build item is a gift: the collection prompt must never reveal its name.
	for spirit: Dictionary in game.spirits:
		if String(game.spirit_prompt_label(spirit)) != "SPIRIT":
			return false
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
	# One item, many recipes: the player picks which build ENTER makes.
	game.load_level(0)
	game.unlocked_ideas["life_jacket"] = true
	game.unlocked_ideas["fishing_catcher"] = true
	game.bottle_count = 1
	game.item_inventory["rope"] = 1
	game.open_craft_table()
	game.craft_selected = 0  # empty bottles feed two recipes
	game.refresh_recipe_index()
	if game.recipe_index != game.recipe_index_for_id("life_jacket"):
		return false
	# Cycle to the second listed build.
	game.cycle_craft_recipe(1)
	if game.recipe_index != game.recipe_index_for_id("fishing_catcher"):
		return false
	# Number keys jump straight to a listed build.
	game.select_craft_recipe_index(0)
	if game.recipe_index != game.recipe_index_for_id("life_jacket"):
		return false
	# Build the picked catcher to prove the picker drives the craft.
	game.select_craft_recipe_index(1)
	game.build_selected()
	if not game.has_fishing_catcher or game.has_life_jacket or game.state != "playing":
		return false
	if int(game.item_inventory.get("rope", 0)) != 0 or game.bottle_count != 0:
		return false

	game.load_level(0)
	if game.has_life_jacket:
		return false
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	game.update_surface_level()
	return game.level_index == 1 and game.level_name == "FACETED DEPTHS"


func validate_jungle_craft() -> bool:
	var jungle_index: int = game.LEVELS.size() - 2
	game.load_level(jungle_index)
	# The axe rests on reachable land near the start of the jungle level.
	if not game.axe_on_ground or game.has_axe:
		return false
	var axe_cell: Vector2i = game.cell_at(game.axe_position)
	if not game.walkable.has(axe_cell) or game.axe_position.distance_to(Vector2(game.start_cell) + Vector2(0.5, 0.5)) > 2.5:
		return false
	# A spirit of logs sits somewhere on the map beside the fishing-catcher spirit.
	var logs_spirit: Dictionary = {}
	for spirit: Dictionary in game.spirits:
		if String(spirit["recipe"]) == "logs":
			logs_spirit = spirit
	if logs_spirit.is_empty() or game.spirits.size() < 2:
		return false
	# G-style gear pickup equips the axe and makes it the main weapon.
	game.player_position = game.axe_position
	if not game._pickup_gear("axe"):
		return false
	if not game.has_axe or game.axe_on_ground or game.active_weapon != "axe":
		return false
	# The axe is a weapon: it can be set as main gear and dropped/re-equipped.
	if not game._is_weapon("axe"):
		return false
	# Cutting a tree with the axe drops logs and opens the cell.
	var trees_before: int = game.tree_cells.size()
	var tree_cell: Vector2i = game.tree_cells[0]
	game.player_position = Vector2(tree_cell) + Vector2(-0.5, 0.5)
	var effects_after_pickup: int = game.effects.size()
	if not game.try_cut_tree():
		return false
	if game.tree_cells.size() != trees_before - 1 or game.solid_cells.has(tree_cell):
		return false
	if game.effects.size() != effects_after_pickup + 1:
		return false
	var log_count := 0
	for item: Dictionary in game.litter:
		if String(item["kind"]) == "log":
			log_count += 1
	if log_count < 3:
		return false
	# ENTER with the axe near a tree cuts instead of swinging: no strike arc.
	game.attack_cooldown = 0.0
	var effects_before_cut: int = game.effects.size()
	var trees_before_cut: int = game.tree_cells.size()
	game.player_position = Vector2(game.tree_cells[0]) + Vector2(-0.5, 0.5)
	game.attack()
	if game.tree_cells.size() != trees_before_cut - 1 or game.effects.size() != effects_before_cut + 1:
		return false
	# With no tree in reach the axe swings (one slash effect).
	game.attack_cooldown = 0.0
	game.player_position = Vector2(game.start_cell) + Vector2(0.5, 0.5)
	var effects_before_swing: int = game.effects.size()
	game.attack()
	if game.effects.size() != effects_before_swing + 1:
		return false
	if String(game.effects[game.effects.size() - 1]["kind"]) != "slash":
		return false
	# The spirit of logs unlocks both the boat and fire ideas.
	game.player_position = logs_spirit["position"]
	if not game.try_collect_spirit():
		return false
	if not game.unlocked_ideas.has("boat") or not game.unlocked_ideas.has("fire"):
		return false
	# The jungle distributes exactly three ropes.
	game.load_level(jungle_index)
	var rope_total := 0
	for item: Dictionary in game.litter:
		if String(item["kind"]) == "rope":
			rope_total += 1
	if rope_total != 3:
		return false
	# Boat recipe: 3 ropes + 3 logs. Building drops the boat at your feet.
	var boat_index: int = game.recipe_index_for_id("boat")
	if boat_index < 0 or int(game.recipe_needs(boat_index)["rope"]) != 3 or int(game.recipe_needs(boat_index)["log"]) != 3:
		return false
	game.item_inventory["rope"] = 3
	game.item_inventory["log"] = 3
	game.open_craft_table()
	var visible: Array = game.craft_visible_elements()
	var log_pos := -1
	for i in range(visible.size()):
		if game.craft_element_kind(visible[i]) == "log":
			log_pos = i
	if log_pos < 0:
		return false
	game.craft_selected = log_pos
	game.refresh_recipe_index()
	if game.recipe_index != boat_index:
		return false
	game.build_selected()
	if game.state != "playing" or not game.boat_on_ground or game.has_boat:
		return false
	if int(game.item_inventory.get("rope", 0)) != 0 or int(game.item_inventory.get("log", 0)) != 0:
		return false
	# G picks the boat up; worn, the river no longer drowns.
	game.player_position = game.boat_position
	if not game._pickup_gear("boat"):
		return false
	if not game.has_boat or game.boat_on_ground:
		return false
	var health_before: int = game.health
	game.player_position = Vector2(17.5, 8.5)
	game.update_drowning(0.5)
	if game.health != health_before:
		return false
	# Dropping the boat leaves it for G pickup, and the river drowns again.
	game._drop_gear("boat")
	if game.has_boat or not game.boat_on_ground:
		return false
	game.player_position = Vector2(17.5, 8.5)
	game.update_drowning(0.5)
	if game.health != health_before - 1:
		return false
	# Fire builds from a single wood scrap once its idea is unlocked.
	game.load_level(jungle_index)
	game.unlocked_ideas["boat"] = true
	game.unlocked_ideas["fire"] = true
	game.item_inventory["wood scrap"] = 1
	game.open_craft_table()
	visible = game.craft_visible_elements()
	var scrap_pos := -1
	for i in range(visible.size()):
		if game.craft_element_kind(visible[i]) == "wood scrap":
			scrap_pos = i
	if scrap_pos < 0:
		return false
	game.craft_selected = scrap_pos
	game.refresh_recipe_index()
	if game.recipe_index != game.recipe_index_for_id("fire"):
		return false
	game.build_selected()
	return game.has_fire and game.state == "playing" and int(game.item_inventory.get("wood scrap", 0)) == 0

func validate_jungle_shovel() -> bool:
	var jungle_index: int = game.LEVELS.size() - 2
	game.load_level(jungle_index)
	# The shovel rests on reachable land near the start, beside the axe.
	if not game.shovel_on_ground or game.has_shovel:
		return false
	var shovel_cell: Vector2i = game.cell_at(game.shovel_position)
	if not game.walkable.has(shovel_cell) or game.shovel_position.distance_to(Vector2(game.start_cell) + Vector2(0.5, 0.5)) > 3.0:
		return false
	# The shovel spawn tile is kept clear of distributed litter.
	for item: Dictionary in game.litter:
		if game.cell_at(item["position"]) == shovel_cell:
			return false
	# G-style pickup equips it as the main tool; it is gear and a weapon-like main.
	game.player_position = game.shovel_position
	if not game._pickup_gear("shovel"):
		return false
	if not game.has_shovel or game.shovel_on_ground or game.active_weapon != "shovel" or not game._is_weapon("shovel"):
		return false
	# A brown soil tile exists on reachable land.
	var soil_cell := Vector2i(-1, -1)
	for key in game.walkable:
		var cell: Vector2i = key
		if not game.is_soil_cell(cell) or game.water_cells.has(cell) or game.solid_cells.has(cell) or game.spirit_cells.has(cell):
			continue
		if cell == game.start_cell or cell == game.exit_cell:
			continue
		soil_cell = cell
		break
	if soil_cell.x < 0:
		return false
	# Digging works on the tile under the player and fades its color.
	game.player_position = Vector2(soil_cell) + Vector2(0.5, 0.5)
	var dug_color_before: Color = game.floor_color(soil_cell)
	var litter_before: int = game.litter.size()
	var effects_before: int = game.effects.size()
	if not game.try_dig_soil():
		return false
	if not game.dug_cells.has(soil_cell) or not game.is_dug_cell(soil_cell):
		return false
	if game.floor_color(soil_cell) == dug_color_before or game.floor_color(soil_cell).is_equal_approx(dug_color_before):
		return false
	if game.effects.size() != effects_before + 1:
		return false
	# Digging either reveals one of the buried loot kinds or nothing at all.
	if game.litter.size() != litter_before:
		if game.litter.size() != litter_before + 1:
			return false
		var new_item: Dictionary = game.litter[game.litter.size() - 1]
		var loot_kinds := ["rope", "wood scrap", "coiled spring", "leaves", "empty bottle"]
		if not loot_kinds.has(String(new_item["kind"])):
			return false
		if not game.can_occupy(new_item["position"], 0.22):
			return false
	# The same tile cannot be dug twice.
	game.player_position = Vector2(soil_cell) + Vector2(0.5, 0.5)
	if game.diggable_soil_cell() != Vector2i(-1, -1):
		return false
	if game.try_dig_soil():
		return false
	# ENTER with the shovel on another soil tile digs (no strike arc), and it can
	# be dropped for a later G pickup.
	var soil_cell2 := Vector2i(-1, -1)
	for key in game.walkable:
		var cell2: Vector2i = key
		if not game.is_soil_cell(cell2) or game.water_cells.has(cell2) or game.solid_cells.has(cell2):
			continue
		if cell2 == soil_cell or cell2 == game.start_cell or cell2 == game.exit_cell:
			continue
		soil_cell2 = cell2
		break
	if soil_cell2.x >= 0:
		game.attack_cooldown = 0.0
		var effects_before_dig: int = game.effects.size()
		game.player_position = Vector2(soil_cell2) + Vector2(0.5, 0.5)
		game.attack()
		if not game.dug_cells.has(soil_cell2) or game.effects.size() != effects_before_dig + 1:
			return false
	game._drop_gear("shovel")
	return not game.has_shovel and game.shovel_on_ground

func validate_night_jungle_level() -> bool:
	var night_index: int = game.LEVELS.size() - 1
	game.load_level(night_index)
	if game.level_index != night_index or game.level_kind != "surface" or game.level_theme != "night_jungle" or game.map_rows.size() != 19:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if not game.walkable.has(game.exit_cell) or not game.flow.has(game.exit_cell):
		return false
	for row in game.map_rows:
		if String(row).length() != 28:
			return false
	# Dense dark jungle: solid trees on land, growing thicker with the dark.
	if game.tree_cells.size() < 40:
		return false
	for tree_cell: Vector2i in game.tree_cells:
		if not game.walkable.has(tree_cell) or game.water_cells.has(tree_cell):
			return false
		if game.can_occupy(Vector2(tree_cell) + Vector2(0.5, 0.5), 0.22):
			return false
	var shallow_night_trees := 0
	var deep_night_trees := 0
	for tree_cell: Vector2i in game.tree_cells:
		var tree_depth := float(game.night_depth_flow.get(tree_cell, 0)) / float(maxi(1, game.night_exit_distance))
		if tree_depth >= 0.5:
			deep_night_trees += 1
		else:
			shallow_night_trees += 1
	if deep_night_trees <= shallow_night_trees:
		return false
	# Flint, wood and leaves scatter on the jungle floor.
	var night_counts: Dictionary = {}
	for item: Dictionary in game.litter:
		var kind := String(item["kind"])
		night_counts[kind] = int(night_counts.get(kind, 0)) + 1
		if not game.can_occupy(item["position"], 0.22):
			return false
	if int(night_counts.get("flint stone", 0)) < 2 or int(night_counts.get("wood", 0)) < 6 or int(night_counts.get("leaves", 0)) < 10:
		return false
	# The three material spirits sit on reachable land, each on a unique tile.
	if game.spirits.size() != 3:
		return false
	var seen_night_recipes: Dictionary = {}
	for spirit: Dictionary in game.spirits:
		var rid := String(spirit["recipe"])
		if not ["flint_stone", "wood", "leaves"].has(rid) or seen_night_recipes.has(rid):
			return false
		seen_night_recipes[rid] = true
		var sc: Vector2i = game.cell_at(spirit["position"])
		if not game.walkable.has(sc) or game.water_cells.has(sc) or game.solid_cells.has(sc):
			return false
		if sc == game.start_cell or sc == game.exit_cell:
			return false
		if not game.can_occupy(spirit["position"], 0.22):
			return false
	# Until the spirits are collected, the night materials unlock nothing.
	game.item_inventory["flint stone"] = 1
	game.item_inventory["wood"] = 1
	game.item_inventory["leaves"] = 3
	if not game.recipes_for_item("flint stone").is_empty() or not game.recipes_for_item("wood").is_empty():
		return false
	if game.recipe_for_build_kind("wood") != -1:
		return false
	# The deepest point is fatally dark without the mashal.
	game.player_position = Vector2(game.exit_cell) + Vector2(0.5, 0.5)
	return game.night_darkness() >= game.NIGHT_LOST_THRESHOLD

func validate_radio_level() -> bool:
	var radio_index := radio_level_index()
	if radio_index < 0:
		return false
	game.load_level(radio_index)
	if game.level_index != radio_index or game.level_kind != "surface" or game.level_theme != "radio_jungle" or game.map_rows.size() != 18:
		return false
	if game.walkable.is_empty() or game.flow.size() != game.walkable.size():
		return false
	if not game.walkable.has(game.start_cell) or not game.flow.has(game.start_cell):
		return false
	if game.water_cells.size() != 0 or not game.enemies.is_empty() or not game.shards.is_empty():
		return false
	# The night palette stands alone: no dark overlay circles, and no dark damage.
	if game.night_darkness() > 0.02:
		return false
	var health_before_night: int = game.health
	game.update_night_darkness(game.NIGHT_DARKNESS_INTERVAL * 3.0)
	if game.health != health_before_night or game.dark_timer != 0.0:
		return false
	for row in game.map_rows:
		if String(row).length() != 30:
			return false
	# The radio station sits on an unreachable mesa: the exit cell is solid.
	if game.walkable.has(game.exit_cell) or game.station_cell != game.exit_cell:
		return false
	if not game.walkable.has(game.rope_cell):
		return false
	# The cliff base beside the station is reachable on foot.
	var cliff_cell := Vector2i(26, 4)
	if not game.walkable.has(cliff_cell) or not game.flow.has(cliff_cell):
		return false
	if game.solid_cells.size() != game.tree_cells.size():
		return false
	for tree_cell: Vector2i in game.tree_cells:
		if not game.walkable.has(tree_cell) or game.can_occupy(Vector2(tree_cell) + Vector2(0.5, 0.5), 0.22):
			return false
	# Aluminum foil scatters on reachable land.
	var foil_count := 0
	for item: Dictionary in game.litter:
		var item_cell: Vector2i = game.cell_at(item["position"])
		if not game.walkable.has(item_cell) or not game.flow.has(item_cell):
			return false
		if not game.can_occupy(item["position"], 0.22):
			return false
		if String(item["kind"]) == "aluminum foil":
			foil_count += 1
	if foil_count < 3:
		return false
	# The radio receiver rests on land a short walk from the start.
	if not game.receiver_on_ground or game.has_radio_receiver:
		return false
	var receiver_cell: Vector2i = game.cell_at(game.receiver_position)
	if not game.walkable.has(receiver_cell) or not game.flow.has(receiver_cell):
		return false
	if Vector2(receiver_cell).distance_to(Vector2(game.start_cell)) > 6.0:
		return false
	# Carry the receiver: without foil the signal at the cliff is too weak.
	game.player_position = game.receiver_position
	if not game._pickup_gear("radio_receiver"):
		return false
	if not game.has_radio_receiver or game.receiver_on_ground or game.active_weapon != "radio_receiver":
		return false
	if not game._is_weapon("radio_receiver"):
		return false
	game.player_position = Vector2(cliff_cell) + Vector2(0.5, 0.5)
	if game.radio_strength() >= game.RADIO_RECEIVE_THRESHOLD:
		return false
	game.update_surface_level()
	if game.signal_sent:
		return false
	# A foil reflector at the cliff bounces the signal back to the station.
	game.item_inventory["aluminum foil"] = 1
	if not game.try_place_foil():
		return false
	if int(game.item_inventory.get("aluminum foil", 0)) != 0 or game.foil_placed_cells.size() != 1:
		return false
	if game.radio_strength() < game.RADIO_RECEIVE_THRESHOLD:
		return false
	game.update_surface_level()
	if not game.signal_sent:
		return false
	# The receiver can be dropped like any gear.
	game._drop_gear("radio_receiver")
	if game.has_radio_receiver or not game.receiver_on_ground or game.active_weapon == "radio_receiver":
		return false
	# Once the signal is sent the helicopter arrives; the rope exits the level.
	game.elapsed = game.helicopter_start + game.HELICOPTER_FLY_TIME
	if game.helicopter_progress() < 1.0:
		return false
	game.player_position = game.rope_position()
	game._pickup_gear("radio_receiver")
	if not game.try_helicopter_escape():
		return false
	return game.state == "playing" and game.level_index == radio_index + 1

func validate_jungle_level() -> bool:
	game.load_level(game.LEVELS.size() - 2)
	if game.level_index != game.LEVELS.size() - 2 or game.level_kind != "surface" or game.level_theme != "jungle" or game.map_rows.size() != 14:
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

func validate_fishing_catcher() -> bool:
	game.load_level(0)
	# The catcher is a primary item: it survives the active-weapon recompute.
	if not game._is_weapon("fishing_catcher"):
		return false
	game.has_fishing_catcher = true
	game.active_weapon = "fishing_catcher"
	game._recompute_active_weapon()
	if game.active_weapon != "fishing_catcher":
		return false
	# Find a river tile and a walkable bank cell beside it.
	var water_cell := Vector2i(-1, -1)
	var shore_cell := Vector2i(-1, -1)
	for cell in game.water_cells:
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor: Vector2i = cell + offset
			if game.walkable.has(neighbor) and not game.water_cells.has(neighbor) and not game.solid_cells.has(neighbor):
				water_cell = cell
				shore_cell = neighbor
				break
		if shore_cell.x >= 0:
			break
	if shore_cell.x < 0:
		return false
	# Standing on the bank, the water is in reach and a cast can land a fish.
	game.player_position = Vector2(shore_cell) + Vector2(0.5, 0.5)
	if game.nearest_water_cell().x < 0:
		return false
	var caught := false
	for attempt in range(40):
		game.attack_cooldown = 0.0
		if not game.try_catch_fish():
			return false
		if int(game.item_inventory.get("fish", 0)) > 0:
			caught = true
			break
	if not caught:
		return false
	# Away from any water the cast fails outright.
	game.player_position = Vector2(game.start_cell) + Vector2(0.5, 0.5)
	var away_from_water := true
	for cell in game.water_cells:
		if game.player_position.distance_to(Vector2(cell) + Vector2(0.5, 0.5)) <= game.SOURCE_REACH:
			away_from_water = false
			break
	if away_from_water:
		if game.nearest_water_cell().x >= 0 or game.try_catch_fish():
			return false
	# The catcher is not a crossing item: standing in water still drowns.
	game.player_position = Vector2(water_cell) + Vector2(0.5, 0.5)
	if game.crossing_safe():
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
