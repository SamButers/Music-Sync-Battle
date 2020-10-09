extends Node2D

export var shoot_frequency = 1;
var time_elapsed = shoot_frequency;
var bullet;

func shoot(strength, target, damping = 0, size = 1, random_start = false, random_end = false):
	var new_bullet = bullet.instance();
	new_bullet.position = Vector2(0, 0);
	new_bullet.change_trajectory(strength, get_angle_to(target), damping);
	add_child(new_bullet);

func _ready():
	bullet = preload("res://src/scenes/Bullet.tscn");

func _physics_process(delta):
	if(time_elapsed > 0):
		time_elapsed -= delta;
		
	else:
		time_elapsed = shoot_frequency;
		shoot(100, get_parent().get_child(1).position);
