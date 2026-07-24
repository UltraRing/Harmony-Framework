function background_create() constructor
{
    bg_layers = [];
    bg_id = 0;
    
    static background_add_layer = function(sprite, frame, scroll_x, scroll_y, spd_x=0, spd_y=0, off_x=0, off_y=0, vertical_loop=false)
    {
        var oldId = bg_id;
        
        bg_layers[bg_id] = {
            background_sprite: sprite,
            background_sprite: sprite,
            background_frame: frame,
            factor_x: scroll_x,
            factor_y: scroll_y,
            speed_x: spd_x,
            speed_y: spd_y,
            offset_x: off_x,
            offset_y: off_y,
            background_vertical: vertical_loop,
            
            line_scroll: false,
            visibility: true,
            trigger: false,
            
            anim_speed: 0,
            alpha: 1,
            
            blend: {
                mode: undefined,
                src: undefined,
                dst: undefined,
                eq: undefined,
                eq_alpha: undefined,
            },
            
            palette_swapper: undefined, //Add support for palette swapper constructor later...
        }
        bg_id++;
        
        return oldId;
    }
    
    static background_add_line_layer = function(sprite, frame, scroll_x, scroll_y, spd_x, spd_y, off_x, off_y, gaps, steps, y_scale=1)
    {
        var oldId = bg_id;
        
        bg_layers[bg_id] = {
            background_sprite: sprite,
            background_frame: frame,
            factor_x: scroll_x,
            factor_y: scroll_y,
            speed_x: spd_x,
            speed_y: spd_y,
            offset_x: off_x,
            offset_y: off_y,
            line_gap: gaps,
            line_steps: steps,
            bg_scale: y_scale,
            
            background_vertical: false,
            line_scroll: true,
            trigger: false,
            visibility: true,
            
            anim_speed: 0,
            alpha: 1,
            
            blend: {
                mode: undefined,
                src: undefined,
                dst: undefined,
                eq: undefined,
                eq_alpha: undefined,
            },
            
            palette_swapper: undefined, //Add support for palette swapper constructor later...
        }
        bg_id++;
        
        return oldId;
    }
    
    static background_layer_set_animation_speed = function(layer_id, speed=0)
    {
        bg_layers[layer_id].anim_speed = speed;
    }
    
    static background_layer_set_alpha = function(layer_id, alpha=1)
    {
        bg_layers[layer_id].alpha = alpha;
    }
    
    /// @description                 Set a blendmode to a background layer from a list of preset blend modes, coresponding to the given layer ID.
    /// @param {layer_id}   layer_id The ID of the background layer.
    /// @param {mode}       mode     The blendmode preset name. The options are: "lighten", "darken", "addition", and "multiply".
    static background_layer_set_blendmode_preset = function(layer_id, mode = "normal")
    {
        with(bg_layers[layer_id]) {
        	switch(mode) {
                case "lighten":
                    blend.src = bm_one;
                    blend.dst = bm_dest_color;
                    
                    blend.eq = bm_eq_max;
                    blend.eq_alpha = bm_eq_add;
                break;
                case "darken":
                    blend.src = bm_one;
                    blend.dst = bm_dest_color;
                    
                    blend.eq = bm_eq_min;
                    blend.eq_alpha = bm_eq_add;
                break;
                case "addition":
                    blend.mode = bm_add;
                break;
                case "multiply":
                    blend.src = bm_zero;
                    blend.dst = bm_src_color;
                break;
            }
        }
    }
    
    /// @description                 Set a blendmode to a background layer coresponding to the given layer ID.
    /// @param {layer_id}   layer_id The ID of the background layer.
    /// @param {mode}       mode     The blendmode constant. It can either take a singular blendmode constant (ex. bm_add) or an array that contains source and destination blendmode factors (ex. [ bm_one, bm_dest_color ]).
    static background_layer_set_blendmode = function(layer_id, mode)
    {
        if(is_array(mode)) {
            bg_layers[layer_id].blend.src = mode[0];
            bg_layers[layer_id].blend.dst = mode[1];
        }
        else {
            bg_layers[layer_id].blend.mode = mode;
        }
        
    }
    
    /// @description                           Set a blendequation to a background layer coresponding to the given layer ID.
    /// @param {layer_id}       layer_id       The ID of the background layer.
    /// @param {equation}       equation       The blendequation constant.
    /// @param {equation_alpha} equation_alpha The blendequation constant for the alpha channel.
    static background_layer_set_blendequation = function(layer_id, equation, equation_alpha = undefined)
    {
        bg_layers[layer_id].blend.eq = equation;
        bg_layers[layer_id].blend.eq_alpha = equation_alpha;
    }
}

function background_draw_layer()
{
    if(!visibility) 
        exit;
    
    //Draw the background
    if(!line_scroll)
    {
        draw_sprite_tiled_new(background_sprite, background_frame, floor(pos_x), floor(pos_y), background_vertical ? 2 : 0);
    }
    else
    {
        //Set the linescroll shader
        shader_set(shd_line_scroll);
        
        //Get shader's uniforms
        var BGWidth = shader_get_uniform(shd_line_scroll, "Width");
        var BGTexel = shader_get_uniform(shd_line_scroll, "TexelWidth");
        var OffX = shader_get_uniform(shd_line_scroll, "OffsetX");
        var PosX = shader_get_uniform(shd_line_scroll, "Position");
        var HeightY = shader_get_uniform(shd_line_scroll, "LineGaps");
        var StepY = shader_get_uniform(shd_line_scroll, "YSteps");
        var ScaleY = shader_get_uniform(shd_line_scroll, "YScale");
        var ShdHeight = shader_get_uniform(shd_line_scroll, "Height");
        
        var repSize = (camera_get_view_width(view_camera[view_current]) / sprite_get_width(background_sprite));
        
        for (var i = -1; i < repSize; ++i) 
        {
            var px = camera_get_view_x(view_camera[view_current]) + sprite_get_width(background_sprite) * i;
        
            //Set shader uniforms
            shader_set_uniform_f(BGWidth, sprite_get_width(background_sprite));
            shader_set_uniform_f(BGTexel, texture_get_texel_width(sprite_get_texture(background_sprite, 0)));
            shader_set_uniform_f(OffX, pos_x);
            shader_set_uniform_f(PosX, px, pos_y);
            shader_set_uniform_f(StepY, line_steps/(1-factor_x));
            shader_set_uniform_f(HeightY, line_gap);
            shader_set_uniform_f(ScaleY, bg_scale); 
            shader_set_uniform_f(ShdHeight, sprite_get_height(background_sprite)); 
            
            draw_sprite_ext(background_sprite, background_frame, px, floor(pos_y) , 1, bg_scale, 0, c_white, alpha);
        }
    }
    
    //Reset the values
    shader_reset();
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    gpu_set_blendequation(bm_eq_add);
}

function background_position_layer()
{
    //Act transition background offset adjustments
    if(trigger)
    {
        //Horizontal offset
        var reposition_x =  ((camera_get_view_x(view_camera[view_current])*factor_x) + offset_x)
        diff_x = reposition_x - camera_get_view_x(view_camera[view_current]);
        offset_x += offset_x - diff_x
            
        //Vertical offset
        var reposition_y =  ((camera_get_view_y(view_camera[view_current])*factor_y) + offset_y)
        diff_y = reposition_y - camera_get_view_y(view_camera[view_current]);
        offset_y += offset_y - diff_y
            
        //Disable the trigger
        trigger = false;
    }
    
    //Different types of scrolling
    if(!line_scroll)
    {
        //Normal scrolling
        pos_x = ((camera_get_view_x(view_camera[view_current])*factor_x) + offset_x)
        pos_y = floor(camera_get_view_y(view_camera[view_current])*factor_y + offset_y);
        
        diff_x = pos_x - camera_get_view_x(view_camera[view_current]);
        diff_y = pos_y - camera_get_view_y(view_camera[view_current]);
    }
    else
    {
        //Normal scrolling
        pos_x = ((camera_get_view_x(view_camera[view_current])*(1-factor_x)) - offset_x);
        pos_y = floor(camera_get_view_y(view_camera[view_current])*factor_y + offset_y);
        
        diff_x = ((camera_get_view_x(view_camera[view_current])*factor_x) + offset_x) - camera_get_view_x(view_camera[view_current])
        diff_y = (floor(camera_get_view_y(view_camera[view_current])*factor_y) + offset_y) - camera_get_view_y(view_camera[view_current])
    }
        
    //Auto scrolling
    if(global.process_objects)
    {
        offset_x += speed_x;
        offset_y += speed_y;
    }
}

function background_update_layer_values()
{
    //Sprite Animation
        if (anim_speed != 0) background_frame += anim_speed;
    
    //Alpha
        draw_set_alpha(alpha);
    
    //Blendmodes
        if(blend.src && blend.dst) {
            gpu_set_blendmode_ext(blend.src, blend.dst);
            gpu_set_alphatestenable(true);
        }
        else if(blend.mode) {
            gpu_set_blendmode(blend.mode);
        }
    
    //Blendequations
        if(blend.eq && blend.eq_alpha) {
            gpu_set_blendequation_sepalpha(blend.eq, blend.eq_alpha);
            gpu_set_alphatestenable(true);
        }
        else if(blend.eq) {
            gpu_set_blendequation(blend.eq);
        }
    
    //Add support for palette swapper constructor later...
    
}