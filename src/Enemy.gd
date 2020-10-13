extends Node2D

# General attack parameters
export var shoot_frequency = 1;
export var state = 0;

# Cumulative sleeping bullets
var generic_direction : float = 0.0;
var generic_angle : float = 0.0;
var generic_strength := Vector2(100, 200);
var generic_damping : float = 0.1;
var generic_bullet_array : Array = [];

var time_elapsed = shoot_frequency;
var previous_state = state;

var bullet;
var BulletTimer;

onready var player = get_parent().get_child(1);

func shoot(strength, target, damping = 0, size = 1, random_start = false, random_end = false):
	var new_bullet = bullet.instance();
	new_bullet.position = Vector2(0, 0);
	new_bullet.change_trajectory_through_direction(strength, get_angle_to(target), damping);
	add_child(new_bullet);
	
func _wake_bullet_barrage(timer, target, strength):
	if(typeof(target) != 5):
		target = to_local(target.position);
		
	for bullet in timer.bullet_array:
		bullet.change_trajectory_through_normalization(strength, (target - bullet.position).normalized());
		
	remove_child(timer);
	timer.queue_free();

func bullet_sleeping_barrage(direction, angle, strength, target, target_strength = 600, time = 0.833333, quantity = 30):
	var timer = BulletTimer.new();
	add_child(timer);
	timer.connect("timeout", self, "_wake_bullet_barrage", [timer, target, target_strength]);
	timer.one_shot = true;
	timer.bullet_array = Array();
	
	for c in range(quantity):
		var new_bullet = bullet.instance();
		new_bullet.position = Vector2(0, 0);
		new_bullet.change_trajectory_through_direction(rand_range(strength.x, strength.y), rand_range(direction - angle, direction + angle), 0.4);
		timer.bullet_array.push_back(new_bullet);
		add_child(new_bullet);
		
	timer.start(time);
	
func pattern_barrage(direction = -PI/2, arc_angle = PI, strength = 400, quantity = 30):
	var angle_delta = arc_angle/quantity;
	var current_angle = direction - arc_angle/2;
	var maximum_angle = direction + arc_angle/2;
	
	while(current_angle < maximum_angle):
		var new_bullet = bullet.instance();
		new_bullet.position = Vector2(0, 0);
		add_child(new_bullet);
		new_bullet.change_trajectory_through_direction(strength, current_angle);
		
		current_angle += angle_delta;

func wake_generic_bullets(target, strength):
	for bullet in generic_bullet_array:
		if(bullet != null):
			bullet.change_trajectory_through_normalization(strength, (target - bullet.position).normalized());
	generic_bullet_array.clear();

func _ready():
	bullet = preload("res://src/scenes/Bullet.tscn");
	BulletTimer = preload("res://src/BulletTimer.gd");

func _physics_process(delta):
#	States
#	State 0: Not moving
#	State 1: Periodically shooting
#	State 2: Charging sleeping bullets
#	State 4: Laser

	if(state == 1):
		if(time_elapsed > 0):
			time_elapsed -= delta;
			
		else:
			time_elapsed = shoot_frequency;
			pattern_barrage(get_angle_to(player.position), PI, 400, 30);
		
	elif(state == 2):
		if(time_elapsed > 0):
			time_elapsed -= delta;
		else:
			var new_bullet = bullet.instance();
			new_bullet.position = Vector2(0, 0);
			new_bullet.change_trajectory_through_direction(rand_range(generic_strength.x, generic_strength.y), rand_range(generic_direction - generic_angle, generic_direction + generic_angle), generic_damping);
			generic_bullet_array.push_back(new_bullet);
			add_child(new_bullet);
			
			time_elapsed = shoot_frequency;
		
	elif(state == 3):
		pass
		
	elif(state == 4):
		pass
		
	else:
		if(time_elapsed > 0):
			time_elapsed -= delta;
			
		else:
			time_elapsed = shoot_frequency;
			bullet_sleeping_barrage(-PI/2, PI/2, Vector2(100, 200), player);
#			shoot(100, get_parent().get_child(1).position);
