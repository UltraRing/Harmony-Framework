function game_macros()
{
	// Developer mode macro
	#macro DEVMODE (os_get_config() == "Dev")
	
	// Easy to access global variable macros
	#macro WINDOW_WIDTH global.window_width
	#macro WINDOW_HEIGHT global.window_height
	#macro FRAME_TIMER global.object_timer
		
	// Culling region size
	#macro CULL_REGION_W 128
	#macro CULL_REGION_H 128
	
	// Culling region offsets for moving platforms
	#macro PLATFORM_CULL_W 32
	#macro PLATFORM_CULL_H 32
	
	// Macros for camera position and sides (All viewports)
	#macro CAMERA_VIEW_X camera_get_view_x(view_camera[view_current])
	#macro CAMERA_VIEW_Y camera_get_view_y(view_camera[view_current])
	#macro CAMERA_VIEW_W camera_get_view_width(view_camera[view_current])
	#macro CAMERA_VIEW_H camera_get_view_height(view_camera[view_current])
}