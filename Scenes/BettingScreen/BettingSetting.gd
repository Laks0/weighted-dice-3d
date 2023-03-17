extends Control

var player

var bet : int = 1

var candidate : int

func _ready():
	var candidates = BetHandler.getCandidates(player.id)

	for c in candidates:
		if not BetHandler.areCandidatesPlayers():
			$"%Results".add_item(str(c), c)
			continue
		var playerCandidate = PlayerHandler.getPlayerById(c)
		$"%Results".add_item(playerCandidate.name, c)
	
	$"%Bank".text = "Bank: " + str(player.bank)
	$"%Name".text = player.name
	$"%Name".modulate = player.color

	$"%BetAmount".min_value = BetHandler.getMinimunBet()
	
	updateTotal()

func updateTotal():
	$"%BetAmount".max_value = player.bank

func _on_BetAmount_value_changed(value):
	bet = value
	updateTotal()

func _process(_delta):
	var selectedId = $"%Results".get_selected_id()
	candidate = selectedId

	if not BetHandler.areCandidatesPlayers():
		return

	var selectedPlayer = PlayerHandler.getPlayerById(selectedId)
	$"%Results".modulate = selectedPlayer.color
