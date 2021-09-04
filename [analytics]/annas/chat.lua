RegisterNetEvent('_chat:messageEntered')
AddEventHandler('_chat:messageEntered', function (author, color, message, mode)
    local _source = source

    local Payload = {
        Event   = 'ChatMessageEvent',
        Player  = GetPlayerName(_source),
        Message = message,
        Mode    = mode, 
    }
    SendHTTPEvent(_source, Payload)
end)