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
FriendsFrameSendMessageButton:Hide()
FriendsFrameAddFriendButton.fitTextWidthPadding = 30
FriendsFrameAddFriendButton:FitToText()
FriendsFrameAddFriendButton:ClearAllPoints()
FriendsFrameAddFriendButton:SetPoint("BOTTOMRIGHT", FriendsListFrame, "BOTTOMRIGHT", -6, 4)
