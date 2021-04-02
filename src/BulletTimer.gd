extends Timer
class_name BulletTimer

var bullet_array : Array;
var data : Array;
var purpose : String;

func _ready():
	connect("timeout", self, "queue_free")

func expand_bullets():
	# Data => 0 - time 1 - radius 2 - final position array 3 - array size
	for c in range(data[3]):
		bullet_array[c].position += data[2][c] * (data[0] - time_left)/data[0];
	
func _process(delta):
	match purpose:
		'expandBullets':
			expand_bullets();
