--[[  
    LSPIS by HF Creations for SoH RP
	- Los Santos Police Information System
	- Criminal Records, MDT, BOLO's, and everything else our LSPD needs.
]]--

--[[ FETCH ESX ]]--
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

--[[ ESX SERVER CALLBACKS ]]--
--[[ BOLOS ]]--
ESX.RegisterServerCallback('soh_lspis:GetBolos', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT * FROM lspis_bolos", {}, function(result)
        if result[1] ~= nil then
            local data = {}

            for i=1, #result, 1 do
                table.insert(data, {
                    reportId = result[i].bolo_id,
                    report = result[i].report,
                    issuedBy = result[i].issuing_officer
                })
            end

            cb(data)
        else
            cb(false)
            print('##### [LSPIS DEBUG]: GetBolos Server Callback returned nil. Check to see if the lspis_bolos table is empty before assuming error. #####')
        end
    end)
end)

--[[ WARRANTS ]]--
ESX.RegisterServerCallback('soh_lspis:GetWarrants', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT * FROM lspis_warrants", {}, function(result)
        if result[1] ~= nil then
            local data = {}

            for i=1, #result, 1 do
                table.insert(data, {
                    warrantId = result[i].warrant_number,
                    name = result[i].name,
                    details = result[i].details,
                    status = result[i].status,
                    issuedBy = result[i].issuing_officer
                })
            end

            cb(data)
        else
            cb(false)
            print('##### [LSPIS DEBUG]: GetWarrants Server Callback returned nil. Check to see if the lspis_warrants table is empty before assuming error. #####')
        end
    end)
end)

--[[ NAME SEARCH ]]--
ESX.RegisterServerCallback('soh_lspis:NameSearch', function(source, cb, firstName, lastName)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {}
    local dbError = false

    local characterCheck = MySQL.Sync.fetchAll('SELECT identifier, firstname, lastname, sex, dateofbirth, height, phone_number, jail FROM users WHERE firstname = @firstname AND lastname = @lastname COLLATE utf8_bin', {
        ['@firstname'] = firstName, ['@lastname'] = lastName
    })

    if characterCheck[1] == nil then
        dbError = true
    end

    if not dbError then
        if characterCheck[1].identifier ~= nil then
            local identifier = characterCheck[1].identifier

            local licenseCheck = MySQL.Sync.fetchAll('SELECT type FROM user_licenses WHERE owner = @identifier', {
                ['@identifier'] = identifier
            })

            local recordCheck = MySQL.Sync.fetchAll('SELECT * FROM lspis_records WHERE first_name = @firstName AND last_name = @lastName', {
                ['@firstName'] = firstName, ['@lastName'] = lastName
            })

            for i=1, #characterCheck, 1 do
                data = {
                    firstname = characterCheck[i].firstname,
                    lastname = characterCheck[i].lastname,
                    sex = characterCheck[i].sex,
                    dateofbirth = characterCheck[i].dateofbirth,
                    height = characterCheck[i].height,
                    phonenumber = characterCheck[i].phone_number,
                    jail = characterCheck[i].jail
                }
            end

            local licenseList = ''
            for i=1, #licenseCheck, 1 do
                local licenseType = licenseCheck[i].type
                if string.find(licenseType, "boat") then
                    licenseList = licenseList .. "Boat License<br/>"
                end
                if string.find(licenseType, "dmv") then
                    licenseList = licenseList .. "Drivers Permit<br/>"
                end
                if string.find(licenseType, "drive") then
                    licenseList = licenseList .. "Drivers License<br/>"
                end
                if string.find(licenseType, "drive_bike") then
                    licenseList = licenseList .. "Motorcycle License<br/>"
                end
                if string.find(licenseType, "drive_truck") then
                    licenseList = licenseList .. "Commercial License<br/>"
                end
                if string.find(licenseType, "weapon") then
                    licenseList = licenseList .. "Weapon License<br/>"
                end
                if string.find(licenseType, "weed_processing") then
                    licenseList = licenseList .. "Weed Processing License<br/>"
                end
                    
                data.licenses = licenseList
            end

            if recordCheck[1] ~= nil then
                for i=1, #recordCheck, 1 do
                    data.address = recordCheck[i].address
                    data.dlStatus = recordCheck[i].drivers_license
                    data.wpStatus = recordCheck[i].weapon_permit
                    data.paroleStatus = recordCheck[i].parole_status
                    data.charges = recordCheck[i].charges
                    data.citations = recordCheck[i].citations
                    data.arrests = recordCheck[i].arrests
                    data.notes = recordCheck[i].notes
                    data.lastUpdatedBy = recordCheck[i].last_updated_by
                end
            else
                data.address = 'No Information Found'
                data.dlStatus = 'No Information Found'
                data.wpStatus = 'No Information Found'
                data.paroleStatus = 'No Information Found'
                data.charges = 'No Information Found'
                data.citations = 'No Information Found'
                data.arrests = 'No Information Found'
                data.notes = 'No Information Found'
                data.lastUpdatedBy = 'No Information Found'
            end

            cb(data)
        else
            data.firstname = firstName
            data.lastname = lastName
            data.sex = 'No Information Found'
            data.dateofbirth = 'No Information Found'
            data.height = 'No Information Found'
            data.phonenumber = 'No Information Found'
            data.jail = 'No Information Found'
            data.licenses = 'No Information Found'
            data.address = 'No Information Found'
            data.dlStatus = 'No Information Found'
            data.wpStatus = 'No Information Found'
            data.paroleStatus = 'No Information Found'
            data.charges = 'No Information Found'
            data.citations = 'No Information Found'
            data.arrests = 'No Information Found'
            data.notes = 'No Information Found'
            data.lastUpdatedBy = 'No Information Found'

            cb(data)
        end
    else
        cb(false)
    end
end)

--[[ PLATE SEARCH ]]--
ESX.RegisterServerCallback('soh_lspis:PlateSearch', function(source, cb, plate)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {}
    local dbError = false

    local checkPlate = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE plate LIKE @plate', {
        ['@plate'] = plate
    })

    if checkPlate[1] == nil then
        dbError = true
    end

    if not dbError then
        if checkPlate[1].owner ~= nil then
            local identifier = checkPlate[1].owner

            local fetchPlayer = MySQL.Sync.fetchAll('SELECT identifier, firstname, lastname FROM users WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            })

            for i=1, #fetchPlayer, 1 do
                data.plate = plate
                data.firstname = fetchPlayer[i].firstname
                data.lastname = fetchPlayer[i].lastname
            end

            for i=1, #checkPlate, 1 do
                data.vehicleProps = checkPlate[i].vehicle
            end

            cb(data)
        else
            print('##### [LSPIS DEBUG]: PlateSearch Server Callback checkPlate returned nil #####')
        end
    else
        cb(false)
    end
end)

--[[ FILE BOLO ]]--
ESX.RegisterServerCallback('soh_lspis:FileBolo', function(source, cb, id, report, officer)
    MySQL.Async.execute('INSERT INTO lspis_bolos (bolo_id, report, issuing_officer) VALUES (@id, @report, @issuing_officer)', {
        ['@id'] = id,
        ['@report'] = report,
        ['@issuing_officer'] = officer
    }, function(didInsert)
        if didInsert then
            cb(true)
        else
            cb(false)
        end
    end)
end)

--[[ EDIT BOLO ]]--
ESX.RegisterServerCallback('soh_lspis:EditBolo', function(source, cb, id, report, officer)
    -- sql update bolo by ID
end)

--[[ FILE WARRANT ]]--
ESX.RegisterServerCallback('soh_lspis:FileWarrant', function(source, cb, id, name, details, officer, status)
    MySQL.Async.execute('INSERT INTO lspis_warrants (warrant_number, name, details, status, issuing_officer) VALUES (@id, @name, @details, @status, @issuing_officer)', {
        ['@id'] = id,
        ['@name'] = name,
        ['@details'] = details,
        ['@status'] = status,
        ['@issuing_officer'] = officer
    }, function(didInsert)
        if didInsert then
            cb(true)
        else
            cb(false)
        end
    end)
end)

--[[ EDIT WARRANT ]]--
ESX.RegisterServerCallback('soh_lspis:EditWarrant', function(source, cb, id, name, details, officer, status)
    -- sql update warrant by ID
end)

--[[ FILE RECORD ]]--
ESX.RegisterServerCallback('soh_lspis:FileRecord', function(source, cb, id, firstName, lastName, dob, height, sex, phoneNumber, address, dlStatus, wlStatus, paroleStatus, charges, citations, arrests, notes, officerName)
    MySQL.Async.execute('INSERT INTO lspis_records (record_number, first_name, last_name, date_of_birth, height, sex, phone_number, address, drivers_license, weapon_permit, parole_status, charges, citations, arrests, notes, last_updated_by) VALUES (@record_number, @first_name, @last_name, @date_of_birth, @height, @sex, @phone_number, @address, @drivers_license, @weapon_permit, @parole_status, @charges, @citations, @arrests, @notes, @last_updated_by)', {
        ['@record_number'] = id,
        ['@first_name'] = firstName,
        ['@last_name'] = lastName,
        ['@date_of_birth'] = dob,
        ['@height'] = height,
        ['@sex'] = sex,
        ['@phone_number'] = phoneNumber,
        ['@address'] = address,
        ['@drivers_license'] = dlStatus,
        ['@weapon_permit'] = wlStatus,
        ['@parole_status'] = paroleStatus,
        ['@charges'] = charges,
        ['@citations'] = citations,
        ['@arrests'] = arrests,
        ['@notes'] = notes,
        ['@last_updated_by'] = officerName
    }, function(didInsert)
        if didInsert then
            cb(true)
        else
            cb(false)
        end
    end)
end)

--[[ EDIT RECORD ]]--
ESX.RegisterServerCallback('soh_lspis:EditRecord', function(source, cb, id, firstName, lastName, dob, height, sex, phoneNumber, address, dlStatus, wlStatus, paroleStatus, charges, citations, arrests, notes, officerName)
    -- sql update record by ID
end)

--[[ ############ END CALLBACKS FOR NUI ############ ]]--

--[[ FETCH OFFICER NAME ]]--
ESX.RegisterServerCallback('soh_lspis:GetName', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	})

	local firstname = result[1].firstname
	local lastname  = result[1].lastname

	local data = {
		firstname = firstname,
		lastname  = lastname
    }
    
    cb(data)
end)