extends Node2D

var enemy;
var player;

func playBGM():
	$BGM.play();
	
func _on_Bounds_body_exited(body):
	if(body.get_class() == 'Bullet'):
		body.queue_free();
