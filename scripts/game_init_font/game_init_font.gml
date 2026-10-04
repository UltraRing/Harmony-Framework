function game_init_font()
{
	global.hud_number = font_add_sprite(spr_hud_numbers, ord("0"), false, 0);
	global.text_font = font_add_sprite_ext(spr_hud_font, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", false, 0);
	global.font_debug = font_add_sprite_ext(spr_font_debug, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~€‚", false,0);
	global.font_small = font_add_sprite_ext(spr_font_small, " ! #$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ", false, 0);
	global.text_random = font_add_sprite_ext(spr_font_random, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.:-!", true, 1);
	global.bss_number = font_add_sprite_ext(spr_hud_bss_numbers, "0123456789", false, 0);
	global.font_titlecard = font_add_sprite_ext(spr_font_titlecard, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ ", true, -1);
}