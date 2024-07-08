ESX = nil

-- Initialisation de ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function ChangeSeat(seatIndex)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and DoesEntityExist(vehicle) then
        TaskWarpPedIntoVehicle(playerPed, vehicle, seatIndex)
    end
end

function IsSeatOccupied(vehicle, seatIndex)
    return not IsVehicleSeatFree(vehicle, seatIndex)
end

function OpenSeatMenu()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2

    local elements = {}

    if not IsSeatOccupied(vehicle, -1) then
        table.insert(elements, {
            title = 'Place conducteur',
            event = 'changeSeat',
            args = -1
        })
    end

    if not IsSeatOccupied(vehicle, 0) then
        table.insert(elements, {
            title = 'Place passager',
            event = 'changeSeat',
            args = 0
        })
    end

    for i = 1, maxSeats do
        if not IsSeatOccupied(vehicle, i) then
            table.insert(elements, {
                title = 'Place arrière ' .. i,
                event = 'changeSeat',
                args = i
            })
        end
    end

    lib.registerContext({
        id = 'seat_menu',
        title = 'Menu des places',
        options = elements
    })

    lib.showContext('seat_menu')
end

Citizen.CreateThread(function()
    local targetAdded = false
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if not targetAdded then
                exports.ox_target:addLocalEntity(vehicle, {
                    {
                        name = 'open_seat_menu',
                        icon = 'fa-solid fa-exchange-alt',
                        label = 'Ouvrir le menu des places',
                        onSelect = function()
                            OpenSeatMenu()
                        end
                    }
                })
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

RegisterNetEvent('changeSeat')
AddEventHandler('changeSeat', function(seatIndex)
    ChangeSeat(seatIndex)
end)
