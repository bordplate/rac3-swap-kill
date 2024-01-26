-- Define a list of weapon IDs
local weapon_ids = {
	0x10, 0x11, 0x13, 0x15, 0x27,
	0x2F, 0x37, 0x3F, 0x47, 0x4F, 0x57, 0x5F, 0x67, 0x6F, 0x77,
	0x7F, 0x87, 0x8F, 0x97
}

function OnLoad()
	-- Set all weapon ammo
	--local value = tonumber(DAT_00c1e43c[param_1])
	--local index = value * -8 + value * 128  -- 0x80 in decimal is 128
	
	setAmmoTo10ForAllWeapons()
	
	math.randomseed(os.time())  -- Initialize random seed
	
	--Ratchetron:WriteMemory(GAME_PID, 0x16e804, 0x42800204)
	--Ratchetron:WriteMemory(GAME_PID, 0x16e7c8, 0xf821ff51)
end

function getRandomWeaponID()
	local index = math.random(1, #weapon_ids)  -- Get a random index between 1 and the length of the array
	return weapon_ids[index]
end

function setAmmoTo10ForAllWeapons()
    -- Iterate through each weapon ID and set ammo to 10
    for i, weapon_id in ipairs(weapon_ids) do
        -- Assuming ammo for each weapon is stored at an offset based on its ID
        -- Replace this with the correct memory address computation logic
        local ammo_address = computeAmmoAddress(weapon_id)  -- Replace with actual function
        local ammo_value = 100  -- Set ammo to 100

        Ratchetron:WriteMemory(GAME_PID, ammo_address, ammo_value)
    end
end


-- Hypothetical base address where ammo for the first weapon is stored
local BASE_AMMO_ADDRESS = 0xda5240  -- Replace with the actual address
-- Each weapon's ammo takes up 4 bytes in this example
local AMMO_BLOCK_SIZE = 4

-- Function to compute the memory address where ammo for a specific weapon is stored
function computeAmmoAddress(weapon_id)
    -- Calculate the offset from the base address
    local offset = weapon_id * AMMO_BLOCK_SIZE
    -- Calculate the actual memory address
    local ammo_address = BASE_AMMO_ADDRESS + offset
    return ammo_address
end

last_xp = -1

swap_tick = 0
swaperoo = false

function OnTick(ticks)

	if (ticks % 4) == 0 then
		current_xp = bytestoint(Ratchetron:ReadMemory(GAME_PID, 0xC1E510, 4))
		
		if last_xp == -1 then
			last_xp = current_xp
		end

		if (current_xp ~= last_xp) then
			print("Enemy killed")
			new_weap = getRandomWeaponID()
			
			local ammo_address = computeAmmoAddress(new_weap)  -- Replace with actual function
			local ammo_value = 100  -- Set ammo to 100

			Ratchetron:WriteMemory(GAME_PID, ammo_address, ammo_value)
			
			print("Swapping to " .. new_weap)
			--Ratchetron:WriteMemory(GAME_PID, 0x16e804, 0x40820204)
			--Ratchetron:WriteMemory(GAME_PID, 0x16e7c8, 0xf821ff51)
			
			Ratchetron:WriteMemory(GAME_PID, 0xDA4E04, new_weap)
			Ratchetron:WriteMemory(GAME_PID, 0xDA27C8, new_weap)
			Ratchetron:WriteMemory(GAME_PID, 0xc1e4f0, new_weap)
			Ratchetron:WriteMemory(GAME_PID, 0xC1E4EF, new_weap)
			
			-- Apply the weapon swap
			Ratchetron:WriteMemory(GAME_PID, 0xda3a14, 3)
			
			swap_tick = ticks
			swaperoo = true
		end

		last_xp = current_xp
	end
	
	if swaperoo and swap_tick + 10 < ticks then
		--Ratchetron:WriteMemory(GAME_PID, 0x16e804, 0x42800204)
		--Ratchetron:WriteMemory(GAME_PID, 0x16e7c8, 0x4e800020)
		swaperoo = false
	end
	
	if false and ((ticks+1) % 4) == 0 then
		current_weap_lock = bytestoint(Ratchetron:ReadMemory(GAME_PID, 0xda3a14, 4))
		
		if current_weap_lock == 2 then
			print("Locking weapon")
			Ratchetron:WriteMemory(GAME_PID, 0xda3a14, 0)
		end
	end
end

function OnUnload()
	
end