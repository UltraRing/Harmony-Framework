function player_state_transform(){
	if (!super) {
		transform_timer = 60;
		super = true;
		play_sound(sfx_transform);
		char_animation_list();
		animator_reset(animator);	
	}
	hitbox_allow = false;
	
    if (transform_timer >= 30) {
        direction_allow = false;
        movement_allow = false;
        gravity_allow = false;
		collision_allow = false;
		hitbox_allow = false;
        x_speed = 0;
        y_speed = 0;
		ground = false;
    }
    else {
        direction_allow = true;
        movement_allow = true;
        gravity_allow = true;
		collision_allow = true;

    }
	//Change animation
	animation_play(animator, ANIM.TRANSFORM);
    
    transform_timer -= 1;
    
    if (transform_timer <= 0 || ground) {
        state = player_state_normal;
		hitbox_allow = true;
        transform_timer = 0;
    }
}