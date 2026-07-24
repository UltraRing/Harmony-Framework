/// @description Insert description here
// You can write your code in this editor

	if(obj_player.x >= x)
	{
		with(par_background)
		{
			for(var i = 0; i <= bg_id; i++)
			{
				bg_layers[i].offset_x -= (obj_player.x - obj_loop_start.x) * (1-bg_layers[i].factor_x);
			}
		}
		obj_camera.target_x -= obj_player.x - obj_loop_start.x;
		obj_player.x -= obj_player.x - obj_loop_start.x;
	
	}