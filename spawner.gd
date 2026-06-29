extends Node2D

var enemy_scene = preload("res://Enemy.tscn")
var enemy_fan = preload("res://Fan.tscn")
@export var max_enemies : int = 3
@export var spawn_delay : float = 2.0
@export var auto_start : bool = true

@onready var marker := $Marker2D
@onready var spawn_area := $Area2D

var current_enemies: Array[Node] = []
var enemies_to_spawn: int = 0
var camera_area: Area2D = null
var spawn_triggered := false

func _ready():
	camera_area = get_tree().get_first_node_in_group("camera_area")

	if !marker or !enemy_scene or !enemy_fan or !spawn_area:
		return

	spawn_area.monitoring = true
	spawn_area.monitorable = true

func _process(_delta):
	if spawn_triggered:
		return

	if !spawn_area or !camera_area:
		return

	var overlapping = spawn_area.get_overlapping_areas()
	if overlapping.has(camera_area):
		spawn_triggered = true
		enemies_to_spawn = max_enemies
		await spawn_sequence()

func spawn_enemy():
	var enemy = enemy_fan.instantiate()
	var parent = get_parent()
	if !enemy or !parent:
		return

	parent.add_child(enemy)
	enemy.global_position = marker.global_position
	current_enemies.append(enemy)

	if enemy.has_signal("tree_exiting"):
		enemy.tree_exiting.connect(
			func(): _on_enemy_destroyed(enemy),
			CONNECT_ONE_SHOT
		)

func _on_enemy_destroyed(enemy):
	if enemy in current_enemies:
		current_enemies.erase(enemy)

	if current_enemies.is_empty() and enemies_to_spawn <= 0:
		await get_tree().create_timer(3.0).timeout
		spawn_triggered = false

func spawn_sequence():
	while enemies_to_spawn > 0 and current_enemies.size() < max_enemies:
		spawn_enemy()
		enemies_to_spawn -= 1
		if enemies_to_spawn > 0:
			await get_tree().create_timer(spawn_delay).timeout
