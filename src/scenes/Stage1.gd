extends Node2D

var enemy;
var player;
var animationPlayer;

var time_begin;
var time_delay;

onready var listeners_array : Array = [
	[6.664, 'action1', []],
	[13.331, 'action2', []],
	[13.753, 'action3', [0]],
	[14.580, 'action3', [1]],
	[15.411, 'action3', [0]],
	[16.246, 'action3', [1]],
	[17.082, 'action3', [0]]
];
	
func action1():
	enemy.generic_direction = -PI/2;
	enemy.generic_angle = PI/2;
	enemy.generic_strength = Vector2(100, 200);
	enemy.generic_damping = 0.5;
	enemy.shoot_frequency = 0.2;
	enemy.time_elapsed = 0;
	enemy.state = 2;
	
func action2():
	enemy.wake_generic_bullets(enemy.to_local(player.position), 500);
	enemy.state = 3;
	animationPlayer.play("Intro3");
	
func action3(side):
	var direction = 2 * PI/3 if side else PI/3;
	enemy.bullet_sleeping_barrage(direction, PI/2, Vector2(500, 650), player, Vector2(750, 850), 0.413);
	
func _ready():
	enemy = get_child(0);
	player = get_child(1);
	enemy.set_process(false);
	enemy.set_physics_process(false);
	animationPlayer = enemy.get_child(2);
	animationPlayer.play("Intro");
	set_process(false);

func _on_Animation_Finished(anim_name):
	if(anim_name == "Intro"):
		animationPlayer.play("Intro2");
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
	
	if(player == null):
		get_tree().paused = true;
	
	while(listeners_array.size() && time >= listeners_array[0][0]):
		var callback = funcref(self, listeners_array[0][1]);
		callback.call_funcv(listeners_array[0][2]);
		
		listeners_array.pop_front();


func _on_Bounds_body_exited(body):
	if(body.get_class() == 'Bullet'):
		body.queue_free();
