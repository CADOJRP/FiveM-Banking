RegisterNetEvent("updateClientMoney")
AddEventHandler("updateClientMoney", function(type, amount)
    if type == "bank" then
        StatSetInt('BANK_BALANCE', amount, true)
    else
        StatSetInt('MP0_WALLET_BALANCE', amount, true)
    end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1000 * 600)
        TriggerServerEvent("weeklyPayment")
	end
end)
