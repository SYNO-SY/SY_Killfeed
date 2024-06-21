ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('gameEventTriggered', function(event, data)
	if event ~= 'CEventNetworkEntityDamage' then return end
	local victim, victimDied = data[1], data[4]
	if not IsPedAPlayer(victim) then return end
	local player = PlayerId()
	local playerPed = PlayerPedId()
	if victimDied and NetworkGetPlayerIndexFromPed(victim) == player and (IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim)) then
		local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
		local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
		if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
			PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
	local WeaponData = ESX.GetWeaponFromHash(deathCause)
	local WeaponName = WeaponData.name

	if WeaponName == nil or type(WeaponName) ~= "string" then
		WeaponName = ''
	end
	local data = {
		killedByPlayer = true,
		deathCause = deathCause,
		killerServerId = killerServerId,
		killerClientId = killerClientId,
		weapon = WeaponName
	}
	if Config.DisplayKillfeed then
		TriggerServerEvent('SY_Killfeed:onPlayerDead', data)
	end
end

RegisterNetEvent('SY_Killfeed:ShowUi')
AddEventHandler('SY_Killfeed:ShowUi', function(data)
	_victim = data.victim
	_killer = data.killerServerId
	_weapon = data.weapon
	SendNUIMessage({
		action = "showui",
		victim = _victim,
		killer = _killer,
		weapon = _weapon
	})
end)
