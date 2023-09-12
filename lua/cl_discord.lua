-- This requires a special module to be installed before it works correctly
-- Sorry to disappoint you
if file.Find("lua/bin/gmcl_gdiscord_win64.dll", "GAME")[1] == nil then return end
require("gdiscord")

-- Configuration
local map_restrict = false -- Should a display default image be displayed if the map is not in a given list?
local map_list = {
    gm_flatgrass = true,
    gm_construct = true
}
local joinbtn1_url = "https://wiki.facepunch.com/gmod"
local joinbtn1_label = "Go to Wiki"

local joinbtn2_url = "https://wiki.facepunch.com/gmod"
local joinbtn2_label = "Go to Wiki2"

local buttons = {
    btn1 = {
        text = "This is first button",
        url = "https://github.com/Etkin44/gmod_discord_rpc_with_buttons/"
    },
    btn2 = {
        text = "This is second button",
        url = "https://github.com/Etkin44/gmod_discord_rpc_with_buttons/"
    }
}

--If you want to add only 1 button to your rpc just delete lines betweens 23-26

local image_fallback = "default"
local discord_id = "626155559779041331"
local refresh_time = 60

local discord_start = discord_start or -1

function DiscordUpdate()
    -- Determine what type of game is being played
    local rpc_data = {}
    if game.SinglePlayer() then
        rpc_data["state"] = "Singleplayer"
    else
        local ip = game.GetIPAddress()
        if ip == "loopback" then
            if GetConVar("p2p_enabled"):GetBool() then
                rpc_data["state"] = "Peer 2 Peer"
            else
                rpc_data["state"] = "Local Server"
            end
        else
            rpc_data["state"] = string.Replace(ip, ":27015", "")
        end
    end

    -- Determine the max number of players
    rpc_data["partySize"] = player.GetCount()
    rpc_data["partyMax"] = game.MaxPlayers()

    if IsValid(buttons.btn1) and not buttons.btn1.text == "" and not buttons.btn1.url then
        rpc_data["btn1_label"] = buttons.btn1.text
        rpc_data["btn1_url"] = buttons.btn1.url
    elseif IsValid(buttons.btn2) and not buttons.btn2.text == "" and not buttons.btn2.url
        rpc_data["btn2_label"] = buttons.btn2.text
        rpc_data["btn2_url"] = buttons.btn2.url
    end

    if game.SinglePlayer() then rpc_data["partyMax"] = 0 end

    -- Handle map stuff
    -- See the config
    rpc_data["largeImageKey"] = game.GetMap()
    rpc_data["largeImageText"] = game.GetMap()
    if map_restrict and not map_list[map] then
        rpc_data["largeImageKey"] = image_fallback
    end
    rpc_data["details"] = GAMEMODE.Name
    rpc_data["startTimestamp"] = discord_start

    DiscordUpdateRPC(rpc_data)
end

hook.Add("Initialize", "UpdateDiscordStatus", function()
    discord_start = os.time()
    DiscordRPCInitialize(discord_id)
    DiscordUpdate()

    timer.Create("DiscordRPCTimer", refresh_time, 0, DiscordUpdate)
end)
