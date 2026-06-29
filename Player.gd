extends CharacterBody2D

# Node References
@onready var _animated_sprite = $AnimatedSprite2D
@onready var top_wall_collider = get_node("../Border/TopWall")
@onready var health_bar = get_node("../CanvasLayer/HealthBar") as ProgressBar
@onready var attack_area = $Attack

# Enemy Tracking
var enemy: CharacterBody2D = null
var enemy_hitbox: Area2D = null

# Movement & Combat
var speed = 75
var is_jumping = false
var is_attacking = false # Added to manage animation priority
var starting_y = 0
var jump_height = 25
var jump_duration = 0.75
var jump_timer = 0.0
var can_attack = true

# Health System
var life_amount = 3
var can_take_damage = true
var game_over = false
const maxHealth = 10
var health = maxHealth

func _ready():
	# Get first enemy reference
	enemy = get_node_or_null("../Enemy")
	if enemy:
		print("Found main enemy at path: ", enemy.get_path())
		enemy_hitbox = get_node_or_null("../Enemy/Body")
		if enemy_hitbox:
			print("Enemy hitbox found at path: ", enemy_hitbox.get_path())
		else:
			print("ERROR: Could not find ../Enemy/Body")
	
	# Health bar setup
	if health_bar:
		health_bar.max_value = maxHealth
		health_bar.value = health


func update_health_ui():
	if health_bar:
		health_bar.value = health
	else:
		# Attempt to recover reference if lost
		health_bar = get_node_or_null("../CanvasLayer/HealthBar") or get_node_or_null("../../CanvasLayer/HealthBar")
		if health_bar:
			health_bar.value = health
		else:
			print("healthbar not found player health value")


# functionality for taking damage from enemies
func damage():
	if can_take_damage:
		health -= 1
		update_health_ui()
		iframes()
		if health <= 0:
			life_lost()


func iframes():
	can_take_damage = false
	can_attack = false
	await get_tree().create_timer(2.0).timeout
	can_take_damage = true
	can_attack = true
	

func life_lost():
	life_amount -= 1
	health = maxHealth
	update_health_ui()
	iframes()
	if life_amount <= 0:
		game_over = true
		print("GAME OVER")


func jump():
	if not is_jumping and top_wall_collider != null:
		is_jumping = true
		starting_y = position.y
		jump_timer = 0.0
		top_wall_collider.disabled = true


func attack_enemy():
	if !can_attack:
		return
	
	# Lock attacking and movement animations immediately
	can_attack = false
	is_attacking = true
	_animated_sprite.play("Attack")
	
	print("--- ATTACKING ALL ENEMIES IN RANGE ---")
	if is_jumping:
		print("--- ATTACKING IN AIR: JUMPING ATTACK ---")
	
	# Get all overlapping areas
	var overlapping_areas = attack_area.get_overlapping_areas()
	var hit_count = 0
	
	# Filter for enemy hitboxes
	for area in overlapping_areas:
		var enemy_node = area.get_parent()
		if enemy_node != null and enemy_node.is_in_group("enemies") and enemy_node.has_method("take_damage"):
			enemy_node.take_damage(5)
			hit_count += 1
			print("Hit enemy at position: ", enemy_node.global_position)

	print("Attack hit ", hit_count, " enemies")
	# Note: We removed the await timer from here!


# Create a new function to handle when animations finish playing
func _on_animated_sprite_2d_animation_finished():
	if _animated_sprite.animation == "Attack":
		can_attack = true
		is_attacking = false


func _physics_process(delta):
	var direction = Vector2.ZERO

	# Inputs
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
		
	if Input.is_key_pressed(KEY_SPACE):
		jump()
	if Input.is_key_pressed(KEY_Z):
		attack_enemy()
		
	# Sprite/hurtbox Flipping
	if direction.x < 0:
		_animated_sprite.flip_h = true

	elif direction.x > 0:
		_animated_sprite.flip_h = false

	# 1. Handle Jump Logic and Jump Animations
	if is_jumping:
		jump_timer += delta
		var progress = jump_timer / jump_duration
		
		if progress < 1.0:
			var jump_progress = -4 * (progress - 0.5) * (progress - 0.5) + 1
			position.y = starting_y - (jump_height * jump_progress)
			
			# Only update jump animations if not currently playing the attack animation
			if not is_attacking:
				if progress < 0.5:
					_animated_sprite.play("Jump_up")
				else:
					_animated_sprite.play("Landing")
				
		else:
			is_jumping = false
			position.y = starting_y
			if top_wall_collider != null:
				top_wall_collider.disabled = false

	# 2. Handle Ground Movement and Walk Animations
	if not is_jumping:
		velocity = direction * speed
		
		# Only update movement animations if not attacking
		if not is_attacking:
			if direction != Vector2.ZERO:
				_animated_sprite.play("Walk")
			else:
				_animated_sprite.play("Idle")
	else:
		# Maintain horizontal movement in the air
		velocity = Vector2(direction.x * speed, 0)
		

	move_and_slide()


func _on_animated_sprite_2d_animation_looped() -> void:
	pass # Replace with function body.
