/// @description Blue Spheres controller

bss_load_playfield(); //scalable playfield from the room's "Playfield" tilemap

global.bss.chain = array_create(global.bss.size, BSS_CELL.NONE);
global.bss.coll  = array_create(global.bss.size, BSS_CELL.NONE);
global.bss.lastSX = 0;
global.bss.lastSY = 0;
global.bss.loop = false;

center_x = WINDOW_WIDTH div 2;

//Per-stage config
stage_music = MUSIC.BLUE_SPHERES;
ring_target = 64;
palette_index = 0; //tex_pal_bss row used to recolour the stage

//Character animator
bss_setup_character();

bss_special_stage_start();
