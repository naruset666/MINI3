extends CharacterBody3D

enum States {attack, idle, chase, die}

var state = States.idle
var hp = 15 # ถ้าโดนตีครั้งละ 5 ก็จะตายใน 3 ครั้ง
var speed = 2
var accel = 10
var gravity = 10
var target = null
var is_dead = false # ป้องกันไม่ให้ตายซ้ำ

@export var navAgent : NavigationAgent3D
@export var animationPlayer : AnimationPlayer

var is_dying = false

func take_damage(amount: int) -> void:
	if is_dead:
		return

	hp -= amount
	print("Enemy HP:", hp)

	if hp <= 0:
		is_dead = true
		is_dying = true
		state = States.die
		animationPlayer.play("Die")



func die() -> void:
	velocity = Vector3.ZERO
	animationPlayer.play("Die")
	queue_free()



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	match state:
		States.idle:
			velocity = Vector3.ZERO
			animationPlayer.play("Idle")

		States.chase:
			if target:
				look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
				navAgent.target_position = target.global_position
				var direction = navAgent.get_next_path_position() - global_position
				direction = direction.normalized()
				velocity = velocity.lerp(direction * speed, accel * delta)
				animationPlayer.play("Walk")

		States.attack:
			velocity = Vector3.ZERO
			animationPlayer.play("Punch")

		States.die:
			velocity = Vector3.ZERO

	move_and_slide()

	



func _on_chasearea_body_entered(body: Node3D) -> void:
	if body.has_method("player"):
		target = body
		state = States.chase

func _on_chasearea_body_exited(body: Node3D) -> void:
	if body.has_method("player"):
		target = null
		state = States.idle


func _on_attarea_body_entered(body: Node3D) -> void:
	if body.has_method("player"):
		state = States.attack

func _on_attarea_body_exited(body: Node3D) -> void:
	if body.has_method("player"):
		state = States.chase


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if is_dying and anim_name == "Die":
		queue_free()
