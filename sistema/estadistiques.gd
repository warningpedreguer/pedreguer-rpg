extends Control

var fps:float=0
var temporal

func _ready() -> void:
	$caixavertical1/tabcontainer.visible=false

func _process(_delta: float) -> void:
	fps=Engine.get_frames_per_second()
	$caixavertical1/textframes.text="Frames per segon: "+str(fps)
	$caixavertical1/barraframes.value=fps
	if global.jugador:
		$caixavertical1/text2.text="Estats:"
		$caixavertical1/text3.text="Dinàmica: "+str(global.jugador.dinamica)\
		+"\nTecles direcció: "+str(global.jugador.dreta,global.jugador.esquerra,global.jugador.baix,global.jugador.dalt)\
		+"\nRumb: "+str(global.jugador.rumb[global.jugador.dinamica])\
		+"\nMira en direcció: "+str(global.jugador.rumb[global.jugador.direccio])\
		+"\nObjectiu: "+str(global.jugador.objectiu)
		$caixavertical1/tabcontainer/tab/Label.text="textprova"
