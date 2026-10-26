extends AcceptDialog
var slider:HSlider
var mute_button:CheckButton
var level_label:Label
func _ready()->void:
 title="8-bit-lydeffekter";ok_button_text="Lukk"
 process_mode=Node.PROCESS_MODE_ALWAYS
 var layout=VBoxContainer.new();layout.add_theme_constant_override("separation",18);add_child(layout)
 level_label=Label.new();level_label.add_theme_font_size_override("font_size",22);layout.add_child(level_label)
 slider=HSlider.new();slider.min_value=0;slider.max_value=100;slider.step=1;slider.custom_minimum_size=Vector2(400,40);layout.add_child(slider)
 mute_button=CheckButton.new();mute_button.text="Demp lydeffekter";mute_button.custom_minimum_size.y=44;layout.add_child(mute_button)
 slider.value_changed.connect(func(value):Sound.set_volume(value/100.0))
 mute_button.toggled.connect(func(value):Sound.set_muted(value))
 Sound.settings_changed.connect(refresh)
 confirmed.connect(queue_free);canceled.connect(queue_free)
 refresh()
func refresh()->void:
 slider.set_value_no_signal(roundi(Sound.volume*100))
 mute_button.set_pressed_no_signal(Sound.muted)
 level_label.text="Effektvolum: %d %%"%roundi(Sound.volume*100)
