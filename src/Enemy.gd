extends Node2D

var bullet;
var BulletTimer;
var animation_player;
var stage;
var player;

var sleeping_bullets : Dictionary = {};

var time_begin;
var time_delay;

var enemy_events;

func _ready():
	set_process(false);
	set_physics_process(false);
	
	var f = File.new();
	f.open("res://src/scenes/stage1_enemy_events.json", File.READ);
	
	enemy_events = JSON.parse(f.get_as_text()).result;
	
	f.close();
	
	bullet = preload("res://src/scenes/Bullet.tscn");
	BulletTimer = preload("res://src/BulletTimer.gd");
	animation_player = get_child(2);
	stage = get_parent();
	player = stage.get_child(1);
	animation_player.play("Intro");

func _on_animation_finished(anim_name):
	if(anim_name == "Intro"):
		animation_player.play("Intro2");
		time_begin = OS.get_ticks_usec();
		time_delay = AudioServer.get_time_since_last_mix() + AudioServer.get_output_latency();
		set_process(true);
		set_physics_process(true);
		stage.playBGM();
		
func addToCollection(bullet, collection):
	if(!sleeping_bullets.has(collection)):
		sleeping_bullets[collection] = [];
	sleeping_bullets[collection].push_back(bullet);
		
func wake_bullets(target, collection, strength):
	for bullet in sleeping_bullets[collection]:
		if(bullet != null):
			bullet.change_trajectory_through_normalization(strength, (target - bullet.global_position).normalized());
	sleeping_bullets[collection].clear();

func sleeping_barrage(direction, angle, strength, collection, quantity = 30):
	for c in range(quantity):
		var new_bullet = bullet.instance();
		new_bullet.position = Vector2(0, 0);
		new_bullet.change_trajectory_through_direction(rand_range(strength.x, strength.y), rand_range(direction - angle, direction + angle), 0.4);
		addToCollection(new_bullet, collection);
		add_child(new_bullet);

func pattern_barrage(direction = PI/2, arc_angle = PI, strength = 600, quantity = 60):
	var angle_delta = arc_angle/quantity;
	var current_angle = direction - arc_angle/2;
	var maximum_angle = direction + arc_angle/2;

	while(current_angle < maximum_angle):
		var new_bullet = bullet.instance();
		new_bullet.position = Vector2(0, 0);
		add_child(new_bullet);
		new_bullet.change_trajectory_through_direction(strength, current_angle);

		current_angle += angle_delta;

#func shoot(strength, target, damping = 0, size = 1, random_start = false, random_end = false):
#	var new_bullet = bullet.instance();
#	new_bullet.position = Vector2(0, 0);
#	new_bullet.change_trajectory_through_direction(strength, get_angle_to(target), damping);
#	add_child(new_bullet);
#
#func _wake_bullet_barrage(timer, target, strength):
#	if(typeof(target) != 5):
#		target = to_local(target.position);
#
#	for bullet in timer.bullet_array:
#		if(bullet != null):
#			bullet.change_trajectory_through_normalization(rand_range(strength.x, strength.y), (target - bullet.position).normalized());
#
#	remove_child(timer);
#	timer.queue_free();
#
#
#func pattern_barrage(direction = -PI/2, arc_angle = PI, strength = 400, quantity = 30):
#	var angle_delta = arc_angle/quantity;
#	var current_angle = direction - arc_angle/2;
#	var maximum_angle = direction + arc_angle/2;
#
#	while(current_angle < maximum_angle):
#		var new_bullet = bullet.instance();
#		new_bullet.position = Vector2(0, 0);
#		add_child(new_bullet);
#		new_bullet.change_trajectory_through_direction(strength, current_angle);
#
#		current_angle += angle_delta;
#
#func wake_generic_bullets(target, strength):
#	for bullet in generic_bullet_array:
#		if(bullet != null):
#			bullet.change_trajectory_through_normalization(strength, (target - bullet.position).normalized());
#	generic_bullet_array.clear();

func _physics_process(delta):
	var time = (OS.get_ticks_usec() - time_begin) / 1000000.0;
	time -= time_delay;
	time = max(0, time);
	
	if(player == null):
		get_tree().paused = true;
	
	while(enemy_events.size() && time >= enemy_events[0].time):
		var ev = enemy_events.pop_front();
		
		match ev.event:
			'singleSleepingBullet':
				if(ev.type == 0):
					var new_bullet = bullet.instance();
					new_bullet.position = Vector2(0, 0);
					new_bullet.change_trajectory_through_direction(rand_range(ev.data.strength.min, ev.data.strength.max),
																   rand_range(ev.data.direction - ev.data.arc, ev.data.direction + ev.data.arc),
																   ev.data.damping);
					addToCollection(new_bullet, ev.collection);
					add_child(new_bullet);
				
			'wakeSleepingBullets':
				wake_bullets(player.global_position, ev.collection, ev.data.strength);
				
			'barrageSleepingBullets':
				sleeping_barrage(ev.data.direction, ev.data.arc, Vector2(ev.data.strength.min, ev.data.strength.max), ev.collection, ev.data.quantity);
				
			'animation':
				animation_player.play(ev.name);
				
			'arcBarrage':
				pattern_barrage(ev.data.direction, ev.data.arc, ev.data.strength, ev.data.quantity);
				
#		var callback = funcref(self, listeners_array[0][1]);
#		callback.call_funcv(listeners_array[0][2]);
	
#	States
#	State 0: Not moving
#	State 1: Periodically shooting
#	State 2: Charging sleeping bullets
#	State 4: Laser

#	if(state == 1):
#		if(time_elapsed > 0):
#			time_elapsed -= delta;
#
#		else:
#			time_elapsed = shoot_frequency;
#			pattern_barrage(get_angle_to(player.position), PI, 400, 30);
#
#	elif(state == 2):
#		if(time_elapsed > 0):
#			time_elapsed -= delta;
#		else:
#			var new_bullet = bullet.instance();
#			new_bullet.position = Vector2(0, 0);
#			new_bullet.change_trajectory_through_direction(rand_range(generic_strength.x, generic_strength.y), rand_range(generic_direction - generic_angle, generic_direction + generic_angle), generic_damping);
#			generic_bullet_array.push_back(new_bullet);
#			add_child(new_bullet);
#
#			time_elapsed = shoot_frequency;
#
#	elif(state == 3):
#		pass
#
#	elif(state == 4):
#		pass
#
#	else:
#		if(time_elapsed > 0):
#			time_elapsed -= delta;
#
#		else:
#			time_elapsed = shoot_frequency;
#			bullet_sleeping_barrage(-PI/2, PI/2, Vector2(100, 200), player);
##			shoot(100, get_parent().get_child(1).position);
