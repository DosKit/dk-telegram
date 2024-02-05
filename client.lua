local locations, Prompts, Telegrams = Config.Locations, {}
local sid = GetPlayerServerId(PlayerId())

---------------------------------------------------------------------------------
---- FUNCTIONS
---------------------------------------------------------------------------------

local function CreatePrompt(data)
    Prompts = {}
    for i=1, #data do
        local prompt = PromptRegisterBegin()
        PromptSetText(prompt, CreateVarString(10, "LITERAL_STRING", data[i][2]))
        PromptSetHoldMode(prompt, 1000)
        PromptSetControlAction(prompt, data[i][1])
        PromptSetEnabled(prompt, true)
        PromptSetVisible(prompt, true)
        PromptRegisterEnd(prompt)
        Prompts[k] = prompt
    end
end

local function ClearPrompts()
    if not Prompts then return end
    for i=1, #Prompts do PromptDelete(Prompts[i]) end
    Prompts = nil
end

local function SendTelegramMenu(data)
    ClearPrompts()
    local data = exports['qbr-input']:ShowInput({
        header = "Telegram",
        submitText = "Send",
        inputs = {
            {
                text = "Message",
                name = "message",
                type = "text",
                isRequired = true
            },
            {
                text = "First Name",
                name = "firstname",
                type = "text",
                isRequired = true,
                default = data and data.sender:match("([^%s]+)") or nil
            },
            {
                text = "Last Name",
                name = "lastname",
                type = "text",
                isRequired = true,
                default = data and data.sender:match("%s(.*)") or nil
            },
        },
    })
    if not data then return end
    TriggerServerEvent('dk-telegram:server:SendMessage', data.firstname, data.lastname, data.message)
end

local function EditTelegram(data)
    local Menu = {
        {
            header = "Edit Telegram",
            isMenuHeader = true,
        },
        {
            header = 'Delete',
            params = {
                isServer = true,
                event = "dk-telegram:server:DeleteTelegram",
                args = {id = data.id}
            }
        },
        {
            header = 'Reply',
            params = {
                isAction = true,
                event = SendTelegramMenu,
                args = {sender = data.sender}
            }
        }
    }
    exports['qbr-menu']:openMenu(Menu)
end

local function ViewTelegramMenu()
    ClearPrompts()
    if not Telegrams then
        TriggerServerEvent('dk-telegram:server:GetTelegrams') 
        Wait(1000)
    end
    local Menu = {
        {
            header = "Telegrams",
            isMenuHeader = true,
        }
    }
    for k, v in pairs(Telegrams) do
        Menu[#Menu+1] = {
            header = v.sender,
            txt = v.message,
            params = {
                isAction = true,
                event = EditTelegram,
                args = {id = v.id, sender = v.sender}
            }
        }
    end
    exports['qbr-menu']:openMenu(Menu)
end

---------------------------------------------------------------------------------
---- EVENT
---------------------------------------------------------------------------------

RegisterNetEvent('dk-telegram:client:UpdateTelegrams', function(data, ReOpenMenu)
    Telegrams = data or {}
    if ReOpenMenu then return ViewTelegramMenu() end
end)

AddStateBagChangeHandler('cid', ('player:%s'):format(sid), function(_, _, value)
    Telegrams = nil
end)

---------------------------------------------------------------------------------
---- THREADS
---------------------------------------------------------------------------------

CreateThread(function()
    local current = locations
    for k, v in pairs(current) do
        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v)
        SetBlipSprite(blip, 1861010125, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Post Office') -- Name of Blip
    end
    local prompts = {{0xCEFD9220, 'Send Telegram'}, {0x760A9C6F, 'View Telegrams'}}
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local interior = GetInteriorFromEntity(ped)
        local inside = current[interior]
        if inside then
            local coords = GetEntityCoords(ped)
            if #(inside - coords) <= 1.0 then
                sleep = 100
                if not Prompts then
                    CreatePrompt(prompts)
                end
                if PromptHasHoldModeCompleted(Prompts[1]) then
                    SendTelegramMenu()
                elseif PromptHasHoldModeCompleted(Prompts[2]) then
                    ViewTelegramMenu()
                end
            elseif Prompts then
                ClearPrompts()
            end
        end
        Wait(sleep)
    end
end)
