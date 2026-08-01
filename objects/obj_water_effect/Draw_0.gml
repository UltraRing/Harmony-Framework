/// @description Draw stuff
	if(!instance_exists(obj_water)) exit;
	var tileLayer, layerList;
	
	layerList = ["BackgroundObject", "PlaneFront", "PlaneBack"]

	for(var i = 0; i < array_length(layerList); i++)
	{
		tileLayer = layer_get_id(layerList[i]);
		layer_script_begin(tileLayer, aaz2_water_dist_start);
		layer_script_end(tileLayer, i == 0 ? aaz2_water_dist_bg_end : aaz2_water_dist_end);
	}
