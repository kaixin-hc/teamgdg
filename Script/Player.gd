extends CharacterBody2D

@onready var NodeScene = global.Game
@onready var NodeAnimatedSprite = $AnimatedSprite2D
@onready var NodeArea2D := $Area2D
@onready var NodeAudio := $Audio

var vel := Vector2.ZERO
var spd := 60.0
var grv := 255.0
var jumpSpd := 233.0
var termVel := 400.0

var onFloor := false
var jump := false

func _physics_process(delta):
	# gravity
	vel.y += grv * delta
	vel.y = clamp(vel.y, -termVel, termVel)
	
	# horizontal input
	var btnx = btn.d("right") - btn.d("left")
	vel.x = btnx * spd
	
	# jump
	if onFloor:
		if btn.p("jump"):
			jump = true
			vel.y = -jumpSpd
			NodeAudio.play()
	elif jump:
		if !btn.d("jump") and vel.y < jumpSpd / -3:
			jump = false
			vel.y = jumpSpd / -3
	
	# apply movement
	velocity = vel
	move_and_slide()
	position = global.wrapp(position)
	# check for Goobers
	var hit = Overlap()
	if !hit:
		if velocity.y == 0:
			vel.y = 0
		# check for floor 0.1 pixel down
		onFloor = test_move(transform, Vector2(0, 0.1))
	
	# sprite flip
	if btnx != 0:
		NodeAnimatedSprite.flip_h = btnx > 0
	
	# animation
	if onFloor:
		if btnx == 0:
			TryLoop("Idle")
		else:
			TryLoop("Walk")
	else:
		TryLoop("Jump")

func Die():
	queue_free()
	NodeScene.Explode(position)
	NodeScene.Lose()

func Overlap():
	var hit = false
	
	for o in NodeArea2D.get_overlapping_areas():
		var par = o.get_parent()
		print ("Overlapping: ", par.name)
		
		if par is Goober:
			var above = position.y - 1 < par.position.y
			
			if onFloor or (vel.y < 0.0 and !above):
				Die()
			else:
				hit = true
				jump = btn.d("jump")
				vel.y = -jumpSpd * (1.0 if jump else 0.6)
				
				par.queue_free()
				NodeScene.Explode(par.position)
				NodeScene.check = true
				print("Goober destroyed")
		if par is Bone:
#			var above = position.y - 1 < par.position.y
#			NodeScene.Explode(par.position)
			NodeScene.check = true
			print("Bone Acquired")
#			if onFloor or (vel.y < 0.0 and !above):
#				Die()
#			else:
#				hit = true
#				jump = btn.d("jump")
#				vel.y = -jumpSpd * (1.0 if jump else 0.6)
#
#				par.queue_free()
#				NodeScene.Explode(par.position)
#				NodeScene.check = true
#				print("Goober destroyed")
	return hit

func TryLoop(arg : String):
	if arg == NodeAnimatedSprite.animation:
		return false
	else:
		NodeAnimatedSprite.play(arg)
		return true
