RegisterNetEvent('Telegram:SendMessage', function(firstname, lastname, message)
	local src = source
	local result = MySQL.scalar.await('SELECT citizenid FROM players WHERE JSON_EXTRACT(charinfo, "$.firstname") = ? AND JSON_EXTRACT(charinfo, "$.lastname") = ?', {firstname:lower(), lastname:lower()})
	if result then
		local Charinfo = exports['qbr-core']:GetPlayer(src)?.PlayerData.charinfo
		if not Charinfo then return end
		MySQL.insert.await('INSERT INTO telegrams (receiver, sender, message) VALUES (?, ?, ?)', {result, Charinfo.firstname..' '..Charinfo.lastname, message})
		local PlayerSource = exports['qbr-core']:GetPlayerByCitizenId(result)?.PlayerData.source
		if not PlayerSource then return end
		local data = MySQL.query.await('SELECT * FROM telegrams WHERE receiver = ?', {result})
		TriggerClientEvent('dk-telegram:client:UpdateTelegrams', PlayerSource, data)
		TriggerClientEvent('qbr-witness:client:WitnessAlert', PlayerSource, 'TELEGRAM', 'You Received a New Telegram')
	else
		TriggerClientEvent('QBCore:Notify', src, 9, 'Unable to process Telegram. Invalid first or lastname.', 2000, 0, 'mp_lobby_textures', 'cross')
	end
end)

RegisterNetEvent('dk-telegram:server:GetTelegrams', function()
	local src = source
	local result = MySQL.query.await('SELECT * FROM telegrams WHERE receiver = ?', {Player(src).state.cid})
	TriggerClientEvent('dk-telegram:client:UpdateTelegrams', src, result)
end)

RegisterNetEvent('dk-telegram:server:DeleteTelegram', function(data)
	local src = source
	MySQL.scalar.await('DELETE FROM telegrams WHERE id = ?', { data.id})
	local result = MySQL.query.await('SELECT * FROM telegrams WHERE receiver = ?', {Player(src).state.cid})
	TriggerClientEvent('dk-telegram:client:UpdateTelegrams', src, result, true)
end)