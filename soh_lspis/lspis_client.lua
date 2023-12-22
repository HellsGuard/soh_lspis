--[[  
    LSPIS by HF Creations for SoH RP
	- Los Santos Police Information System
	- Criminal Records, MDT, BOLO's, and everything else our LSPD needs.
]]--

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

--[[ VARS ]]--
local guiOpen = false
local playerInfo = {}
local currentTask = {}
ESX = nil

--[[ FETCH ESX ]]--
Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

    ESX.PlayerData = ESX.GetPlayerData()
end)

--[[ EVENT HANDLERS ]]--
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if guiOpen then
			CloseGUI()
		end
	end
end)

--[[ ======================== END EVENT HANDLERS ======================== ]]--

--[[ COMMANDS ]]--
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/lspis', "Opens the Los Santos Police Information System")
    SetNuiFocus(false, false)
end)

RegisterCommand('lspis', function(source)
    if not guiOpen then
        --HandleGUI(true, 'open')
        OpenGUI()
    end
end, false)

--[[ ======================== END COMMANDS ======================== ]]--

--[[ FUNCTIONS ]]--
function HandleGUI(bool, status)
    local user = ''
    if ESX.PlayerData.job.name == 'police' then
        user = 'police'
    elseif ESX.PlayerData.job.name == 'offpolice' then
        user = 'police_offDuty'
        ESX.ShowNotification('~r~You are not on duty, access has been limited')
    else
        user = 'civilian'
    end

    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = status,
        user = user
    })
    guiOpen = bool
end

function OpenGUI()
    local user = ''
    if ESX.PlayerData.job.name == 'police' then
        user = 'police'
    elseif ESX.PlayerData.job.name == 'offpolice' then
        user = 'police_offDuty'
    else
        user = 'civilian'
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        user = 'civilian'
    })
    guiOpen = true
end

function CloseGUI()
    local user = ''
    if ESX.PlayerData.job.name == 'police' then
        user = 'police'
    elseif ESX.PlayerData.job.name == 'offpolice' then
        user = 'police_offDuty'
    else
        user = 'civilian'
    end

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close',
        user = user
    })
    guiOpen = false
end

--[[ ======================== END FUNCTIONS ======================== ]]--

--[[ NUI CALLBACKS ]]--
RegisterNUICallback('NUIFocusHandler', function(data)
    if data == "open" then
        OpenGUI()
    else
        CloseGUI()
    end
end)

--[[ BOLOS ]]--
RegisterNUICallback('NUIFetchBolos', function(data, cb)
    ESX.TriggerServerCallback('soh_lspis:GetBolos', function(result)
        if result ~= nil and result ~= false then
            local bolos = {}

            for i=1, #result, 1 do
                table.insert(bolos, {
                    reportId = result[i].reportId,
                    report = result[i].report,
                    issuedBy = result[i].issuedBy
                })
            end
            SendNUIMessage({
                action = 'bolos',
                list = bolos
            })
        else
            SendNUIMessage({
                action = 'bolos',
                list = 'empty'
            })
        end
    end)
end)

--[[ WARRANTS ]]--
RegisterNUICallback('NUIFetchWarrants', function(data, cb)
    ESX.TriggerServerCallback('soh_lspis:GetWarrants', function(result)
        if result ~= nil and result ~= false then
            local warrants = {}

            for i=1, #result, 1 do
                table.insert(warrants, {
                    warrantId = result[i].warrantId,
                    name = result[i].name,
                    details = result[i].details,
                    status = result[i].status,
                    issuedBy = result[i].issuedBy
                })
            end

            SendNUIMessage({
                action = 'warrants',
                list = warrants
            })
        else
            SendNUIMessage({
                action = 'warrants',
                list = 'empty'
            })
        end
    end)
end)

--[[ NAME SEARCH ]]--
RegisterNUICallback('NUINameSearch', function(data, cb)
    ESX.TriggerServerCallback('soh_lspis:NameSearch', function(result)
        if result == false then
            SendNUIMessage({
                action = 'name_search_results',
                list = 'invalid name'
            })
        else
            if result ~= nil then
                local searchResults = {}
                
                --for i=1, #result, 1 do
                    table.insert(searchResults, {
                        firstname = result.firstname,
                        lastname = result.lastname,
                        sex = result.sex,
                        dob = result.dateofbirth,
                        height = result.height,
                        phonenumber = result.phonenumber,
                        jail = result.jail,
                        licenses = result.licenses,
                        address = result.address,
                        dlStatus = result.dlStatus,
                        wpStatus = result.wpStatus,
                        paroleStatus = result.paroleStatus,
                        charges = result.charges,
                        citations = result.citations,
                        arrests = result.arrests,
                        notes = result.notes,
                        lastUpdatedBy = result.lastUpdatedBy
                    })
                --end

                SendNUIMessage({
                    action = 'name_search_results',
                    list = searchResults
                })
            else
                ESX.ShowNotification("Name Search Error")
            end
        end
    end, data.firstName, data.lastName)
end)

--[[ PLATE SEARCH ]]--
RegisterNUICallback('NUIPlateSearch', function(data, cb)
    ESX.TriggerServerCallback('soh_lspis:PlateSearch', function(result)
        if result == false then
            SendNUIMessage({
                action = 'plate_search_results',
                list = 'invalid plate'
            })
        else
            if result ~= nil then
                local searchResults = {}
                local vehicleProps = json.decode(result.vehicleProps)
                local modelHash = vehicleProps.model

                table.insert(searchResults, {
                    plate = result.plate,
                    firstname = result.firstname,
                    lastname = result.lastname,
                    model = GetDisplayNameFromVehicleModel(modelHash)
                })

                SendNUIMessage({
                    action = 'plate_search_results',
                    list = searchResults
                })
            else
                ESX.ShowNotification("Plate Search Error")
            end
        end
    end, data.plateNumber)
end)

RegisterNUICallback('NUINearPlates', function(data, cb)
    local nearestVehicle = ESX.Game.GetVehicleInDirection()
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
    local closecar = GetClosestVehicle(x, y, z, 4.0, 0, 71)
    local vehicleExists = DoesEntityExist(nearestVehicle)
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(nearestVehicle))
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(nearestVehicle))
    local nearBy = {}

    table.insert(nearBy, {
        plate = plate,
        model = model
    })

    SendNUIMessage({
        action = 'plate_search_nearest',
        list = nearBy
    })
end)

--[[ FILE BOLO ]]--
RegisterNUICallback('NUIFileBolo', function(data, cb)
    officerName = nil
    ESX.TriggerServerCallback('soh_lspis:GetName', function(name)
        officerName = name.firstname .. " " .. name.lastname

        ESX.TriggerServerCallback('soh_lspis:FileBolo', function(result)
            if result then
                SendNUIMessage({
                    action = 'file_bolo_result',
                    result = 'success'
                })
            else
                SendNUIMessage({
                    action = 'file_bolo_result',
                    result = 'failed'
                })
            end
        end, data.id, data.report, officerName)

    end, GetPlayerServerId(PlayerId()))
end)

--[[ EDIT BOLO ]]--
RegisterNUICallback('NUIEditBolo', function(data, cb)
    -- server callback soh_lspis:EditBolo
    officerName = nil
    ESX.TriggerServerCallback('soh_lspis:GetName', function(name)
        officerName = name.firstname .. " " .. name.lastname

        ESX.TriggerServerCallback('soh_lspis:EditBolo', function(result)
            if result[1] ~= nil then
                --
            else
                --
            end
        end)
    end)
end)

--[[ FILE WARRANT ]]--
RegisterNUICallback('NUIFileWarrant', function(data, cb)
    officerName = nil
    ESX.TriggerServerCallback('soh_lspis:GetName', function(name)
        officerName = name.firstname .. " " .. name.lastname

        ESX.TriggerServerCallback('soh_lspis:FileWarrant', function(result)
            if result then
                SendNUIMessage({
                    action = 'file_warrant_result',
                    result = 'success'
                })
            else
                SendNUIMessage({
                    action = 'file_warrant_result',
                    result = 'failed'
                })
            end
        end, data.id, data.name, data.details, officerName, data.status)

    end, GetPlayerServerId(PlayerId()))
end)

--[[ EDIT WARRANT ]]--
RegisterNUICallback('NUIEditWarrant', function(data, cb)
    -- server callback soh_lspis:EditWarrant
end)

--[[ FILE RECORD ]]--
RegisterNUICallback('NUIFileRecord', function(data, cb)
    officerName = nil
    ESX.TriggerServerCallback('soh_lspis:GetName', function(name)
        officerName = name.firstname .. " " .. name.lastname

        ESX.TriggerServerCallback('soh_lspis:FileRecord', function(result)
            if result then
                SendNUIMessage({
                    action = 'file_record_result',
                    result = 'success'
                })
            else
                SendNUIMessage({
                    action = 'file_record_result',
                    result = 'failed'
                })
            end
        end, data.id, data.firstName, data.lastName, data.dob, data.height, data.sex, data.phoneNumber, data.address, data.dlStatus, data.wlStatus, data.paroleStatus, data.charges, data.citations, data.arrests, data.notes, officerName)

    end, GetPlayerServerId(PlayerId()))
end)

--[[ EDIT RECORD ]]--
RegisterNUICallback('NUIEditRecord', function(data, cb)
    -- server callback soh_lspis:EditRecord
end)

--[[ ======================== END NUI CALLBACKS ======================== ]]--

--[[ THREADS ]]--
Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(1)
		if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'offpolice') then
			if IsControlJustPressed(0, Keys[","]) then
				if not guiOpen then
                    OpenGUI()
				end
			end
		end
	end
end)