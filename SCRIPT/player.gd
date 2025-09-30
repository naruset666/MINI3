extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensivity = 0.002
const CAMERA_SENS = 0.002

var onCooldown = false
@onready var animationPlayer = $AnimationPlayer
@onready var cooldown = $attcooldown
var can_damage = false
var damaged_enemies = []
@onready var at_tsfx: AudioStreamPlayer = $ATTsfx

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func player():
	pass


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func attack():
	if Input.is_action_just_pressed("attack") and not onCooldown:
		at_tsfx.play()
		animationPlayer.play("swordswing")
		onCooldown = true
		cooldown.start()

		can_damage = true
		damaged_enemies.clear()
		
	
	
	
	
func _input(event):
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * CAMERA_SENS
		rotation.x -= event.relative.y * CAMERA_SENS
		rotation.x = clamp(rotation.x, -0.5, 1.2)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	attack()
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	


func _on_attcooldown_timeout() -> void:
	onCooldown = false
	can_damage = false




func _on_att_area_body_entered(body: Node3D) -> void:
	if can_damage and body.has_method("take_damage") and body not in damaged_enemies:
		body.take_damage(5) # หรือจะเปลี่ยนค่า damage ก็ได้
		damaged_enemies.append(body)
