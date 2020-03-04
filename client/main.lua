local bitcoinQTE       			= 0
ESX 			    			= nil
local bitcoin_poochQTE 			= 0
local myJob 					= nil
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx_bitcoin:hasEnteredMarker', function(zone)
	if myJob == 'police' or myJob == 'ambulance' then
		return
	end

	ESX.UI.Menu.CloseAll()

	if zone == 'BitCoin' then
		CurrentAction = zone
		CurrentActionMsg = _U('press_take_bitcoin')
		CurrentActionData = {}
	elseif zone == 'BitcoinProcessing' then
		if bitcoinQTE >= 5 then
			CurrentAction = zone
			CurrentActionMsg = _U('carrega_para_colocares_frutos_dentro_dos_sacos')
			CurrentActionData = {}
		end
	elseif zone == 'BitcoinSale' then
		if bitcoin_poochQTE >= 1 then
			CurrentAction = zone
			CurrentActionMsg = _U('press_sell_bitcoin')
			CurrentActionData = {}
		end
	end
end)

AddEventHandler('esx_bitcoin:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

	if zone == 'BitCoin' then
		TriggerServerEvent('esx_bitcoin:stopHarvestBitcoin')
	elseif zone == 'BitcoinProcessing' then
	TriggerServerEvent('esx_bitcoin:stopTransformBitcoin')
	elseif zone == 'BitcoinSale' then
		TriggerServerEvent('esx_bitcoin:stopSellBitcoin')
	end
end)

-- Marker
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do
			if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, v.x, v.y, v.z, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end

	end
end)

-- Blips
if Config.ShowBlips then
	Citizen.CreateThread(function()
		for k,v in pairs(Config.Zones) do
			local blip = AddBlipForCoord(v.x, v.y, v.z)

			SetBlipSprite (blip, v.sprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.9)
			SetBlipColour (blip, v.color)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.name)
			EndTextCommandSetBlipName(blip)
		end
	end)
end

-- Item
RegisterNetEvent('esx_bitcoin:ReturnInventory')
AddEventHandler('esx_bitcoin:ReturnInventory', function(bitcoinNbr, bitcoinpNbr, jobName, currentZone)
	bitcoinQTE = bitcoinNbr
	bitcoin_poochQTE = bitcoinpNbr
	myJob = jobName
	TriggerEvent('esx_bitcoin:hasEnteredMarker', currentZone)
end)

-- Menu Maker
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.ZoneSize.x / 2) then
				isInMarker = true
				currentZone = k
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone = currentZone
			TriggerServerEvent('esx_bitcoin:GetUserInventory', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_bitcoin:hasExitedMarker', lastZone)
		end
	end
end)

-- Keys
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and IsPedOnFoot(PlayerPedId()) then
				if CurrentAction == 'BitCoin' then
					TriggerServerEvent('esx_bitcoin:startHarvestBitcoin')
				elseif CurrentAction == 'BitcoinProcessing' then
					TriggerServerEvent('esx_bitcoin:startTransformBitcoin')
				elseif CurrentAction == 'BitcoinSale' then
					TriggerServerEvent('esx_bitcoin:startSellBitcoin')
				end

				CurrentAction = nil
			end
		end
	end
end)
