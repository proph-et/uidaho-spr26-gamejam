extends Panel
class_name ShopPanel

@export var shop_player_id := 0

const BUTTON_HEIGHT := 46.0
const BUTTON_GAP := 6.0
const PANEL_CHROME_HEIGHT := 84.0
const MIN_PANEL_HEIGHT := 180.0

@onready var money_label: Label = $Margin/VBoxContainer/MoneyLabel
@onready var button_list: VBoxContainer = $Margin/VBoxContainer/Buttons
@onready var button_style_template: PlayerUIButton = $Margin/VBoxContainer/Buttons/Tower_Alpha

func _ready() -> void:
  _apply_player_ownership_to_buttons()
  GameManager.money_changed.connect(_on_money_changed)

  if shop_player_id > 0:
    money_label.text = "$%d" % GameManager.get_money(shop_player_id)
  else:
    money_label.text = "$---"


func _apply_player_ownership_to_buttons() -> void:
  for child in find_children("*", "PlayerUIButton", true, false):
    child.allowed_player_id = shop_player_id

func set_tower_options(tower_options: Array) -> void:
  _ensure_button_count(tower_options.size())
  var buttons: Array = find_children("*", "PlayerUIButton", true, false)
  for i in range(buttons.size()):
    var button := buttons[i] as PlayerUIButton
    if button == null:
      continue

    if i >= tower_options.size():
      button.visible = false
      continue

    var option: Dictionary = tower_options[i]
    button.visible = true
    button.tower_name = str(option.get("name", "Tower"))
    button.tower_cost = int(option.get("cost", 100))
    button.tower_scene = option.get("scene")
    button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    button.set_tower_display(button.tower_name, button.tower_cost)
    button.clip_text = true
    button.allowed_player_id = shop_player_id
  _fit_height_for_option_count(tower_options.size())

func _ensure_button_count(required_count: int) -> void:
  if button_list == null:
    return

  var buttons: Array = find_children("*", "PlayerUIButton", true, false)
  var current_count := buttons.size()
  if required_count <= current_count:
    return

  for i in range(current_count, required_count):
    var button := PlayerUIButton.new()
    button.name = "Tower_%d" % (i + 1)
    button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    button.clip_text = true
    button.set_tower_display("Tower", 0)
    _apply_button_theme(button)
    button_list.add_child(button)

func _apply_button_theme(button: PlayerUIButton) -> void:
  if button == null or button_style_template == null:
    return
  button.add_theme_color_override("font_color", button_style_template.get_theme_color("font_color"))
  button.add_theme_font_size_override("font_size", button_style_template.get_theme_font_size("font_size"))
  for state in ["normal", "hover", "pressed", "focus", "disabled"]:
    var style: StyleBox = button_style_template.get_theme_stylebox(state)
    if style != null:
      button.add_theme_stylebox_override(state, style.duplicate(true))

func _on_money_changed(player_id: int, new_amount: int) -> void:
  if player_id == shop_player_id:
    money_label.text = "$%d" % new_amount

func get_preferred_height() -> float:
  return custom_minimum_size.y

func _fit_height_for_option_count(option_count: int) -> void:
  var rows := maxi(option_count, 1)
  var buttons_height := rows * BUTTON_HEIGHT + maxi(rows - 1, 0) * BUTTON_GAP
  var desired_height := PANEL_CHROME_HEIGHT + buttons_height
  custom_minimum_size.y = maxf(desired_height, MIN_PANEL_HEIGHT)
