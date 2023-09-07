----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
-- Images are provided for new items if you choose to add them 		--
----------------------------------------------------------------------

-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-NPCCrew:CustomNotify')
AddEventHandler('angelicxs-NPCCrew:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
    --exports['okokNotify']:Alert('', Message, 4000, type, false)
end)

Config.NHMenu = false						-- Use NH-Menu [https://github.com/whooith/nh-context]
Config.QBMenu = true						-- Use QB-Menu (Ignored if Config.NHMenu = true) [https://github.com/qbcore-framework/qb-menu]
Config.OXLib = false						-- Use the OX_lib (Ignored if Config.NHInput or Config.QBInput = true) [https://github.com/overextended/ox_lib]  !! must add shared_script '@ox_lib/init.lua' and lua54 'yes' to fxmanifest!!

-- Visual Preference
Config.Use3DText = false 					-- Use 3D text for NPC/Job interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication


Config.NPCCrew ={
    ['ballas'] = {                                              -- Crew Name
        ['CrewBosses'] = {                                      -- Crewboss information, can have multiple loctions, spawn is where the peds come from
            {boss = vector4(341.06, -2027.36, 22.14, 126.08), spawn = vector4(343.54, -2027.75, 22.35, 145.95), model = 'a_m_m_og_boss_01'},
        },
        ['CrewInfo'] = {                                        -- Number of crew NPC provided and the cost
            {number = 1, cost = 5000},
            {number = 2, cost = 10000},
            {number = 3, cost = 15000},
        },
        ['HostileGang'] = false,                                -- If true will be hostile to other crews/gangs (in this list) on sight
        ['ModelTypes'] = {                                      -- List of model types that a gang member may spawn as
            'g_f_y_ballas_01',
            'g_m_y_ballaeast_01',
            'g_m_y_ballaorig_01',
            'g_m_y_ballasout_01',
        },
        ['PedWeapons'] = {                                      -- List of weapons gang member may spawn with
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        ['BlipSprite'] = 84,                                    -- Sprite for blips for each boss location, if not desired turn to FALSE to turn off blips
        ['BlipName'] = 'Ballas Crewboss',                       -- Name of blips
        ['BlipColour'] = 2,                                     -- Colour of blips
    },
    ['lost'] = {                                                -- Crew Name
        ['CrewBosses'] = {                                      -- Crewboss information, can have multiple loctions, spawn is where the peds come from
            {boss = vector4(956.2, -123.11, 74.35, 176.5), spawn = vector4(959.07, -121.12, 74.96, 198.05), model = 'g_m_y_salvaboss_01'},
        },
        ['CrewInfo'] = {                                        -- Number of crew NPC provided and the cost
            {number = 1, cost = 5000},
            {number = 2, cost = 10000},
            {number = 3, cost = 15000},
        },
        ['HostileGang'] = false,                                -- If true will be hostile to other crews/gangs (in this list) on sight
        ['ModelTypes'] = {                                      -- List of model types that a gang member may spawn as
            'g_f_y_lost_01',
            'g_m_y_lost_01',
            'g_m_y_lost_02',
            'g_m_y_lost_03',
        },
        ['PedWeapons'] = {                                      -- List of weapons gang member may spawn with
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        ['BlipSprite'] = 84,                                    -- Sprite for blips for each boss location, if not desired turn to FALSE to turn off blips
        ['BlipName'] = 'Lost Crewboss',                         -- Name of blips
        ['BlipColour'] = 2,                                     -- Colour of blips
    },
    --[[
    ['none'] = {                                                -- Crew Name      !!!! 'none' crews can be hired by anyone not in one of the gangs above !!!!
        ['CrewBosses'] = {                                      -- Crewboss information, can have multiple loctions, spawn is where the peds come from
            {boss = vector4(-1072.85, -2001.74, 13.16, 123.24), spawn = vector4(-1070.53, -2003.05, 15.79, 135.55), model = 'g_m_m_chiboss_01'},
        },
        ['CrewInfo'] = {                                        -- Number of crew NPC provided and the cost
            {number = 1, cost = 5000},
            {number = 2, cost = 10000},
            {number = 3, cost = 15000},
        },
        ['ModelTypes'] = {                                      -- List of model types that a gang member may spawn as
            'g_m_m_chemwork_01',
        },
        ['PedWeapons'] = {                                      -- List of weapons gang member may spawn with
            'weapon_pistol',
            'weapon_carbinerifle',
        },
        ['BlipSprite'] = 84,                                    -- Sprite for blips for each boss location, if not desired turn to FALSE to turn off blips
        ['BlipName'] = 'Crewboss',                              -- Name of blips
        ['BlipColour'] = 2,                                     -- Colour of blips
    },
    ]]
}

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['request_crew_3d'] = 'Press ~r~[E]~w~ to request a crew.',
    ['request_crew'] = 'Request Crew',
    ['menu_header'] = "Crew Options",
    ['member'] = "Crew Members: ",
    ['cost'] = "Cost $ ",
    ['cancel'] = "Leave",
    ['crew_bought'] = "Perfect, here comes the crew now!",
    ['no_cash'] = "You need more cash if you want to have this many crew members come with you.",
    ['crew_up'] = 'You still have crew from last time!',
}
