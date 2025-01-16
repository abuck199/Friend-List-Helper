--------------------------------------------------------------------------------
-- Show WoWOnline/Total friend 
--------------------------------------------------------------------------------
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

	FriendsFrameTitleText:SetText(IndexWowFriendOnline.. " Friends currently on WoW")
end
FriendsFrameTitleText:SetVertexColor(0.196, 0.803, 0.196, 1)

GetTotalWowFriendOnline()

function UpdateOnlineFriend()
	numFriends, numOnline = BNGetNumFriends()
end

hooksecurefunc("FriendsList_Update", UpdateOnlineFriend)
hooksecurefunc("FriendsList_Update", GetTotalWowFriendOnline)

--------------------------------------------------------------------------------
-- Change Friends Frame Add Friend Button Background  
--------------------------------------------------------------------------------
FriendsFrameAddFriendButton:Hide()
FriendsFrameSendMessageButton:Hide()

FriendsTabHeaderTab1:ClearAllPoints()
FriendsTabHeaderTab1:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 4, -50)
FriendsTabHeaderTab1.SetPoint = function () end

local btn = CreateFrame("Button", "CustomAddFriend", FriendsTabHeaderTab3, "FriendsTabTemplate");
btn:SetPoint("RIGHT", FriendsTabHeaderTab3, "RIGHT", 75, 0)
btn:SetText("Add friend");
btn:SetScript("OnClick", FriendsFrameAddFriendButton_OnClick)

CustomAddFriend.LeftActive:SetAlpha(0)
CustomAddFriend.MiddleActive:SetAlpha(0)
CustomAddFriend.RightActive:SetAlpha(0)
CustomAddFriend.Text:SetVertexColor(0.196, 0.803, 0.196, 1)
CustomAddFriend.Text:ClearAllPoints()
CustomAddFriend.Text:SetPoint("BOTTOM", CustomAddFriend, "BOTTOM", 0, 3)
CustomAddFriend.Text.SetPoint = function () end