RDX = nil
TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)

RegisterServerEvent("rdx_animalharvest:add")
AddEventHandler("rdx_animalharvest:add", function(item, amount)
	xPlayer = RDX.GetPlayerFromId(source)
	if item == 'item_feather' then
		num = math.random(1, 5)
		xPlayer.addInventoryItem(item, num)
	else
		xPlayer.addInventoryItem(item, amount)
	end
end)