extends Control

onready var pantallatext:TextEdit = get_node("vinterface/pantallatext")
onready var introtext:LineEdit = get_node("vinterface/introtext")
onready var comandos = get_node("comandos")

var historialcomandos:Array=global.historialcomandos
var historialcursor:int=-1

#borrar
var moviment:bool
var objectiu:Vector2

func _ready() -> void:
	# warning-ignore:return_value_discarded
	introtext.connect("text_entered", self, "introdueixtext")
	pantallatext.text=tr("NOMJOC")+" - "+tr("TITOLCOMANDO")
	introtext.grab_focus()
	global.consola=true
	yield(get_tree(), "idle_frame") #espera a que passe un frame
	introtext.text=""
#	pantallatext.add_keyword_color("Valkyr", global.c_cian)

func _process(delta) -> void:
	#borrar
	if moviment:
		rect_position=lerp(rect_position,objectiu,delta*2)
		if rect_position.distance_to(objectiu)<2: rect_position=rect_position.snapped(Vector2(64,64))
		if rect_position==objectiu:
			print("la consola ja aplegat")
			moviment=false
#	if Input.is_action_just_pressed("consola")==true:
#		#get_tree().paused=false
#		global.congela=false
#		queue_free()

func interpretacomando(textcomando):
	#separa paraules del comando en un array
	var paraules=textcomando.split(" ")
	paraules=Array(paraules)
	
	#elimina tots els espais per a que no conten com a paraula
	for _paraula in range(paraules.count("")):
		paraules.erase("")
	
	#ix de la funció en el cas que no hi haja paraules
	if paraules.size()==0:
		return
	#print("El tamany de paraules: "+str(paraules.size()))
	
	#lleva la primera paraula de paraules, i la guarda en comando (flipa)
	var comando=paraules.pop_front()
	#mostratext("El comando es "+comando)
	
	#EXEPCIONS ESTROCTURA dels comandos
	#if comandos.exepcions(comando,paraules,self)!=false: return
	
	for coman in comandos.comandosvalids:
		if coman[2].has(comando):
			comando=coman[0]
		if coman[0]==comando:
			if paraules.size()!=coman[1].size():
				mostratext(tr("ERRORCOMANDO")+str(comando)+tr("ESPERAVA")+str(coman[1].size())+tr("ARGUMENTS"))
				mostratext(comandos.ajuda(comando))
				return
			for i in range(paraules.size()):
				if not comprovatipo(paraules[i], coman[1][i]):
					mostratext(tr("ERRORPARAMETRE")+str(i+1)+" '"+str(paraules[i])+"'"+tr("INCORRECTECOMANDO")+str(comando)+"'")
					return
			if mostratext(comandos.callv(comando,paraules))=="-1":
				mostratext(tr("ERRORCOMANDO"))
				return
			return
	mostratext(tr("WARNINGCOMANDO")+str(comando)+"'"+tr("COMANDONOVALID"))

func comprovatipo(variable, tipo):
	if tipo==comandos.tipo_int:
		return variable.is_valid_integer()
	if tipo==comandos.tipo_string:
		return true
	if tipo==comandos.tipo_bool:
		return (variable=="true" or variable=="false")
	if tipo==comandos.tipo_float:
		return variable.is_valid_float()
	return false

	#un poc de debug per a veure com separa les paraules del comando
#	mostratext("El comando té: "+str(paraules.size())+" paraules")
#	for i in paraules:
#		mostratext(i)
		
func mostratext(textamostrar) -> void:
	pantallatext.text=pantallatext.text+"\n"+str(textamostrar)
	#farà scroll automàticament fins aplegar a una linia 99999 "infinit"
	pantallatext.set_v_scroll(99999999)

func introdueixtext(textintroduit) -> void:
	introtext.clear()
	#guarda al historial de comandos introuits
	if historialcomandos.size()>=10:
		historialcomandos.pop_back()
	historialcomandos.push_front(textintroduit)
	historialcursor=-1
	#Si envia comando netetja:
	if ["neteja","netetja","cls","clear","limpia","borra"].has(textintroduit):
		neteja()
		return
	interpretacomando(textintroduit)

func neteja() -> void:
	pantallatext.text=tr("NOMJOC")+" - "+tr("TITOLCOMANDO")

func _input(event: InputEvent) -> void:
	#Navega per lhistorial de comandos introduits
	if event.is_action_pressed("ui_up"):
		if historialcursor>=historialcomandos.size()-1: return
		historialcursor+=1
		introtext.clear()
		introtext.text=historialcomandos[historialcursor]
		yield(get_tree(), "idle_frame")
		introtext.caret_position=introtext.text.length()
	elif event.is_action_pressed("ui_down"):
		if historialcursor<=0:
			historialcursor=-1
			introtext.text=""
			return
		historialcursor-=1
		introtext.clear()
		introtext.text=historialcomandos[historialcursor]

func _exit_tree() -> void:
	#executa quan es destrueix
	global.historialcomandos=historialcomandos
