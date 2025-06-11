extends CharacterBody2D

enum FACING { RIGHT = 1, LEFT = -1 }

const GRAVITY: float = 690.0
const WALK_SPEED: float = 60.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var _facing: int = FACING.RIGHT
var start_position: Vector2

var turn_cooldown: float = 0.0
const TURN_COOLDOWN: float = 0.5

enum State { WALK }
var current_state: State = State.WALK

func _ready() -> void:
	start_position = global_position
	
	ray_cast_2d.enabled = true
	ray_cast_2d.collision_mask = 1
	
	var ray_cast_distance = 25
	ray_cast_2d.position.x = ray_cast_distance * _facing
	ray_cast_2d.target_position = Vector2(0, 30)
	
	ray_cast_2d.force_raycast_update()
	
	if animated_sprite_2d and animated_sprite_2d.sprite_frames:
		animated_sprite_2d.play("walk")
		
func _physics_process(delta: float) -> void:
	if turn_cooldown > 0:
		turn_cooldown -= delta
		
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		
	handle_walking()
	
	move_and_slide()
	
	if turn_cooldown <= 0:
		check_for_obstacles()	
		
	update_animation()
	
	queue_redraw()
	
func handle_walking() -> void:
	velocity.x = WALK_SPEED * _facing
	
	
func check_for_obstacles() -> void:
	if not is_on_floor():
		return
		
	if not ray_cast_2d.is_colliding():
		flip_direction()
		
func update_animation() -> void:
	if not animated_sprite_2d.is_playing():
		animated_sprite_2d.play("walk")
		
func flip_direction() -> void:
	turn_cooldown = TURN_COOLDOWN
	
	_facing *= -1
	
	animated_sprite_2d.flip_h = (_facing == FACING.LEFT)
	
	var raycast_distance = 25
	ray_cast_2d.position.x = raycast_distance * _facing
	
	ray_cast_2d.force_raycast_update()
	
func _draw() -> void:
	if ray_cast_2d and ray_cast_2d.enabled:
		var ray_start = ray_cast_2d.global_position
		var ray_end = ray_start + ray_cast_2d.target_position
		
		var local_start = to_local(ray_start)
		var local_end = to_local(ray_end)
		
		var line_color = Color.GREEN if  ray_cast_2d.is_colliding() else Color.RED
		draw_line(local_start, local_end, line_color, 2.0)
		
		if ray_cast_2d.is_colliding():
			var collision_point = to_local(ray_cast_2d.get_collision_point())
			draw_circle(collision_point, 3.0, Color.YELLOW)
			
		var direction_pos = Vector2(_facing * 20, - 30)
		draw_circle(direction_pos, 5.0, Color.BLUE)
		
		var debug_text = "Facing: " + ("LEFT" if _facing == FACING.LEFT else "RIGHT")
		debug_text = "\nRaycast hit: " + str(ray_cast_2d.is_colliding())
		debug_text += "\nCooldown: " + str(turn_cooldown)
		
		var font = ThemeDB.fallback_font
		var lines = debug_text.split("\n")
		
		for i in range(lines.size()):
			draw_string(font, Vector2(-50, -60 + i * 15), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
