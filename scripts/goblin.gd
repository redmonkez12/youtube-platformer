# GoblinWalking.gd - Simple walking AI with cliff detection tutorial
extends CharacterBody2D

enum FACING { RIGHT = 1, LEFT = -1}  # Opraveno: RIGHT = 1, LEFT = -1

# Movement constants
const GRAVITY: float = 690.0
const WALK_SPEED: float = 60.0

# Node references
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Movement variables
var _facing: int = FACING.RIGHT  # Začínáme doprava
var start_position: Vector2

# Cooldown to prevent rapid direction changes
var turn_cooldown: float = 0.0
const TURN_COOLDOWN_TIME: float = 0.5  # Half second cooldown

# Simple states for animation
enum State { IDLE, WALK }
var current_state: State = State.WALK

func _ready() -> void:
	# Remember starting position
	start_position = global_position
	
	# Set raycast to detect platforms (layer 1)
	#ray_cast_2d.enabled = true
	#ray_cast_2d.collision_mask = 1
	#ray_cast_2d.force_raycast_update()
	
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
	
	var should_turn = false
	var turn_reason = ""
	
	# Check for walls first (higher priority)
	if is_on_wall():
		should_turn = true
		turn_reason = "Hit wall"
	# Only check for cliff if not hitting a wall
	elif not ray_cast_2d.is_colliding():
		should_turn = true
		turn_reason = "No ground ahead"
	
	# Turn around if needed
	if should_turn:
		print(turn_reason + " - turning around")
		flip_direction()

func flip_direction() -> void:
	# Start cooldown to prevent rapid direction changes
	turn_cooldown = TURN_COOLDOWN_TIME
	
	# Flip the facing direction first
	_facing *= -1
	
	# Update sprite flip
	animated_sprite_2d.flip_h = (_facing == FACING.LEFT)
	
	# Move the raycast to the new front
	ray_cast_2d.position.x = abs(ray_cast_2d.position.x) * _facing
	
	print("Goblin turned around, now facing: ", "left" if _facing == FACING.LEFT else "right")

func update_animation() -> void:
	# Simple animation logic
	if abs(velocity.x) > 5.0:
		if current_state != State.WALK:
			current_state = State.WALK
			animated_sprite_2d.play("walk")
	else:
		if current_state != State.IDLE:
			current_state = State.IDLE
			animated_sprite_2d.play("idle")

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
		draw_line(local_start, local_end, Color.RED, 2.0)
		
		# Draw a dot at the collision point if hitting something
		if ray_cast_2d.is_colliding():
			var collision_point = to_local(ray_cast_2d.get_collision_point())
			draw_circle(collision_point, 3.0, Color.GREEN)
		
		# Draw direction indicator
		var direction_pos = Vector2(_facing * 20, -30)
		draw_circle(direction_pos, 5.0, Color.BLUE)
		
		# Debug text
		var debug_text = "Facing: " + ("LEFT" if _facing == FACING.LEFT else "RIGHT")
		var font = ThemeDB.fallback_font
		draw_string(font, Vector2(-30, -40), debug_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
