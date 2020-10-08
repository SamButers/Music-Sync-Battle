extends KinematicBody2D

export var player_speed = 100;

func _ready():
	pass
	
func _physics_process(delta):
	var movement := Vector2(0, 0);
		
	if(Input.is_action_pressed("move_left")):
		movement.x -= Input.get_action_strength("move_left") * player_speed;
	
	if(Input.is_action_pressed("move_right")):
		movement.x += Input.get_action_strength("move_right") *player_speed;
		
	if(Input.is_action_pressed("move_up")):
		movement.y -= Input.get_action_strength("move_up") *player_speed;
	
	if(Input.is_action_pressed("move_down")):
		movement.y += Input.get_action_strength("move_down") *player_speed;
	
	move_and_slide(movement);
