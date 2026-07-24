/// @description Add background
    water_layer = undefined;	
    
	//Inherit the parent event
	event_inherited();
	
    with (background)
    {
        //Add backgrounds, ID starting out from 0, increments by 1 with each background added
        background_add_layer(spr_bg_aaz_bottom, 5, 1, 1, 0, 0, 0, 0, false); //ID 0
        
        // You may use fractions as parallax factors too!
        background_add_layer(spr_bg_aaz_ruins, 0, 2/3, 2/3, 0, 0, 0, 354, false); //ID 1
        background_add_layer(spr_bg_aaz_ruins, 1, 2/3, 2/3, 0, 0, 0, 930, false); //ID 2
        
        // HCZ-like 3d water parallax
        other.water_layer = background_add_line_layer(spr_bg_aaz_water, 1, 2/3, 2/3, 0, 0, 0, 930, 1, (2/3)/96); //ID 3 - this will be accessed later in Draw
        
        /* In the above example, 2/3 is the X factor of the top part of the water, and 96 is the height.
        This allows for the top of the water parallax to be the same speed as the horizon and the bottom
        of the water parallax to be the same speed as the foreground. In previous versions of Harmony
        Framework the calculation for the speeds was done in a way that required extra math to be done
        for this effect, but now it can be done with a single divison!*/    
    }
