--------------------------------------------------------------------------------
-- Show WoWOnline/Total friend 
--------------------------------------------------------------------------------
local FriendOnline = CreateFrame("Frame","FriendOnline", FriendsTabHeaderTab3, "BackdropTemplate")
FriendOnline:SetWidth(22)
FriendOnline:SetHeight(22)
FriendOnline:SetPoint("RIGHT", 21, -5)
FriendOnline:Show()

FriendOnline.icon = FriendOnline:CreateTexture("FriendOnlineIcon", "BACKGROUND")
FriendOnline.icon:SetAllPoints()
FriendOnline.icon:SetSize(32,32)
FriendOnline.icon:SetAtlas("Battlenet-ClientIcon-WoW", true)

FriendOnline.text = FriendOnline:CreateFontString(nil,"OVERLAY","GameTooltipText")
FriendOnline.text:ClearAllPoints()
FriendOnline.text:SetPoint("RIGHT",FriendOnline.icon,"RIGHT",46,0)
FriendOnline.text.SetPoint = function() end

function GetTotalWowFriendOnline()
	IndexWowFriendOnline = 0

	for i = 1, BNGetNumFriends() do
		for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
			local game = C_BattleNet.GetFriendGameAccountInfo(i, j)
			if game.characterName ~= nil then
				for k, v in pairs{game.characterName} do
					IndexWowFriendOnline = IndexWowFriendOnline + 1
				end
			end
		end
	end
	
	FriendsFrameTitleText:SetText("You have "..IndexWowFriendOnline.. " friends playing WoW")
	FriendsFrameTitleText:SetVertexColor(0.196, 0.803, 0.196, 1)
end

GetTotalWowFriendOnline()

function UpdateOnlineFriend()
	numFriends, numOnline = BNGetNumFriends()
	FriendOnline.text:SetPoint("CENTER")
	FriendOnline.text:SetText(IndexWowFriendOnline.."/"..numFriends)
end

hooksecurefunc("FriendsList_Update", UpdateOnlineFriend)
hooksecurefunc("FriendsList_Update", GetTotalWowFriendOnline)