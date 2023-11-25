Keys = {
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

ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0);

        ESX = exports["es_extended"]:getSharedObject()  
    end 
end)
  
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

CreateThread(function()

   	if not DoesEntityExist(ped) then
		RequestModel(Config.ped.hash)
		while not HasModelLoaded(Config.ped.hash) do
			Citizen.Wait(1)
		end
		ped = CreatePed(4, Config.ped.hash, Config.ped.pos)

		SetEntityAsMissionEntity(ped, true, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, "world_human_drug_dealer_hard", 0, true)
        
    end
end)

Citizen.CreateThread(function()
	local locations = {Config.ped.hash}

    Citizen.Wait(100)
	    while true do
		local playerCoords = GetEntityCoords(PlayerPedId())
		for k, v in pairs(locations) do
			local distance = #(playerCoords - Config.ped.pos)
			if distance < 2.0 then
				sleepThread = 5
                if distance < 2 then
                    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.ped.pos, true) < 2 then
                        
                        exports['evrp_tools']:DrawText3D(GetOffsetFromEntityInWorldCoords (ped, 0.0, 0.0, 0.0), " ~g~[E]~w~ Pablo")            
                        if IsControlJustReleased(0, Keys["E"]) then
                            OpenMenu()
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleepThread)
    end
end)
                                                                              
function OpenMenu()
    local elements = {}
	for k, v in pairs(Config.Items) do
		table.insert(elements, {
            label = v.label .. ' - <span style="color:gray;">' .. v.amount .. ' st </span>' .. ' - <span style="color:white;">' .. v.price .. '</span> Kr',
			data = {
				item = v.item,
				price = v.price,
				amount = v.amount
			}
		})
	end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blackmarket', {
        title    = 'Pablo',
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blackmarket_confirm', {
            title    = 'Bekräfta köp',
            align    = 'top-left',
            elements = {
                {label = 'Ja', value = 'yes'},
                {label = 'Nej', value = 'no'}
            }
        }, function(data2, menu2)
            if data2.current.value == 'yes' then
                ESX.TriggerServerCallback('gs-vapenhandlare:canStart', function(cooldown)
                    if cooldown then
                        TriggerServerEvent("g-drugnpc:buy", data.current.data.item, data.current.data.price, data.current.data.amount)
                    else
                        ESX.ShowNotification('Du har redan köpt något, vänta en stund')
                    end
                end)
            end
            menu2.close()
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end
	
function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end
function loadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end