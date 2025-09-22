extends AnimationStep

func _onStart():
	var display : BetDisplaySimple = animationRoot().betDisplay
	var camera : MultipleResCamera = animationRoot().camera
	
	for c in BetHandler.getCandidates():
		if BetHandler.getCandidateOdds(c) <= 2:
			continue
		
		var label := display.createLabelForCandidate(c)
		var finalTransform := label.global_transform
		var startTransform := camera.getBillboardTransformForScreenPos(Vector2(960, 650), 3)
		startTransform = startTransform.rotated_local(Vector3.UP, PI)
		
		label.global_transform = startTransform
		label.scale = Vector3.ONE * .01
		
		var tween := create_tween()
		tween.tween_property(label, "scale", Vector3.ONE, .4)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_interval(1)
		tween.tween_property(label, "global_transform", finalTransform, .3)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		
		await tween.finished
	
	end()
