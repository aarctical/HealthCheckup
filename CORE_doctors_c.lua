
-- //               NOTIFICATIONS                    //--
function ShowAdvNotification(image, title, subtitle, text)
	SetNotificationTextEntry("STRING");
	AddTextComponentString(text);
	SetNotificationMessage(image, image, false, 0, title, subtitle);
	DrawNotification(false, true);
end
function ShowHelp(text)
	Citizen.InvokeNative(0x8509B634FBE7DA11, "STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayHelp(0, false, 1, 0)
end

-- //               ANIMATIONS                    //--
function SetPlayerAnimation()
    print("recieved anim start")

    local dict = "amb@world_human_sunbathe@male@back@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict,"base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end
function StopPlayerAnimation()
    ClearPedTasksImmediately(GetPlayerPed(-1))
    ClearPedTasks(GetPlayerPed(-1))
end

-- //               MAIN FUNCTIONS                    //--
function PutPlayerOnBed()
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetEntityCoords(GetPlayerPed(-1), 326.91, -576.45, 43.01, 0,0,1)
    SetEntityHeading(GetPlayerPed(-1), 340.16)
    FreezeEntityPosition(GetPlayerPed(-1), true)
    Wait(500)
    SetPlayerAnimation()
    DoScreenFadeIn(800)
    while not IsScreenFadedIn() do
        Wait(10)
    end
end
function GetPlayerOffBed()
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetEntityCoords(GetPlayerPed(-1), 327.75, -576.75, 43.32, 0,0,1)
    SetEntityHeading(GetPlayerPed(-1), 158.74)
    FreezeEntityPosition(GetPlayerPed(-1), false)
    Wait(500)
    StopPlayerAnimation()
    DoScreenFadeIn(800)
    while not IsScreenFadedIn() do
        Wait(10)
    end
end

hasCancer = false
function DecideFate()
    -- Chance = math.random( 100 )
    -- if Chance == 69 then
        ShowAdvNotification("CHAR_BARRY", "Doctor", "Emergency Diagnosis", "You have cancer, you have "..math.random(100).." days to live.")
        hasCancer = true
    -- end
end

Hospitals = {
    {
        Hospital = {name="Pillbox Hospital", x=328.83,y=-577.79,z=42.25,h=31.18}
    }
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local pedPos = GetEntityCoords(GetPlayerPed(-1), 0)
		for id=1, #Hospitals do
			local dist_ext = GetDistanceBetweenCoords(Hospitals[id].Hospital.x + 0.0, Hospitals[id].Hospital.y + 0.0, Hospitals[id].Hospital.z + 0.5, pedPos, true)
			if dist_ext < 15 then
				if dist_ext <= 0.9 then 
					ShowHelp("Get checkup with ~INPUT_VEH_HORN~")
					if IsControlJustReleased(0, 86) then
						PutPlayerOnBed()
                        ShowAdvNotification("CHAR_BARRY", "Doctor", "Conducting checkup...")
                        Wait(15000)
                        DecideFate()
                        GetPlayerOffBed()
                        ShowHelp("You have paid~g~ $300~w~ for the checkup.")
                        if hasCancer then
                            Citizen.Wait(math.random(10000, 100000))
                            SetEntityHealth(GetPlayerPed(-1), 0)
                            ShowAdvNotification("CHAR_LESTER_DEATHWISH", "You have died from cancer.")
                        end
					end
				end
				DrawMarker(1, Hospitals[id].Hospital.x + 0.0, Hospitals[id].Hospital.y + 0.0, Hospitals[id].Hospital.z + 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 0, 160, 255, 60, 0, 0, 2, 0, 0, 0, 0)
			end
        end
    end
end)

local DisableHealthCommands = false
RegisterCommand('disablehealth', function()
    if DisableHealthCommands then
        DisableHealthCommands = false
        ShowAdvNotification("CHAR_MP_MORS_MUTUAL", "Health checkup", "Enabled notifications")
    else
        DisableHealthCommands = true
        ShowAdvNotification("CHAR_MP_MORS_MUTUAL", "Health checkup", "Disabled notifications")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- 20 minutes
        if not DisableHealthCommands then
            ShowAdvNotification("CHAR_MP_MORS_MUTUAL", "It's time for your Health checkup", "Head to Pillbox Medical Centre.")
        end
    end
end)