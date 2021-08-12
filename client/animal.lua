RDX = nil
Citizen.CreateThread(function()
	while RDX == nil do
		TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)
		Citizen.Wait(100)
	end
end)

local looting = false

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
		local player = PlayerPedId()
		if IsControlJustPressed(0,1101824977) and not IsPedInAnyVehicle(player, true) and not looting then
			local shape = true
			while shape do
				Wait(0)
				local coords = GetEntityCoords(player)
				local entityHit = 0
				local shapeTest = StartShapeTestBox(coords.x, coords.y, coords.z, 2.0, 2.0, 2.0, 0.0, 0.0, 0.0, true, 8, player)
				local rtnVal, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
				local type = GetPedType(entityHit)
				local model = GetEntityModel(entityHit)
				local dead = IsEntityDead(entityHit)
				if type == 28 and dead then
					for i, row in pairs(Animal) do
						if model == Animal[i]["model"] then
							local looted = Citizen.InvokeNative(0x8DE41E9902E85756, entityHit)
							if not looted then
								shape = false
								looting = true
								while looting do
									Wait(0)
									local lootedcheck = Citizen.InvokeNative(0x8DE41E9902E85756, entityHit)
									local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
									local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
									if lootedcheck and holding then
										if Animal[i]["poor"] == nil or Animal[i]["good"] == nil or Animal[i]["perfect"] == nil then
											TriggerServerEvent("rdx_animalharvest:add", Animal[i]["item"], 1)
											if Animal[i]["icon"] == nil then
												exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a "..Animal[i]["name"].." Skin",'inventory_items_mp', 'provision_arrowhead_obsidian',10000)
											else
												exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a "..Animal[i]["name"].." Skin",'inventory_items_mp', Animal[i]["icon"],10000)
											end
										else
											if quality == Animal[i]["poor"] then
												TriggerServerEvent("rdx_animalharvest:add", Animal[i]["item"], 1)
												if Animal[i]["icon"] == nil then
													exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a ~COLOR_BRONZE~Poor~COLOR_WHITE~ "..Animal[i]["name"].." Skin",'inventory_items_mp', 'provision_arrowhead_obsidian',10000)
												else
													exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a ~COLOR_BRONZE~Poor~COLOR_WHITE~ "..Animal[i]["name"].." Skin",'inventory_items_mp', Animal[i]["icon"],10000)
												end
											elseif quality == Animal[i]["good"] then
												TriggerServerEvent("rdx_animalharvest:add", Animal[i]["item"], 2)
												if Animal[i]["icon"] == nil then
													exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a ~COLOR_GREENDARK~Good~COLOR_WHITE~ "..Animal[i]["name"].." Skin",'inventory_items_mp', 'provision_arrowhead_obsidian',10000)
												else
													exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a ~COLOR_GREENDARK~Good~COLOR_WHITE~ "..Animal[i]["name"].." Skin",'inventory_items_mp', Animal[i]["icon"],10000)
												end
											elseif quality == Animal[i]["perfect"] then
												TriggerServerEvent("rdx_animalharvest:add", Animal[i]["item"], 3)
												if Animal[i]["icon"] == nil then
													exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a ~COLOR_GOLD~Perfect~COLOR_WHITE~ "..Animal[i]["name"].." Skin",'inventory_items_mp', 'provision_arrowhead_obsidian',10000)
												else
													exports['LRP_Notify']:DisplayLeftNotification('Animal Skin',"You picked up a ~COLOR_GOLD~Perfect~COLOR_WHITE~ "..Animal[i]["name"].." Skin",'inventory_items_mp', Animal[i]["icon"],10000)
												end
											end
										end
										looting = false
									end
								end
							end
						end
					end
				end
			end
		end
    end
end)

local npc = nil--create a variable, so npc can be deleted
RegisterCommand("npc", function(source, args, raw)--command to spawn
	if args[1] ~= nil and args[2] ~= nil then
		local num = args[1]
		local _scale = tonumber(args[2])
		TriggerEvent("npc:spawns",num, _scale)
	else
		print("Usage: /npc pedmodelname size - /npc a_c_badger_01 2.0")
	end
end,false)

RegisterNetEvent('npc:spawns')
AddEventHandler('npc:spawns', function(num1,num2)
    local pped = PlayerPedId() --Get Player Ped
    local _num1 = tostring(num1) --First Param will be a string
    local _num2 = tonumber(num2) --Second Param is a number
    if _num1 ~= nil then --If model is not nil
        if npc then --If the ped exists
            DeleteEntity(npc)--Delete the existing ped
        end
        local animalHash = GetHashKey(_num1) --Get the Has key of the First param
        if not IsModelValid(animalHash) then --If model is not valid, function returns
            return
        end
        RequestModel(animalHash) --Request the model's hash
        while not HasModelLoaded(animalHash) do --wait till model loads
            Citizen.Wait(0)
        end
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(pped, 0.0, 5.0, 0.5)) --Get Coords front of player
        npc = CreatePed(animalHash, x, y, z, GetEntityHeading(pped)+90, 1, 0) --create the npc
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) --set random outfit
        Citizen.InvokeNative(0x25ACFC650B65C538,npc,_num3) -- set the scale, second param used
		while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C,npc) do --wait till outfit loads
			Citizen.Wait(0)
		end
		Citizen.InvokeNative(0x704C908E9C405136, npc)
		Citizen.InvokeNative(0xAAB86462966168CE, npc, 1)
        Citizen.Wait(500)
		Citizen.InvokeNative(0xCE6B874286D640BB, npc, math.random(0,2))
        --FreezeEntityPosition(npc, true)--Freeze the npc in position
    else
        print("Model not found.")--debug if first param is not valid
    end
end)