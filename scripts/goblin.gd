# GoblinWalking.gd - Simple walking AI with cliff detection tutorial
extends CharacterBody2D

# Movement constants
const GRAVITY: float = 690.0
const WALK_SPEED: float = 60.0

# Node references
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Movement variables
var _facing: int = 1  # 1 for right, -1 for left
var start_position: Vector2

# Simple states for animation
enum State { IDLE, WALK }
var current_state: State = State.WALK

func _ready() -> void:
	# Remember starting position
	start_position = global_position
	
	# Start walking animation
	if animated_sprite_2d and animated_sprite_2d.sprite_frames:
		animated_sprite_2d.play("walk")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	# Handle walking movement
	handle_walking()
	
	# Move the goblin
	move_and_slide()
	
	# Check for obstacles after moving
	check_for_obstacles()
	
	# Update animations
	update_animation()

func handle_walking() -> void:
	# Move horizontally based on facing direction
	velocity.x = WALK_SPEED * _facing

func check_for_obstacles() -> void:
	# Only check when on the ground
	if not is_on_floor():
		return
	
	# Check for walls or cliffs
	var should_turn = false
	
	# Hit a wall
	if is_on_wall():
		print("Hit wall - turning around")
		should_turn = true
	
	# No ground ahead (cliff detection)
	elif not ray_cast_2d.is_colliding():
		print("No ground ahead - turning around")
		should_turn = true
	
	# Turn around if needed
	if should_turn:
		flip_direction()

func flip_direction() -> void:
	# Flip the facing direction
	_facing *= -1
	
	# Flip the sprite
	animated_sprite_2d.flip_h = (_facing < 0)
	
	# Move the raycast to the new front
	ray_cast_2d.position.x *= -1
	
	print("Goblin turned around, now facing: ", "left" if _facing < 0 else "right")

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

# Optional: Debug visualization (remove for final version)
func _draw() -> void:
	if ray_cast_2d and ray_cast_2d.enabled:
		# Draw the raycast line for debugging
		var start_pos = ray_cast_2d.position
		var end_pos = start_pos + ray_cast_2d.target_position
		draw_line(start_pos, end_pos, Color.RED, 2.0)
		
		# Draw a dot at the collision point if hitting something
		if ray_cast_2d.is_colliding():
			var collision_point = ray_cast_2d.get_collision_point() - global_position
			draw_circle(collision_point, 3.0, Color.GREEN)
