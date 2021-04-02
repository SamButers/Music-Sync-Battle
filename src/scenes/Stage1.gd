extends Node2D

var enemy;
var player;

var bulletGroup;
var bullet;

var bullet_pool : Array;
var group_pool : Array;

var active_bullets : Array = [];
var active_groups : Array = [];

export var BULLET_POOL_SIZE = 1000;
export var BULLET_GROUP_POOL_SIZE = 25;

func playBGM():
	$BGM.play();
	
func _ready():
	bullet = preload("res://src/scenes/Bullet.tscn");
	bulletGroup = preload("res://src/scenes/BulletGroup.tscn");
	
	for c in range(BULLET_POOL_SIZE):
		bullet_pool.push_back(bullet.instance());
		
	for c in range(BULLET_GROUP_POOL_SIZE):
		group_pool.push_back(bulletGroup.instance());
		
func getBullet():
	var new_bullet = bullet_pool.pop_back();
	
	return new_bullet;
	
func getBulletGroup():
	var new_bullet_group = group_pool.pop_back();
	
	return new_bullet_group;
			
func moveBullets():
	pass
	
func treatCollisions():
	pass
			
func _physics_process(delta):
	moveBullets();
	treatCollisions()

func _on_Bounds_body_exited(body):
	match body.get_class():
		'Bullet':
			body.linear_velocity = Vector2.ZERO;
			body.angular_velocity = 0;
			remove_child(body);
			
			bullet_pool.push_back(body);
			
		'BulletGroup':
			body.set_process(true);
