extends Node3D
class_name DisplayCard

func _ready():
	setEffect(3, "Mind the gap", load("res://Classes/Effects/MindTheGap/TarotMindTheGap.png"))

func setEffect(number : int, effectName : String, cardTexture : Texture):
	$CardLabel.text = numToRoman(number) + "\n" + effectName
	if cardTexture == null:
		return
	$CartaTarot/Plane.material_override.albedo_texture = cardTexture

func numToRoman(n : int) -> String:
	match n:
		1: return "I"
		2: return "II"
		3: return "III"
		4: return "IV"
		5: return "V"
		6: return "VI"
		_: return ""
