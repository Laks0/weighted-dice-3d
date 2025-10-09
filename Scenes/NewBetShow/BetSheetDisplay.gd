extends TextureRect

func setBetToDisplay(newBet : Bet):
	for i in range(3):
		$HBoxContainer.get_child(i).texture = newBet.getSlotWheelImage(i)
	
	$HBoxContainer2/BetNameLabel.text = newBet.betName
	$HBoxContainer2/BetNameDescription.text = newBet.betDescription
	
	$GuidePlayer.stream = newBet.videoGuide
	$GuidePlayer.play()

func restartVideoGuide():
	$GuidePlayer.stream_position = 0
