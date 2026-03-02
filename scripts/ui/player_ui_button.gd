extends Button
class_name PlayerUIButton

@export var tower_name := "Tower"
@export var tower_cost := 100
@export var tower_scene: PackedScene
@export var allowed_player_id := 0 # 0 means any player

var _name_label: Label
var _cost_label: Label

func _ready() -> void:
  add_to_group("player_ui_interactable")
  _build_layout()
  update_display()

func set_tower_display(name: String, cost: int) -> void:
  tower_name = name
  tower_cost = cost
  update_display()

func update_display() -> void:
  if _name_label == null or _cost_label == null:
    return
  _name_label.text = tower_name
  _cost_label.text = "$%d" % tower_cost

func _build_layout() -> void:
  text = ""
  clip_text = false

  var margin := MarginContainer.new()
  margin.name = "ContentMargin"
  margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
  margin.set_anchors_preset(Control.PRESET_FULL_RECT)
  margin.offset_left = 10
  margin.offset_top = 0
  margin.offset_right = -10
  margin.offset_bottom = 0
  add_child(margin)

  var row := HBoxContainer.new()
  row.name = "ContentRow"
  row.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  row.size_flags_vertical = Control.SIZE_EXPAND_FILL
  row.alignment = BoxContainer.ALIGNMENT_CENTER
  row.add_theme_constant_override("separation", 8)
  margin.add_child(row)

  _name_label = Label.new()
  _name_label.name = "TowerName"
  _name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
  _name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  _name_label.clip_text = true
  row.add_child(_name_label)

  _cost_label = Label.new()
  _cost_label.name = "TowerCost"
  _cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
  _cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  row.add_child(_cost_label)

  _sync_label_theme()

func _sync_label_theme() -> void:
  if _name_label == null or _cost_label == null:
    return
  var font_size := get_theme_font_size("font_size")
  var font_color := get_theme_color("font_color")
  _name_label.add_theme_font_size_override("font_size", font_size)
  _cost_label.add_theme_font_size_override("font_size", font_size)
  _name_label.add_theme_color_override("font_color", font_color)
  _cost_label.add_theme_color_override("font_color", font_color)

func _notification(what: int) -> void:
  if what == NOTIFICATION_THEME_CHANGED:
    _sync_label_theme()

func player_interact(player_id: int, cursor: PlayerCursor = null) -> void:
  if allowed_player_id > 0 and player_id != allowed_player_id:
    return

  if GameManager.player_money[player_id] >= tower_cost:
    GameManager.spend_money(player_id, tower_cost)
    print("purchased tower %s for %d money" % [tower_name, tower_cost])
  else:
    return
  if cursor != null:
    cursor.queue_tower_purchase(tower_scene, tower_name, tower_cost)
