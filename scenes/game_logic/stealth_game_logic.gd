# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name StealthGameLogic
extends Node

@export var portal_item: Node

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Guard.game_started = false
	Guard.reset_chase_slots()
	# Ocultar portal al inicio
	if portal_item:
		portal_item.set("revealed", false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var player_detected_callback: Callable = Callable(self, "_on_player_detected")
	var guards: Array[Node] = get_tree().get_nodes_in_group(&"guard_enemy")
	for guard: Node in guards:
		if guard.has_signal(&"player_detected"):
			if guard.is_connected(&"player_detected", player_detected_callback):
				guard.disconnect(&"player_detected", player_detected_callback)
			guard.connect(&"player_detected", player_detected_callback)
	Guard.game_started = true

func _on_player_detected(_player: Node2D) -> void:
	pass
