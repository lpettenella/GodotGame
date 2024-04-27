extends Area2D

signal Obstacle
signal Checkpoint

enum TerrainType {
	OBSTACLE = 1
}

var current_tilemap
	
func update_terrain(terrain_mask: int):
	if terrain_mask == 1:
		Obstacle.emit()
	pass
	
func process_tilemap_collision(body: TileMap, body_rid):
	current_tilemap = body
	
	var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
	
	for index in current_tilemap.get_layers_count():
		var tile_data = current_tilemap.get_cell_tile_data(index, collided_tile_coords)
		if not tile_data is TileData:
			continue
		var terrain_mask = tile_data.get_custom_data_by_layer_id(0)
		if terrain_mask != null:
			update_terrain(terrain_mask)

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		process_tilemap_collision(body, body_rid)

func _on_area_entered(area):
	Checkpoint.emit(area)
