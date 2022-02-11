local QBCore = exports['qb-core']:GetCoreObject()

-- Apanhar Plantas
RegisterServerEvent('mt-weed:server:Apanhar', function() 
    local src = source
    local Player  = QBCore.Functions.GetPlayer(src)
    local quantity = math.random(1, 2)
	if (60 >= math.random(1, 100)) then
        if Player.Functions.AddItem("og_kush_weed", math.random(1,2)) then   
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["og_kush_weed"], 'add')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Tens os bolsos cheios..', 'error')
        end		
	else
        TriggerClientEvent('QBCore:Notify', src, 'Destruis-te a planta..', 'error')
    end
end)

-- Cortar plantas de weed em sacos
RegisterServerEvent('mt-weed:server:CortarWeed', function(args) 
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local args = tonumber(args)
    local removeAmount = 1
    local returnAmount = math.random (20,28)
	local returnAmount2 = math.random (30,50)
    local baggieAmount = 28
	local baggieAmount2 = 50
    local packageTime = 7500
    if args == 1 then 
        local cocaine = Player.Functions.GetItemByName("og_kush_weed") 
        if cocaine ~= nil then
            if cocaine.amount >= removeAmount then
                local baggies = Player.Functions.GetItemByName("empty_weed_bag") 
                if baggies ~= nil then
                    if baggies.amount >= baggieAmount then
                        Player.Functions.RemoveItem("og_kush_weed", removeAmount)
						Player.Functions.RemoveItem("empty_weed_bag", returnAmount)
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['og_kush_weed'], "remove", removeAmount)
						TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['empty_weed_bag'], "remove", returnAmount)
                        TriggerClientEvent('pogressBar:drawBar', src, packageTime, 'A cortar weed..')
                        SetTimeout(packageTime, function()
                            if Player.Functions.AddItem('og_kush_bag', returnAmount, nil, info, {["quality"] = 100}) then
                                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["og_kush_bag"], "add", returnAmount)
								TriggerClientEvent('QBCore:Notify', src, 'Cortas-te uma planta de weed!', 'success')
                                TriggerClientEvent('mt-weed:client:MenuCorte', src)
                            else
                                TriggerClientEvent('QBCore:Notify', src, 'Tens os bolsos cheios..', 'error')
                            end
                        end)
                    else
                        TriggerClientEvent('QBCore:Notify', src, "Necessitas de pelo menos 28 sacos.", 'error')
                        TriggerClientEvent('mt-weed:client:MenuCorte', src)
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, "Necessitas de pelo menos 28 sacos..", "error")
                    TriggerClientEvent('mt-weed:client:MenuCorte', src)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Não tens plantas de weed..", 'error')
                TriggerClientEvent('mt-weed:client:MenuCorte', src)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Não tens plantas de weed..", "error")
            TriggerClientEvent('mt-weed:client:MenuCorte', src)
        end
    end
end)

-- Usar kit de corte
QBCore.Functions.CreateUseableItem("drug_cuttingkit", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local scaleCheck = Player.Functions.GetItemByName('drug_scales')
    if scaleCheck ~= nil then
        TriggerClientEvent('mt-weed:client:MenuCorte', source)
    else
        TriggerClientEvent('QBCore:Notify', source, "Não tens uma balança", 'error')
    end
end)