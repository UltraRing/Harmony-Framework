function game_init_font()
{
	global.hud_number = font_add_sprite(spr_hud_numbers, ord("0"), false, 0);
	global.font_debug = font_add_sprite_ext(spr_font_debug, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ΔÇüéâäàåçêëèïîìÄÂÉæÆôöòûùÿü¢£¥ƒáíóúñÑͣ°¿⌐¬½¼¡«»", false,0);
	global.font_small = font_add_sprite_ext(spr_font_small, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`", false, 0);
	global.font_text = font_add_sprite_ext(spr_font_text, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.:-!", true, 1);
	global.bss_number = font_add_sprite_ext(spr_hud_bss_numbers, "0123456789", false, 0);
	global.font_titlecard = font_add_sprite_ext(spr_font_titlecard, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ ", true, -1);
}