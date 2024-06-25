local QBCore = exports['qb-core']:GetCoreObject()

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1).. QBCore.Shared.RandomStr(2).. QBCore.Shared.RandomInt(3).. QBCore.Shared.RandomStr(2)
    local result = exports.oxmysql:execute('SELECT plate FROM player_vehicles WHERE plate =?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

QBCore.Commands.Add("givecar", "Bir oyuncunun datasına araç ver (only god", {{name="id", help="Player ID"}, {name="model", help="Vehicle Model"}}, true, function(source, args)
    local playerId = tonumber(args[1])
    local vehicleModel = args[2]

    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player == nil then
        TriggerClientEvent("QBCore:Notify", source, "Oyuncu bulunamadı", "error")
    else
        TriggerClientEvent('spawnVehicle:client', playerId, vehicleModel, GeneratePlate(), true)
    end
end, "admin", "god")

RegisterServerEvent("giveCar", function(vehicleProps, vehiclemodel, vehicle)
    local pData = QBCore.Functions.GetPlayer(source)
    exports.oxmysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?,?,?,?,?,?,?,?)', {
        pData.PlayerData.license,
        pData.PlayerData.citizenid,
        vehiclemodel,
        GetHashKey(vehiclemodel),
        json.encode(vehicleProps),
        vehicleProps.plate,
        '',
        0
    }, function() 
        TriggerClientEvent("QBCore:Notify", pData.PlayerData.source, vehicleProps.plate.." plakalı araç artık senin")
    end)
end)