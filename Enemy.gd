extends CharacterBody2D

@onready var attack_area = $Attack
@onready var hitbox = $HitBox  # Reference to own HitBox

var player: CharacterBody2D = null
var player_hurtbox: Area2D = null
var SPEED = 50.0
var MIN_DISTANCE = 15.0
var health = 15
var can_attack = true

func _ready():
	player = get_node("../Player")
	if player:
		player_hurtbox = get_node("../Player/Body")
		if !player_hurtbox:
			push_error("Enemy: Failed to find player's HurtBox at ../Player/Body")
	add_to_group("enemies")


func attack_player():
	if !can_attack or !player_hurtbox:
		return

	can_attack = false

	var overlapping = attack_area.get_overlapping_areas()
	if player_hurtbox in overlapping and player.has_method("damage"):
		player.damage()

	await get_tree().create_timer(1).timeout
	can_attack = true


func take_damage(amount: int):
	health -= amount
	print("current enemy health: " [health])
	if health <= 0:
		print("enemy killed")
		queue_free()

func _exit_tree():  # Called RIGHT BEFORE deletion
	if hitbox:
		hitbox.queue_free()  # Clean up properly
	emit_signal("enemy_destroyed", self)  # Notify spawner EARLY

func _physics_process(delta):
	if !player:
		return
	
	var direction = player.position - position
	velocity = direction.normalized() * SPEED if direction.length() > MIN_DISTANCE else Vector2.ZERO
	
	if player.can_take_damage:
		attack_player()
	
	move_and_slide()
