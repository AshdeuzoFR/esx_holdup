local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('esx_holdup:toofar')
AddEventHandler('esx_holdup:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at') .. Stores[robb].nameofstore)
			TriggerClientEvent('esx_holdup:killblip', xPlayers[i])
		end
	end
	if(robbers[source])then
		TriggerClientEvent('esx_holdup:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_has_cancelled') .. Stores[robb].nameofstore)
	end
end)

RegisterServerEvent('esx_holdup:rob')
AddEventHandler('esx_holdup:rob', function(robb)

	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	if Stores[robb] then

		local store = Stores[robb]

		if (os.time() - store.lastrobbed) < 600 and store.lastrobbed ~= 0 then

			TriggerClientEvent('esx:showNotification', source, _U('already_robbed') .. (1800 - (os.time() - store.lastrobbed)) .. _U('seconds'))
			return
		end


		local cops = 0
		for i=1, #xPlayers, 1 do
 		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end


		if rob == false then

			if(cops >= Config.NumberOfCopsRequired)then

				rob = true
				for i=1, #xPlayers, 1 do
 					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 					if xPlayer.job.name == 'police' then
							TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog') .. store.nameofstore)
							TriggerClientEvent('esx_holdup:setblip', xPlayers[i], Stores[robb].position)
					end
				end

				TriggerClientEvent('esx:showNotification', source, _U('started_to_rob') .. store.nameofstore .. _U('do_not_move'))
				TriggerClientEvent('esx:showNotification', source, _U('alarm_triggered'))
				TriggerClientEvent('esx:showNotification', source, _U('hold_pos'))
				--TriggerClientEvent('esx_holdup:currentlyrobbing', source, robb)
				
				-- ADD Ashdeuzo 
				TriggerClientEvent('esx_holdup:currentlyrobbing', source, robb, secondsRemaining)
				
				
				Stores[robb].lastrobbed = os.time()
				robbers[source] = robb
				local savedSource = source
				SetTimeout(store.secondsRemaining*1000, function()

					if(robbers[savedSource])then

						rob = false
						TriggerClientEvent('esx_holdup:robberycomplete', savedSource, job)
						if(xPlayer)then

							xPlayer.addAccountMoney('black_money', store.reward)
							local xPlayers = ESX.GetPlayers()
							for i=1, #xPlayers, 1 do
 								local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
 								if xPlayer.job.name == 'police' then
										TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at') .. store.nameofstore)
										TriggerClientEvent('esx_holdup:killblip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', source, _U('min_two_police'))
			end
		else
			TriggerClientEvent('esx:showNotification', source, _U('robbery_already'))
		end
	end
end)
