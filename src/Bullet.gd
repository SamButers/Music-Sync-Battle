extends RigidBody2D
class_name Bullet

var impulse_strength;
var direction;

func _on_body_entered(body):
	body.getHit();
	
func change_trajectory(impulse_strength, direction, damping = 0):
	set_linear_damp(damping);
	apply_central_impulse(Vector2(impulse_strength * cos(direction), impulse_strength * sin(direction)));

