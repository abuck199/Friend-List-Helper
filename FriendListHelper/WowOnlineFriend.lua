--------------------------------------------------------------------------------
-- Show WoWOnline/Total friend 
--------------------------------------------------------------------------------
local function GetTotalWowFriendOnline()
	local CountOfFriendsOnline = 0

	for i = 1, BNGetNumFriends() do
		for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
			local game = C_BattleNet.GetFriendGameAccountInfo(i, j)
			-- is it the WoW client and
			if game.clientProgram == BNET_CLIENT_WOW and game.wowProjectID == WOW_PROJECT_ID then
				CountOfFriendsOnline = CountOfFriendsOnline + 1
			end
		end
	end

	FriendsFrameTitleText:SetText(CountOfFriendsOnline .. " Friends currently on WoW")
end

hooksecurefunc("FriendsFrame_Update", function()
	local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame) or FRIEND_TAB_FRIENDS
	if selectedTab == FRIEND_TAB_FRIENDS then
		local selectedHeaderTab = PanelTemplates_GetSelectedTab(FriendsTabHeader) or FRIEND_HEADER_TAB_FRIENDS
		if selectedHeaderTab == FRIEND_HEADER_TAB_FRIENDS then
			GetTotalWowFriendOnline()
		end
	end
end)

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
btn:SetText(ADD_FRIEND)
btn:SetScript("OnClick", FriendsFrameAddFriendButton_OnClick)

CustomAddFriend.LeftActive:SetAlpha(0)
CustomAddFriend.MiddleActive:SetAlpha(0)
CustomAddFriend.RightActive:SetAlpha(0)
CustomAddFriend.Text:SetVertexColor(0.196, 0.803, 0.196, 1)
CustomAddFriend.Text:ClearAllPoints()
CustomAddFriend.Text:SetPoint("BOTTOM", CustomAddFriend, "BOTTOM", 0, 3)
CustomAddFriend.Text.SetPoint = function () end