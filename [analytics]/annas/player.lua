AddEventHandler('playerConnecting', function (name, setKickReason, deferrals)
    local _source        = source
    local identifiers    = GetPlayerIdentifiers(_source)

    local tokens = {}
    for i = 0, GetNumPlayerTokens(_source) do
        table.insert(tokens, GetPlayerToken(_source, i))
    end

    local Payload = {
        Event           = 'PlayerJoiningEvent',
        Player          = GetPlayerName(_source),
        PlayersOnline   = #GetPlayers(),
        Identifiers     = identifiers,
        Tokens          = tokens,
    }
    SendHTTPEvent(_source, Payload)
end)

AddEventHandler('playerDropped', function (reason)
    local _source        = source

    local Payload = {
        Event   = 'PlayerDroppedEvent',
        Player  = GetPlayerName(_source),
        Reason  = reason,
    }
    SendHTTPEvent(_source, Payload)
end)