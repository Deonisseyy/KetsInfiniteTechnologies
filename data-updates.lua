local tools = data.raw.tool;
local packs = {} -- contains ingredients for all packs technology
local formula = "";

local research_time = settings.startup["Ket-IT-research-time"].value;
local research_units = settings.startup["Ket-IT-research-units"].value;
local all_packs = settings.startup["Ket-IT-all-packs"].value;
local cost_multiplier = settings.startup["Ket-IT-ignore-cost-multiplier"].value;
local growth_type = settings.startup["Ket-IT-growth-type"].value;
local parameter_A = settings.startup["Ket-IT-parameter-A"].value;
local parameter_B = settings.startup["Ket-IT-parameter-B"].value;

if growth_type == "Linear" then
	formula = tostring(parameter_A) .. "*L+" .. tostring(parameter_B);
elseif growth_type == "Exponential" then
	if parameter_B == 0 then parameter_B = 1; end
	formula = tostring(parameter_A) .. "*" .. tostring(parameter_B) .. "^(L-1)";
end

for k, v in pairs(tools) do
	data:extend {
		{
			name = "IT_" .. k,
			localised_name = v.name,
			type = "technology",
			icon = v.icon,
			icon_size = 64, icon_mipmaps = 4,
			max_level = "infinite",
			ignore_cost_multiplier = cost_multiplier,
			unit = {
				count_formula = formula,
				ingredients = {
					{v.name, research_units}
				},
				time = research_time
			}
		}
	}
	table.insert(packs, {k, research_units})
end

if all_packs then
	data:extend {
		{
			name = "IT_all-packs",
			localised_name = "All packs infinite technology",
			type = "technology",
			icon_size = 64, icon_mipmaps = 4,
			icon = "__base__/graphics/icons/checked-green.png",
			max_level = "infinite",
			ignore_cost_multiplier = cost_multiplier,
			unit = {
				count_formula = formula,
				ingredients = packs,
				time = research_time
			}
		}
	}
end