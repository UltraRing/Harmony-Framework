	// Collision plane layer
	enum PLANE
	{
		A,
		B
	}
	
	// Side of a collision hitbox
	enum COLLISION
	{
		MAIN,
		BOTTOM,
		TOP,
		LEFT,
		RIGHT
	}
	
	// Terrain collision mode
	enum COLLISION_MODE
	{
		FLOOR,
		LEFT_WALL,
		CEILING,
		RIGHT_WALL,
	}
	
	// Fade type
	enum FADE
	{
		IN = 1,
		OUT = -1,
	}
	
	// Fade color type
	enum FADE_COLOR
	{
		BLACK,
		WHITE,
	}
	
	// Enums for monitor type
	enum MONITOR
	{
		RINGS,
		SHIELD,
		FIRE_SHIELD,
		ELECTRIC_SHIELD,
		BUBBLE_SHIELD,
		INVINCIBLE,
		SPEED_SHOES,
		EXTRA_LIFE,
		EGGMAN,
		COMBINE_RING
	}
	
	// Enums for culling type
	enum CULL_TYPE
	{
		DISABLE,
		DEACTIVATE
	}
	
	// Enums for culling flags
	enum CULL_FLAG
	{
		CHECK_ENTITY_POS = 1 << 0,	
		CHECK_ENTITY_START = 1 << 1
	}
	
	// Enums for bounding box sides
	enum BBOX
	{
		LEFT,
		TOP,
		RIGHT,
		BOTTOM
	}
	
	// Stage state
	enum LEVEL_STATE
	{
		NORMAL,
		BONUS,
	}
	
	// Checkpoint types
	enum CHECKPOINT
	{
		NORMAL,
		SPECIAL_RING
	}
	
	// Shields
	enum SHIELD
	{
		NONE = -1,
		NORMAL,
		FIRE,
		ELECTRIC,
		BUBBLE,
		END,
	}
	
	// Collision indexes
	enum COL_INDEX
	{
		GLOBAL,
		END,
	}

	// Special stage results
	enum SS_RESULT
	{
		FAILED,
		GOT_EMERALD,
	}