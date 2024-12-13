extends Control

@export var banks : Dictionary

enum {NONE, M, F} #gender

func _ready() -> void:
	createSimpleBank("bets")
	#OJO ACÁ, EL ESTAN LISTOS XL NO ES DIFERENCIADO DE LOS DEMÁS POR AHORA!
	createBank("charselscreen", [["charselscreen_estan-listos", 1],["charselscreen_preparense", 1], ["charselscreen_guarda-que-arranca", 1] ])
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
	createBank("corranlabola", [["corranlabola_normal, 1"], ["corranlabola_refraseado", 0.3]] )
	createBank("kill_aceituna", [["kill_aceituna_aceitunadx", 1, 1]])
	
	playBank("charselscreen")
#	playBank("bets")

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
	var fileToSearch : String = "narr_" + bankName
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
		var elementChance : float = bankElement[1]
		var elementIsGendered : bool
		if bankElement.size() == 3:
			elementIsGendered = bankElement[2]
		else: elementIsGendered = 0
	
	#El diccionario bank contiene una key para cada bankPointer que es un array
	#tiene en el 0 la chance, en el 1 info de género
	#en el 2 un bankElement (audiostreamrandomizer) o un array con un bankelement para M y uno para F
		bank[bankElement[0]] = [elementChance , elementIsGendered]
		if elementIsGendered:
			bank[bankElement[0]].append([createBankElement(elementName + "_M"), createBankElement(elementName + "_F")])
		else:
			bank[bankElement[0]].append(createBankElement(elementName))

		banks[bankName] = bank
