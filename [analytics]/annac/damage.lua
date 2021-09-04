AddEventHandler('gameEventTriggered', function (name, data)
    if name == 'CEventNetworkEntityDamage' then
        local aType = GetEntityType(data[2])
        local vType = GetEntityType(data[1])
        
        -- Ignore object based events
        if aType == 3 or vType == 3 then
            return
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
            DamageType       = GetDamageTypeDisplayName(GetWeaponDamageType(data[7])),
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

        -- Damage Event Name
        if aType == 1 and vType == 2 and DamageEvent.FatalDamage == true and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "Player Destroyed Vehicle"
        elseif aType == 1 and vType == 2 and DamageEvent.FatalDamage == false and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "Player Damaged Vehicle"
        elseif aType == 1 and vType == 2 and DamageEvent.FatalDamage == true and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPC Destroyed Vehicle"
        elseif aType == 1 and vType == 2 and DamageEvent.FatalDamage == false and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPC Damaged Vehicle"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Player" then
            DamageEvent.DamageEvent = "Vehicle Killed Player"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Player" then
            DamageEvent.DamageEvent = "Vehicle Rammed Player"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Ped" then
            DamageEvent.DamageEvent = "Vehicle Killed NPC"
        elseif aType == 2 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Ped" then
            DamageEvent.DamageEvent = "Vehicle Rammed NPC"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "Player Killed Player"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "Player Damaged Player"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Ped" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "Player Killed NPC"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Ped" and DamageEvent.AttackerType == "Player" then
            DamageEvent.DamageEvent = "Player Damaged NPC"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == true and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPC Killed Player"
        elseif aType == 1 and vType == 1 and DamageEvent.FatalDamage == false and DamageEvent.VictimType == "Player" and DamageEvent.AttackerType == "Ped" then
            DamageEvent.DamageEvent = "NPC Damaged Player"
        elseif aType == 2 and vType == 2 and DamageEvent.FatalDamage == true then
            DamageEvent.DamageEvent = "Vehicle Destroyed Vehicle"
        elseif aType == 2 and vType == 2 and DamageEvent.FatalDamage == false then
            DamageEvent.DamageEvent = "Vehicle Rammed Vehicle"
        else
            return
        end
        
        TriggerServerEvent("anna:event", DamageEvent)
    end
end)
