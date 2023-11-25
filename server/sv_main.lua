
ESX = nil
local Webhook = "https://discord.com/api/webhooks/1051440574399528990/BqmZYZKo_x8WGPmOoKLS5P-kGNC2iJa0eP9Cf_O-nRz821XxIDEsebPvUnT8lJfBxyxC"
-- local Webhook = Config.WebHook
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('g-drugnpc:buy')
AddEventHandler('g-drugnpc:buy', function(item, price, amount)
    print ('g-drugnpc:buyItem')
    print (item)
    print (price)
    print (amount)
    
    local _source = source
    local player = ESX.GetPlayerFromId(_source)
    if player.getMoney() >= price then
        player.removeMoney(price)
        player.addInventoryItem({
            item = item,
            count = amount
        })
        TriggerClientEvent('esx:showNotification', _source, 'Du köpte ' .. amount .. ' ' .. item .. ' för ' .. price .. 'kr' .. ' ')

        local identifierlist = ExtractIdentifiers(player.source)
        local data = {
            playerid = player.source,
            identifier = identifierlist.license:gsub("license2:", ""),
            discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
            steam = identifierlist.steam,
            message = player.name .. " köpte " .. amount .. " " .. item .. " för " .. price .. "kr"
        }
        noSession(data)
    else
        TriggerClientEvent('esx:showNotification', _source, 'Du har inte tillräckligt med cash')
    end
end)

   

ESX.RegisterServerCallback('g-drugnpc:checkInriktning', function(source, cb, inriktning)
    local identifier =  ESX.GetPlayerFromId(source)
    MySQL.Async.fetchScalar('SELECT `inriktning` FROM `evrp_inriktningar` WHERE `identifier`=@identifier', {
        ['@identifier'] = identifier.identifier
    }, function(result)
        cb(result) -- callbackar riktnigen
    end)
end)


ESX.RegisterServerCallback('g-drugnpc:canStart', function(source, cb) -- kollar inriktningen från client side
    local _source = source
    local identifier = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM evrp_droghandlare WHERE identifier = @identifier', {['@identifier'] = identifier.identifier}, function(result3) -- Kollar om spelaren finns
        if #result3 > 0 then -- om spelaren finns 
            MySQL.Async.fetchAll('SELECT cooldown FROM evrp_droghandlare WHERE identifier = @identifier', {['@identifier'] = identifier.identifier}, function(result5) -- Kollar om cooldown finns
                local cooldown = result5[1]

                if cooldown.cooldown <= os.time() then -- ifall tiden är mindre eller samma som os time
                    MySQL.Async.execute('UPDATE `evrp_droghandlare` SET `cooldown`=@ostime WHERE `identifier`=@identifier', {['@identifier'] = identifier.identifier, ['@ostime'] = os.time() + Config.Cooldown})
                    cb(true)
                else
                    cb(false)
                end
            end)
        else -- annars insertar den spelaren till databasen (FUNKAR)
            cb(true)
            MySQL.Async.execute("INSERT INTO evrp_droghandlare (identifier, cooldown) VALUES (@identifier,@cooldown)", {['@identifier'] = identifier.identifier, ['@cooldown'] = os.time() + Config.Cooldown})
        end
    end)
end)
  
function noSession(data)
	local color = '65352'
	local category = 'test'
	
	local information = {
		{
			["color"] = color,
			["author"] = {
				["icon_url"] = 'https://cdn.discordapp.com/attachments/869138252022575104/987700315136606268/dfgdfgdfgdf.png',
				["name"] = 'Gurkish - Logs',
			},
			["title"] = Config.Title,
			["description"] = '**ID:** '..data.playerid..'\n**Identifier:** '..data.identifier..'\n**Discord:** '..data.discord ..'\n**Steam:** '..data.steam ..  '\n\n' .. data.message .. ' **',
			["footer"] = {
				["text"] = os.date(Config.DateFormat),
			}
		}
	}

    PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({username = 'Gurkish', embeds = information}), {['Content-Type'] = 'application/json'})
end

function ExtractIdentifiers(id)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(id) - 1 do
        local playerID = GetPlayerIdentifier(id, i)

        if string.find(playerID, "steam") then
            identifiers.steam = playerID
        elseif string.find(playerID, "ip") then
            identifiers.ip = playerID
        elseif string.find(playerID, "discord") then
            identifiers.discord = playerID
        elseif string.find(playerID, "license") then
            identifiers.license = playerID
        elseif string.find(playerID, "xbl") then
            identifiers.xbl = playerID
        elseif string.find(playerID, "live") then
            identifiers.live = playerID
        end
    end

    return identifiers
end