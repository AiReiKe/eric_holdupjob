local holdingUp = false
local store = ""
local blipRobbery = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

if Config.oldESX then
	ESX = nil
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	Citizen.CreateThread(function()
		if ESX.IsPlayerLoaded() then
			ESX.PlayerData = ESX.GetPlayerData()
		end
	end)

	RegisterNetEvent("esx:playerLoaded")
	AddEventHandler("esx:playerLoaded", function(xPlayer)
		ESX.PlayerData = xPlayer
	end)

	RegisterNetEvent("esx:onPlayerLogout")
	AddEventHandler("esx:onPlayerLogout", function()
		ESX.PlayerData = nil
	end)

	RegisterNetEvent("esx:setJob")
	AddEventHandler("esx:setJob", function(job)
		ESX.PlayerData.job = job
	end)
end

local function drawTxt(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	if outline then SetTextOutline() end

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('eric_holdupjob:currentlyRobbing')
AddEventHandler('eric_holdupjob:currentlyRobbing', function(currentStore)
	holdingUp, store = true, currentStore
end)

RegisterNetEvent('eric_holdupjob:killBlip')
AddEventHandler('eric_holdupjob:killBlip', function()
	RemoveBlip(blipRobbery)
end)

RegisterNetEvent('eric_holdupjob:setBlip')
AddEventHandler('eric_holdupjob:setBlip', function(position)
	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)

	SetBlipSprite(blipRobbery, 161)
	SetBlipScale(blipRobbery, 2.0)
	SetBlipColour(blipRobbery, 3)

	PulseBlip(blipRobbery)
end)

RegisterNetEvent('eric_holdupjob:tooFar')
AddEventHandler('eric_holdupjob:tooFar', function()
	holdingUp, store = false, ''
	ESX.ShowNotification(_U('robbery_cancelled'))
end)

RegisterNetEvent('eric_holdupjob:robberyComplete')
AddEventHandler('eric_holdupjob:robberyComplete', function(award)
	holdingUp, store = false, ''
	if award > 0 or Config.NegativeSociety == true then
		ESX.ShowNotification(_U('robbery_complete', award))
	end
	print('\nCreate by AiReiKe\nProhibit any commercial activities\n')
end)

RegisterNetEvent('eric_holdupjob:startTimer')
AddEventHandler('eric_holdupjob:startTimer', function()
	local timer = Stores[store].secondsRemaining

	Citizen.CreateThread(function()
		while timer > 0 and holdingUp do
			Citizen.Wait(1000)

			if timer > 0 then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		while holdingUp do
			Citizen.Wait(0)
			drawTxt(0.66, 1.44, 1.0, 1.0, 0.4, _U('robbery_timer', Stores[store].nameOfJob, timer), 255, 255, 255, 255)
		end
	end)
end)

Citizen.CreateThread(function()
	for k,v in pairs(Stores) do
		if v.blip == true then
			local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
			SetBlipSprite(blip, 484)
			SetBlipScale(blip, 0.7)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('shop_robbery', v.nameOfJob))
			EndTextCommandSetBlipName(blip)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPos = GetEntityCoords(PlayerPedId(), true)
		local inZone = false

		for k,v in pairs(Stores) do
			local storePos = v.position
			local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z)

			if distance < Config.Marker.DrawDistance then
				if not holdingUp then
					if ESX.PlayerData.job.name ~= v.job or Config.member_holdup then
						inZone = true
						DrawMarker(Config.Marker.Type, storePos.x, storePos.y, storePos.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, false, false, false, false)

						if distance < 0.5 then
							ESX.ShowHelpNotification(_U('press_to_rob', v.nameOfJob))

							if IsControlJustReleased(0, Keys['E']) then
								if IsPedArmed(PlayerPedId(), 4) then
									TriggerServerEvent('eric_holdupjob:robberyStarted', k)
								else
									ESX.ShowNotification(_U('no_threat', v.nameOfJob))
								end
							end
						end
					end
				end
			end
		end

		if holdingUp then
			local storePos = Stores[store].position
			if Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z) > Config.MaxDistance then
				TriggerServerEvent('eric_holdupjob:tooFar', store)
			end
		end

		if not inZone then
			Wait(500)
		end
	end
end)
