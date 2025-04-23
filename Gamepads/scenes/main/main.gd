extends Node2D

var current_gamepad := -1


func _ready() -> void:
    refresh_gamepad_list()


func _process(_delta: float) -> void:
    update_buttons_and_axis_readings(current_gamepad)


func refresh_gamepad_list() -> void:
    var gamepad_list: ItemList = $HBoxContainer/VBoxContainer/GamepadList
    var connected_joypads := Input.get_connected_joypads()

    gamepad_list.clear()

    if connected_joypads.is_empty():
        select_gamepad(-1)
    else:
        for id in connected_joypads:
            gamepad_list.add_item("[%d] %s" % [id, Input.get_joy_name(id)])

        gamepad_list.select(0)
        select_gamepad(0)


func select_gamepad(id: int) -> void:
    current_gamepad = id

    update_gamepad_info(current_gamepad)
    update_buttons_and_axis_readings(current_gamepad)


func update_gamepad_info(id: int) -> void:
    var gamepad_name := Input.get_joy_name(id)
    var joy_info := Input.get_joy_info(id)
    var info_text := "GUID: %s\n" % Input.get_joy_guid(id)

    for key: String in joy_info:
        info_text += "%s: %s\n" % [key, joy_info[key]]

    ($HBoxContainer/VBoxContainer2/InfoTextEdit as TextEdit).text = info_text
    ($HBoxContainer/VBoxContainer2/NameLabel as Label).text = gamepad_name if gamepad_name != "" else "unknown"


func update_buttons_and_axis_readings(id: int) -> void:
    var button_labels_container: Container = $HBoxContainer/VBoxContainer2/GridContainer
    var axis_progress_bars_container: Container = $HBoxContainer/VBoxContainer2/GridContainer2

    for button in JOY_BUTTON_SDL_MAX:
        var button_label: Label = button_labels_container.get_node("LabelButton%d" % button)
        button_label.theme_type_variation = "ButtonPressed" if Input.is_joy_button_pressed(id, button) else "ButtonNotPressed"

    for axis in JOY_AXIS_SDL_MAX:
        var axis_progress_bar: ProgressBar = axis_progress_bars_container.get_node("ProgressBarAxis%d" % axis)
        var axis_value_label: Label = axis_progress_bars_container.get_node("LabelAxisValue%d" % axis)
        var axis_value := Input.get_joy_axis(id, axis)
        axis_progress_bar.value = axis_value
        axis_value_label.text = "%0.3f" % axis_value


func _on_refresh_button_pressed() -> void:
    refresh_gamepad_list()


func _on_gamepad_list_item_selected(index: int) -> void:
    select_gamepad(index)
