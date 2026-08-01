	// This is where you configure Harmony Framework
	
	// Game's default resolution
	#macro GAME_WINDOW_WIDTH 426
	#macro GAME_WINDOW_HEIGHT 240
	
	// The size of the grid for the angle sensors, default is 16x16
	#macro ANGLE_GRID_SIZE 16
	
	// A flag for the alternative way of handling how ground collision mode changes,
	// setting it to true will make it closer to Sonic Studio [Resource link: https://sonicstudiofangame.weebly.com/blog/improving-classic-sonic-physics]
	#macro PLAYER_ALT_COLLISION_MODE true
	
	// The maximum step collision precision player could have
	#macro PLAYER_MAX_STEPS 4
	
	// This macro is used to divide player's movement for step collision variable, the lower the number the more precise collision is along with execution time
	#macro PLAYER_STEPS_AMOUNT 14
	
	// Configuration for insta shield's hitbox size for all four sides
	#macro INSTA_SHIELD_BOX_SIZE 24
	
	// Configuration for water flashing color
	#macro WATER_FLASH_COLOR #e0e0e0
	
	// Configuration flag for allowing water to flash when the electric shield is lost
	#macro WATER_FLASH false
	
	// Configuration flag for usage of Sonic 3's Knuckles glide turning behaviour
	#macro KNUCKLES_S3_GLIDE_TURN false