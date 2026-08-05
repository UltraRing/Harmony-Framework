/// @description Render the playfield

//Background + globe, recoloured to the chosen tex_pal_bss row
effect_set_palette(tex_pal_bss, palette_index);

//Scrolling parallax background
var bgw = sprite_get_width(spr_bss_bg);
var bgh = sprite_get_height(spr_bss_bg);
draw_sprite_tiled_ext(spr_bss_bg, 0, -(bg_scroll_x mod bgw), (bg_scroll_y mod bgh) - bgh, 1, 1, c_white, 1);

//Rolling globe frames, or the pre-rendered turn animation while the globe layer is hidden
if (globe_hidden)
{
	var fl = turn_flip ? -1 : 1;
	//Match the turn sprite's checkerboard colours to the current palette parity
	var turn_spr = (palette_page & 1) ? spr_bss_globe_turn_b : spr_bss_globe_turn_a;
	draw_sprite_ext(turn_spr, turn_frame, center_x, 240, fl, 1, 0, c_white, 1);
}
else
{
	var bf = ((palette_page & 1) * 16 + palette_line) mod 32;
	draw_sprite(spr_bss_globe_roll, bf, center_x, 240);
}

shader_reset();

//Horizon glow blending (Uncomment this if you like Sonic Mania!)
/*
gpu_set_blendmode(bm_add);
draw_sprite_ext(spr_bss_horizon,  0, center_x, 240, 1, 1, 0, c_white, 0.5); 
draw_sprite_ext(spr_bss_rimlight, 0, center_x, 240, 1, 1, 0, c_white, 0.5);
gpu_set_blendmode(bm_normal);
*/

//Player shadow
draw_sprite_ext(spr_bss_player_shadow, 0, center_x, 170, 1, 1, 0, c_white, 1);

//BSS_Setup_HandleCollectableMovement

//Facing angle, its integer sine/cosine and the current cardinal quadrant
var aa = angle & 255;
var cs = cos256(aa);
var sn = sin256(aa);
var offset_dir = (aa >> 6) & 3;

//Visible cell offsets, the second frustum covers the mid-turn angles
var use_f2 = ((aa & 0x3F) != 0);
var fxs = use_f2 ? global.bss.frustum2X : global.bss.frustum1X;
var fys = use_f2 ? global.bss.frustum2Y : global.bss.frustum1Y;
var fcount = array_length(fxs);

for (var i = 0; i < fcount; i++)
{
	//Rotate the offset into the current quadrant
	var ox, oy;
	switch (offset_dir)
	{
		case 0: ox =  fxs[i]; oy =  fys[i]; break; //FLIP_NONE
		case 1: ox = -fys[i]; oy =  fxs[i]; break; //FLIP_X
		case 2: ox =  fxs[i]; oy = -fys[i]; break; //FLIP_Y
		case 3: ox =  fys[i]; oy =  fxs[i]; break; //FLIP_XY
	}
	
	//Wrap the offset around the board
	var idx = bss_wrap_y(oy + player_y) + (BSS_H * bss_wrap_x(ox + player_x));
		
	//Get the cell index
	var tile = global.bss.pf[idx];
		
	//No object? Skip
	if (tile == BSS_CELL.NONE) continue;
	
	//Rotate the cell into view space
	var sx = ((ox * cs + oy * sn) >> 4);
	var sy = ((oy * cs - ox * sn) >> 4);
	
	//Depth row, blending in the roll scroll
	var dep = -(sy + palette_line - 16);
	
	//Behind the camera or past the horizon? Skip
	if (dep < 0 || dep >= 112) continue;
	
	//Scale frame shrinks with depth and toward the screen edges
	var f = global.bss.frameTable[dep] - (abs(sx) >> 5);
	if (f < 0) f = 0;
	
	//Fan the cell out horizontally with perspective correction
	var fxv  = global.bss.xMultiplierTable[dep] * sx;
	var dist = (fxv * fxv) div 65536; //1 << 16
	var worldX = (((fxv <= 0) ? fxv + dist : fxv - dist) >> 4);
	
	//Screen position, following the globe's curved horizon
	var dx = worldX + center_x;
	var dy = global.bss.screenYTable[dep] + (worldX * worldX) div global.bss.divisorTable[dep];
	
	//Jettisonning
	if (state == BSS_STATE.JETTISON)
	{
		dx = (((256 + spin_timer) * (dx - center_x)) >> 8) + center_x;
		dy -= spin_timer * 2;
	}
	
	//Draw the cell
	bss_draw_cell(tile, dx, dy, f, ring_spin, floor(medal_spin), global.bss.spark_phase, emerald_index);
}

//Draw player
var py = 170 + ((gravity_strength >> 1) - (gravity_strength >> 4)) / 65536; //1 << 16
draw_animator(animator, center_x, py, 1, 1, 0, c_white, 1);
if (has_tail) draw_animator(tail_animator, center_x, py, 1, 1, 0, c_white, 1);

//HUD counts
draw_set_color(c_white);
draw_sprite(spr_hud_bss_spheres, 0, center_x-141, 13);
draw_sprite(spr_hud_bss_rings, 0, center_x+64, 13);
bss_draw_number(sphere_count, center_x - 104 + 16, 17);
bss_draw_number(ring_count, center_x + 120 + 16, 17);

//Messages
if (msg_phase <= 2)
	bss_draw_message(spr_hud_bss_get_blue_spheres, center_x, 104, (msg_phase < 2) ? 0 : intro_offset);

if (perfect_active)
	bss_draw_message(spr_hud_bss_perfect, center_x, 104, perfect_offset); //slides in/out
