extends RigidBody2D
class_name Bullet

var impulse_strength;
var direction;

func _on_body_entered(body):
	body.getHit();
	
func get_class():
	return 'Bullet'
	
func change_trajectory_through_direction(impulse_strength, direction, damping = 0):
	set_linear_damp(damping);
	apply_central_impulse(-linear_velocity);
	apply_central_impulse(Vector2(impulse_strength * cos(direction), impulse_strength * sin(direction)));
	
func change_trajectory_through_normalization(impulse_strength, normalized_vector, damping = 0):
	set_linear_damp(damping);
	apply_central_impulse(-linear_velocity);
	apply_central_impulse(normalized_vector * impulse_strength);
	
