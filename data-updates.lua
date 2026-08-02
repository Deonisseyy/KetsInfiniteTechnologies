local util = require("util")

local research_time = settings.startup["Ket-IT-research-time"].value
local research_units = settings.startup["Ket-IT-research-units"].value
local all_packs = settings.startup["Ket-IT-all-packs"].value
local each_pack = settings.startup["Ket-IT-each-pack"].value
local cost_multiplier = settings.startup["Ket-IT-ignore-cost-multiplier"].value
local growth_type = settings.startup["Ket-IT-growth-type"].value
local parameter_A = settings.startup["Ket-IT-parameter-A"].value
local parameter_B = settings.startup["Ket-IT-parameter-B"].value
local filter_string = settings.startup["Ket-IT-science-filter-string"].value
local filter_type = settings.startup["Ket-IT-science-filter-type"].value

local function get_science_pack_names()
    local science_pack_names = {}
    local lab_prototypes = data.raw["lab"]
    if lab_prototypes then
        for _, lab_prototype in pairs(lab_prototypes) do
            if lab_prototype.inputs then
                for _, input_name in pairs(lab_prototype.inputs) do
                    table.insert(science_pack_names, input_name)
                end
            end
        end
    end
    return science_pack_names
end

local function define_formula()
    if growth_type == "Linear" then
        return tostring(parameter_A) .. "*L+" .. tostring(parameter_B)
    elseif growth_type == "Exponential" then
        if parameter_B == 0 then parameter_B = 1 end
        return tostring(parameter_A) .. "*" .. tostring(parameter_B) .. "^(L-1)"
    end
end

local function science_pack_is_allowed(science_pack_name)
    if filter_type == "White list" then
        if filter_string:find(science_pack_name, 1, true) then
            return true
        else
            return false
        end
    else
        if filter_string:find(science_pack_name, 1, true) then
            return false
        else
            return true
        end
    end
end

local function get_allowed_science_packs(science_pack_names)
    local allowed_packs = {}
    for _, pack_name in pairs(science_pack_names) do
        if science_pack_is_allowed(pack_name) then
            local v = data.raw["item"][pack_name]
            if v then
                table.insert(allowed_packs, pack_name)
            end
        end
    end
    return allowed_packs
end

local function create_technology(pack_name, formula)
    local v = data.raw["item"][pack_name]
    local localised_name = v.localised_name
    if localised_name == nil then
        localised_name = {"item-name." .. v.name}
    end
    local technology = {}
    technology.name = "Ket-IT-" .. pack_name
    technology.type = "technology"
    technology.localised_name = {"", localised_name, " infinite"}
    if v.icon ~= nil then
        technology.icon = v.icon
    else
        technology.icons = v.icons
    end
    if v.icon_size ~= nil then
        technology.icon_size = v.icon_size
    end
    if v.icon_mipmaps ~= nil then
        technology.icon_mipmaps = v.icon_mipmaps
    end
    if v.order ~= nil then
        technology.order = "Ket-IT-" .. v.order
    else
        technology.order = "ket_IT-" .. string.sub(pack_name, 1, 3)
    end
    technology.max_level = "infinite"
    technology.ignore_cost_multiplier = cost_multiplier
    technology.unit = {
        count_formula = formula,
        ingredients = {
            {pack_name, research_units}
        },
        time = research_time
    }
    if data.raw["technology"][pack_name] ~= nil then
        technology.prerequisites = {pack_name}
    end
    if technology.name:find('(.+)-(%d+)$') then
        local p1, p2 = technology.name:match('(.+)-(%d+)$')
        technology.name = p1 .. "_" .. p2
    end
    return technology
end

local function create_all_packs_technology(allowed_science_packs, formula)
    local ingredients = {}
    for _, pack_name in pairs(allowed_science_packs) do
        table.insert(ingredients, {pack_name, research_units})
    end
    local technology_prerequisites = {}
    for _, pack_name in pairs(allowed_science_packs) do
        if data.raw["technology"][pack_name] ~= nil then
            table.insert(technology_prerequisites, pack_name)
        end
    end
    local technology = {
        name = "Ket-IT-all-packs",
        localised_name = "All packs infinite technology",
        type = "technology",
        icon_size = 64, icon_mipmaps = 4,
        icon = "__base__/graphics/icons/signal/signal-checked-green.png",
        order = "Ket-IT-zzzzz",
        max_level = "infinite",
        ignore_cost_multiplier = cost_multiplier,
        unit = {
            count_formula = formula,
            ingredients = ingredients,
            time = research_time
        },
        prerequisites = technology_prerequisites
    }
    return technology
end

local function array_contains(arr, element)
    for _, v in pairs(arr) do
        if v == element then return true end
    end
    return false
end

local function is_all_packs_lab_required(allowed_science_packs)
    local lab_prototypes = data.raw["lab"]
    if lab_prototypes then
        for _, lab_prototype in pairs(lab_prototypes) do
            if lab_prototype.inputs then
                local all_packs_required = true
                for _, pack_name in pairs(allowed_science_packs) do
                    if not array_contains(lab_prototype.inputs, pack_name) then
                        all_packs_required = false
                        break
                    end
                end
                if all_packs_required then
                    return true
                end
            end
        end
    end
    return false
end

local function get_lab_ingredient_names()
    local lab_ingredients = {}
    local used_items = {}
    local lab_prototypes = data.raw["lab"]
    if lab_prototypes then
        for _, lab_prototype in pairs(lab_prototypes) do
            if lab_prototype.minable and lab_prototype.minable.result then
                local item_name = lab_prototype.minable.result
                if item_name and not used_items[item_name] then
                    used_items[item_name] = true
                    table.insert(lab_ingredients, item_name)
                end
            end
        end
    end
    return lab_ingredients
end

local science_pack_names = get_science_pack_names()
local formula = define_formula()
local allowed_science_packs = get_allowed_science_packs(science_pack_names)

if each_pack then
    for _, pack_name in pairs(allowed_science_packs) do
        local technology = create_technology(pack_name, formula)
        data:extend{technology}
    end
end

if all_packs then
    ingredients = {}
    for _, pack_name in pairs(allowed_science_packs) do
        table.insert(ingredients, {pack_name, research_units})
    end
    technology_prerequisites = {}
    for _, pack_name in pairs(allowed_science_packs) do
        if data.raw["technology"][pack_name] ~= nil then
            table.insert(technology_prerequisites, pack_name)
        end
    end
    local technology = create_all_packs_technology(allowed_science_packs, formula)
    data:extend {technology}
    if is_all_packs_lab_required(allowed_science_packs) then
        lab_tint = {r=0.5, g=0.5, b=0.5, a=1}

        technology.effects = {
            {
                type = "unlock-recipe",
                recipe = "Ket-IT-all-packs-lab"
            }
        }
        
        local lab_recipe = util.copy(data.raw["recipe"]["lab"])
        lab_recipe.name = "Ket-IT-all-packs-lab"
        lab_recipe.localised_name = {"", {"item-name."..data.raw["item"]["lab"].name}, " (All packs)"}
        lab_recipe.tint = lab_tint
        lab_recipe.results = {
            {type = "item", name = "Ket-IT-all-packs-lab", amount = 1}
        }
        data:extend{lab_recipe}

        local lab_item = util.copy(data.raw["item"]["lab"])
        lab_item.name = "Ket-IT-all-packs-lab"
        lab_item.localised_name = {"", {"item-name."..data.raw["item"]["lab"].name}, " (All packs)"}
        lab_item.icons = {
            {icon = data.raw["item"]["lab"].icon, tint = lab_tint}
        }
        lab_item.place_result = "Ket-IT-all-packs-lab"
        data:extend{lab_item}

        ingredient_names = get_lab_ingredient_names()
        lab_ingredients = {}
        for _, lab_name in pairs(ingredient_names) do
            table.insert(lab_ingredients, {
                type = "item", name = lab_name, amount = 1
            })
        end
        lab_recipe.ingredients = lab_ingredients

        local lab_entity = util.copy(data.raw["lab"]["lab"])
        lab_entity.name = "Ket-IT-all-packs-lab"
        lab_entity.localised_name = {"", {"item-name."..data.raw["item"]["lab"].name}, " (All packs)"}
        lab_entity.icons = {
            {icon = data.raw["lab"]["lab"].icon, tint = lab_tint}
        }
        for _, layer in pairs(lab_entity.on_animation.layers) do
            layer["tint"] = lab_tint
        end
        for _, layer in pairs(lab_entity.off_animation.layers) do
            layer["tint"] = lab_tint
        end
        lab_entity.minable.result = "Ket-IT-all-packs-lab"
        lab_entity.inputs = allowed_science_packs
        data:extend{lab_entity}
    end
end
