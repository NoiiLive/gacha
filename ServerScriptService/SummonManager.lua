-- @ScriptType: ModuleScript
local SummonManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))

SummonManager.Rates = {
	Standard = {R = 70, SR = 25, SSR = 4, SP = 1},
	Event = {R = 70, SR = 25, SSR = 4, SP = 1},
	Carnival = {R = 50, SR = 30, SSR = 15, SP = 5}
}

function SummonManager.GetPool(rarity, bannerType)
	local pool = {}
	for id, data in pairs(UnitDatabase.Units) do
		if data.BaseRarity == rarity and data.Banners then
			for _, banner in ipairs(data.Banners) do
				if banner == bannerType then
					table.insert(pool, id)
					break
				end
			end
		end
	end
	return pool
end

function SummonManager.RollOne(bannerType)
	local rates = SummonManager.Rates[bannerType] or SummonManager.Rates.Standard
	local roll = math.random(1, 100)
	local pulledRarity = "R"

	if roll <= rates.SP then
		pulledRarity = "SP"
	elseif roll <= rates.SP + rates.SSR then
		pulledRarity = "SSR"
	elseif roll <= rates.SP + rates.SSR + rates.SR then
		pulledRarity = "SR"
	end

	local pool = SummonManager.GetPool(pulledRarity, bannerType)

	-- Fallbacks in case a rarity pool is completely empty for a specific banner
	if #pool == 0 then
		pool = SummonManager.GetPool("SSR", bannerType)
		if #pool == 0 then
			return "U001"
		end
	end

	return pool[math.random(1, #pool)]
end

function SummonManager.PerformSummon(bannerType, amount)
	local results = {}
	for i = 1, amount do
		table.insert(results, SummonManager.RollOne(bannerType))
	end
	return results
end

return SummonManager