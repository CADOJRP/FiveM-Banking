local resource = GetCurrentResourceName()

local taxes = {
    ["income"] = 10.0,  -- 10%
    ["sales"] = 7.5   -- 7.5%
}

local govmoney = {
    ["taxes"] = 0,      -- Money Made Per Resource Run From Taxes (Server Uptime Duration)
    ["police"] = 0      -- Money Made Per Resource Run From Policing (Server Uptime Duration)
}

--[[
function UpdateUser(user, rank)
    local userinfo = {
        ["name"] = GetPlayerName(user),
        ["rank"] = rank,
        ["license"] = GetPlayerIdentifiers(user)[2],
        ["steam"] = GetPlayerIdentifiers(user)[1],
    }
    local data = ReadFile('users')
    local count = 0
    local found = false
    for k, v in pairs(data) do
        count = count + 1
        if v.license == GetPlayerIdentifiers(user)[2] then
            print('Yep 1')
            table.remove(data, k)
            table.insert(data, userinfo)
            WriteFile('users', data)
            found = true
        end
    end
    if not found then
        count = 1
        print('Yep 2')
        table.insert(data, userinfo)
        WriteFile('users', data)
    end
    if count == 0 then
        print('Yep 3')
        table.insert(data, userinfo)
        WriteFile('users', data)
    end
end
]]--
RegisterCommand("balance", function(source, args)
    if args[1] == nil then
        local userdata = GetUserData(source)
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^2^* " .. GetPlayerName(source) .. "'s Balance")
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Bank Balance: $" .. format_thousand(userdata.bank))
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Cash Balance: $" .. format_thousand(userdata.cash))
    else
        if GetPlayerPing(args[1]) ~= 0 then
            local userdata = GetUserData(args[1])
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^2^* " .. GetPlayerName(args[1]) .. "'s Balance:")
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Bank Balance: $" .. format_thousand(userdata.bank))
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Cash Balance: $" .. format_thousand(userdata.cash))
        else 
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Unknown Player. Example: /balance ID")        
        end
    end
end)

RegisterCommand("serverbalance", function(source, args)
    local cash = 0
    local bank = 0
    for k, v in pairs(ReadFile('data')) do
        cash = cash + v.cash
        bank = bank + v.bank
    end
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^2^* Total Server Balance:")
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Bank Balance: $" .. format_thousand(bank))
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Cash Balance: $" .. format_thousand(cash))
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Combined Balance: $" .. format_thousand(cash + bank))
end)

RegisterCommand("taxinfo", function(source, args)
    local cash = 0
    local bank = 0
    for k, v in pairs(ReadFile('data')) do
        cash = cash + v.cash
        bank = bank + v.bank
    end
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^2^* Tax Information:")
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Income Tax: " .. taxes.income .. "%")
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Sales Tax: " .. taxes.sales .. "%")
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Tax Balance: $" .. format_thousand(govmoney.taxes))
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Police Balance: $" .. format_thousand(govmoney.police))
end)

RegisterCommand('pay', function (source, args)
    if args[1] == nil or args[2] == nil then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Missing Parameter! Example: /pay ID amount")
        return
    end
    if GetPlayerPing(args[1]) ~= 0 then
        local amount = tonumber(args[2])
        if amount < 1 then
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 The minimum amount to pay is $1")        
        else
            if RemoveMoney(source, "cash", amount) then
                AddMoney(args[1], "cash", amount)
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 You have paid $" .. amount .. " to " .. GetPlayerName(args[1]))   
                TriggerClientEvent('chatMessage', args[1], "", {255, 0, 0}, "^8[CADOJRP]^7 You have received $" .. amount .. " from " .. GetPlayerName(source))
            else
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Not enough money!")
            end
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Unknown Player. Example: /pay ID amount")
    end
end)

RegisterCommand('adminpay', function (source, args)
	if IsPlayerAceAllowed(source, "blockVPN.bypass") then
        if GetPlayerPing(args[1]) ~= 0 then
            local amount = tonumber(args[2])
            AddMoney(args[1], "cash", amount)
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 You have admin paided $" .. amount .. " to " .. GetPlayerName(args[1]))     
            TriggerClientEvent('chatMessage', args[1], "", {255, 0, 0}, "^8[CADOJRP]^7 You have received $" .. amount .. " from " .. GetPlayerName(source))
        else
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Unknown Player. Example: /pay ID amount")
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 You do not have permission to use /adminpay")
    end
end)

RegisterCommand('settax', function (source, args)
    if IsPlayerAceAllowed(source, "blockVPN.bypass") then
        if tonumber(args[2]) > 100 then
            args[2] = 100
        else
            args[2] = tonumber(args[2])
        end
        if args[1] == "income" then
            taxes.income = args[2]
            if args[2] < 15 then
                args[2] = "^2" .. args[2]
            elseif args[2] >= 15 and args[2] < 25 then
                args[2] = "^3" .. args[2]
            else
                args[2] = "^8" .. args[2]
            end
            TriggerClientEvent('chatMessage', -1, "", {255, 0, 0}, "^8[CADOJRP]^7 Income Tax Change! Income tax has changed to " .. args[2] .. "%")
        elseif args[1] == "sales" then
            taxes.sales = args[2]
            if args[2] < 15 then
                args[2] = "^2" .. args[2]
            elseif args[2] >= 15 and args[2] < 25 then
                args[2] = "^3" .. args[2]
            else
                args[2] = "^8" .. args[2]
            end
            TriggerClientEvent('chatMessage', -1, "", {255, 0, 0}, "^8[CADOJRP]^7 Sales Tax Change! Sales tax has changed to " .. args[2] .. "%")
        else
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Missing Parameter! Example: /settax (sales/income) amount (/settax sales 20).")
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 You do not have permission to use /settax")
    end
end)

RegisterCommand('ticket', function (source, args)
    if args[1] == nil or args[2] == nil  or args[3] == nil then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Missing Parameter! Example: /ticket PASS ID PRICE")
        return
    end
    if args[1] == "cadojrp2018" then
        if GetPlayerPing(args[2]) ~= 0 then
            local amount = tonumber(args[3])
            if amount > 1000 or amount < 30 then
                TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Ticket price can't exceed $1000 or be lower than $30")
            else
                if RemoveMoney(args[2], "cash", amount) then
                    TriggerClientEvent('chatMessage', args[2], "", {255, 0, 0}, "^8[CADOJRP]^7 You have been issued a $" .. amount .. " citation by " .. GetPlayerName(source))     
                    AddMoney(source, "cash", amount / 2)     
                    govmoney.police = govmoney.police + amount / 2
                    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 You have received $" .. amount / 2 .. " from the citation.")
                else
                    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 " .. GetPlayerName(args[2]) .. " doesn't have enough money to pay the citation.")
                    TriggerClientEvent('chatMessage', args[2], "", {255, 0, 0}, "^8[CADOJRP]^7 You don't have enough money to pay the $" .. args[3] .. " citation.")
                end
            end
        else
            TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Unknown Player. Example: /ticket PASS ID PRICE")
        end
    else
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Incorrect ticket password! /ticket PASS ID PRICE")
    end
end)
  
  --[[
RegisterCommand("rem", function(source, args)
    local remove = RemoveMoney(source, "cash", 10)
    if remove then
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 Remved")
    else
        
        TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 N0 Remved")
    end
end)

RegisterCommand("add", function(source, args)
    AddMoney(source, args[1], args[2])
end)
]]--

AddEventHandler("playerConnecting", function(name, setReason, deferrals)
    if string.find(GetPlayerIdentifiers(source)[1], "steam:") then
        local user = source
        local data = ReadFile('data')
        local count = 0
        local found = false
    
        for k, v in pairs(data) do
            count = count + 1
            if v.steamid == GetPlayerIdentifiers(user)[1] then
                found = true
            end
        end
    
        if not found then
            count = count + 1
            local userinfo = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = 0,
                ["bank"] = 0,
            }
            table.insert(data, userinfo)
            WriteFile('data', data)
        end
    
        if count == 0 then
            local userinfo = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = 0,
                ["bank"] = 0,
            }
            table.insert(data, userinfo)
            WriteFile('data', data)
        end
	else 
		setReason("Error! Steam is required to play on this FiveM server.")
		CancelEvent()
	end
end)

RegisterNetEvent("weeklyPayment")
AddEventHandler("weeklyPayment", function()
    local money = math.random(220,550)
    local taxed = money - (money * (taxes.income / 100))
    AddMoney(source, "cash", taxed)
    govmoney.taxes = govmoney.taxes + (money - taxed)
    TriggerClientEvent('chatMessage', source, "", {255, 0, 0}, "^8[CADOJRP]^7 You have received $" .. money .. " ($" .. taxed .. " after taxes) from unemployment.")
end)

RegisterNetEvent("BankingAddMoney")
AddEventHandler("BankingAddMoney", function(user, type, amount)
    local Source = source
    AddMoney(user, type, amount)
end)

RegisterNetEvent("BankingRemoveMoney")
AddEventHandler("BankingRemoveMoney", function(user, type, amount)
    RemoveMoney(user, type, amount)
end)

RegisterServerEvent('chat:init')
AddEventHandler('chat:init', function()
    TriggerClientEvent("updateClientMoney", source, "cash", GetUserData(source).cash)  
    TriggerClientEvent("updateClientMoney", source, "bank", GetUserData(source).bank)  
end)

function AddMoney(user, type, amount)
    amount = tonumber(amount)
    if user == "self" then
        user = source
    end
    local userdata = GetUserData(user)
    local data = ReadFile('data')
    if type == "bank" then
        local newuserdata = {
            ["name"] = GetPlayerName(user),
            ["steamid"] = GetPlayerIdentifiers(user)[1],
            ["cash"] = userdata.cash,
            ["bank"] = math.floor(userdata.bank + amount),
        }
        for k, v in pairs(data) do
            if v.steamid == userdata.steamid then
                table.remove(data, k)
                table.insert(data, newuserdata)
                WriteFile('data', data)
            end
        end
        TriggerClientEvent("updateClientMoney", user, "bank", GetUserData(user).bank)  
    else
        local newuserdata = {
            ["name"] = GetPlayerName(user),
            ["steamid"] = GetPlayerIdentifiers(user)[1],
            ["cash"] = math.floor(userdata.cash + amount),
            ["bank"] = userdata.bank,
        }
        for k, v in pairs(data) do
            if v.steamid == userdata.steamid then
                table.remove(data, k)
                table.insert(data, newuserdata)
                WriteFile('data', data)
            end
        end
        TriggerClientEvent("updateClientMoney", user, "cash", GetUserData(user).cash)  
    end
end

function RemoveMoney(user, type, amount)
    amount = tonumber(amount)
    if user == "self" then
        user = source
    end
    local userdata = GetUserData(user)
    local data = ReadFile('data')
    if type == "bank" then
        if userdata.bank < amount then
            return false
        else
            local newuserdata = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = userdata.cash,
                ["bank"] = math.floor(userdata.bank - amount),
            }
            for k, v in pairs(data) do
                if v.steamid == userdata.steamid then
                    table.remove(data, k)
                    table.insert(data, newuserdata)
                    WriteFile('data', data)
                end
            end
            TriggerClientEvent("updateClientMoney", user, "bank", GetUserData(user).bank)  
            return true
        end
    else
        if userdata.cash < amount then
            return false
        else
            local newuserdata = {
                ["name"] = GetPlayerName(user),
                ["steamid"] = GetPlayerIdentifiers(user)[1],
                ["cash"] = math.floor(userdata.cash - amount),
                ["bank"] = userdata.bank,
            }
            for k, v in pairs(data) do
                if v.steamid == userdata.steamid then
                    table.remove(data, k)
                    table.insert(data, newuserdata)
                    WriteFile('data', data)
                end
            end
            TriggerClientEvent("updateClientMoney", user, "cash", GetUserData(user).cash)  
            return true
        end
    end
end

RegisterNetEvent("updateClientTaxesServer")
AddEventHandler("updateClientTaxesServer", function()
    TriggerClientEvent("updateClientTaxes", source, taxes)
end)

exports("GetTaxes", function()
    return taxes
end)

RegisterNetEvent("AddGovBalance")
AddEventHandler("AddGovBalance", function(type, amount)
    AddGovBalance(type, amount)
end)

exports("AddGovBalance", function(type, amount)
    AddGovBalance(type, amount)
end)

function AddGovBalance(type, amount)
    if type == "taxes" then
        govmoney.taxes = govmoney.taxes + amount
    elseif type == "police" then
        govmoney.police = govmoney.police + amount
    end
end

function GetUserData(user)
    if user == "self" then
        user = source
    end
    local returndata = nil
    for k, v in pairs(ReadFile('data')) do
        if v.steamid == GetPlayerIdentifiers(user)[1] then
            returndata = v
        end
    end
    return returndata
end

function ReadFile(file)
    local data = LoadResourceFile(resource, file .. '.json')
    if data then
        return json.decode(data)
    else
        return false
    end
end

function WriteFile(file, data)
    SaveResourceFile(resource, file .. '.json', json.encode(data), -1)
end

if not ReadFile('data') then
    WriteFile('data', {})
end

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos) .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end