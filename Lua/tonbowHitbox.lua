
--Take a look at the hitboxes in Space Tonbow

while true do
	--Variables change every frame. Location found using Emulicious
	--Tonbow hurtbox
	tonbowHurtBoxX1 = memory.readbyte(0xC182);
	tonbowHurtBoxY1 = memory.readbyte(0xC181);
	tonbowHurtBoxW  = memory.readbyte(0xC185);
	tonbowHurtBoxH  = memory.readbyte(0xC186);
	--Tonbow hitbox
	tonbowHitBoxX1 = memory.readbyte(0xC17C);
	tonbowHitBoxY1 = memory.readbyte(0xC17B);
	tonbowHitBoxW  = memory.readbyte(0xC17F);
	tonbowHitBoxH  = memory.readbyte(0xC180);
	--Tonbow Position
	tonbowX1 = memory.readbyte(0xC18D);
	tonbowY1 = memory.readbyte(0xC18C);	

	--Demo Orb 1 hitbox
	demoOrb1HitBoxX1 = memory.readbyte(0xC1BC);
	demoOrb1HitBoxY1 = memory.readbyte(0xC1BB);
	demoOrb1HitBoxW  = memory.readbyte(0xC1BF);
	demoOrb1HitBoxH  = memory.readbyte(0xC1C0);
	--OrbShot hitbox
	orbShot1HitBoxX1 = memory.readbyte(0xC28D);
	orbShot1HitBoxY1 = memory.readbyte(0xC28C);
	orbShot1HitBoxW  = memory.readbyte(0xC290);
	orbShot1HitBoxH  = memory.readbyte(0xC291);

	--Variables will be ahead of what's being drawn, so if we draw the next frame
	--first,then the hitboxes will match up with how the hitboxes are drawn on screen
	emu.frameadvance();

	gui.drawText(10,0, "Tonbow Hurtbox Width: " .. tonbowHurtBoxW);

	--Draw the hurtbox for the Tonbow
	if tonbowHurtBoxW ~= 0 then
		gui.drawRectangle(tonbowHurtBoxX1, tonbowHurtBoxY1, tonbowHurtBoxW, tonbowHurtBoxH, "yellow");
	end

	--Draw the hitbox for the Tonbow
	if tonbowHitBoxW ~= 0 then
		gui.drawRectangle(tonbowHitBoxX1, tonbowHitBoxY1, tonbowHitBoxW, tonbowHitBoxH, "green");
		--gui.drawRectangle(tonbowX1, tonbowY1, tonbowHitBoxW, tonbowHitBoxH, "white");
	
	end

	--Draw the hitbox for the Demo Orb
	if demoOrb1HitBoxW ~= 0 then
		gui.drawRectangle(demoOrb1HitBoxX1, demoOrb1HitBoxY1, demoOrb1HitBoxW, demoOrb1HitBoxH, "red");

	end

	--Draw the hitbox for the Orb Shot
	if orbShot1HitBoxW ~= 0 then
		gui.drawRectangle(orbShot1HitBoxX1, orbShot1HitBoxY1, orbShot1HitBoxW, orbShot1HitBoxH, "orange");

	end

	
end
