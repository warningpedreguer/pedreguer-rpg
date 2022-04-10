extends Node

#VARIABLES GLOBALS

onready var hud:Object=get_node_or_null("root/hud")
onready var monitor:Object=get_node_or_null("root/hud/estadistiques")
onready var consolaid:Object=get_node_or_null("root/hud/consola")

########################################
########################################
#millor crear una classe que es diga dialeg o bambolla
########################################
########################################
var bambolla = preload("res://sistema/dialeg.tscn")
var obconsola = preload("res://sistema/consola.tscn")
var obestadistiques = preload("res://sistema/estadistiques.tscn")
var obpaleta=load("res://sistema/paleta.tscn")

#stats personatge
var nom = "Warning"
var vida = 250
var congela=false

#tamanys i mesures
var tamany_casilla:int = 64
var tamany_bambolla:int = 32

#colors
var c_cian = Color("009bdb")
var c_blanc = Color("ffffff")
var c_morat = Color("58167d")

var color:Dictionary = {
	"cel":Color("00bfff"),
	"blanc":Color("ffffff"),
	"negre":Color("000000"),
	"blau":Color("1E90FF"),
	"morat":Color("58167d"),
	"fuxia":Color("9400D3"),
	"taronja":Color("FFA500"),
	"pistatxo":Color("ADFF2F"),
	"roig":Color("DC143C"),
	"magenta":Color("FF00FF"),
	"rosa":Color("FF1493"),
	"roseta":Color("FF69B4"),
	"groc":Color("FFFF00"),
	"moreno":Color("D2B48C"),
	"cian":Color("00FFFF")
}

#pantalles (escenes)
var pantalla={
	"consola":"res://sistema/consola.tscn"
	}

#personatges
#els valors es trasmeten al crear els objectes (nodes), per tant son dinàmics
var jugador
var personatges:Array=[]
var interactuables:Dictionary={
	"personatge":[],
	"objecte":[]
}
var dialegs

#Variables necessaries per a la consola
var consola:bool=false
var historialcomandos:Array=[]
var estadistiques:bool=false
var paleta:bool=false

func _ready():
	#Estableix llengua
	TranslationServer.set_locale("ca")
	
	#carrega dades
	#cartess=_carregadades("res://dades/cartes.valkyr")

func _input(event: InputEvent) -> void:
	#Administra l'obertura de la consola
	if event.is_action_pressed("consola"):
		consola=!consola
		if consola:
			consolaid=anyadeix_a_hud("consola")
		else:
			lleva_de_hud("consola")
			consolaid=get_node_or_null("nohiha") #canviar per monitor=null?
	elif event.is_action_pressed("F2"):
		estadistiques=!estadistiques
		if estadistiques:
			monitor=anyadeix_a_hud("estadistiques")
		else:
			lleva_de_hud("estadistiques")
			monitor=get_node_or_null("nohiha") #canviar per monitor=null?

func anyadeix_a_hud(objecte:String):
	#get_tree().paused=true
	if !self.get_parent().get_node_or_null("hud"):
		var obhud=CanvasLayer.new()
		obhud.name="hud"
		self.get_parent().add_child(obhud)
		hud=obhud #guarda lobjecte node dins de la variable global hud
	if !self.get_parent().get_node("hud").get_node_or_null(objecte):
		var objectetemp=get("ob"+objecte).instance()
		get_parent().get_node("hud").add_child(get("ob"+objecte).instance())
		return objectetemp

func lleva_de_hud(objecte:String):
	#get_tree().paused=false
	if get_parent().get_node_or_null("hud/"+objecte):
		get_parent().get_node("hud/"+objecte).queue_free()

#func dialeg2(emisor,posicio,text):
#	var bambolla1 = bambolla.instance()
#	#fa invisible la "bambolla" mentre es carrega el text
#	bambolla1.visible=false
#	emisor.add_child(bambolla1)
#	bambolla1.position=posicio
#	bambolla.llibre=text
#	bambolla1._obridialeg(emisor.get_name())
#	print(bambolla1)
#	bambolla1.dialegid=bambolla1 #temp
#	return bambolla1
#	#textenpantalla=true
#
#func dialeg(emisor,posicio,text):
#	var bambolla1 = bambolla.instance()
#	#fa invisible la "bambolla" mentre es carrega el text
#	bambolla1.visible=false
#	emisor.add_child(bambolla1)
#	bambolla1.position=posicio
#	bambolla1._mostratext(emisor.get_name(),text)
#	print(bambolla1)
#	bambolla1.dialegid=bambolla1 #temp
#	return bambolla1
#	#textenpantalla=true
#
#func llevadialeg(idbambolla):
#	if idbambolla!=null:idbambolla._llevatext()
#
#func introdueix(pregunta):
#	var introduccio=load("res://interface/introdueix.tscn")
#	var introduccio1=introduccio.instance()
#	get_tree().paused = true
#	self.add_child(introduccio1)
#	introduccio1.pregunta.text=str(pregunta)
#	yield(introduccio1,"confirma")
#	var dadesintroduides:String=introduccio1._missatge
#	if introduccio1!=null:
#		introduccio1.queue_free()
#	get_tree().paused = false
#	print(dadesintroduides)
#	return str(dadesintroduides)
#

func _carregadades(ruta):
	var arxiu = File.new()
	var dades
	if not arxiu.file_exists(ruta):
		return 0
	arxiu.open(ruta, File.READ)
	dades = JSON.parse(arxiu.get_as_text())
	#dades = str2var(arxiu.get_as_text())
	arxiu.close()
	return dades.result
	#return dades

func reiniciaparametres():
	congela=false
	consola=false

#func interpretadialegs():
#	dialegs=_carregadades("res://dades/dialegsguio.valkyr")
#	dialegs=dialegs["0"].values()
#	pass
