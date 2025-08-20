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
	enemy = get_node("../Enemy")  # Or use get_tree().get_nodes_in_group("enemies")[0]
	if enemy:
		print("Found main enemy at path: ", enemy.get_path())
		enemy_hitbox = get_node("../Enemy/Body")
		if enemy_hitbox:
			print("Enemy hitbox found at path: ", enemy_hitbox.get_path())
		else:
			print("ERROR: Could not find ../Enemy/Body")
	# Health bar setup
	health_bar.max_value = maxHealth
	health_bar.value = health



func update_health_ui():
	if health_bar:
		health_bar.value = health
	else:
		# Attempt to recover reference if lost
		health_bar = get_node("../CanvasLayer/HealthBar") or get_node("../../CanvasLayer/HealthBar")
		if health_bar:
			health_bar.value = health
		else:
			print("healthbar not found player health value")

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
	
	can_attack = false
	print("--- ATTACKING ALL ENEMIES IN RANGE ---")
	
	# Get all overlapping areas
	var overlapping_areas = attack_area.get_overlapping_areas()
	var hit_count = 0
	
	# Filter for enemy hitboxes
	for area in overlapping_areas:
		# Check if area belongs to an enemy
		var enemy = area.get_parent()
		if enemy != null and enemy.is_in_group("enemies") and enemy.has_method("take_damage"):
			enemy.take_damage(5)
			hit_count += 1
			print("Hit enemy at position: ", enemy.global_position)

	print("Attack hit ", hit_count, " enemies")
	await get_tree().create_timer(0.3).timeout
	can_attack = true


func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_key_pressed(KEY_SPACE):
		jump()
	if Input.is_key_pressed(KEY_Z):    
		attack_enemy()
		
	if is_jumping:
		jump_timer += delta
		var progress = jump_timer / jump_duration
		
		if progress < 1.0:
			var jump_progress = -4 * (progress - 0.5) * (progress - 0.5) + 1
			position.y = starting_y - (jump_height * jump_progress)
		else:
			is_jumping = false
			position.y = starting_y
			if top_wall_collider != null:
				top_wall_collider.disabled = false

	if direction != Vector2.ZERO:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.stop()

	if not is_jumping:
		velocity = direction * speed
	else:
		velocity = Vector2(direction.x * speed, 0)

	move_and_slide()
