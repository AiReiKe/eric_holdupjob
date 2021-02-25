local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('eric_holdupjob:tooFar')
AddEventHandler('eric_holdupjob:tooFar', function(currentStore)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if Stores[currentStore].call_police == true then
			if xPlayer.job.name == 'police' then
				TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Stores[currentStore].nameOfJob))
				TriggerClientEvent('eric_holdupjob:killBlip', xPlayers[i])
			end
		end
		if xPlayer.job.name == Stores[currentStore].job or xPlayer.job.name == 'ambulance' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Stores[currentStore].nameOfJob))
			TriggerClientEvent('eric_holdupjob:killBlip', xPlayers[i])
		end
	end

	if robbers[_source] then
		TriggerClientEvent('eric_holdupjob:tooFar', _source)
		robbers[_source] = nil
		TriggerClientEvent('esx:showNotification', _source, _U('robbery_cancelled_at', Stores[currentStore].nameOfJob))
	end
end)

RegisterServerEvent('eric_holdupjob:robberyStarted')
AddEventHandler('eric_holdupjob:robberyStarted', function(currentStore)
	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	if Stores[currentStore] then
		local store = Stores[currentStore]

		if (os.time() - store.lastRobbed) < Config.TimerBeforeNewRob and store.lastRobbed ~= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('recently_robbed', store.nameOfJob, Config.TimerBeforeNewRob - (os.time() - store.lastRobbed)))
			return
		end

		local cops, jobMembers = 0, 0
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
				cops = cops + 1
			elseif xPlayer.job.name == store.job then
				jobMembers = jobMembers + 1
			end
		end

		if not rob then
			if store.call_police == false or cops >= Config.PoliceNumberRequired then
				if jobMembers >= store.online_player then
					rob = true

					for i=1, #xPlayers, 1 do
						local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
						if store.call_police == true then
							if xPlayer.job.name == 'police' then
								TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog', store.nameOfJob))
								TriggerClientEvent('eric_holdupjob:setBlip', xPlayers[i], Stores[currentStore].position)
							end
						end
						if xPlayer.job.name == store.job or xPlayer.job.name == 'ambulance' then
							TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog', store.nameOfJob))
							TriggerClientEvent('eric_holdupjob:setBlip', xPlayers[i], Stores[currentStore].position)
						end
					end
					TriggerClientEvent('esx:showNotification', _source, _U('started_to_rob', store.nameOfJob))
					TriggerEvent("esx:robberyjob", xPlayer.name, store.nameOfJob)
					TriggerClientEvent('esx:showNotification', _source, _U('alarm_triggered'))
				
					TriggerClientEvent('eric_holdupjob:currentlyRobbing', _source, currentStore)
					TriggerClientEvent('eric_holdupjob:startTimer', _source)
				
					Stores[currentStore].lastRobbed = os.time()
					robbers[_source] = currentStore

					SetTimeout(store.secondsRemaining * 1000, function()
						if robbers[_source] then
							rob = false
							if xPlayer then
								local reward = store.reward
								local societyAccount = nil

								TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..store.job, function(account)
									societyAccount = account
								end)

								if Config.NegativeSociety == false then
									if societyAccount.money < reward and societyAccount.money > 0 then
										reward = societyAccount.money
									elseif societyAccount.money == 0 then
										reward = 0
										TriggerClientEvent('esx:showNotification', xPlayer.source, _U('society_empty'))
									end
								end

								TriggerClientEvent('eric_holdupjob:robberyComplete', _source, reward)

								if reward > 0 or Config.NegativeSociety == true then
									if Config.GiveBlackMoney then
										xPlayer.addAccountMoney('black_money', reward)
									else
										xPlayer.addMoney(reward)
									end

									societyAccount.removeMoney(reward)
								end
							
								local xPlayers, xPlayer = ESX.GetPlayers(), nil
								for i=1, #xPlayers, 1 do
									xPlayer = ESX.GetPlayerFromId(xPlayers[i])

									if store.call_police == true then
										if xPlayer.job.name == 'police' then
											TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at', store.nameOfJob))
											TriggerClientEvent('eric_holdupjob:killBlip', xPlayers[i])
										end
									end
									if xPlayer.job.name == store.job or xPlayer.job.name == 'ambulance' then
										TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at', store.nameOfJob))
										TriggerClientEvent('eric_holdupjob:killBlip', xPlayers[i])
									end
								end
							end
						end
					end)
				else
					TriggerClientEvent('esx:showNotification', _source, _U('min_member', store.online_player, store.nameOfJob))
				end
			else
				TriggerClientEvent('esx:showNotification', _source, _U('min_police', Config.PoliceNumberRequired))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)








print('##################################')
print('\nEdit by AiReiKe')
print('Thanks for using eric_holdupjob')
print('\n##################################')
