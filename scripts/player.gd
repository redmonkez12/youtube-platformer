extends CharacterBody2D

const GRAVITY: float = 690.0
const RUN_SPEED: float = 120.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum State { IDLE, RUN }
var current_state: State = State.IDLE
var new_state: State

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	get_input()
	update_animation()
	move_and_slide()
	
func get_input() -> void:
	var horizontal_input = Input.get_axis("move_left", "move_right")

	velocity.x = RUN_SPEED * horizontal_input

	if not is_equal_approx(velocity.x, 0.0):
		animated_sprite_2d.flip_h = velocity.x < 0

func update_animation() -> void:
	if is_on_floor():
		if abs(velocity.x) > 10:
			new_state = State.RUN
		else:
			new_state = State.IDLE
			
	if new_state != current_state:
		current_state = new_state
		match current_state:
			State.IDLE:
				animated_sprite_2d.play("idle")
			State.RUN:
				animated_sprite_2d.play("run")
