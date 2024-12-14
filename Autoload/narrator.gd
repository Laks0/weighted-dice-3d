extends Control

@export var banks : Dictionary

enum {NONE, M, F} #gender

func _ready() -> void:
	createSimpleBank("bets")
	createBank("charselscreen", [
		["charselscreen_estan-listos"],
		["charselscreen_preparense"],
		["charselscreen_guarda-que-arranca"],
		["charselscreen_estan-listos-XL", 0.05] ])
	
	createSimpleBank("charsel_juan")
	createSimpleBank("charsel_fran")
	createSimpleBank("charsel_male")
	createSimpleBank("charsel_marta")
	createSimpleBank("charsel_pedro")
	createSimpleBank("charsel_tomi")
	
	createSimpleBank("fx_aceitunas")
	createSimpleBank("fx_allin")
	createSimpleBank("fx_batidoymezclado")
	createSimpleBank("fx_cayolaficha")
	createSimpleBank("fx_cuidadoabajo")
	createSimpleBank("fx_espaditas")
	createSimpleBank("fx_fullhouse")
	createSimpleBank("fx_pinball")
	
	
	createBank("fx_corranlabola", [
		["fx_corranlabola-normal", 1],
		["fx_corranlabola-refraseado", 0.3] ])
	createBank("gameend", [
		["gameend_fin-de-la-partida"],
		["gameend_fin-del-juego"],
		["gameend_juego-terminado"],
		["gameend_termino", 1],
		["gameend_tenemos-unx-ganadorx", 1, 1] ])
	
	
	createSimpleBank("kill_8ball")
	createBank("kill_aceituna", [
		["kill_aceituna_aceitunadx", 1, 1],
		["kill_aceituna_descarozadx", 1, 1],
		["kill_aceituna_lx-aceitunaron", 1, 1],
		["kill_aceituna_lx-descarozaron", 1, 1],
		["kill_aceituna_le-sacaron-el-carozo", 1] ])
	createBank("kill_allin", [
		["kill_allin_adentro"],
		["kill_allin_atroden", 0.5],
		["kill_allin_ingeridx", 1, 1],
		["kill_allin_tragadx", 1, 1]])
	createBank("kill_card", [
		["kill_card_descartadx", 1, 1],
		["kill_card_lx-descartaron", 1, 1],
		["kill_card_lx-recortaron", 1, 1],
		["kill_card_picadx", 1, 1],
		["kill_card_picadelly", 0.2],
		["kill_card_recortadx", 1, 1],
		["kill_card_se-corto-solx", 1, 1] ])
	createBank("kill_cuidadoabajo", [
		["kill_cuidadoabajo_evacuadx", 1, 1],
		["kill_cuidadoabajo_se-cayo-a-la-nada"],
		["kill_cuidadoabajo_se-cayo-al-vacio"] ])
	createBank("kill_espaditas", [
		["kill_espaditas_apuñaladx", 1, 1],
		["kill_espaditas_empaladx", 1, 1] ])
	createBank("kill_generic", [
		["kill_generic_auch", 1.2],
		["kill_generic_efe", 0.1],
		["kill_generic_la-quedo"],
		["kill_generic_quedo-tocando-el-arpa", 0.2] ])
	createBank("kill_squash", [
		["kill_squash_aplastadx", 1, 1],
		["kill_squash_despachurradx", 0.8, 1],
		["kill_squash_prensadx", 0.6, 1] ])
	
	
	createSimpleBank("menu_configuracion")
	createSimpleBank("menu_creditos")
	createSimpleBank("menu_timba")
	createSimpleBank("menu_titulo")
	
	#acá nos faltó el "bien", porque estaba mal exportado:/
	createBank("roundend", [
		["roundend_felicitaciones"],
		["roundend_vamos"],
		["roundend_victoria"]
	])

func announceKill(killSource : String):
	if killSource == "8ball":
		if randi_range(0, 100) < 20:
			playBank("kill_" + killSource)
		else:
			playBank("kill_squash")
	else:
		playBank("kill_" + killSource)

func announceEffect(effectName : String):
	playBank("fx_" + effectName.to_pascal_case().to_lower().replace("!", "").replace("ó", "o"))


func testBank(bankName : String, gender : int):
	for i in 10:
		await get_tree().create_timer(1.5).timeout
		playBank(bankName, gender)

func playBank(bankName : String, gender : int = 0):
	var bank = banks[bankName]
	if bank is AudioStreamRandomizer:	#bancos simples
		$VOX.stream = bank
	else:			#bancos complejos
		$VOX.stream = AudioStreamRandomizer.new()
		for element in bank.keys():
			var newElement : AudioStreamRandomizer
			if bank[element][1]: #si es un elemento con género
				newElement = bank[element][2][gender-1]
			else:
				newElement = bank[element][2]
			$VOX.stream.add_stream(-1, newElement, bank[element][0])
	$VOX.play()
#busca los audios con el nombre buscado, y los añade a un audiostreamrandomizer que devuelve
func createBankElement(bankName : String):
	var bankElement := AudioStreamRandomizer.new()
	var fileToSearch : String = "narr_" + bankName + "_"
	var narratorPath := "res://Assets/SFX/Narrador/"
	
	for fileName in DirAccess.get_files_at(narratorPath):
		if fileName.contains(fileToSearch) && !fileName.contains("import"):
			bankElement.add_stream(-1, load(narratorPath+fileName))
	return bankElement

func createSimpleBank(bankName):
	banks[bankName] = createBankElement(bankName)

#bankData tiene que tener bankElements con nombres así:
# nombre del bankElement : Array[elementName, elementChance, elementIsGendered
func createBank(bankName: String, bankData : Array):
	var bank : Dictionary
	for bankElement in bankData:
		var elementName : String = bankElement[0]
		var elementChance : float
		var elementIsGendered : bool
		if bankElement.size() == 3:
			elementIsGendered = bankElement[2]
			elementChance = bankElement[1]
		else:
			elementIsGendered = 0
			if bankElement.size() == 2:
				elementChance = bankElement[1]
			else: elementChance = 1
	
	#El diccionario bank contiene una key para cada bankPointer que es un array
	#tiene en el 0 la chance, en el 1 info de género
	#en el 2 un bankElement (audiostreamrandomizer) o un array con un bankelement para M y uno para F
		bank[bankElement[0]] = [elementChance , elementIsGendered]
		if elementIsGendered:
			bank[bankElement[0]].append([createBankElement(elementName + "_M"), createBankElement(elementName + "_F")])
		else:
			bank[bankElement[0]].append(createBankElement(elementName))

		banks[bankName] = bank
