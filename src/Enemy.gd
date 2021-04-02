extends Node2D

var bullet;
var BulletGroup;
var animation_player;
var stage;
var player;

var sleeping_bullets : Dictionary = {};
var groups : Dictionary = {};

var time_begin;
var time_delay;

var enemy_events;

const _360_DEGREES = 2 * PI;

func _ready():
	set_process(false);
	set_physics_process(false);
	
	var f = File.new();
	f.open("res://src/scenes/stage1_enemy_events.json", File.READ);
	
	enemy_events = JSON.parse(f.get_as_text()).result;
	
	f.close();
	
#	bullet = preload("res://src/scenes/Bullet.tscn");
#	BulletGroup = preload("res://src/scenes/BulletGroup.tscn");
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
		var new_bullet = stage.getBullet();
		new_bullet.position = Vector2(0, 0);
		new_bullet.change_trajectory_through_direction(rand_range(strength.x, strength.y), rand_range(direction - angle, direction + angle), 0.4);
		addToCollection(new_bullet, collection);
		add_child(new_bullet);

func pattern_barrage(direction = PI/2, arc_angle = PI, strength = 600, quantity = 60):
	var angle_delta = arc_angle/quantity;
	var current_angle = direction - arc_angle/2;
	var maximum_angle = direction + arc_angle/2;

	while(current_angle < maximum_angle):
		var new_bullet = stage.getBullet();
		new_bullet.position = Vector2(0, 0);
		add_child(new_bullet);
		new_bullet.change_trajectory_through_direction(strength, current_angle);

		current_angle += angle_delta;
		
func circle_barrage(direction, strength, quantity, radius, tween_duration = 0.25):
	var bullet_group = stage.getBulletGroup();
#	var tween = Tween.new();
	var angle_delta = _360_DEGREES/quantity;
	var current_angle = 0;
	
	add_child(bullet_group);
#	add_child(tween);
	bullet_group.position = Vector2(0, 0);
	bullet_group.change_trajectory_through_direction(strength, direction);
	
	while(current_angle < _360_DEGREES):
		var new_bullet = stage.getBullet();
		bullet_group.add_child(new_bullet);
#		No expanding for now
#		new_bullet.position = Vector2(0, 0);
#
#		tween.interpolate_property(new_bullet, "position", new_bullet.position, Vector2(cos(current_angle), sin(current_angle)) * radius, tween_duration);
		
		new_bullet.position = Vector2(cos(current_angle), sin(current_angle)) * radius;
		current_angle += angle_delta;
#	tween.start();

func _process(delta):
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
					var new_bullet = stage.getBullet();
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
				
			'circleBarrage':
				if(!ev.type):
					circle_barrage(ev.data.direction, ev.data.strength, ev.data.quantity, ev.data.radius);
				
