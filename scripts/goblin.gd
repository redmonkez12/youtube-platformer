# GoblinWalking.gd - Simple walking AI with cliff detection tutorial
extends CharacterBody2D

enum FACING { RIGHT = 1, LEFT = -1}

# Movement constants
const GRAVITY: float = 690.0
const WALK_SPEED: float = 60.0

# Node references
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Movement variables
var _facing: int = FACING.RIGHT
var start_position: Vector2

# Cooldown to prevent rapid direction changes
var turn_cooldown: float = 0.0
const TURN_COOLDOWN_TIME: float = 0.5

# Simple states for animation
enum State { WALK }
var current_state: State = State.WALK

func _ready() -> void:
	# Remember starting position
	start_position = global_position
	
	# Set raycast to detect platforms (layer 1)
	ray_cast_2d.enabled = true
	ray_cast_2d.collision_mask = 1  # Layer 1 where platforms are
	
	# Position raycast correctly based on initial facing direction
	var raycast_distance = 25
	ray_cast_2d.position.x = raycast_distance * _facing
	ray_cast_2d.target_position = Vector2(0, 30)  # Point downward to detect ground
	
	ray_cast_2d.force_raycast_update()
	
	# Start walking animation
	if animated_sprite_2d and animated_sprite_2d.sprite_frames:
		animated_sprite_2d.play("walk")

func _physics_process(delta: float) -> void:
	# Update turn cooldown
	if turn_cooldown > 0:
		turn_cooldown -= delta
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	# Handle walking movement
	handle_walking()
	
	# Move the goblin
	move_and_slide()
	
	# Check for obstacles after moving (only if cooldown is finished)
	if turn_cooldown <= 0:
		check_for_obstacles()
	
	# Update animations
	update_animation()
	
	# Force redraw for debug visualization
	queue_redraw()

func handle_walking() -> void:
	# Move horizontally based on facing direction
	velocity.x = WALK_SPEED * _facing

func check_for_obstacles() -> void:
	# Only check when on the ground
	if not is_on_floor():
		return
	
	# Check for cliff - if raycast is NOT colliding, there's no ground ahead
	if not ray_cast_2d.is_colliding():
		flip_direction()

func flip_direction() -> void:
	# Start cooldown to prevent rapid direction changes
	turn_cooldown = TURN_COOLDOWN_TIME
	
	# Flip the facing direction first
	_facing *= -1
	
	# Update sprite flip
	animated_sprite_2d.flip_h = (_facing == FACING.LEFT)
	
	# Move the raycast to the new front - FIXED POSITIONING
	var raycast_distance = 25  # Distance from center to edge
	ray_cast_2d.position.x = raycast_distance * _facing
	
	# Force raycast update after repositioning
	ray_cast_2d.force_raycast_update()

func update_animation() -> void:
	# Just keep playing the walk animation
	if not animated_sprite_2d.is_playing():
		animated_sprite_2d.play("walk")

# Debug visualization
func _draw() -> void:
	if ray_cast_2d and ray_cast_2d.enabled:
		# Get the actual world positions
		var ray_start = ray_cast_2d.global_position
		var ray_end = ray_start + ray_cast_2d.target_position
		
		# Convert to local coordinates for drawing
		var local_start = to_local(ray_start)
		var local_end = to_local(ray_end)
		
		# Draw the raycast line
		var line_color = Color.GREEN if ray_cast_2d.is_colliding() else Color.RED
		draw_line(local_start, local_end, line_color, 2.0)
		
		# Draw a dot at the collision point if hitting something
		if ray_cast_2d.is_colliding():
			var collision_point = to_local(ray_cast_2d.get_collision_point())
			draw_circle(collision_point, 3.0, Color.YELLOW)
		
		# Draw direction indicator
		var direction_pos = Vector2(_facing * 20, -30)
		draw_circle(direction_pos, 5.0, Color.BLUE)
		
		# Debug text with more info
		var debug_text = "Facing: " + ("LEFT" if _facing == FACING.LEFT else "RIGHT")
		debug_text += "\nRaycast Hit: " + str(ray_cast_2d.is_colliding())
		debug_text += "\nCooldown: " + str(turn_cooldown)
		
		var font = ThemeDB.fallback_font
		var lines = debug_text.split("\n")
		for i in range(lines.size()):
			draw_string(font, Vector2(-50, -60 + i * 15), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
