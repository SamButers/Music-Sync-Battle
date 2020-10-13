extends Node2D

export var shoot_frequency = 1;
export var state = 0;
var generic_direction = 0;
var generic_angle = 0;
var generic_strength = 300;
var generic_damping = 0.1;
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
	for bullet in timer.bullet_array:
#		Keeping it here for possible future needs
#		print(target)
#		print(bullet.position)
#		print((target - bullet.position).normalized())
#		print((target - bullet.position).normalized() * strength)
#		var line = Line2D.new();
#		add_child(line);
#		line.position = bullet.position;
#		line.add_point(Vector2(0, 0));
#		line.add_point((target - bullet.position).normalized() * strength);
#		line.width = 5;
#		Use length divided by time to make bullet reach at the same time.
#		bullet.change_trajectory_through_normalization((target - bullet.position).length(), (target - bullet.position).normalized());
		bullet.change_trajectory_through_normalization(strength, (target - bullet.position).normalized());
#		get_tree().paused = true;
	remove_child(timer);
	timer.queue_free();

func bullet_sleeping_barrage(target, strength = 400, time = 0.833333, quantity = 30):
	var timer = BulletTimer.new();
	add_child(timer);
	timer.connect("timeout", self, "_wake_bullet_barrage", [timer, target, strength]);
	timer.one_shot = true;
	timer.bullet_array = Array();
	
	for c in range(quantity):
		var new_bullet = bullet.instance();
		new_bullet.position = Vector2(0, 0);
		new_bullet.change_trajectory_through_direction(rand_range(100, 300), rand_range(-PI, 0), 0.4);
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
#			shoot(100, get_parent().get_child(1).position);
		
	elif(state == 2):
		if(time_elapsed > 0):
			time_elapsed -= delta;
		else:
			var new_bullet = bullet.instance();
			new_bullet.position = Vector2(0, 0);
			new_bullet.change_trajectory_through_direction(rand_range(generic_strength - 100, generic_strength + 100), rand_range(generic_direction - generic_angle, generic_direction + generic_angle), generic_damping);
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
			bullet_sleeping_barrage(to_local(player.position), 600);
#			shoot(100, get_parent().get_child(1).position);
