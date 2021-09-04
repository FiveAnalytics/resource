local IsInsideVehicle = false
local ActiveVehicle   = 0

function CaptureVehicleEvent(vehicle, event)
    local ped = PlayerPedId()
    
    local VehicleEvent = {
        Event               = 'VehicleEvent',
        Player              = GetPlayerName(PlayerId()),
        PlayerCoords        = GetEntityCoords(ped),
        PlayerHeading       = GetEntityHeading(ped),
        VehicleEvent        = event,
        VehicleModel        = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
        VehicleNumberPlate  = GetVehicleNumberPlateText(vehicle),
        Passengers          = {},
        StreetName          = "",
        CrossingRoad        = "",
        ZoneName            = "",
    }
    local street, crossing = GetStreetNameAtCoord(VehicleEvent.PlayerCoords.x, VehicleEvent.PlayerCoords.y, VehicleEvent.PlayerCoords.z)
    
    VehicleEvent.ZoneName     = GetStreetNameFromHashKey(GetNameOfZone(VehicleEvent.PlayerCoords))
    VehicleEvent.StreetName   = GetStreetNameFromHashKey(street)
    VehicleEvent.CrossingRoad = GetStreetNameFromHashKey(crossing)

    for i = -1, 4 do
        local passenger = GetPedInVehicleSeat(vehicle, i)
        if passenger ~= 0 and passenger ~= ped and IsPedAPlayer(passenger) == 1 then
            table.insert(VehicleEvent.Passengers, GetPlayerName(NetworkGetPlayerIndexFromPed(passenger)))
        end
    end
    TriggerServerEvent("anna:event", VehicleEvent)
end

Citizen.CreateThread(function ()
    while true do
        local vehicle = GetVehiclePedIsUsing(PlayerPedId())
        if vehicle ~= 0 then
            if IsInsideVehicle == false then
                IsInsideVehicle = true
                ActiveVehicle = vehicle

                if ActiveVehicle ~= 0 then
                    CaptureVehicleEvent(ActiveVehicle, 'Entered Vehicle')
                end
            end
        else
            if IsInsideVehicle == true then
                IsInsideVehicle = false
                CaptureVehicleEvent(ActiveVehicle, 'Exited Vehicle')
            end
        end
        Citizen.Wait(1000)
    end
end)