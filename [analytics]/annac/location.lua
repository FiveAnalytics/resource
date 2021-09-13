Citizen.CreateThread(function ()
    while true do
        local ped =  PlayerPedId()

        local LocationEvent = {
            Event           = 'LocationEvent',
            Player          = GetPlayerName(PlayerId()),
            PlayerCoords    = GetEntityCoords(ped),
            PlayerHeading   = GetEntityHeading(ped),
            StreetName      = "",
            CrossingRoad    = "",
            ZoneName        = "",
            IsOutside       = GetRoomKeyFromEntity(ped) == 0,
            IsInVehicle     = GetVehiclePedIsUsing(ped) ~= 0,
            IsSwimming      = GetPedConfigFlag(ped, 65, false) == 1,
            IsAimingGun     = GetPedConfigFlag(ped, 78, false) == 1,
            Health          = GetEntityHealth(ped),
            Armour          = GetPedArmour(ped),
        }
        local street, crossing = GetStreetNameAtCoord(LocationEvent.PlayerCoords.x, LocationEvent.PlayerCoords.y, LocationEvent.PlayerCoords.z)

        LocationEvent.ZoneName     = GetStreetNameFromHashKey(GetNameOfZone(LocationEvent.PlayerCoords))
        LocationEvent.StreetName   = GetStreetNameFromHashKey(street)
        LocationEvent.CrossingRoad = GetStreetNameFromHashKey(crossing)

        TriggerServerEvent("anna:event", LocationEvent)
        Citizen.Wait(15000)
    end
end)
