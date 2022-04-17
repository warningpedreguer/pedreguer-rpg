extends KinematicBody2D

class_name Ente

onready var animacions:AnimationPlayer=get_node("ente_sprites/ap_ente") #valorar
onready var eskin:String=self.get_name()
onready var hud:Object=global.hud #valorar (canviar pere global.hub)
onready var cara:RayCast2D=$cara
onready var lletrero_estat:Label=$lletrero_estat
onready var monitor:Object=global.monitor

var controlable:bool=false
var interactua:bool=false
var animacio_bloquejada:bool=false #valorar
enum estat{
	parat,
	camina,
	corre,
	neutre
}
#print("Hola "+str(estat.keys()[estat.parat]))
var estat_actual
var estat_anterior

var dreta:bool
var baix:bool
var esquerra:bool
var dalt:bool
var corre:bool
var dinamica:Vector2=Vector2(0,0)
var velocitat:int=2
var direccio:Vector2=Vector2(0,1)
var rumb:Dictionary={
	Vector2(1,0):"dreta",Vector2(-1,0):"esquerra",
	Vector2(0,1):"baix",Vector2(0,-1):"dalt",Vector2(0,0):"paranoia"
	}
var objectiu:Vector2
var puntdemira:Object


func _init() -> void:
	controlable=true
	global.personatges.append(self)

func _ready() -> void:
	set_meta("personatge",true)
	if controlable:global.jugador=self
	estat_actual=estat.parat
	objectiu=position
	
	#Carrega variant arxiu d'sprite, si està disponible
	var _arxiu:File=File.new()
	var _ruta:String
	for _esprait in ["baix","dalt","lateral"]:
		_ruta="res://personatges/"+eskin+"/"+eskin+"_"+_esprait+".png"
		if !_arxiu.file_exists(_ruta):
			_ruta="res://personatges/ente/ente_"+_esprait+".png"
		get_node("ente_sprites/sp_ente_"+_esprait).texture=load(_ruta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tecladreta"):dreta=true
	if event.is_action_released("tecladreta"):dreta=false
	if event.is_action_pressed("teclaesquerra"):esquerra=true
	if event.is_action_released("teclaesquerra"):esquerra=false
	if event.is_action_pressed("teclabaix"):baix=true
	if event.is_action_released("teclabaix"):baix=false
	if event.is_action_pressed("tecladalt"):dalt=true
	if event.is_action_released("tecladalt"):dalt=false
	
	if event.is_action_pressed("corre"):corre=true
	if event.is_action_released("corre"):corre=false

func _process(_delta: float) -> void:
	#lletrero_estat.text=estat.keys()[estat_actual]
	lletrero_estat.text=str(estat.keys()[estat_actual])
	#controls()
	
	match estat_actual:
		estat.camina:
			if corre:
				canvia_estat(estat.corre)
		estat.corre:
			if !corre:
				canvia_estat(estat_anterior)

func _physics_process(delta: float) -> void:
	match estat_actual:
		estat.parat:
			canvia_animacio(rumb[direccio]+"_p")
			comensa_moviment()
		estat.camina,estat.corre:
			canvia_animacio(rumb[direccio])
			moviment(delta)
		estat.neutre:
			position=Vector2(0,0)

func canvia_estat(postestat) -> void:
	if postestat==estat_actual:return
	#if !postestat in estat.values(): print("LOLOLOLOL")
	ix_estat()
	estat_anterior=estat_actual
	estat_actual=postestat
	entra_estat()

func entra_estat() -> void:
	match estat_actual:
		estat.parat:
			print("Entra en estat PARAT")
		estat.camina:
			print("Entra en estat CAMINA")
		estat.corre:
			if objectiu!=position and position.distance_to(objectiu)<=64:
				objectiu=position+dinamica*global.tamany_casilla
			velocitat=4
		estat.neutre:
			print("Entra en l'estat NEUTRE")
		_: return

func ix_estat() -> void:
	match estat_actual:
		estat.parat:
			print("Està eixint del estat PARAT")
		estat.camina:
			print("Està eixint del estat CAMINA")
		estat.corre:
			velocitat=2
		estat.neutre:
			print("Està eixint de l'estat NEUTRE")
		_: return

func canvia_animacio(_animacio) -> void:
	if !animacio_bloquejada:
		animacions.play(_animacio)

func comensa_moviment() -> void:
	if !controlable:return
	if dreta: dinamica=Vector2(1,0)
	elif esquerra: dinamica=Vector2(-1,0)
	elif baix: dinamica=Vector2(0,1)
	elif dalt: dinamica=Vector2(0,-1)
	else:return
	gira(dinamica)
	if puntdemira: return #si es direcciona cap algun objecte anula el moviment
	#estableix la posició objectiu de destí
	objectiu=position+dinamica*global.tamany_casilla
	objectiu=objectiu.snapped(Vector2(1,1)*global.tamany_casilla)
	canvia_estat(estat.camina)

func moviment(delta) -> void:
	if detecta_colisio():
		print("xoc brutal")
		return
	direccio=dinamica
	if dreta and dinamica==Vector2(1,0)\
	or esquerra and dinamica==Vector2(-1,0)\
	or baix and dinamica==Vector2(0,1)\
	or dalt and dinamica==Vector2(0,-1):
		if position.distance_to(objectiu)<16:
			objectiu+=dinamica*global.tamany_casilla
	if objectiu!=position:
		var velocitaaa=dinamica*velocitat*round(delta*100)
		position=position+velocitaaa
#		if move_and_collide(dinamica*velocitat*round(delta*100)):
#			print("XOC?")
	else:
		print("diana")
		para()
	
	#FIX temporal/TELEMETRIA
	if position.distance_to(objectiu)>(global.tamany_casilla*2):
		if !controlable:return
		print("THAS PASSAO")
		print("THAS PASSAO")
		print("THAS PASSAO")
		para()

func para() -> void:
	position=position.snapped(Vector2(1,1)*global.tamany_casilla)
	dinamica=Vector2(0,0)
	objectiu=position
	canvia_estat(estat.parat)

func gira(_dinamica) -> void:
	if _dinamica is String:
		_dinamica=treudinamica(_dinamica)
	#estableix nova direcció i el personatge es gira
	direccio=_dinamica
	cara.cast_to=(_dinamica*global.tamany_casilla)/2
	#escanetja si hi ha una colisio
	yield(get_tree(), "idle_frame") #deixa passar un frame
	puntdemira=detecta_colisio() #torna objecte que està davant del personatge

func treudinamica(_superdireccio:String) -> Vector2:
	var claus:Array=rumb.keys()
	var valors:Array=rumb.values()
	var _superdinamica:Vector2=claus[valors.find(_superdireccio,0)]
	if !_superdinamica:
		return Vector2(1,0)
	return _superdinamica

func meneja(superdireccio:String,pases:int) -> void:
	dinamica=treudinamica(superdireccio)
	gira(dinamica)
	yield(get_tree(), "idle_frame") #deixa passar un frame per a detectar bé colisió puntdemira
	if puntdemira: return #si es direcciona cap algun objecte anula el moviment
	objectiu=position+dinamica*global.tamany_casilla*pases
	objectiu=objectiu.snapped(Vector2(1,1)*global.tamany_casilla)
	canvia_estat(estat.camina)

func detecta_colisio() -> Object:
	#comprova si hi ha colisio i en cas afirmatiu torna al id del node
	var xoc=cara.is_colliding()
	if xoc:
		para()
		puntdemira=cara.get_collider()
		return puntdemira
#	#prepara per si envia senyal (queno siga continuament
#	if puntdemira:
#		print("NULO!")
	return null

func dona_el_control() -> void:
	var _interactuacio:Node=get_node_or_null("interactuable")
	if !controlable:
		if !_interactuacio:return
		else:
			_interactuacio.queue_free()
	else:
		if _interactuacio:return
		else:
			_interactuacio=global.interactuable.instance()
			add_child(_interactuacio)
	controlable=!controlable

func controls() -> void:
	pass
