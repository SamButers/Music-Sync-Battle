extends Bullet
class_name BulletGroup

func get_class():
	return 'BulletGroup'
	
func _ready():
	set_process(false);
	set_physics_process(false);
	
func _process(delta):
	if(!get_child_count()):
		linear_velocity = Vector2(0, 0);
		angular_velocity = 0;
		get_parent().group_pool.push_back(self);
		get_parent().remove_child(self);
