ESX = nil

-- Initialisation de ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)


-- Fonction pour changer de place dans le véhicule
function ChangeSeat(seatIndex)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and DoesEntityExist(vehicle) then
        TaskWarpPedIntoVehicle(playerPed, vehicle, seatIndex)
    end
end

-- Ajouter une cible au véhicule lorsque le joueur est dans un véhicule
Citizen.CreateThread(function()
    local targetAdded = false
    while true do
        Citizen.Wait(500) -- Vérifier toutes les 500ms pour économiser les ressources
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if not targetAdded then
                local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2
                local options = {
                    {
                        name = 'change_seat_driver',
                        icon = 'fa-solid fa-exchange-alt',
                        label = 'Passer à la place conducteur',
                        onSelect = function()
                            -- Changer à la place conducteur (index -1)
                            ChangeSeat(-1)
                        end
                    },
                    {
                        name = 'change_seat_passenger',
                        icon = 'fa-solid fa-exchange-alt',
                        label = 'Passer à la place passager',
                        onSelect = function()
                            -- Changer à la place passager (index 0)
                            ChangeSeat(0)
                        end
                    }
                }

                for i = 1, maxSeats do
                    table.insert(options, {
                        name = 'change_seat_back_' .. i,
                        icon = 'fa-solid fa-exchange-alt',
                        label = 'Passer à la place arrière ' .. i,
                        onSelect = function()
                            ChangeSeat(i)
                        end
                    })
                end

                exports.ox_target:addLocalEntity(vehicle, options)
                targetAdded = true
            end
        else
            if targetAdded then
                local vehicle = GetVehiclePedIsIn(playerPed, true)
                if vehicle and DoesEntityExist(vehicle) then
                    exports.ox_target:removeLocalEntity(vehicle)
                end
                targetAdded = false
            end
        end
    end
end)
