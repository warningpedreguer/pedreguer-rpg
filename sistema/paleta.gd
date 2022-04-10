extends Control

func _ready() -> void:
	var tamany=global.color.size()
	print("Actualment hi ha en la paleta "+str(tamany)+" colors:")
	if !get_node_or_null("horizontal"):
		var obhorizontal:Node=HBoxContainer.new()
		obhorizontal.name="horizontal"
		obhorizontal.set("custom_constants/separation",10)
		self.add_child(obhorizontal)
	for item in $horizontal.get_children():
		item.queue_free()
	var puntero:int=0
	for color in global.color:
		print(color)
		var item:ColorRect=ColorRect.new()
		item.name="color"+str(puntero)
		item.rect_min_size=Vector2(40,40)
		item.color=global.color[color]
		$horizontal.add_child(item)
		puntero+=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
