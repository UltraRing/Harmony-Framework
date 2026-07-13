animator_update(animator);

if player_collide_object(C.MAIN){
	var player = instance_nearest(x,y,obj_player);
	var angle = point_direction(x,y,player.x,player.y);
	player.x_speed = BUMPER_FACTOR * dcos(angle);
	player.y_speed = -BUMPER_FACTOR * dsin(angle);
	player.ground = false;
	
	play_sound(sfx_bumper)
	score_life--;
	if (score_life > 0) {
		var obj = instance_create_depth(x, y, depth-1, obj_score_effect);
		obj.image_index = 6;
		global.score += 10;
	
	}
	animation_play(animator, BUMPERANI.BUMP);
}

if (animation_is_playing(animator, BUMPERANI.BUMP) && animation_has_finished(animator)){
	animation_play(animator, BUMPERANI.STOPPED);	
}