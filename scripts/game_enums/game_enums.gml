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
	
	// Collision
	enum PLANE
	{	
		A,
		B
	}
	
	// Collision side
	enum C 
	{
		MAIN,
		BOTTOM,
		TOP,
		LEFT,
		RIGHT
	}
	
	// Collision mode
	enum CMODE 
	{
		FLOOR,
		LWALL,
		CEILING,
		RWALL
	}
	
	// Fading
	enum FADE
	{
		IN = 1,
		OUT = -1,
		BLACK = 0,
		WHITE = 1
	}
	
	// Animation for the player
	enum ANIM 
	{
		STAND,
		WAIT,
		WALK,
		RUN,
		MAXRUN,
		ROLL,
		LOOKDOWN,
		LOOKUP,
		SPINDASH,
		SPRING,
		HURT,
		PUSH,
		SKID,
		SKIDTURN,
		DIE,
		DROWN,
		BREATHE,
		LEDGE1,
		LEDGE2,
		VICTORY,
		DROPDASH,
		TAILSFLY,
		TAILSTIRED,
		TAILSSWIM,
		TAILSSWIMTIRED,
		KNUXGLIDE, 
		KNUXGLIDETURN,
		KNUXCLIMBUP, 
		KNUXCLIMBDOWN,
		KNUXCLIMBIDLE,
		KNUXLEDGE,
		KNUXFALL, 
		KNUXLAND, 
		KNUXSLIDE, 
		KNUXGETUP, 
		TRANSFORM,
		
		// Tails' tails animations
		TAILS_NORMAL,
		TAILS_ROLL,
	}
	