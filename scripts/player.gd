extends CharacterBody2D

const GRAVITY: float = 690.0

enum State { IDLE }
var current_state: State = State.IDLE
var new_state: State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	update_animation()

func update_animation() -> void:
	if is_on_floor():
		new_state = State.IDLE
