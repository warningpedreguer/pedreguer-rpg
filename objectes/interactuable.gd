extends Area2D

class_name Interactuable

onready var jugador:Ente=global.jugador #millor cridar directe de global
onready var amo=get_parent()
var activat:bool
var contacte:bool=false
var idcontacte:Object=null
var interactua:bool=false
var dialegid:Object=null
signal accio
signal talla

#tmpborrar
const altura = Vector2(0,-220)

func _ready() -> void:
	var _error=self.connect("body_entered",self,"_quan_entra_un_cos")
	_error=self.connect("body_exited",self,"_quan_ix_un_cos")
	if senyals.connect("xevaxe",self,"_algu_vol_alguna_cosa"):print("ERROR!")
	assert(self.connect("accio",amo,"_accio")==OK)
	_error=self.connect("talla",amo,"_talla")
	#print(_error)
	if _error:print("ERROR!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _quan_entra_un_cos(individu) -> void:
	if interactua==false and individu==global.jugador:
		print("El jugador "+str(global.jugador.name)+" ha entrat en contacte"\
		+" amb "+str(individu.name))
		idcontacte=individu
		contacte=true
	elif individu==global.jugador:
		print("El personatge "+str(individu.name)+" està ocupat")

func _quan_ix_un_cos(individu) -> void:
	if individu==idcontacte:
		idcontacte=null
		contacte=false
		interactua=false
		print("se'n va!")
		if amo.has_method("_talla"): emit_signal("talla",true)
		else: _talla(true)

func _algu_vol_alguna_cosa(individu):
	if contacte==false:return
	if individu!=idcontacte:return
	interactua=!interactua
	if amo.has_method("_accio"): 
		emit_signal("accio", interactua)
	else: _accio(interactua)

#funcions interactua per defecte
func _accio(_interactua):
	#fa que es gire el npc
	if amo.has_meta("tipo"):
		if amo.get_meta("tipo")=="personatge":
			amo.dinamica=global.jugador.dinamica*-1
	
	print("interactua: "+str(_interactua))
	if _interactua==true:
		mostra_cartell()
	elif _interactua==false:
		lleva_cartell()

func _talla(cambioicorto:bool):
	lleva_cartell()
	if cambioicorto:
		return

func mostra_cartell():
	if dialegid:return
	print("s'HA ACTIVAT EL CARTELL")
	dialegid=global.dialeg(amo,self.altura,"Aquesta és un text de prova, per a"\
	+" testejar. L'objecte principal hereda lscript interactua.")

func lleva_cartell():
	if !dialegid:return
	print("SHA DESACTIVAT EL CARTELL")
	senyals.emit_signal("eliminadialegs",dialegid)
	dialegid=null

func autodestruccio() -> void:
	queue_free()
