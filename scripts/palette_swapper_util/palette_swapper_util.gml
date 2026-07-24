//Basic Palette Swapper with the original functionality
    function palette_swap(texture, index){
        //Get the shader
        var shader = shd_color_replacer;
        
        //Get shader uniforms
        var sampled_id = shader_get_sampler_index(shader, "u_sPalette");
        var u_coords = shader_get_uniform(shader, "u_vPalcoords");
        var u_size = shader_get_uniform(shader, "u_vSize");
        var u_index = shader_get_uniform(shader, "u_fIndex");
        var u_tolerance = shader_get_uniform(shader, "u_fTolerance");
        
        //Get values for shader
        var tex = sprite_get_texture(texture, 0);
        var coords = texture_get_uvs(tex);
        var size_w = texture_get_texel_width(tex);
        var size_h = texture_get_texel_height(tex);
        var tolerance = 0.004;
        
        //Get sprite height
        var height = sprite_get_height(texture)
        
        //Set the shader
        shader_set(shader);
        var ind
        ind = index mod (height-1);
        //ind = max(ind, 1);
        
        //Set the shader uniforms
        texture_set_stage(sampled_id, tex);
        shader_set_uniform_f(u_coords, coords[0], coords[1], coords[2], coords[3]);
        shader_set_uniform_f(u_size, size_w, size_h);
        shader_set_uniform_f(u_index, ind + 1);
        shader_set_uniform_f(u_tolerance, tolerance);
    	
    }

//Palette Swapper Construct
    function palette_swapper_create() constructor 
    {
        palettes = [];
        current_palette_id = -1;
    }
    
    function palette_add(swapper, palette_id, palette_sprite, palette_start_index=0, palette_speed=0, palette_loop_index=-1)
    {
        swapper.palettes[palette_id] =
        {
            palette_sprite: palette_sprite,
            palette_index:  palette_start_index,
            palette_speed:  palette_speed,
            palette_loop:   palette_loop_index,
            
            palette_amount: sprite_get_height(palette_sprite)-1,
            palette_finished: false,
            palette_reset_flag: false,
            
            palette_initial: {
                palette_sprite: palette_sprite,
                palette_index:  palette_start_index,
                palette_speed:  palette_speed,
                palette_loop:   palette_loop_index,
            }
        }
    }
    
    function palette_reset(swapper)
    {
        swapper.palette_reset_flag = true;
    }
    
    function palette_swapper_update(swapper)
    {
        with (swapper.palettes[swapper.current_palette_id])
        {
            if ((palette_loop > -1 && palette_index >= palette_amount) || (palette_finished && palette_reset_flag))
            {
                palette_index %= palette_amount;
                palette_reset_flag = false;
                palette_finished = false;
            }
            else if (palette_loop == -1 && palette_index >= palette_amount)
            {
                palette_finished = true;
            }
            
            palette_index += palette_speed;
            
            if (palette_index < palette_loop)
            {
                palette_index = (palette_index % 1) + palette_loop;
            }
            
            palette_index = clamp(palette_index, 0, palette_amount);
        }
    }
    
    function palette_play(swapper, palette_id, reset_palette_start=true)
    {
        if(!global.process_objects)
            exit;
        
        //If current palette is not matching the palette ID, then update it
        if(swapper.current_palette_id != palette_id)
        {
            //If palette doesn't exist just don't update anything
            if(palette_id > array_length(swapper.palettes)-1)
                exit;	
            
            //Update the current palette
            swapper.current_palette_id = palette_id;
            
            with (swapper.palettes[swapper.current_palette_id]) {
                //Reset palette's properties
                if (reset_palette_start) {
                    palette_index = palette_initial.palette_index;
                }
                
                palette_finished = false;
                palette_reset_flag = false;
                palette_speed = palette_initial.palette_speed;
                palette_loop = palette_initial.palette_loop;
            }
        }
    }
    
    function palette_swapper_start(swapper)
    {
        //Get the shader
        var shader = shd_color_replacer;
        
        //Get shader uniforms
        var sampled_id = shader_get_sampler_index(shader, "u_sPalette");
        var u_coords = shader_get_uniform(shader, "u_vPalcoords");
        var u_size = shader_get_uniform(shader, "u_vSize");
        var u_index = shader_get_uniform(shader, "u_fIndex");
        var u_tolerance = shader_get_uniform(shader, "u_fTolerance");
        
        //Get values for shader
        var tex = sprite_get_texture(swapper.palettes[swapper.current_palette_id].palette_sprite, 0);
        var coords = texture_get_uvs(tex);
        var size_w = texture_get_texel_width(tex);
        var size_h = texture_get_texel_height(tex);
        var tolerance = 0.004;
        
        //Get sprite height
        var height = sprite_get_height(swapper.palettes[swapper.current_palette_id].palette_sprite)
        
        //Set the shader
        shader_set(shader);
        var ind
        ind = swapper.palettes[swapper.current_palette_id].palette_index mod (height-1);
        //ind = max(ind, 1);
        
        //Set the shader uniforms
        texture_set_stage(sampled_id, tex);
        shader_set_uniform_f(u_coords, coords[0], coords[1], coords[2], coords[3]);
        shader_set_uniform_f(u_size, size_w, size_h);
        shader_set_uniform_f(u_index, ind + 1);
        shader_set_uniform_f(u_tolerance, tolerance);
    }
    
    //Palette Swapper Check/Set Functions
        function palette_has_finished(swapper)
        {
            return swapper.palettes[swapper.current_palette_id].palette_finished;
        }
        
        function palette_is_playing(swapper, palette_id)
        {
            return swapper.current_palette_id == palette_id;
        }
        
        function palette_swapper_get_current_palette(swapper)
        {
            return swapper.current_palette_id;
        }
        
        function palette_get_sprite(swapper)
        {
            return swapper.palette_sprite;
        }
        
        function palette_swapper_get_index(swapper)
        {
            return swapper.palettes[swapper.current_palette_id].palette_index;	
        }
        
        function palette_get_speed(swapper)
        {
            return swapper.palettes[swapper.current_palette_id].palette_speed;
        }
        
        function palette_get_index_count(swapper)
        {
            return swapper.palettes[swapper.current_palette_id].palette_amount;
        }
        
        function palette_get_loop_index(swapper)
        {
            return swapper.palettes[swapper.current_palette_id].palette_loop;
        }
        
        function palette_set_speed(swapper, palette_speed)
        {
            swapper.palettes[swapper.current_palette_id].palette_speed = palette_speed;
        }
        
        function palette_set_loop_index(swapper, palette_loop_index)
        {
            swapper.palettes[swapper.current_palette_id].palette_loop = palette_loop_index;
        }
        
        function palette_set_index(swapper, palette_index)
        {
            swapper.palettes[swapper.current_palette_id].palette_index = palette_index;
        }