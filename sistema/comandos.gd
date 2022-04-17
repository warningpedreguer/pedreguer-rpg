extends Node

onready var jugador=global.jugador

enum {
	tipo_int,
	tipo_string,
	tipo_bool,
	tipo_float
}

# lestroctura es:
# ["comando",[tipus de parametres],[equivalencies comando],[text ajuda]
const comandosvalids=[
	["escriu",[tipo_string],["marca","remarca"],"escriu <text>"],
	["neteja",[],["netetja","cls","clear","limpia","borra"],"Borra tot el text de la consola"],
	["sobre",[],["about","versio","version"],"Mostra la versió del joc"],
	["llista",[tipo_string],["list","lista","llistat","listado"],"llista <valor> (ex: llista jugador)"],
	["ajuda",[tipo_string],["help","ayuda"],"ajuda <comando> (ex: ajuda escena) (ajuda list, mostra tots els comandos)"],
	["llig",[tipo_string],["read","lee","llegir","leer"],"llig <variable>"],
	["ataca",[],[],"ataca (Ordena al personatge actual a fer un atac)"],
	["camina",[tipo_string,tipo_int],[],"camina <$direccio> <%distancia> (ex: camina dreta 2)"],
	["mou",[tipo_string,tipo_string,tipo_int],[],"mou <personatge> <direccio> <%distancia> (ex: mou max dreta 4)"],
	["atac",[tipo_string],[],"atac <personatge> (Fa atacar cert personatge ex: atac vergante)"],
	["escena",[tipo_string],["pantalla","map"],"escena <nompantalla> (Canvia de pantalla ex: escena poble)"],
	["llengua",[tipo_string],["lang","idioma","language","lengua",\
	"llenguatge","lenguaje"],"llengua <nomllengua> (Canvia la llengua del joc ex: llengua valencia)"],
	["tanca",[],["close","cierra","tancar","cerrar","llevar"],"tanca (Tanca la consola)"],
	["exit",[],["eixir","pirarse","quit","au","bye","adeu","apagar"],"eixir (Tanca el joc)"],
	["controlable",[tipo_string],["control","controla","controlar"],"controla <personatge> (El jugador passa a controlar unaltre personatge) ex: controla vergante"],
	["interactua",[tipo_string],["accio","inter","ie"],"interactua <personatge> (Envia ordre per a que cert personatge interactue) ex: interactua vergante"],
	["introdueix",[tipo_string],["input","introduir","entrar"]],
	["estadistiques",[],["stats","estatics","estadisticas","estats"],"Mostra el menú d'estadistiques"],
	["paleta",[],["palette","colors","color"],"Mostra la paleta de colors"],
	["aspija",[tipo_string,tipo_int],["espija","tiracapalla"],"Locura perque mou la consola"],
	["orfans",[],["orfa","orphan"],"Mostra nodes perduts"],
	["gira",[tipo_string,tipo_string],["turn","mira"],"gira <personatge> <direccio> (Gira el personatge en una direcció)"],
	["web",[tipo_string],["navega"],"web <url> (Intenta carregar la URL d'internet)"],
	["musica",[tipo_string],["posamusica","music","play","reproduir","canso","canço","cançó","cançons","cansons","canción","canciones","mp3","cancion","song","theme","bso","ost"],"musica <titol>.mp3 (Sona una música de fons)"],
	["pantallacompleta",[],["fullscreen","full"],"Passa a mode pantalla completa"]
]


func escriu(text):
	print(text)
	return tr("SHAESCRIT")+" '"+str(text)+"' "+tr("ENELDEBUG")

func neteja():
	#Borra tot el text de la consola
	get_parent().pantallatext.text=""
	return "neteja"

func sobre():
	print("Versió: "+ProjectSettings.get_setting("application/config/name")\
	+" "+ProjectSettings.get_setting("application/config/versio"))
	return "Versió: "+ProjectSettings.get_setting("application/config/name")\
	+" "+ProjectSettings.get_setting("application/config/versio")

func llista(parametre):
	if ["comandos","comandaments","commands","comando","comandament","command"].has(parametre):
		var comandos = ""
		for comando in comandosvalids:
			comandos=comandos+str(comando[0])+", "
		return tr("ELSCOMANDOSSON")+"\n"+str(comandos)
	elif ["jugador","player","jugadors","jugadores","players","personatge"\
	,"personaje","personajes","personatges"].has(parametre):
		var _llistatpersonatges:String
		for perso in global.personatges:
			_llistatpersonatges=_llistatpersonatges+" "+str(perso.get_name())
		return "Personatges disponibles:"+str(_llistatpersonatges)
	elif ["musica","music","cançons","cansons","canción","canciones","mp3"\
	,"cancion","song","theme","bso","ost"].has(parametre):
		var _llistatcansons:Array=minicadena.llista("res://audio/musica/")
		var _llista:String=""
		for canso in _llistatcansons:
			_llista+="\n"+str(canso)
		return "Les següents cançons estan disponibles"+_llista+"\n Per a escoltar, scriu: musica <titol>"

func ajuda(parametre):
	if ["llista","list","lista"].has(parametre):
		var comandos=""
		for comando in comandosvalids:
			comandos=comandos+str(comando[0])+", "
		return tr("ELSCOMANDOSSON")+"\n"+str(comandos)
		
	for comando in comandosvalids:
		if comando[0]==parametre or comando[2].has(parametre):
			if comando.size()>=4:
				return "El comando "+comando[0]+" s'utilitza:"+"\n"+comando[3]
			else:
				return "No hi ha text d'ajuda per aquest comandament"
	return "No hi ha cap commando"

func llig(variable):
	var supervariable=global.get(str(variable))
	match typeof(supervariable):
		TYPE_NIL:
			return "No hi ha accès a la variable "+str(variable)+", o no existeix"
		_:
			return "El valor de "+variable+" és:\n"+str(global.get(str(variable)))

func ataca():
	if jugador!=null:
		jugador.estat_anterior=jugador.estat_actual
		jugador.estat_actual=jugador.estat.ataca
		return "El jugador ataca!"
	return "No hi ha un jugador seleccionat"

func camina(direccio, distancia):
	if !jugador:return "No hi ha un jugador seleccionat"
	match direccio:
		"dreta", "esquerra", "dalt", "baix":
			jugador.meneja(direccio, int(distancia))
		_:
			return tr("LADIRECCIO")+" '"+str(direccio)+"' "+tr("NOESVALIDA")
	return tr("JUGADORCAMINAT")+" "+str(distancia)+" "+tr("PASSESCAPA")+" "+str(direccio)
	
func mou(personatge, direccio, distancia):
	var _persotempo=comprovapersonatge(personatge)
	match typeof(_persotempo):
		TYPE_STRING: return _persotempo
		TYPE_OBJECT: personatge=_persotempo
		_: return "ERROR"
	
	match direccio:
		"dreta", "esquerra", "dalt", "baix":
			if !personatge.has_method("meneja"):return tr("ELPERSONATGE")+" '"+str(personatge.get_name())\
			+"' No pot moures!" 
			personatge.meneja(direccio, int(distancia))
		_:
			return tr("LADIRECCIO")+" '"+str(direccio)+"' "+tr("NOESVALIDA")
	return tr("ELPERSONATGE")+" '"+str(personatge.get_name())+"' "+tr("HACAMINAT")+" "+str(distancia)\
	+" "+tr("PASSESCAPA")+str(direccio)

func atac(personatge):
	var _persotempo=comprovapersonatge(personatge)
	match typeof(_persotempo):
		TYPE_STRING: return _persotempo
		TYPE_OBJECT: personatge=_persotempo
		_: return "ERROR"
	if !personatge.get("estat_anterior"): return "No pot atacar!"
	personatge.estat_anterior=personatge.estat_actual
	personatge.estat_actual=personatge.estat.ataca
	return "El personatge "+str(personatge.name)+" ataca!"

func escena(nomescena):
	#comprova que existeix lescena declarada en global i en eixe cas canvia
	if global.pantalla.has(nomescena):
		print("Si que hi ha una escena que es diu "+str(nomescena))
		global.reiniciaparametres()
		var _escena = get_tree().change_scene_to(load(global.pantalla[nomescena]))
	elif ["list","llista","lista"].has(nomescena):
		return "Escenes disponibles: "+str(global.pantalla.keys())
	else:
		return "ERROR!: No hi ha cap escena que es diga '"+str(nomescena)\
		+"', introdueix un nom d'escena vàlid!"
	
func llengua(idioma):
	var castella=["castella","castellano","español","espanyol","spanish",\
	"Castella","Castellano","Español","Espanyol","Spanish","es","ES",\
	"castellà","Castellà"]
	var valencia=["valencia","valencià","valenciano","valencian",\
	"Valencia","Valencià","Valenciano","Valencian","pedreguero","Pedreguero",\
	"VA","va","es_VA"]
	var catala=["catala","català","catalan","Catala","Català","Catalan",\
	"ca","CA","es_CA"]
	if valencia.has(idioma):
		TranslationServer.set_locale("ca")
		return "S'ha establit l'idioma valencià"
	elif catala.has(idioma):
		TranslationServer.set_locale("ca")
		return "Sha establit l'idioma català"
	elif castella.has(idioma):
		TranslationServer.set_locale("es")
		return "Se ha establecido el idioma castellano"
	else:
		return "La llengua "+str(idioma)+" no està disponible"
	
func tanca():
	global.congela=false #no se si borrar
	global.consola=false
	get_parent().queue_free()

func exit():
	get_tree().quit()
	return "bye bye, hasta otro ratito"

func controlable(_personatge):
	if ["ningu","cap","0","null"].has(_personatge):
		for perso in global.personatges:
			if !perso.get("controlable"):continue #Si no te la propietat controlable passa al seguent del bucle
			perso.dona_el_control()
		global.jugador=null
		return "Ara no controles a ningú!"
	var _persotempo=comprovapersonatge(_personatge)
	match typeof(_persotempo):
		TYPE_STRING: return _persotempo
		TYPE_OBJECT: _personatge=_persotempo
		_: return "ERROR"
	if _personatge.get("controlable")==null:return "El personatge no pot ser controlable"
	if global.jugador!=null:
		if _personatge.name==global.jugador.name: return "Ja tens el control de tu mateixa!!"
	for perso in global.personatges:
		if perso.get("controlable")==null:continue 
		if perso.get_name()==_personatge.get_name():
			global.jugador=perso
			if perso.controlable:continue #aborta si ja té estat controlable
			perso.dona_el_control() #dona el control
		elif perso.controlable:
			perso.dona_el_control() #lleva el control
	return tr("ELPERSONATGE")+" '"+str(_personatge.name)+" ara és controlable!"

func interactua(personatge):
	var _persotempo=comprovapersonatge(personatge)
	match typeof(_persotempo):
		TYPE_STRING: return _persotempo
		TYPE_OBJECT: personatge=_persotempo
		_: return "ERROR"
	senyals.emit_signal("xevaxe",personatge)
	return "S'ha enviat ordre d'interactuar a "+tr("ELPERSONATGE")+" '"+str(personatge)+" (unaltra"\
	+"cosa es que faja cas...)"

func introdueix(dades):
	if dades!=null:
		if !global.get("input"): return "ERROR"
		global.input=str(dades)
		return "Sha guardat l'introducció de dades en la variable global.input"

func estadistiques():
	global.estadistiques=!global.estadistiques
	if global.estadistiques:
		global.anyadeix_a_hud("estadistiques")
		tanca()
		return "Menú d'estadistiques obert"
	else:
		global.lleva_de_hud("estadistiques")
		return "S'ha tancat el menú d'estadistiques"

func paleta():
	global.paleta=!global.paleta
	if global.paleta:
		global.anyadeix_a_hud("paleta")
		tanca()
		return "Paleta colors activada"
	else:
		global.lleva_de_hud("paleta")
		return "S'ha tancat la paleta de colors"

func aspija(direccio,pases):
	var consola:Object=get_parent()
	var dinamica:Vector2
	if consola.moviment:return "Ja està en moviment! "+str(consola.rect_position)+" cap a "+str(consola.objectiu)
	match direccio:
		"dreta": dinamica=Vector2(1,0)
		"baix": dinamica=Vector2(0,1)
		"esquerra": dinamica=Vector2(-1,0)
		"dalt": dinamica=Vector2(0,-1)
		_: return "La direcció "+direccio+" no és vàlida. Utilitza: dreta, baix, esquerra, dalt"
	dinamica*=int(pases)*global.tamany_casilla
	consola.objectiu=dinamica+consola.rect_position
	consola.moviment=true
	return "Es mou "+str(pases)+" cap a la "+str(direccio)+", fins aplegar a "+str(dinamica+consola.rect_position)

func orfans():
	 return print_stray_nodes()

func gira(personatge, direccio):
	var _persotempo=comprovapersonatge(personatge)
	match typeof(_persotempo):
		TYPE_STRING: return _persotempo
		TYPE_OBJECT: personatge=_persotempo
		_: return "ERROR"
	match direccio:
		"dreta", "esquerra", "dalt", "baix":
			if !personatge.has_method("gira"):return tr("ELPERSONATGE")+" '"+str(personatge.get_name())\
			+"' no pot girar!"
			personatge.gira(direccio)
		_:
			return tr("LADIRECCIO")+" '"+str(direccio)+"' "+tr("NOESVALIDA")
	return tr("ELPERSONATGE")+" '"+str(personatge.get_name())+"' "+" s'ha girat cap a la "+str(direccio)

func web(_url:String):
	var superconnexio:HTTPRequest=HTTPRequest.new()
	add_child(superconnexio)
	# warning-ignore:return_value_discarded
	superconnexio.connect("request_completed",self,"connexiocompletada")
	var _error=superconnexio.request("https://"+_url)
	if _error!=OK:
		push_error("La connexió no està disponible")
	return "De moment no está disponible aquesta funció"

func connexiocompletada(_resultat, _codi_resposta, _capsalera, coset):
	var _imatge:Image=Image.new()
	var _error=_imatge.load_jpg_from_buffer(coset)
	if _error!=OK:
		push_error("No sha carregat bé l'imatge!")
	var _textura:ImageTexture=ImageTexture.new()
	_textura.create_from_image(_imatge)
	var _panelltextura:TextureRect=TextureRect.new()
	add_child(_panelltextura)
	_panelltextura.texture=_textura

func musica(_canso:String):
	if ["llista","list","lista","llistat","listado"].has(_canso):
		return llista("mp3")
	var _reprodueix:String=minicadena.musica(_canso)
	return _reprodueix

func pantallacompleta():
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,  SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1280,720),0.5)
	OS.window_fullscreen=!OS.window_fullscreen
	var fullescrin:String
	if OS.window_fullscreen:
		fullescrin="pantalla completa"
	else:
		fullescrin="finestra"
	#yield(get_tree(), "idle_frame") #espera a que passe un frame
	var nodetemp=get_parent().get_node("vinterface")
	if nodetemp.anchor_bottom==0:
		nodetemp.set_anchors_and_margins_preset(3,3)
	else:
		nodetemp.set_anchors_and_margins_preset(0,3)
	return "S'ha passat al mode "+fullescrin

#EXEPCIONS DE FORMAT I COMANDOS AMB PARAMETRES ALTERNATIUS
#func exepcions(_comando,_paraules,_jo):
#	if _comando=="mou" and ["llista","llistat","list","lista","listado"].has(_paraules[0]):
#		return _jo.mostratext(self.call(_comando,"llista","llista","llista"))
#	if _comando=="controlable" and _paraules==[]:
#		return _jo.mostratext(self.call(_comando,"llista"))
#	return false

func comprovapersonatge(personatge):
	######## a mode dexemple borrar
	if global.personatges.empty():
		global.personatges.append(self)
		global.personatges.append(get_node("/root/global"))
	##############################
	var _llistapersos:Array
	var _persotemp
	for perso in global.personatges:
		_llistapersos.append(str(perso.get_name()))
		if str(perso.get_name())==personatge:
			_persotemp=perso
	if !_llistapersos.has(personatge):
		if !["self","ell","mi","jo","personatge"].has(personatge):
			return tr("ELPERSONATGE")+" '"+str(personatge)+"' "+tr("NOEXISTEIX")+" i es puga controlar."\
			+"\n"+"Personatges disponibles: "+str(_llistapersos)
		if !global.jugador:return "Actualment no estás controlant cap personatge"
		return global.jugador
	return _persotemp
