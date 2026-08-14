/// @self
/// @description							Function used for playing a sound effect
/// @param {Asset.Sound} sound				The index of the sound to use
/// @param {Bool} loop						The flag to make sound loop or not
/// @param {Real} gain						Sets the gain of the sound effect
/// @param {Bool} interrupt					The flag to make the sound interrupt when played or not
/// @param {Id.AudioEmitter} emitter		The index of the sound emitter to use
/// @returns {Id.Sound}

function sound_play(sound, loop = false, gain = 1.0, interrupt = true, emitter = obj_global.sfx_emitter)
{
	//Stop the audio before playing so it doesn't overlay
	if(interrupt)
		audio_stop_sound(sound);
	
	//Play the sound
	return audio_play_sound_on(emitter, sound, 0, loop, global.sfx_volume * gain);
}

function sound_ring_pan_play(gain = 1.0){	  
	global.ring_pan *= -1;
	if global.ring_pan > 0 {
		if audio_is_playing(global.audio_ring_right){
			audio_stop_sound(global.audio_ring_right);
		}
		global.audio_ring_right = audio_play_sound_at(sfx_ring,100 * global.ring_pan,0,0,100,300,1,false,0,global.sfx_volume * gain);
		return global.audio_ring_right;
	} else {
		if audio_is_playing(global.audio_ring_left){
			audio_stop_sound(global.audio_ring_left);
		}
		global.audio_ring_left = audio_play_sound_at(sfx_ring,100 * global.ring_pan,0,0,100,300,1,false,0,global.sfx_volume * gain);
		return global.audio_ring_left;
	}
}