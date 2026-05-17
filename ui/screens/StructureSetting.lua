Root = {
	Type = "Control",
	Name = "MEA-StructureSetting",
	Style = "Normal",
	Position = {900, 30},
	Size = {0, 0},
	Children = {
		-- Structure Info
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-SI_StructureId",
			Text = "id: 999",
			Control = {Position = {0, 0}},
		},
		-- Structure Execution
		{
			Type = "TextButton",
			Style = "Normal",
			Name = "MEA-SE_CollentInformation",
			Text = {
				Text = "$MEA.SE_CollentInformation",
				Control = {Position = {0, 20}},
			},
		},
		-- Structure Owner
		{
			Type = "TextButton",
			Name = "MEA-SO_None",
			Style = "Normal",
			Text = {
				Text = "$SetOwnerTeam0",
				Control = {Position = {0, 40}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-SO_Team1",
			Style = "Normal",
			Text = {
				Text = "$SetOwnerTeam1",
				Control = {Position = {0, 60}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-SO_Team2",
			Style = "Normal",
			Text = {
				Text = "$SetOwnerTeam2",
				Control = {Position = {0, 80}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-SO_Background",
			Style = "Normal",
			Text = {
				Text = "$SetOwnerBackground",
				Control = {Position = {0, 100}},
			},
		},
	},
}
