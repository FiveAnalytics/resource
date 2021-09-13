local Limiter = {
    {DamageType = 0,   Last = 0, Expiration = 1},
    {DamageType = 1,   Last = 0, Expiration = 1},
    {DamageType = 2,   Last = 0, Expiration = 1},
    {DamageType = 3,   Last = 0, Expiration = 1},
    {DamageType = 5,   Last = 0, Expiration = 1},
    {DamageType = 6,   Last = 0, Expiration = 2},
    {DamageType = 10,  Last = 0, Expiration = 2},
    {DamageType = 11,  Last = 0, Expiration = 2},
    {DamageType = 12,  Last = 0, Expiration = 2},
    {DamageType = 13,  Last = 0, Expiration = 2},
    {DamageType = 14,  Last = 0, Expiration = 2}
}

function GetTimestamp()
    local _, _, _, h, m, s = GetUtcTime()
    return tonumber(tostring(h) .. tostring(m) .. tostring(s))
end

AddEventHandler('gameEventTriggered', function (name, data)
    if name == 'CEventNetworkEntityDamage' then
        local aType = GetEntityType(data[2])
        local vType = GetEntityType(data[1])
        local dType = GetWeaponDamageType(data[7])

        if aType == 0 or vType == 0 or aType == 3 or vType == 3 then
            return
        end

        local tStamp = GetTimestamp()
        for _, limit in pairs(Limiter) do
            if limit.DamageType == dType then

                -- Rate limit types of tick based damage
                if limit.Last + limit.Expiration > tStamp then
                    return
                end
                limit.Last = tStamp
            end
        end
        
        local DamageEvent = {
            Event            = 'DamageEvent',
            AttackerName     = "",
            AttackerType     = "",
            AttackerCoords   = vector3(0, 0, 0),
            AttackerHeading  = 0,
            VictimName       = "",
            VictimType       = "",
            VictimCoords     = vector3(0, 0, 0),
            VictimHeading    = 0,
            FatalDamage      = data[6] == 1,
            DamageCause      = GetDamageDisplayName(data[7]),
            DamageType       = GetDamageTypeDisplayName(dType),
            DamageEvent      = "",
            DamagedBone      = "",
        }

        -- Attacker and Victim Names (Players, NPCs, and Vehicles)
        if aType ~= 0 then
            if aType == 1 then
                if IsPedAPlayer(data[2]) == 1 then
                    DamageEvent.AttackerName = GetPlayerName(NetworkGetPlayerIndexFromPed(data[2]))
                    DamageEvent.AttackerType = "Player"
                else
                    DamageEvent.AttackerName = "NPC"
                    DamageEvent.AttackerType = "Ped"
                end
            elseif aType == 2 then
                DamageEvent.AttackerName = GetVehicleNumberPlateText(data[2])
                DamageEvent.AttackerType = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(data[2])))
            end
            DamageEvent.AttackerCoords = GetEntityCoords(data[2])
            DamageEvent.AttackerHeading = GetEntityHeading(data[2])
        end
        if vType ~= 0 then
            if vType == 1 then
                if IsPedAPlayer(data[1]) == 1 then
                    DamageEvent.VictimName = GetPlayerName(NetworkGetPlayerIndexFromPed(data[1]))
                    DamageEvent.VictimType = "Player"
                else
                    DamageEvent.VictimName = "NPC"
                    DamageEvent.VictimType = "Ped"
                end
            elseif vType == 2 then
                DamageEvent.VictimName = GetVehicleNumberPlateText(data[1])
                DamageEvent.VictimType = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(data[1])))
            end
            DamageEvent.VictimCoords = GetEntityCoords(data[1])
            DamageEvent.VictimHeading = GetEntityHeading(data[1])
        end

        -- Vehicle Flag and Ped Bone Names
        if vType == 2 then
            DamageEvent.DamagedBone = GetVehicleFlagDisplayName(data[13])
        end
        if vType == 1 then
            Citizen.Wait(50)
            local hit, bone = GetPedLastDamageBone(data[1])
            if hit == 1 then
                DamageEvent.DamagedBone = GetPedBoneDisplayName(bone)
            end
        end
        if dType == 0 and DamageEvent.DamageCause == "Vehicle Ramming" then
            DamageEvent.DamageType = "VehicleDamage"
        end

        -- Damage Event Name
        if aType == 1 and vType == 2 and DamageEvent.FatalDamage == true and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "PlayerDestroyedVehicle"
        elseif aType == 1 and vType == 2 and DamageEvent.FatalDamage == false and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "PlayerDamagedVehicle"
        elseif aType == 1 and vType == 2 and DamageEvent.FatalDamage == true and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPCDestroyedVehicle"
        elseif aType == 1 and vType == 2 and DamageEvent.FatalDamage == false and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPCDamagedVehicle"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Player" then
            DamageEvent.DamageEvent = "VehicleKilledPlayer"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Player" then
            DamageEvent.DamageEvent = "VehicleRammedPlayer"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Ped" then
            DamageEvent.DamageEvent = "VehicleKilledNPC"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Ped" then
            DamageEvent.DamageEvent = "VehicleRammedNPC"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "PlayerKilledPlayer"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "PlayerDamagedPlayer"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Ped" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "PlayerKilledNPC"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Ped" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "PlayerDamagedNPC"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPCKilledPlayer"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPCDamagedPlayer"
        elseif aType == 2 and vType == 2 and DamageEvent.FatalDamage == true then
            DamageEvent.DamageEvent = "VehicleDestroyedVehicle"
        elseif aType == 2 and vType == 2 and DamageEvent.FatalDamage == false then
            DamageEvent.DamageEvent = "VehicleRammedVehicle"
        else
            return
        end

        TriggerServerEvent("anna:event", DamageEvent)
    end
end)
