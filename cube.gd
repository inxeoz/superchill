extends Node2D

const SPEED := 240.0
const HALF_SIZE := 24.0

func _ready() -> void:
	position = get_viewport_rect().size * 0.5

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction.length_squared() > 0.0:
		position += direction.normalized() * SPEED * delta
		var viewport := get_viewport_rect().size
		position.x = clampf(position.x, HALF_SIZE, viewport.x - HALF_SIZE)
		position.y = clampf(position.y, HALF_SIZE, viewport.y - HALF_SIZE)

func _draw() -> void:
	var cube := Rect2(-HALF_SIZE, -HALF_SIZE, HALF_SIZE * 2.0, HALF_SIZE * 2.0)
	draw_rect(cube, Color(0.20, 0.72, 0.92), true)
	draw_rect(cube, Color(0.80, 0.96, 1.0), false, 3.0)
	draw_rect(Rect2(-HALF_SIZE + 6.0, -HALF_SIZE + 6.0, 12.0, 12.0), Color(1.0, 1.0, 1.0, 0.75), true)
