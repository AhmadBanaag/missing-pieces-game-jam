extends Area2D

## Stand in range: [interact] (S) opens the read UI. After it appears: [advance_read] (Enter) loads the next level.
## Auto next level: finds a host scene named [code]level_N.tscn[/code] on this node's parents (or current scene), then loads [code]level_(N+1).tscn[/code] in the same folder.
## Works when the level is instanced under [code]main.tscn[/code] — not only when the level is the run scene.
## Diary art: host [code]level_N.tscn[/code] maps to [code]Page(N-1).png[/code]: level_2→Page1, level_3→Page2, … level_6→Page5 ([code]Page 5.png[/code] or [code]Page5.png[/code]). Levels below 2 keep the scene default texture. Override with [code]diary_page_texture[/code].

@export var next_level_scene: String = "" ## Optional override. Empty = auto level_N → level_(N+1).
@export var diary_page_texture: Texture2D ## If set, always show this texture instead of auto PageN.
@export var diary_sprites_folder: String = "res://sprites" ## Page1.png … Page5.png (Page 5.png allowed).

var player_in_range := false
var reading_letter := false
var can_proceed_to_next_level := false

var _cached_next_path: String = ""

@onready var pickup_label: Label = $Label
@onready var letter_ui: TextureRect = $CanvasLayer/LetterUI
@onready var next_hint: Label = $CanvasLayer/NextHint


func _ready() -> void:
	pickup_label.modulate.a = 0.0
	letter_ui.visible = false
	next_hint.visible = false
	letter_ui.scale = Vector2(0.2, 0.2)
	_apply_diary_page_texture()
	_cached_next_path = _resolve_next_level_path()
	if _cached_next_path.is_empty():
		push_warning(
			"InteratibleObject at %s: could not resolve next level (set export next_level_scene, or place inside a scene saved as level_N.tscn)."
			% str(get_path())
		)


func _level_number_from_filename(fname: String) -> int:
	var regex := RegEx.new()
	if regex.compile("(?i)^level_(\\d+)\\.tscn$") != OK:
		return -1
	var m := regex.search(fname)
	if m == null:
		return -1
	return int(m.get_string(1))


## PackedScene instance roots (and the run scene) set scene_file_path; main.tscn does not match level_*.
func _host_level_scene_path() -> String:
	var n: Node = self
	while n:
		var scene_path: String = n.scene_file_path
		if not scene_path.is_empty() and _level_number_from_filename(scene_path.get_file()) >= 0:
			return scene_path
		n = n.get_parent()

	var tree := get_tree()
	if tree and tree.current_scene:
		var cp: String = tree.current_scene.scene_file_path
		if not cp.is_empty() and _level_number_from_filename(cp.get_file()) >= 0:
			return cp
	return ""


func _diary_texture_path_for_page_number(page_num: int) -> String:
	var base := diary_sprites_folder.strip_edges()
	if base.is_empty():
		base = "res://sprites"
	var candidates: PackedStringArray = PackedStringArray()
	if page_num == 5:
		candidates.append("%s/Page 5.png" % base)
		candidates.append("%s/Page5.png" % base)
	elif page_num >= 1:
		candidates.append("%s/Page%d.png" % [base, page_num])
		candidates.append("%s/page%d.png" % [base, page_num])
	for p in candidates:
		if ResourceLoader.exists(p):
			return p
	return ""


func _apply_diary_page_texture() -> void:
	if diary_page_texture != null:
		letter_ui.texture = diary_page_texture
		return

	var host := _host_level_scene_path()
	if host.is_empty():
		return
	var level_n := _level_number_from_filename(host.get_file())
	if level_n < 2:
		return

	var page_num := level_n - 1

	var tex_path := _diary_texture_path_for_page_number(page_num)
	if tex_path.is_empty():
		push_warning(
			"InteratibleObject: no diary image for level_%d (expects Page%d) under %s"
			% [level_n, page_num, diary_sprites_folder]
		)
		return

	var tex: Texture2D = load(tex_path) as Texture2D
	if tex != null:
		letter_ui.texture = tex
	else:
		push_warning("InteratibleObject: could not load %s" % tex_path)


func _resolve_next_level_path() -> String:
	var manual := next_level_scene.strip_edges()
	if not manual.is_empty():
		return manual

	var cur_path := _host_level_scene_path()
	if cur_path.is_empty():
		return ""

	var fname := cur_path.get_file()
	var n := _level_number_from_filename(fname)
	if n < 0:
		return ""

	var folder := cur_path.get_base_dir()
	return "%s/level_%d.tscn" % [folder, n + 1]


func _process(delta: float) -> void:
	if player_in_range and not reading_letter:
		pickup_label.modulate.a = lerp(pickup_label.modulate.a, 1.0, 5.0 * delta)
		if Input.is_action_just_pressed("interact"):
			open_letter()
	else:
		pickup_label.modulate.a = lerp(pickup_label.modulate.a, 0.0, 5.0 * delta)

	if reading_letter and can_proceed_to_next_level and _is_advance_read_pressed():
		next_level()


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = false


func _is_advance_read_pressed() -> bool:
	if InputMap.has_action("advance_read") and Input.is_action_just_pressed("advance_read"):
		return true
	# Default project ui_accept is Enter / spacebar — helps if advance_read keys differ by device
	if InputMap.has_action("ui_accept") and Input.is_action_just_pressed("ui_accept"):
		return true
	return false


func open_letter() -> void:
	reading_letter = true
	can_proceed_to_next_level = false
	pickup_label.visible = false
	letter_ui.visible = true
	letter_ui.scale = Vector2(0.2, 0.2)

	var tween := create_tween()
	tween.tween_property(
		letter_ui,
		"scale",
		Vector2(1.0, 1.0),
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished
	if not is_instance_valid(self):
		return
	if not is_instance_valid(next_hint):
		return
	next_hint.visible = true
	can_proceed_to_next_level = true


func next_level() -> void:
	if not is_inside_tree():
		return
	can_proceed_to_next_level = false
	var tree := get_tree()
	if tree == null:
		return

	var path := _cached_next_path.strip_edges()
	if path.is_empty():
		path = _resolve_next_level_path().strip_edges()
		_cached_next_path = path

	if path.is_empty():
		push_warning("InteratibleObject: no next level path (auto or override).")
		can_proceed_to_next_level = true
		return
	if not ResourceLoader.exists(path):
		push_error("InteratibleObject: scene file not found: %s" % path)
		can_proceed_to_next_level = true
		return

	var err := tree.change_scene_to_file(path)
	if err != OK:
		push_error("InteratibleObject: change_scene_to_file failed (%s): %d" % [path, err])
		can_proceed_to_next_level = true
