extends Node2D

export var shoot_frequency = 1;
var time_elapsed = shoot_frequency;
var bullet;

func _ready():
	bullet = preload("res://src/scenes/Bullet.tscn");

func _physics_process(delta):
	if(time_elapsed > 0):
		time_elapsed -= delta;
		
	else:
		time_elapsed = shoot_frequency;
		var new_bullet = bullet.instance();
		new_bullet.position = Vector2(0, 0);
		new_bullet.speed = 50;
		new_bullet.direction = get_angle_to(get_parent().get_child(1).position);
		add_child(new_bullet);
