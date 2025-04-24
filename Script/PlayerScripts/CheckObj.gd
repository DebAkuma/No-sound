extends RayCast3D

class_name CheckOBJ
@onready var check_obj: Label = $"../PlayerUI/CheckObj"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_obj.visible = false

# Called every frame to check for collisions with interactable objects.
func _process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider is Interactable:
			check_obj.visible = true
			check_obj.text = String(collider.get_promt())
		else:
			check_obj.visible = false
	else:
		check_obj.visible = false
