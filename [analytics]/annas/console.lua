Citizen.CreateThread(function ()
    RegisterConsoleListener(function (channel, message)
        local Payload = {
            Event    = 'ConsoleEvent',
            Resource = channel,
            Message  = message,
        }
        SendHTTPEvent(0, Payload)
    end)
end)