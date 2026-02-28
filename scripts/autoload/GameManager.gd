extends Node

signal money_changed(player_id, new_amount)

var player_money := {}

func _ready():
    # Starting money
    player_money[1] = 650
    player_money[2] = 650


func add_money(player_id: int, amount: int):
    player_money[player_id] += amount
    money_changed.emit(player_id, player_money[player_id])


func can_afford(player_id: int, cost: int) -> bool:
    return player_money[player_id] >= cost


func spend_money(player_id: int, cost: int) -> bool:
    if not can_afford(player_id, cost):
        return false

    player_money[player_id] -= cost
    money_changed.emit(player_id, player_money[player_id])
    return true


func get_money(player_id: int) -> int:
    return player_money[player_id]
