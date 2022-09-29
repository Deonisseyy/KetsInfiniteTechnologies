data:extend {
	{
		type = "int-setting",
		name = "Ket-IT-research-time",
		order = "a",
		setting_type = "startup",
		default_value = 60,
		minimum_value = 1,
	},
	{
		type = "int-setting",
		name = "Ket-IT-research-units",
		order = "b",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
	},
	{
		type = "bool-setting",
		name = "Ket-IT-all-packs",
		order = "c",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "Ket-IT-ignore-cost-multiplier",
		order = "d",
		setting_type = "startup",
		default_value = false
	},
	{
		type = "string-setting",
		name = "Ket-IT-growth-type",
		order = "e",
		setting_type = "startup",
		allowed_values = {"Linear", "Exponential"},
		default_value = "Linear";
	},
	{
		type = "int-setting",
		name = "Ket-IT-parameter-A",
		order = "f",
		setting_type = "startup",
		default_value = 1000,
		minimum_value = 1,
	},
	{
		type = "int-setting",
		name = "Ket-IT-parameter-B",
		order = "g",
		setting_type = "startup",
		default_value = 0,
		minimum_value = 0,
	},
}