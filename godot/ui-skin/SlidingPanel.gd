extends PanelContainer

export var duration : float = 0.3
export var hidden_position : int = -320


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func expand_toggled(expand):
	if expand:
		$Tween.interpolate_property(self, "rect_position",
			get_position(), Vector2(0, 0), duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		$Tween.interpolate_property(self, "rect_position",
			get_position(), Vector2(0, hidden_position), duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
