function game_init_global_variables()
{
	//Game variables
	global.process_objects = true;			//Flag that allows step event of every object to be processed
	global.dev_mode = DEVMODE;					//Flag for developer mode, which allows you to use dev commands, don't forget to turn this off when releasing the game
	
	//Character globals
	global.character = CHAR_SONIC;			//Global value for the character
	
	//Screen values
	global.window_width  = GAME_WINDOW_WIDTH;				//Window's horizontal size
	global.window_height = GAME_WINDOW_HEIGHT;				//Window's vertical size
	global.window_size_limit = 4;							//Window size limiter
	global.window_size = 2;									//Window size multiplier
	global.draw_state = ds_stack_create();
	
	//Setup volume
	global.bgm_volume = 1;					//Music's channel volume
	global.sfx_volume = 1;					//Sound effects volume
	
	//Checkpoint values
	global.checkpoint = ds_list_create();	//The list of active checkpoints
	global.checkpoint_id = noone;			//Checkpoint that is currently active
	global.time_store = 0;					//Store value for timer when checkpoint gets active
	global.checkpoint_type = CHECKPOINT.NORMAL;
	global.special_ring_x = 0;
	global.special_ring_y = 0;
	global.special_ring_store = ds_list_create();
	
	global.bonus_room = rm_bonus				//Which bonus stage a checkpoint sends you to
	global.store_object_state = ds_list_create();
	global.previous_room = rm_splash
	global.store_player_state = 
	{
		shield : SHIELD.NONE,
		combinering : 0,
		rings : 0
	};
	global.store_background_visibility = {};
	global.allow_stage_restart = true;			//Allow the player to restart the stage during pause?
	
	//Stage values
	global.object_timer = 0;				//Object pre frame timer, every 60 frames in a 1 second
	global.score = 0;						//Global variable for score
	global.stage_timer = 0;					//Global variable for stage timer
	global.rings = 0;						//Global variable for rings
	global.life = 3;						//Global variable for life
	global.title_card = true;				//Flag that allows title card to be triggered, used in dev
	global.emeralds = [false, false, false, false, false, false, false];				//List of active emeralds
	global.col_tile = ["CollisionMain", "CollisionSemi", "CollisionA", "CollisionB"];	//List of collision layers
	global.col_tile_sprite = ["","","",""];
	global.collision_index = 0;
	global.extra_life_jingle = true;		//flag that plays a jingle that cuts out the music when true, plays a sound effect if false
	
	//Act transition variables
	global.monitor_store = [];				//List of monitor instances that were bumped with sign
	global.monitor_id = 0;					//Current list ID of bumped monitor
	global.act_transition = false;			//Act transition trigger, this is active for a single frame when new act starts
	
	//Extra life stuff
	global.score_extralife = 50000;			//Score threshold for extra life
	global.ring_extralife = 100;			//Ring threshold for extra life
	
	//Customizables variables
	global.rotation_type = 0;				// This changes player's visual rotation 
	global.use_peelout = true;				// Flag that allows peel-out ability
	global.use_dropdash = true;				// Flag that allows dropdash ability
	global.use_airroll = false;				// Flag that allows rolling while air-borne
	global.use_spindash = true;				// Flag that allows player to use the spindash
	global.use_insta_shield = false;		// Flag that allows player to use the insta shield
	global.camera_pan_type = 0;				// Variable that changes how camera panning works. 0 = No panning, 1 = Sonic CD panning[currently inaccurate], 2 = S1D/XG styled camera panning 
	global.chaotix_dust_effect = false;		// Flag that disables classic spindash/skid dust effect
	global.chaotix_monitors = false;		// Changes monitor icons to be like chaotix, monitor icon spins and it turns into dust
	global.camera_type = 1;					// Vertical camera scrolling type, 0 = Megadrive, 1 = Mania
	global.knux_camera_smooth = false;		// Flag for using smooth ledge climb camera movement
	global.water_running_effect = 0;		// 0 for the hydrocity effect, 1 for repeating splashes
	global.no_skid_state = true;			// makes skidding work closer to the genesis games, instead of a seperate state
	global.super_button = INPUT.C			// This defines which input will be used for super transformation
	
	global.draw_state_holder = 
	{
		col : draw_get_colour(),
		alpha : draw_get_alpha(),
        blendmode : gpu_get_blendmode(),
        blendmode_ext : gpu_get_blendmode_ext(),
        colourwriteenable : gpu_get_colourwriteenable(),
        cullmode : gpu_get_cullmode(),
        fog : gpu_get_fog(),
        ztestenable : gpu_get_ztestenable(),
        zfunc : gpu_get_zfunc(),
        zwriteenable : gpu_get_zwriteenable(),
        alphatestenable : gpu_get_alphatestenable(),
        alphatestref : gpu_get_alphatestref(),
        filter : gpu_get_texfilter(),
        wrap : gpu_get_texrepeat(),
        shader : shader_current(),
        mw : matrix_get(matrix_world),
        mv : matrix_get(matrix_view),
        mp : matrix_get(matrix_projection)
    };
	
	global.collision_result_struct = {
		object : noone,
		this_object : noone,
		this_box : noone,
		col_side : 0,
		col_x : 0,
		col_y : 0
	}
	
	// Not in use as of now
	//global.use_battery_rings = false;		// If this is disabled, destroying enemies will spawn flickies instead
}