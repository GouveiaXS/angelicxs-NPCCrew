ESX = nil
QBcore = nil
PlayerGang = nil

Relationships = {}
garbage = nil
local CrewSpawns = {}
local BossPed = nil

RegisterNetEvent('angelicxs-NPCCrew:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-NPCCrew:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    garbage, Relationships['none'] = AddRelationshipGroup(GetHashKey('none'))
    for k,v in pairs(Config.NPCCrew) do
        if v['BlipSprite'] then
            for line, data in pairs (v['CrewBosses']) do
                SetBlip(data.boss, v)
            end
        end
        local name = GetHashKey(k)
        garbage, Relationships[k] = AddRelationshipGroup(name)
        SetRelationshipBetweenGroups(0, Relationships[k], Relationships[k])
        SetRelationshipBetweenGroups(3, Relationships[k], Relationships['none'])
        SetRelationshipBetweenGroups(3, Relationships['none'], Relationships[k])
    end
    for k,v in pairs(Config.NPCCrew) do
        local name = Relationships[k]
        if v['HostileGang'] then
            for g, rival in pairs(Config.NPCCrew) do
                local name2 = Relationships[g]
                if name2 ~= name and name2 ~= 'none' then
                    SetRelationshipBetweenGroups(5, name, name2)
                    SetRelationshipBetweenGroups(5, name2, name)
                end
            end
        end
    end

    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	    while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        CreateThread(function()
            while true do
                local playerData = ESX.GetPlayerData()
                if playerData.job.name ~= nil then
                    PlayerGang = playerData.job.name
                    local gangcheck = false
                    for k,v in pairs(Config.NPCCrew) do
                        if PlayerGang == k then
                            gangcheck = true
                            break
                        end
                    end
                    if not gangcheck then PlayerGang = 'none' end
                    if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
                    else
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
                    end
                    break
                end
                Wait(100)
            end
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerGang = job.name
            local gangcheck = false
            for k,v in pairs(Config.NPCCrew) do
                if PlayerGang == k then
                    gangcheck = true
                    break
                end
            end
            if not gangcheck then PlayerGang = 'none' end
            if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
            else
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
            end
        end)

    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerGang = playerData.gang.name
                    if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
                    else
                        SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
                    end
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            local playerData = QBCore.Functions.GetPlayerData()
            PlayerGang = playerData.gang.name
            if DoesRelationshipGroupExist(Relationships[PlayerGang]) then
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships[PlayerGang])
            else
                SetPedRelationshipGroupHash(PlayerPedId(), Relationships['none'])
            end
        end)
    end
end)

CreateThread(function()
    for crew, data in pairs (Config.NPCCrew) do 
        for slot, info in pairs (data['CrewBosses']) do
            info.crew = crew
            CreateThread(function()
                local PedSpawned = false
                while true do
                    local Pos = GetEntityCoords(PlayerPedId())
                    local Dist = #(Pos - vector3(info.boss.x, info.boss.y, info.boss.z))
                    if Dist <= 50 and not PedSpawned then
                        TriggerEvent('angelicxs-NPCCrew:BossSpawner', info, data['CrewInfo'])
                        PedSpawned = true
                    elseif DoesEntityExist(BossPed) and PedSpawned then
                        local Dist2 = #(Pos - GetEntityCoords(BossPed))
                        if Dist2 > 50 then
                            SetEntityAsNoLongerNeeded(BossPed)
                            PedSpawned = false
                            if Config.UseThirdEye then
                                if Config.ThirdEyeName == 'ox_target' then
                                    exports.ox_target:removeZone('NPCCrewBossPed')
                                else
                                    exports[Config.ThirdEyeName]:RemoveZone('NPCCrewBossPed')
                                end
                            end
                        end
                    end
                    Wait(2000)
                end
            end)
        end
    end
end)

RegisterNetEvent('angelicxs-NPCCrew:BossSpawner',function(info, options)
    local hash = HashGrabber(info.model)
    BossPed = CreatePed(3, hash, info.boss.x, info.boss.y, (info.boss.z-1) , info.boss.w, false, false)
    FreezeEntityPosition(BossPed, true)
    SetEntityInvincible(BossPed, true)
    SetBlockingOfNonTemporaryEvents(BossPed, true)
    TaskStartScenarioInPlace(BossPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
    SetModelAsNoLongerNeeded(info.model)
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local options = {
                {
                    name = 'NPCCrewBossPed',
                    label = Config.Lang['request_crew'],
                    onSelect = function()
                        TriggerEvent('angelicxs-NPCCrew:CategoryMenu', info, options)
                    end,
                    canInteract = function(entity)
                        return (PlayerGang==info.crew)
                    end,
                },
            }
            exports.ox_target:addLocalEntity(BossPed, options)
        else
            exports[Config.ThirdEyeName]:AddEntityZone('NPCCrewBossPed', BossPed, {
                name="NPCCrewBossPed",
                debugPoly=false,
                useZ = true
                }, {
                options = {
                    {
                    label = Config.Lang['request_crew'],
                    action = function()
                        TriggerEvent('angelicxs-NPCCrew:CategoryMenu', info, options)
                    end,
                    canInteract = function(entity)
                        return (PlayerGang==info.crew)
                    end,
                    },                    
                },
                distance = 2
            })        
        end
    end
    while DoesEntityExist(BossPed) and Config.Use3DText do
        local sleep = 2000
        local Dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(BossPed))
        if Dist <= 50 and PlayerGang == info.crew then 
            sleep = 1000
            if Dist <= 25 then 
                sleep = 500
                if Dist <= 15 then 
                    sleep = 0
                    if Dist <= 5 then 
                        DrawText3Ds(info.boss.x, info.boss.y, info.boss.z, Config.Lang['request_crew_3d'])
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent('angelicxs-NPCCrew:CategoryMenu', info, options)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)



RegisterNetEvent('angelicxs-NPCCrew:CategoryMenu', function(info, options)
    if not info.spawn or PlayerGang ~= info.crew then return end
    local menu = {}
    if Config.NHMenu then
        table.insert(menu, {
            header = Config.Lang['menu_header'],
        })
    elseif Config.QBMenu then
        table.insert(menu, {
            header = Config.Lang['menu_header'],
            isMenuHeader = true
        })
    end
    for i = 1, #options do
        local op = options[i]
        local text = Config.Lang['member']..op.number
        op.spawn = info.spawn
        op.crew = info.crew
        if op.cost > 0 then
            text = Config.Lang['member']..op.number..' '..Config.Lang['cost']..op.cost
        end
        if Config.NHMenu then
            table.insert(menu, {
                context = text,
                event = 'angelicxs-NPCCrew:CrewGrab',
                args = {op}
            })
        elseif Config.QBMenu then
            table.insert(menu, {
                header = text,
                    params = {
                        event = 'angelicxs-NPCCrew:CrewGrab',
                        args = op
                    }
                })
        elseif Config.OXLib then
            table.insert(menu, {
                title = text,
                onSelect = function()
                    TriggerEvent("angelicxs-NPCCrew:CrewGrab", op)
                end,
            })
        end

    end
    if Config.NHMenu then
        table.insert(menu, {
            context = Config.Lang['cancel'],
            event = '',
        })
        TriggerEvent("nh-context:createMenu", menu)
    elseif Config.QBMenu then
        table.insert(menu, {
        header = Config.Lang['cancel'],
            params = {event = ''}
        })
        TriggerEvent("qb-menu:client:openMenu", menu)
    elseif Config.OXLib then
        lib.registerContext({
            id = 'NPCCrewCategorymenu_ox',
            title = Config.Lang['menu_header'],
            options = menu,
            position = 'top-right',
        }, function(selected, scrollIndex, args)
        end)
        lib.showContext('NPCCrewCategorymenu_ox')
    end
end)

RegisterNetEvent('angelicxs-NPCCrew:CrewGrab', function(info)
    local crewup = false
    for crew,spawns in pairs(CrewSpawns) do
        if DoesEntityExist(spawns) then
            crewup = true
        end
    end
    if crewup then
        TriggerEvent('angelicxs-NPCCrew:Notify', Config.Lang['crew_up'], Config.LangType['success'])
        return
    end
    if Config.UseESX then
        ESX.TriggerServerCallback('angelicxs-NPCCrew:PayUp:ESX', function(cb)
            if cb then
                CrewAttributes(info.crew, info)
            end
        end, info.cost)                                    
    elseif Config.UseQBCore then
        QBCore.Functions.TriggerCallback('angelicxs-NPCCrew:PayUp:QBCore', function(cb)
            if cb then
                CrewAttributes(info.crew, info)
            end
        end, info.cost)
    end
end)

RegisterNetEvent('angelicxs-NPCCrew:Client:RelationshipUpdater', function(crew, net)
    local spawn = NetworkGetEntityFromNetworkId(net)
    if not spawn then return end
    if DoesEntityExist(spawn) then
        SetPedRelationshipGroupHash(spawn, GetHashKey(Relationships[crew]))
    end
end)

function CrewAttributes(crew, info)
    local crewnumber = 0
    while true do 
        crewnumber = crewnumber + 1
        local i = crewnumber
        local spot = info.spawn
        local model = Randomizer(Config.NPCCrew[crew]['ModelTypes'])
        local weapon = Randomizer(Config.NPCCrew[crew]['PedWeapons'])
        local hash = HashGrabber(model)
        CrewSpawns[i] = CreatePed(4, hash, spot.x, spot.y, spot.z-0.9, spot.w, true, true)
        while not DoesEntityExist(CrewSpawns[i]) do Wait(100) end
        SetEntityAsMissionEntity(CrewSpawns[i], true, true)
        NetworkRegisterEntityAsNetworked(CrewSpawns[i])
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(CrewSpawns[i]), true)
        SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(CrewSpawns[i]), true)
        SetPedRelationshipGroupHash(CrewSpawns[i], Relationships[crew])
        TriggerServerEvent('angelicxs-NPCCrew:Server:RelationshipUpdater', crew, NetworkGetNetworkIdFromEntity(CrewSpawns[i]))
        SetPedArmour(CrewSpawns[i], math.random(0,50))
        GiveWeaponToPed(CrewSpawns[i], weapon, 500)
        SetPedFleeAttributes(CrewSpawns[i], 0, false)
        SetPedCombatAttributes(CrewSpawns[i], 0, true)
        SetPedCombatAttributes(CrewSpawns[i], 1, true)
        SetPedCombatAttributes(CrewSpawns[i], 2, true)
        SetPedCombatAttributes(CrewSpawns[i], 3, true)
        SetPedCombatAttributes(CrewSpawns[i], 5, true)
        SetPedCombatAttributes(CrewSpawns[i], 46, true)
        SetPedCombatAbility(CrewSpawns[i], math.random(0,2)) -- best 2
        SetPedCombatMovement(CrewSpawns[i], math.random(0,3)) -- best 1 (defence), best 2 (offence)
        SetPedAccuracy(CrewSpawns[i], math.random(75,100)) -- best 100
        SetPedCombatRange(CrewSpawns[i], math.random(0,2)) -- best 2
        SetEntityVisible(CrewSpawns[i], true) 
        TaskFollowToOffsetOfEntity(CrewSpawns[i], PlayerPedId(), -0.5-(i/10), -0.5-(i/10), 0, 2.0, 1.0, 2.0, true)
        CreateThread(function()
            local oldcar = 0
            local incar = false
            while DoesEntityExist(CrewSpawns[i]) do       
                local car = GetVehiclePedIsIn(PlayerPedId(), false)
                local carfull = AreAnyVehicleSeatsFree(car)
                if car and not incar and carfull then
                    while IsVehicleSeatFree(car, i-1) do
                        TaskEnterVehicle(CrewSpawns[i], car, 5000, i-1, 2.0, 1, 0)
                        Wait(1000)
                        if GetVehiclePedIsIn(CrewSpawns[i], false) then
                            oldcar = car
                            incar = true
                            break
                        end
                    end
                    Wait(1000)
                end
                if car==0 and incar then
                    TaskLeaveVehicle(CrewSpawns[i], oldcar, 1)
                    incar = false
                    TaskFollowToOffsetOfEntity(CrewSpawns[i], PlayerPedId(), -0.5-(i/10), -0.5-(i/10), 0, 2.0, 1.0, 2.0, true)
                end
                Wait(2000)
            end
        end)
        CreateThread(function()
            while true do
                if GetEntityHealth(CrewSpawns[i]) <5 then
                    SetEntityAsNoLongerNeeded(CrewSpawns[i])
                    Wait(30000)
                    DeleteEntity(CrewSpawns[i])
                    break
                end
                Wait(5000)
            end
        end)
        Wait(1500)
        if crewnumber == info.number then break end
    end 
end

function Randomizer(Options)
    local List = Options
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        Number = Number + 1
        if Number == Selection then
            return List[i]
        end
    end
end

function SetBlip(loc, data)
    local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
    SetBlipSprite(blip, data['BlipSprite'])
    SetBlipColour(blip, data['BlipColour'])
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data['BlipName'])
    EndTextCommandSetBlipName(blip)
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        RemoveRelationshipGroup(GetHashKey('none'))
        for i = 1, #Relationships do
            RemoveRelationshipGroup(GetHashKey(Relationships[i]))
        end
        for crew,spawns in pairs(CrewSpawns) do
            if DoesEntityExist(spawns) then
                DeleteEntity(spawns)
            end
        end
    end
end)
