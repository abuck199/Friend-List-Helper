FriendListHelper.defaults = {
	profile = {
		FactionColorBackground = true,
        PutGreyNameOnFriendPlayingClassic = true,
		ShowFriendLevelCustom = true,
		ShowFriendClassColor = true,
	},
}
FriendListHelper.options = {
	type = "group",
	name = "|c0189ADB1Friend List Helper Options|r",
    handler = FriendListHelper,
	args = {
		versionAndDescription = {
			order = 1,
            type = "description",
			name = "Version : 3.0.0",
			fontSize = "medium",
            cmdHidden = true,
		},
        ReloadButtonFunction = {
			type = "execute",
			name = "Reload UI",
			order = 3,
			func = "Reload",
		},
        inlineDesc = {
			type = "description",
			name = "\n|cFFFFFF00" .. "[ Press |cffff4150Reload UI|r to see your changes ] \n ",
			fontSize = "medium",
			order = 4,
		},
        GroupShowClassColor = {
            type = "group",
			order = 5,
			name = "Settings",
			inline = true,
            get = "GetValue",
			set = "SetValue",
            args = {
                FactionColorBackground = {
                    type = "toggle",
					order = 1,
					name = "Show Faction Color (|cffff4150reload required|r)",
					desc = "Show the action color in the background of your friend list",
					width = "double",
                },
                PutGreyNameOnFriendPlayingClassic = {
                    type = "toggle",
					order = 2,
					name = "Grey Name For Friend Playing Classic (|cffff4150reload required|r)",
					desc = "Put your friends character name grey if they are currently playing Classic",
					width = "double",
                },
				ShowFriendLevelCustom = {
					type = "toggle",
					order = 3,
					name = "Show Your Friend Level After Character Name (|cffff4150reload required|r)",
					desc = "Show your Friend character level after their name",
					width = "double",
				},
				ShowFriendClassColor = {
					type = "toggle",
					order = 4,
					name = "Show Your Friend Class Color In Character Name (|cffff4150reload required|r)",
					desc = "Show your Friend class color in their character name",
					width = "double",
				},
            },
        },
	},
}

function FriendListHelper:Reload()
	ReloadUI()
end

function FriendListHelper:GetValue(info)
	return self.db.profile[info[#info]]
end

function FriendListHelper:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
