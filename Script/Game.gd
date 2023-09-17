extends Node2D

var tmpath := "res://TileMap/"
enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}
var NodeTileMap

var ScenePlayer = load("res://Scene/Player.tscn")
# Didn't implement this part, also note audio is missing
#var SceneGoober = load("res://Scene/Goober.tscn")
#var SceneExplo = load("res://Scene/Explosion.tscn")

@onready var NodeAudioWin := $Audio/Win
@onready var NodeAudioLose := $Audio/Lose
@onready var NodeSprite := $Sprite2D
@onready var LevelCompletionScreen := $LevelComplete
@onready var OpeningScreen := $OpeningScreen

var clock := 0.0
var delay := 1.5
var check := false
var change := false

func _ready():
	global.Game = self
	
	if global.level == 0:
		OpeningScreen.visible = true
	
	MapLoad()
	MapStart()

func _process(delta):
	clock += delta
	# title and finish
	if btn.p("jump") and (global.level == 0 or (global.level == 21  and clock > 0.5)):
		global.level = posmod(global.level + 1, 22)
		DoChange()
	
	MapChange(delta)

func MapLoad():
	var nxtlvl = min(global.level, global.lastLevel)
	
	if global.level != 0:
		var tm = load(tmpath + str("level")+ str(nxtlvl) + str("new.tscn")).instantiate()
#	var tm = load(tmpath + str(nxtlvl) + ".tscn").instantiate()
		tm.name = "TileMap"
		add_child(tm)
		NodeTileMap = tm

func MapStart():
	print("--- MapStart: Begin ---")
	var inst = ScenePlayer.instantiate()

	if global.level == 1:
		inst.position = Vector2(250, -500)
	elif global.level == 2:
		inst.position = Vector2(-190, -450)
	elif global.level == 3:
		inst.position = Vector2(300, -40)
	
	self.add_child(inst)

	print("--- MapStart: End ---")

func MapChange(delta):
	# if its time to change scene
	if change:
		delay -= delta
		if delay < 0:
			DoChange()
		return # skip the rest if change == true
	
	# should i check?
	if check:
		check = false
#		var count = NodeBones.get_child_count()
#		print("Bones: ", count)
#		if count == 0:
		Win()

func Lose():
	change = true
	NodeAudioLose.play()
	NodeSprite.visible = true
	NodeSprite.frame = 2
	global.level = max(0, global.level - 1)

func Win():
	change = true
	NodeAudioWin.play()
	NodeTileMap.visible = false
	LevelCompletionScreen.visible = true
	global.level = min(global.lastLevel, global.level + 1)
	print("Level Complete!, change to level: ", global.level)

func DoChange():
	change = false
	get_tree().reload_current_scene()

#func Explode(arg : Vector2):
#	var xpl = SceneExplo.instantiate()
#	xpl.position = arg
#	add_child(xpl)
