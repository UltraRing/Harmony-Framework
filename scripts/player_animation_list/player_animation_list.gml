/// @self					obj_player	
/// @description			Function that handles player's animation list
function player_animation_list()
{
	enum ANIM {
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
		TRANSFORM,
		CORKSCREW,
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
		
		// Tails' tails animations
		TAILS_NORMAL,
		TAILS_ROLL,
	}
	
	
	switch(global.character)
	{
		case CHAR_SONIC:
		if (!super) 
		{
			animation_add(ANIM.STAND, spr_sonic_idle, 0.2)
			animation_add(ANIM.WAIT, spr_sonic_wait, 6, 2, true, true);
			animation_add(ANIM.WALK, spr_sonic_walk, 3, 0, true, true);
			animation_add(ANIM.RUN, spr_sonic_run, 2, 0, true, true);
			animation_add(ANIM.MAXRUN, spr_sonic_peelout, 0, 0, true, true);
			animation_add(ANIM.LOOKDOWN, spr_sonic_lookdown, 0.4, 0, false, false);
			animation_add(ANIM.LOOKUP, spr_sonic_lookup, 0.4, 0, false, false);
			animation_add(ANIM.PUSH, spr_sonic_push, 0.1, 0, true, false);
		} 
		else 
		{
			animation_add(ANIM.STAND, spr_super_sonic_idle, 0.2)
			animation_add(ANIM.WAIT, spr_super_sonic_wait, 12, 1, true, true);
			animation_add(ANIM.WALK, spr_super_sonic_walk, 3, 0, true, true);
			animation_add(ANIM.RUN, spr_super_sonic_run, 2, 0, true, true);
			animation_add(ANIM.MAXRUN, spr_super_sonic_run, 0, 0, true, true);
			animation_add(ANIM.LOOKDOWN, spr_super_sonic_lookdown, 0.4, 0, false, false);
			animation_add(ANIM.LOOKUP, spr_super_sonic_lookup, 0.4, 0, false, false);
			animation_add(ANIM.PUSH, spr_super_sonic_push, 0.1, 0, true, false);
		}
		animation_add(ANIM.ROLL, spr_sonic_roll, 0, 0, true, true);
		animation_add(ANIM.SPINDASH, spr_sonic_spindash, 0.6, 0, true, false);
		animation_add(ANIM.SPRING, spr_sonic_spring, 0.4, 0, true, false);
		animation_add(ANIM.SKID, spr_sonic_skid, 0.4, 0, false, false);
		animation_add(ANIM.SKIDTURN, spr_sonic_skidturn, 0.3, 0, false, false);
		animation_add(ANIM.HURT, spr_sonic_hurt, 0.3, 0, false, false);
		animation_add(ANIM.DIE, spr_sonic_death, 0.3, 0, false, false);
		animation_add(ANIM.DROWN, spr_sonic_drown, 0.3, 0, false, false);
		animation_add(ANIM.BREATHE, spr_sonic_breathe, 16, 0, false, true);
		animation_add(ANIM.LEDGE1, spr_sonic_ledge_left, 0.1, 0, true, false);
		animation_add(ANIM.LEDGE2, spr_sonic_ledge_right, 0.1, 0, true, false);
		animation_add(ANIM.VICTORY, spr_sonic_victory, 0.1, 1, true, false);
		animation_add(ANIM.TRANSFORM, spr_sonic_transform, 0.4, 3, true, false);
		animation_add(ANIM.CORKSCREW, spr_sonic_corkscrew, 0.2, 0, true, false);
		animation_add(ANIM.DROPDASH, spr_sonic_dropdash, 0.5, 1, true, false);
		break;
		
		case CHAR_TAILS:
		animation_add(ANIM.STAND, spr_tails_idle, [60, 6], 0, true, true);
		animation_add(ANIM.WAIT, spr_tails_wait, [80, 10], 0, true, true);
		animation_add(ANIM.WALK, spr_tails_walk, 3, 0, true, true);
		animation_add(ANIM.RUN, spr_tails_run, 2, 0, true, true);
		animation_add(ANIM.MAXRUN, spr_tails_maxrun, 1, 0, true, true);
		animation_add(ANIM.ROLL, spr_tails_roll, 0.4, 0, true, false);
		animation_add(ANIM.LOOKDOWN, spr_tails_lookdown, 0.4, 0, false, false);
		animation_add(ANIM.LOOKUP, spr_tails_lookup, 0.4, 0, false, false);
		animation_add(ANIM.SPINDASH, spr_tails_spindash, 0.6, 0, true, false);
		animation_add(ANIM.SPRING, spr_tails_spring, 0.4, 0, true, false);
		animation_add(ANIM.SKID, spr_tails_skid, 0.4, 0, false, false);
		animation_add(ANIM.SKIDTURN, spr_tails_skidturn, 0.3, 0, false, false);
		animation_add(ANIM.HURT, spr_tails_hurt, 0.3, 0, false, false);
		animation_add(ANIM.DIE, spr_tails_die, 0.3, 0, false, false);
		animation_add(ANIM.TAILSFLY, spr_tails_fly, 0.3, 0, true, false);
		animation_add(ANIM.TAILSTIRED, spr_tails_tired, 0.2, 0, true, false);
		animation_add(ANIM.TAILSSWIM, spr_tails_swim, 0.3, 0, true, false);
		animation_add(ANIM.TAILSSWIMTIRED, spr_tails_swim_tired, 0.2, 0, true, false);	
		animation_add(ANIM.DROWN, spr_tails_drown, 0.3, 0, false, false);
		animation_add(ANIM.BREATHE, spr_tails_breathe, 16, 0, false, true);
		animation_add(ANIM.PUSH, spr_tails_push, 0.1, 0, true, false);
		animation_add(ANIM.LEDGE1, spr_tails_ledge_left, 0.1, 0, true, false);
		animation_add(ANIM.LEDGE2, spr_tails_ledge_right, 0.1, 0, true, false);
		animation_add(ANIM.VICTORY, spr_tails_victory, 0.1, 0, false, false);
		animation_add(ANIM.TRANSFORM, spr_tails_transform, 0.4, 0, false, false);
		animation_add(ANIM.CORKSCREW, spr_tails_corkscrew, 0.2, 0, true, false);
		
		// Tails' tails animations
		animation_add(ANIM.TAILS_NORMAL, spr_tails_tail1, 0.15, 0, true, false);
		animation_add(ANIM.TAILS_ROLL, spr_tails_tail2, 0.25, 0, true, false);
		break;
		
		case CHAR_KNUX:
		animation_add(ANIM.STAND, spr_knuckles_idle, 0.2, 0, true, false);
		animation_add(ANIM.WAIT, spr_knuckles_wait, [60, 12], 2, true, true);
		animation_add(ANIM.WALK, spr_knuckles_walk, 3, 0, true, true);
		animation_add(ANIM.RUN, spr_knuckles_run, 0, 0, true, true);
		animation_add(ANIM.MAXRUN, spr_knuckles_maxrun, 0, 0, true, true);
		animation_add(ANIM.ROLL, spr_knuckles_roll, 0, 0, true, true);
		animation_add(ANIM.LOOKDOWN, spr_knuckles_lookdown, 0.4, 0, false, false);
		animation_add(ANIM.LOOKUP, spr_knuckles_lookup, 0.4, 0, false, false);
		animation_add(ANIM.SPINDASH, spr_knuckles_spindash, 0.6, 0, true, false);
		animation_add(ANIM.SPRING, spr_knuckles_spring, 0.4, 0, true, false);
		animation_add(ANIM.SKID, spr_knuckles_skid, 0.4, 0, false, false);
		animation_add(ANIM.SKIDTURN, spr_knuckles_skidturn, 0.3, 0, false, false);
		animation_add(ANIM.HURT, spr_knuckles_hurt, 0.3, 0, false, false);
		animation_add(ANIM.DIE, spr_knuckles_death, 0.3, 0, false, false);
		animation_add(ANIM.KNUXGLIDE, spr_knuckles_glide, 0.15, 0, true, false);
		animation_add(ANIM.KNUXGLIDETURN, spr_knuckles_turn, 0.12, 0, false, false);
		animation_add(ANIM.KNUXCLIMBUP, spr_knuckles_climb, 0.12, 0, true, false);
		animation_add(ANIM.KNUXCLIMBDOWN, spr_knuckles_climb_down, 0.12, 0, true, false);
		animation_add(ANIM.KNUXCLIMBIDLE, spr_knuckles_climb_idle, 0.12, 0, false, false);
		animation_add(ANIM.KNUXLEDGE, spr_knuckles_edge_climb, 4, 0, false, true);
		animation_add(ANIM.KNUXFALL, spr_knuckles_fall, 0.2, 0, false, false);
		animation_add(ANIM.KNUXLAND, spr_knuckles_landed, 0.2, 0, false, false);
		animation_add(ANIM.KNUXSLIDE, spr_knuckles_slide, 0.2, 0, false, false);
		animation_add(ANIM.KNUXGETUP, spr_knuckles_getup, 0.2, 0, false, false);
		animation_add(ANIM.DROWN, spr_knuckles_drown, 0.3, 0, false, false);
		animation_add(ANIM.BREATHE, spr_knuckles_breathe, 16, 0, false, true);
		animation_add(ANIM.PUSH, spr_knuckles_push, 0.1, 0, true, false);
		animation_add(ANIM.LEDGE1, spr_knuckles_ledge_left, 0.1, 0, true, false);
		animation_add(ANIM.LEDGE2, spr_knuckles_ledge_right, 0.1, 0, true, false);
		animation_add(ANIM.VICTORY, spr_knuckles_victory, 0.1, 0, false, false);
		animation_add(ANIM.TRANSFORM, spr_knuckles_transform, 0.4, 0, false, false);
		animation_add(ANIM.CORKSCREW, spr_knuckles_corkscrew, 0.2, 0, true, false);
		break;
	}
}