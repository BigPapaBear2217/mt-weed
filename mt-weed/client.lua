local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPlants = 0
local weedPlants = {}

-- Criar blip para a apanha de weed
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-2198.48, 5123.81, 12.42) -- Mudar coordenadas do blip aqui!
	SetBlipSprite(blip, 140) -- Mudar estilo do blip aqui!
	SetBlipDisplay(blip, 2)
	SetBlipScale(blip, 0.7)
	SetBlipAsShortRange(blip, true)
	SetBlipColour(blip, 3)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Weed Picking") -- Mudar nome do Blip aqui!
    EndTextCommandSetBlipName(blip)
end)

-- Apanhar Plantas
RegisterNetEvent('mt-weed:client:Apanhar', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local nearbyObject, nearbyID
	for i=1, #weedPlants, 1 do
		if GetDistanceBetweenCoords(coords, GetEntityCoords(weedPlants[i]), false) < 1.2 then
			nearbyObject, nearbyID = weedPlants[i], i
		end
	end
	QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
		if HasItem then
			if nearbyObject and IsPedOnFoot(playerPed) then
				isPickingUp = true
                QBCore.Functions.Progressbar('name_here', 'HAVERSTING PLANT...', 5000, false, true, {
		    disableMovement = true,
		    disableCarMovement = true,
		    disableMouse = false,
		    disableCombat = true,
		}, {}, {}, {}, function()
				TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)
				Wait(6500)
				ClearPedTasks(playerPed)
				Wait(1000)
				DeleteObject(nearbyObject) 
				table.remove(weedPlants, nearbyID)
				spawnedPlants = spawnedPlants - 1
				TriggerServerEvent('mt-weed:server:Apanhar')
			end)
			else
				QBCore.Functions.Notify('Too far way...', 'error', 3500)
			end
		else
			QBCore.Functions.Notify('You need a towler!', 'error', 3500)
		end
	end, "trowel")
end)

-- Pegar Coordenadas
CreateThread(function()
	while true do
		Wait(10)
		local coords = GetEntityCoords(PlayerPedId())
		if GetDistanceBetweenCoords(coords, Config.WeedField, true) < 50 then
			SpawnweedPlants()
			Wait(500)
		else
			Wait(500)
		end
	end
end)

-- Eliminar Plantas ao Apanhar
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(weedPlants) do
			DeleteObject(v)
		end
	end
end)

-- Spawn Plantas
function SpawnObject(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(1)
	end
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if cb then
        cb(obj)
    end
end

-- Gerar Coordenadas para as Plantas
function SpawnweedPlants()
	while spawnedPlants < 15 do
		Wait(1)
		local plantCoords = GeneratePlantsCoords()
		SpawnObject('prop_weed_01', plantCoords, function(obj)
			table.insert(weedPlants, obj)
			spawnedPlants = spawnedPlants + 1
		end)
	end
end 

-- Validar Coordenadas
function ValidatePlantsCoord(plantCoord)
	if spawnedPlants > 0 then
		local validate = true
		for k, v in pairs(weedPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end
		if GetDistanceBetweenCoords(plantCoord, Config.WeedField, false) > 50 then
			validate = false
		end
		return validate
	else
		return true
	end
end

-- Gerar Box Coords
function GeneratePlantsCoords()
	while true do
		Wait(1)
		local weedCoordX, weedCoordY
		math.randomseed(GetGameTimer())
		local modX = math.random(-15, 15)
		Wait(100)
		math.randomseed(GetGameTimer())
		local modY = math.random(-15, 15)
		weedCoordX = Config.WeedField.x + modX
		weedCoordY = Config.WeedField.y + modY
		local coordZ = GetCoordZPlants(weedCoordX, weedCoordY)
		local coord = vector3(weedCoordX, weedCoordY, coordZ)
		if ValidatePlantsCoord(coord) then
			return coord
		end
	end
end

-- Verificar Altura das Coordenadas
function GetCoordZPlants(x, y)
	local groundCheckHeights = { 35, 36.0, 37.0, 38.0, 39.0, 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0 }
	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)
		if foundGround then
			return z
		end
	end
	return 53.85
end

--Target para apanha
exports['qb-target']:AddTargetModel(`prop_weed_01`, {
    options = {
        {
            event = "mt-weed:client:Apanhar",
            icon = "fas fa-seedling",
            label = "Havert Plant",
        },
    },
    distance = 2.0
})

RegisterNetEvent('mt-weed:client:pararMenuCorte', function()
    ClearPedTasks(PlayerPedId())
end)

-- Menu de corte
RegisterNetEvent('mt-weed:client:MenuCorte', function()
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_PARKING_METER", 3500, false)
    exports['qb-menu']:openMenu({
        {
            header = "Cut Weed",
            txt = "Weed necessária:</p>10x Sacos de weed vazios</p>1x Planta de weed.",
            isMenuHeader = true
        },
        {
            header = "Cut weed Plant",
            txt = "",
            params = {
                event = "mt-weed:server:CortarWeed",
                isServer = true,
                args = 1

            }
        },
        {
            header = "< Close",
            params = {
                event = "mt-weed:client:pararMenuCorte"
            }
        },
    })
end)
