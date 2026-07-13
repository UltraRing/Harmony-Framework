function char_add(name, select_sprite, hitbox_normal, hitbox_rolling, camera_rolling_offset, physics_table, super_palette, animation_setup)
{
	//Name
	char_name[global.character_total] = name;
	
	//Hitboxes
	char_hitbox_normal[global.character_total] = hitbox_normal;
	char_hitbox_rolling[global.character_total] = hitbox_rolling;
	char_camrolling_offset[global.character_total] = camera_rolling_offset;
	
	//Physics
	char_physic_table[global.character_total] = physics_table;
	
	//Visuals
	char_super_palette[global.character_total] = super_palette;
	char_select_sprite[global.character_total] = select_sprite;
	char_anim_script[global.character_total] = animation_setup;
	
	global.character_total++;
}

function char_physics_table(Accel, Deaccel, Fric, Grav, Top_speed, Jump_strength, Jump_release, Roll_fric, Slope_up, Slope_down) constructor
{
	if(array_length(Accel) == 0) accel = array_create(2, Accel); else accel = Accel;
	if(array_length(Deaccel) == 0) deaccel = array_create(2, Deaccel); else deaccel = Deaccel;	
	if(array_length(Fric) == 0) fric = array_create(2, Fric); else fric = Fric;	
	if(array_length(Grav) == 0) grav = array_create(2, Grav); else grav = Grav;	
	if(array_length(Top_speed) == 0) top_speed = array_create(2, Top_speed); else top_speed = Top_speed;	
	if(array_length(Jump_strength) == 0) jump_strength = array_create(2, Jump_strength); else jump_strength = Jump_strength;
	if(array_length(Jump_release) == 0) jump_release = array_create(2, Jump_release); else jump_release = Jump_release;
	if(array_length(Roll_fric) == 0) roll_fric = array_create(2, Roll_fric); else roll_fric = Roll_fric;
	if(array_length(Slope_up) == 0) slope_up = array_create(2, Slope_up); else slope_up = Slope_up;
	if(array_length(Slope_down) == 0) slope_down = array_create(2, Slope_down); else slope_down = Slope_down;
}

function char_animation_list(char = global.character)
{
	script_execute(obj_global.char_anim_script[char], super);
}

function char_get_hitbox_normal(char = global.character)
{
	return obj_global.char_hitbox_normal[char];
}

function char_get_hitbox_rolling(char = global.character)
{
	return obj_global.char_hitbox_rolling[char];
}

function char_get_super_palette(char = global.character)
{
	return obj_global.char_super_palette[char];
}

function char_get_name(char = global.character)
{
	return obj_global.char_name[char];
}

function char_get_menu_sprite(char = global.character)
{
	return obj_global.char_select_sprite[char];
}

function char_get_camera_roll_offset(char = global.character)
{
	return obj_global.char_camrolling_offset[char];
}

function char_get_physics_table(char = global.character)
{
	return obj_global.char_physic_table[char];
}