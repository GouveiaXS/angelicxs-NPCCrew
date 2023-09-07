ESX = nil
QBcore = nil

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Deposit
if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-NPCCrew:PayUp:ESX', function(source, cb, price)
        local xPlayer = ESX.GetPlayerFromId(source)
        local amount = price
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            TriggerClientEvent('angelicxs-NPCCrew:Notify', source, Config.Lang['crew_bought'], Config.LangType['success'])
            cb(true)
        else
            TriggerClientEvent('angelicxs-NPCCrew:Notify', source, Config.Lang['no_cash'], Config.LangType['error'])
            cb(false)
        end
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-NPCCrew:PayUp:QBCore', function(source, cb, price)
        local player = QBCore.Functions.GetPlayer(source)
        local amount = price
        local cash = player.PlayerData.money["cash"]
        if cash >= amount then
            player.Functions.RemoveMoney("cash", amount, "npc-crew")
            TriggerClientEvent('angelicxs-NPCCrew:Notify', source, Config.Lang['crew_bought'], Config.LangType['success'])
            cb(true)
        else
            TriggerClientEvent('angelicxs-NPCCrew:Notify', source, Config.Lang['no_cash'], Config.LangType['error'])
            cb(false)
        end
    end)
end

RegisterNetEvent('angelicxs-NPCCrew:Server:RelationshipUpdater', function(crew, net)
    TriggerClientEvent('angelicxs-NPCCrew:Client:RelationshipUpdater', -1, crew, net)
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then

    end
end)