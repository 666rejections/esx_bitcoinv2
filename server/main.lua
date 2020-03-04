ESX 						   = nil
local CopsConnected       	   = 0
local PlayersHarvestingBitcoin    = {}
local PlayersTransformingBitcoin  = {}
local PlayersSellingBitcoin       = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

--Bitcoin Farm
local function HarvestBitcoin(source)

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingBitcoin[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local bitcoin = xPlayer.getInventoryItem('bitcoinitem')

			if bitcoin.limit ~= -1 and bitcoin.count >= bitcoin.limit then
				TriggerClientEvent('esx:showNotification', source, _U('inventory_full'))
			else
				xPlayer.addInventoryItem('bitcoinitem', 1)
				HarvestBitcoin(source)
			end
		end
	end)
end

RegisterServerEvent('esx_bitcoin:startHarvestBitcoin')
AddEventHandler('esx_bitcoin:startHarvestBitcoin', function()
	local _source = source

	if not PlayersHarvestingBitcoin[_source] then
		PlayersHarvestingBitcoin[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('take_bitcoin'))
		HarvestBitcoin(_source)
	else
		print(('esx_bitcoin: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_bitcoin:stopHarvestBitcoin')
AddEventHandler('esx_bitcoin:stopHarvestBitcoin', function()
	local _source = source

	PlayersHarvestingBitcoin[_source] = false
end)

local function TransformBitcoin(source)

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingBitcoin[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local bitcoinQuantity = xPlayer.getInventoryItem('bitcoinitem').count
			local pooch = xPlayer.getInventoryItem('bitcoinitem')

			if pooch.limit ~= -1 and pooch.count >= pooch.limit then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_frutos_suficientes'))
			elseif bitcoinQuantity < 2 then
				TriggerClientEvent('esx:showNotification', source, _U('you_dont_have_bitcoin2'))
			else
				xPlayer.removeInventoryItem('bitcoinitem', 2)
				xPlayer.addInventoryItem('bitcoinitem', 1)

				TransformBitcoin(source)
			end
		end
	end)
end

RegisterServerEvent('esx_bitcoin:startTransformBitcoin')
AddEventHandler('esx_bitcoin:startTransformBitcoin', function()
	local _source = source

	if not PlayersTransformingBitcoin[_source] then
		PlayersTransformingBitcoin[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('colocar_frutos_dentro_dos_sacos'))
		TransformBitcoin(_source)
	else
		print(('esx_bitcoin: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_bitcoin:stopTransformBitcoin')
AddEventHandler('esx_bitcoin:stopTransformBitcoin', function()
	local _source = source

	PlayersTransformingBitcoin[_source] = false
end)

local function SellBitcoin(source)

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingBitcoin[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local poochQuantity = xPlayer.getInventoryItem('bitcoinitem').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('you_dont_have_bitcoin'))
			else
				xPlayer.removeInventoryItem('bitcoinitem', 1)
				if CopsConnected == 0 then
					xPlayer.addAccountMoney('black_money', 100)
					TriggerClientEvent('esx:showNotification', source, _U('bitcoin_sell'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('black_money', 110)
					TriggerClientEvent('esx:showNotification', source, _U('bitcoin_sell'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('black_money', 120)
					TriggerClientEvent('esx:showNotification', source, _U('bitcoin_sell'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('black_money', 130)
					TriggerClientEvent('esx:showNotification', source, _U('bitcoin_sell'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('black_money', 140)
					TriggerClientEvent('esx:showNotification', source, _U('bitcoin_sell'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('black_money', 150)
					TriggerClientEvent('esx:showNotification', source, _U('bitcoin_sell'))
				end

				SellBitcoin(source)
			end
		end
	end)
end

RegisterServerEvent('esx_bitcoin:startSellBitcoin')
AddEventHandler('esx_bitcoin:startSellBitcoin', function()
	local _source = source

	if not PlayersSellingBitcoin[_source] then
		PlayersSellingBitcoin[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('bitcoin_selltext'))
		SellBitcoin(_source)
	else
		print(('esx_bitcoin: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_bitcoin:stopSellBitcoin')
AddEventHandler('esx_bitcoin:stopSellBitcoin', function()
	local _source = source

	PlayersSellingBitcoin[_source] = false
end)

RegisterServerEvent('esx_bitcoin:GetUserInventory')
AddEventHandler('esx_bitcoin:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_bitcoin:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('bitcoinitem').count,
		xPlayer.getInventoryItem('bitcoinitem').count,
		xPlayer.job.name,
		currentZone
	)
end)

ESX.RegisterUsableItem('bitcoinitem', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('bitcoinitem', 1)

	TriggerClientEvent('esx_bitcoin:onPot', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('used_one_bitcoin'))
end)
