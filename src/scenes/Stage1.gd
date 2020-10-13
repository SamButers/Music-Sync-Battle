extends Node2D

var enemy;
var player;

var time_begin;
var time_delay;

var thing = false;
var thing2 = false;

func _ready():
	enemy = get_child(0);
	player = get_child(1);
	enemy.set_process(false);
	enemy.set_physics_process(false);
	enemy.get_child(2).play("Intro");
	set_process(false);

func _on_Animation_Finished(anim_name):
	if(anim_name == "Intro"):
		enemy.get_child(2).play("Intro2");
		time_begin = OS.get_ticks_usec();
		time_delay = AudioServer.get_time_since_last_mix() + AudioServer.get_output_latency();
		set_process(true);
		enemy.set_process(true);
		enemy.set_physics_process(true);
		$BGM.play();
	
func _process(delta):
	var time = (OS.get_ticks_usec() - time_begin) / 1000000.0;
	time -= time_delay;
	time = max(0, time);
	
	if(!thing && time >= 6.664):
		enemy.generic_direction = -PI/2;
		enemy.generic_angle = PI/2;
		enemy.generic_strength = 250;
		enemy.generic_damping = 0.5;
		enemy.shoot_frequency = 0.2;
		enemy.time_elapsed = 0;
		enemy.state = 2;
		thing = true;
		
	elif(!thing2 && time >= 13.331):
		enemy.wake_generic_bullets(enemy.to_local(player.position), 500);
		enemy.state = 1;
		enemy.shoot_frequency = 0.5;
		thing2 = true;
#	print("Time is: ", time);


func _on_Bounds_body_exited(body):
	if(body.get_class() == 'Bullet'):
		body.queue_free();
