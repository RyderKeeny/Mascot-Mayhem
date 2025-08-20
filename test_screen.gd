extends Node2D

#@export var enemy_scene : PackedScene
#@export var max_enemies : int = 3
#@export var spawn_delay : float = 2.0
#
#@onready var spawn_points_parent = $SpawnPoints
#var spawn_points : Array[Marker2D] = []
#
#var current_enemies : Array[Node] = []
#var enemies_to_spawn : int = 0
#
#func _ready():
	#if !enemy_scene:
		#push_error("No enemy scene assigned!")
		#return
#
	#for child in spawn_points_parent.get_children():
		#if child is Marker2D:
			#spawn_points.append(child)
#
	#if spawn_points.is_empty():
		#push_error("No Marker2D spawn points found under $SpawnPoints!")
		#return
	#
	#start_spawning()
#
#func start_spawning():
	#enemies_to_spawn = max_enemies
	#try_spawn_enemies()
#
#func try_spawn_enemies():
	#while enemies_to_spawn > 0 and current_enemies.size() < max_enemies:
		#spawn_enemy()
		#enemies_to_spawn -= 1
		#await get_tree().create_timer(spawn_delay).timeout
#
#func spawn_enemy():
	#if spawn_points.is_empty():
		#return
	#if !enemy_scene:
		#return
#
	#var spawn_point = spawn_points.pick_random()
	#var new_enemy = enemy_scene.instantiate()
	#if !new_enemy:
		#return
#
	#add_child(new_enemy)
	#new_enemy.global_position = spawn_point.global_position
	#current_enemies.append(new_enemy)
#
	#if !new_enemy.tree_exiting.is_connected(_on_enemy_destroyed):
		#new_enemy.tree_exiting.connect(_on_enemy_destroyed.bind(new_enemy))
#
#func _on_enemy_destroyed(enemy):
	#if enemy in current_enemies:
		#current_enemies.erase(enemy)
#
	#if current_enemies.is_empty():
		#start_spawning()
