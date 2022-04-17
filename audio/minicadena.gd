extends Node

class_name Minicadena

onready var reproductormusica:AudioStreamPlayer=$musica

func _ready() -> void:
	if $musica.connect("finished",self,"para"):print("ERROR!")

func musica(canso:String) -> String:
	if reproductormusica.playing \
	and ["stop","para","dentindre","prou","calla"].has(canso):
		$musica.stream=null
		para()
		return "S'ha parat la musica"
	var ruta:String="res://audio/musica/"+canso
	var fitxer=File.new()
	if !fitxer.file_exists(ruta):return "La cançò no està disponible, no s'ha pogut carregar."
	var arxiu:AudioStream=load(ruta)
	if $musica.stream!=arxiu:
		reproductormusica.stream=arxiu
		reproductormusica.play()
	else:
		return "Eixa cançò és la que està sonant!"
	return "Ja sona la cançó: "+str(canso)

func para():
	$musica.stop()

func llista(ruta:String):
	if !ruta.ends_with("/"):
		ruta+="/"
	var arxius:Array=[]
	var carpeta:Directory=Directory.new()
	if carpeta.open(ruta)!=OK:return "ERROR"
	if carpeta.list_dir_begin()!=OK:return "ERROR"
	
	while true:
		var arxiu:String=carpeta.get_next()
		if arxiu=="":
			break
		elif !arxiu.begins_with(".") and !arxiu.begins_with("..") and !arxiu.ends_with(".import"):
			#arxius.append(ruta+arxiu)
			arxius.append(arxiu)
	
	carpeta.list_dir_end()
	return arxius

#func _process(delta: float) -> void:
#	pass
