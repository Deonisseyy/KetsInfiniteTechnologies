-- mod variables
local tools = data.raw.tool;
local packs = {} -- contains ingredients for all packs technology
local formula = "";

-- settings data
local research_time = settings.startup["Ket-IT-research-time"].value;
local research_units = settings.startup["Ket-IT-research-units"].value;
local all_packs = settings.startup["Ket-IT-all-packs"].value;
local each_pack = settings.startup["Ket-IT-each-pack"].value;
local cost_multiplier = settings.startup["Ket-IT-ignore-cost-multiplier"].value;
local growth_type = settings.startup["Ket-IT-growth-type"].value;
local parameter_A = settings.startup["Ket-IT-parameter-A"].value;
local parameter_B = settings.startup["Ket-IT-parameter-B"].value;
local filter_string = settings.startup["Ket-IT-science-filter-string"].value;
local filter_type = settings.startup["Ket-IT-science-filter-type"].value;

local function science_pack_is_allowed(science_pack_name)
	if filter_type == "White list" then
		if filter_string:find(science_pack_name, 1, true) then
			return true;
		else
			return false;
		end
	else
		if filter_string:find(science_pack_name, 1, true) then
			return false;
		else
			return true;
		end
	end
end

if growth_type == "Linear" then
	formula = tostring(parameter_A) .. "*L+" .. tostring(parameter_B);
elseif growth_type == "Exponential" then
	if parameter_B == 0 then parameter_B = 1; end
	formula = tostring(parameter_A) .. "*" .. tostring(parameter_B) .. "^(L-1)";
end

for k, v in pairs(tools) do
	if science_pack_is_allowed(k) then
		if each_pack then
			local technology = {};
			technology.name = "Ket-IT-" .. k;
			technology.localised_name = v.name;
			technology.type = "technology";
			if v.icon ~= nil then
				technology.icon = v.icon;
			else
				technology.icons = v.icons;
			end
			if v.icon_size ~= nil then
				technology.icon_size = v.icon_size;
			end
			if v.icon_mipmaps ~= nil then
				technology.icon_mipmaps = v.icon_mipmaps;
			end
			technology.order = "Ket-IT-" .. v.order;
			technology.max_level = "infinite";
			technology.ignore_cost_multiplier = cost_multiplier;
			technology.unit = {
				count_formula = formula,
				ingredients = {
					{v.name, research_units}
				},
				time = research_time
			}
			-- if technology name ends with "-digits" then replace '-' to ' '
			if technology.name:find('(.+)-(%d+)$') then
				local p1, p2 = technology.name:match('(.+)-(%d+)$')
				technology.name = p1 .. " " .. p2;
			end
			data:extend{technology};
		end
		table.insert(packs, {k, research_units});
	end
end

if all_packs then
	data:extend {
		{
			name = "Ket-IT-all-packs",
			localised_name = "All packs infinite technology",
			type = "technology",
			icon_size = 64, icon_mipmaps = 4,
			icon = "__base__/graphics/icons/checked-green.png",
			order = "Ket-IT-zzzzz", -- 11881376-th slphabetic [a-z] technology order
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