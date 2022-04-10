extends KinematicBody2D

class_name Ente

onready var animacio:Object=get_node("ente_sprites/ap_ente") #valorar
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
	neutre
}
#print("Hola "+str(estat.keys()[estat.parat]))
var estat_actual
var estat_anterior

var dreta:bool
var baix:bool
var esquerra:bool
var dalt:bool
var dinamica:Vector2=Vector2(0,0)
var direccio:Vector2=Vector2(0,1)
var rumb:Dictionary={
	Vector2(1,0):"dreta",Vector2(-1,0):"esquerra",
	Vector2(0,1):"baix",Vector2(0,-1):"dalt",Vector2(0,0):"paranoia"
	}
var objectiu:Vector2

#temporal ==================================
enum accio{dreta,esquerra,baix,dalt}
var accions:Array=[false,false,false,false]
#===========================================

func _init() -> void:
	controlable=true
	global.personatges.append(self)
	global.jugador=self

func _ready() -> void:
	set_meta("personatge",true)
	print(hud)
	estat_actual=estat.parat
	print("Estat actual: ",estat_actual)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tecladreta"):dreta=true
	if event.is_action_released("tecladreta"):dreta=false
	if event.is_action_pressed("teclaesquerra"):esquerra=true
	if event.is_action_released("teclaesquerra"):esquerra=false
	if event.is_action_pressed("teclabaix"):baix=true
	if event.is_action_released("teclabaix"):baix=false
	if event.is_action_pressed("tecladalt"):dalt=true
	if event.is_action_released("tecladalt"):dalt=false

func _process(delta: float) -> void:
	#lletrero_estat.text=estat.keys()[estat_actual]
	lletrero_estat.text=str(estat.keys()[estat_actual])
	
	match estat_actual:
		estat.parat:
			comensa_moviment()
		estat.camina:
			moviment(delta)
		estat.neutre:
			position=Vector2(0,0)

func canvia_estat(postestat) -> void:
	if postestat==estat_actual:return
	if postestat in estat: print("LOLOLOLOL")
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
		estat.neutre:
			print("Entra en l'estat NEUTRE")
		_: return

func ix_estat() -> void:
	match estat_actual:
		estat.parat:
			print("Està eixint del estat PARAT")
		estat.camina:
			print("Està eixint del estat CAMINA")
		estat.neutre:
			print("Està eixint de l'estat NEUTRE")
		_: return

func comensa_moviment() -> void:
	if !controlable:return
	elif dreta: dinamica=Vector2(1,0)
	elif esquerra: dinamica=Vector2(-1,0)
	elif baix: dinamica=Vector2(0,1)
	elif dalt: dinamica=Vector2(0,-1)
	else:return
	objectiu=position+dinamica*global.tamany_casilla
	objectiu=objectiu.snapped(Vector2(1,1)*global.tamany_casilla)
	canvia_estat(estat.camina)

func moviment(delta) -> void:
	direccio=dinamica
	if dreta and dinamica==Vector2(1,0)\
	or esquerra and dinamica==Vector2(-1,0)\
	or baix and dinamica==Vector2(0,1)\
	or dalt and dinamica==Vector2(0,-1):
		if position.distance_to(objectiu)<16:
			objectiu+=dinamica*global.tamany_casilla
#		if move_and_collide(dinamica*4,delta):
#			print("XOC?")
	if objectiu!=position:
		if move_and_collide(dinamica*4,delta):
			print("XOC?")
	else:
		print("diana")
		position=position.snapped(Vector2(1,1)*global.tamany_casilla)
		dinamica=Vector2(0,0)
		canvia_estat(estat.parat)

func meneja(superdireccio:String,pases:int) -> void:
	var claus:Array=rumb.keys()
	var valors:Array=rumb.values()
	dinamica=claus[valors.find(superdireccio,0)]
	objectiu=position+dinamica*global.tamany_casilla*pases
	objectiu=objectiu.snapped(Vector2(1,1)*global.tamany_casilla)
	canvia_estat(estat.camina)
