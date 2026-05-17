Root = {
	Type = "Control",
	Name = "MEA-BlockSetting",
	Style = "Normal",
	Position = {900, 30},
	Size = {0, 0},
	Children = {
		-- Block Flags
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_Foundations",
			Text = "$Foundations",
			Control = {
				Position = {0, 0},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_Foundations-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_Foundations-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_Mines",
			Text = "$Mines",
			Control = {
				Position = {0, 20},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_Mines-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_Mines-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_WaterLevel",
			Text = "$WaterLevel",
			Control = {
				Position = {0, 40},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_WaterLevel-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_WaterLevel-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_EdgeWithFill",
			Text = "$DrawEdgeWithFill", -- special
			Control = {
				Position = {0, 60},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_EdgeWithFill-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_EdgeWithFill-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		-- OilDrills
		-- OilRigs
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_PassProjectiles",
			Text = "$PassProjectiles",
			Control = {
				Position = {0, 80},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_PassProjectiles-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_PassProjectiles-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_PassBeams",
			Text = "$PassBeams",
			Control = {
				Position = {0, 100},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_PassBeams-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_PassBeams-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_Hazard",
			Text = "$Hazard",
			Control = {
				Position = {0, 120},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_Hazard-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_Hazard-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_NoSplash",
			Text = "$NoSplash",
			Control = {
				Position = {0, 140},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_NoSplash-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_NoSplash-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_NoBuild",
			Text = "$NoBuild",
			Control = {
				Position = {0, 160},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_NoBuild-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_NoBuild-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_CanBuildOver",
			Text = "$CanBuildOver",
			Control = {
				Position = {0, 180},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_CanBuildOver-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_CanBuildOver-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},
		{
			Type = "Text",
			Style = "Normal",
			Name = "MEA-BF_NoDrawEdges",
			Text = "$NoDrawEdges",
			Control = {
				Position = {0, 200},
				Children = {
					{
						Type = "Button",
						Name = "MEA-BF_NoDrawEdges-T",
						Style = "Normal",
						Static = {
							Texture = "ui-plus",
							Control = {
								Position = {-46, -2},
								Size = {18, 18},
							},
						},
					},
					{
						Type = "Button",
						Name = "MEA-BF_NoDrawEdges-F",
						Style = "Normal",
						Static = {
							Texture = "ui-minus",
							Control = {
								Position = {-23, -2},
								Size = {18, 18},
							},
						},
					},
				},
			},
		},

		-- Block Owner
		{
			Type = "TextButton",
			Name = "MEA-BO_Background",
			Style = "Normal",
			Text = {
				Text = "$MEA.BO_Background",
				Control = {Position = {0, 220}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-BO_Any",
			Style = "Normal",
			Text = {
				Text = "$MEA.BO_Any",
				Control = {Position = {0, 240}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-BO_None",
			Style = "Normal",
			Text = {
				Text = "$MEA.BO_None",
				Control = {Position = {0, 260}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-BO_Team1",
			Style = "Normal",
			Text = {
				Text = "$MEA.BO_Team1",
				Control = {Position = {0, 280}},
			},
		},
		{
			Type = "TextButton",
			Name = "MEA-BO_Team2",
			Style = "Normal",
			Text = {
				Text = "$MEA.BO_Team2",
				Control = {Position = {0, 300}},
			},
		},
	},
}
