extends KinematicBody2D
class_name Bullet

var speed;
var direction;
	
func _physics_process(delta):
	var collision = move_and_collide(Vector2(self.speed * cos(self.direction), self.speed * sin(self.direction)));
	
	if(collision):
		hide();
		queue_free();
		collision.collider.hide();
		collision.collider.queue_free();
