extends Control
class_name InventoryItem

signal Add
	
func add_to_inventory():
	Add.emit(self)
