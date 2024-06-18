
--Take a look at the hitboxes in Space Tonbow


	--Variables change every frame. Location found using Emulicious
	--Tonbow hurtbox
	tonbowXPos = emu.read(0xC19E, cpuDebug)


	emu.displayMessage("Tonbow Hurtbox Width: ", tonbowXPos)

