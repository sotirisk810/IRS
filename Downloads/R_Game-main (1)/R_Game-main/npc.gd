extends CharacterBody2D  

@export var chat_texts: Array[String] = ["Hello, traveler...", "It's been a while since we had visitors.", "Be careful on your journey", "Good luck out there!"]
@onready var chat_area = $chat_area
@onready var chat_box = $ChatBox  # Reference the Panel
@onready var chat_label = $ChatBox/Label  # Reference the Label inside the Panel

var is_chatting = false
var current_chat_index = 0  

func _ready() -> void:
	chat_area.connect("area_entered", Callable(self, "_on_chat_area_area_entered"))
	chat_area.connect("area_exited", Callable(self, "_on_chat_area_area_exited"))
	chat_box.visible = false  # Initially hide the chat box
	print("NPC script ready!")

func _process(delta: float) -> void:
	if is_chatting and Input.is_action_just_pressed("interact"):  
		advance_chat()

func start_chat() -> void:
	print("Chat started with NPC.")  
	chat_box.visible = true  # Show the chat box
	show_chat_ui(chat_texts[current_chat_index])  

func stop_chat() -> void:
	print("Chat ended with NPC.")  
	chat_box.visible = false  # Hide the chat box

func advance_chat() -> void:
	current_chat_index += 1
	if current_chat_index < chat_texts.size():
		show_chat_ui(chat_texts[current_chat_index]) 
	else:
		stop_chat()  

func show_chat_ui(text: String) -> void:
	chat_label.text = text

func _on_chat_area_area_entered(area: Area2D) -> void:
	print("Entered chat area")
	if area.get_parent().is_in_group("player"):  
		print("Player detected in chat area")  # Debugging
		is_chatting = true
		current_chat_index = 0  
		start_chat()

func _on_chat_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):  
		is_chatting = false
		stop_chat()
