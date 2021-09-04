local APIKey        = GetResourceMetadata("annas", "my_data", 0)
local EndpointURL   = GetResourceMetadata("annas", "my_data", 1)
local Development   = GetResourceMetadata("annas", "my_data", 2) == '1'

-- API Key Check
AddEventHandler('onServerResourceStart', function (resource)
    if GetCurrentResourceName() ~= resource then
        return
    end
    -- PerformHttpRequest(EndpointURL .. "/api/key/check", function (code, data, headers)
    --     if code == 401 then
    --         print('Unauthorized Analytics API Key. Please contact support.')
    --         return
    --     elseif code ~= 200 then
    --         print('Analytics service seems to be offline. Please contact support.')
    --         return
    --     end
    -- end, 'POST', '', {['Content-Type'] = 'application/json', ['Authorization'] = APIKey})
end)

function SendHTTPEvent(source, payload)
    if type(payload) ~= "table" then
        return
    end

    if payload.Event == nil or payload.Event == "" then
        return
    end

    if source ~= 0 then
        local PlayerID = ""

        for _, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                PlayerID = v
            end
        end
        if PlayerID ~= "" then
            payload.PlayerID = PlayerID
        end 
    end

    -- Debugging (DO NOT CHANGE)
    if Development == true and payload.Event ~= 'ConsoleEvent' then
        print(json.encode(payload))
    end

    PerformHttpRequest(EndpointURL .. "/api/send", function (code, data, headers)
        if code ~= 200 then
            -- TODO: Logging
            return
        end
    end, 'POST', json.encode(payload), {['Content-Type'] = 'application/json', ['Authorization'] = APIKey, ['Event'] = payload.Event})
end

-- Client Events
RegisterNetEvent('anna:event')
AddEventHandler('anna:event', function (payload)
    local _source = source

    SendHTTPEvent(_source, payload)
end)

-- Resource Start and Stop Events
AddEventHandler('onServerResourceStart', function(resource)
    local Payload = {
        Event    = 'ServerResourceStartEvent',
        Resource = resource,
    }
    SendHTTPEvent(0, Payload)
end)

AddEventHandler('onServerResourceStop', function(resource)
    local Payload = {
        Event    = 'ServerResourceStopEvent',
        Resource = resource,
    }
    SendHTTPEvent(0, Payload)
end)