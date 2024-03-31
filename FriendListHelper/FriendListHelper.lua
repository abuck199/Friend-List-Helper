FriendListHelper = LibStub("AceAddon-3.0"):NewAddon("FriendListHelper", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

function FriendListHelper:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("FriendListHelperDB", self.defaults, true)

	AC:RegisterOptionsTable("FriendListHelper_Options", self.options)

	self.optionsFrame = ACD:AddToBlizOptions("FriendListHelper_Options", "FriendListHelper")

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("FriendListHelper_Profiles", profiles)
	ACD:AddToBlizOptions("FriendListHelper_Profiles", "Profiles", "FriendListHelper")

	self:RegisterChatCommand("flh", "SlashCommand")
	self:RegisterChatCommand("fl", "SlashCommand")
	self:RegisterChatCommand("friendlist", "SlashCommand")
	self:RegisterChatCommand("friendlisthelper", "SlashCommand")
end

function FriendListHelper:SlashCommand(input, editbox)
	if input == "enable" then
		self:Enable()
		self:Print("Enabled.")
	elseif input == "disable" then
		self:Disable()
		self:Print("Disabled.")
	else
		print("|c0189ADB1FriendListHelper:|r Made By Buckwar-Zul'jin")
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	end
end

--------------------------------------------------------------------------------
-- Adding SearchBar to the Friend List Frame
--------------------------------------------------------------------------------
FriendSearchBar = CreateFrame("EditBox", "FriendSearchBar", FriendsListFrame,"InputBoxTemplate")
FriendSearchBar:SetWidth(325)
FriendSearchBar:SetHeight(20)
FriendSearchBar:SetPoint("BOTTOMLEFT", FriendsListFrame, "BOTTOMLEFT", 10, 4)
FriendSearchBar:Show()
FriendSearchBar:SetAutoFocus(false)
FriendSearchBar:ClearFocus()

--------------------------------------------------------------------------------
-- Adding modification to blizzard FriendList_Update Function 
--------------------------------------------------------------------------------
function FriendsList_Update(forceUpdate)
	local numBNetTotal, numBNetOnline, numBNetFavorite, numBNetFavoriteOnline = BNGetNumFriends();
	local numBNetOffline = numBNetTotal - numBNetOnline;
	local numBNetFavoriteOffline = numBNetFavorite - numBNetFavoriteOnline;
	local numWoWTotal = C_FriendList.GetNumFriends();
	local numWoWOnline = C_FriendList.GetNumOnlineFriends();
	local numWoWOffline = numWoWTotal - numWoWOnline;
    local dataProvider = CreateDataProvider();
	AddingTableForCustomSearchBarBnetName = {}

	if #FriendSearchBar:GetText() >= 1 then
		for h = 1, numBNetTotal do
			local bnetIDAccount, accountName, battleTag, isBattleTagPresence, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR, isReferAFriend, canSummonFriend = BNGetFriendInfo(h)
			table.insert(AddingTableForCustomSearchBarBnetName, string.lower(string.match(battleTag, "(.*)#")))
		end

		for p = 1, numBNetTotal do
			if #FriendSearchBar:GetText() ~= 0 then
				if string.find(string.lower(FriendSearchBar:GetText()), string.sub(AddingTableForCustomSearchBarBnetName[p], 1, #FriendSearchBar:GetText())) then
					dataProvider:Insert({id=p, buttonType=FRIENDS_BUTTON_TYPE_BNET});
					local retainScrollPosition = not forceUpdate;
					FriendsListFrame.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition);
				end
			end
		end
	else
        QuickJoinToastButton:UpdateDisplayedFriendCount();
        if ( not FriendsListFrame:IsShown() and not forceUpdate) then
            return;
        end

        local dataProvider = CreateDataProvider();

	--party invites
	if InGlue() then
		local numPartyInvites = C_WoWLabsMatchmaking.GetNumPartyInvites();
		if numPartyInvites > 0 then
			dataProvider:Insert({buttonType=FRIENDS_BUTTON_TYPE_PARTY_INVITE_HEADER});
			if ( not GetCVarBool("partyInvitesCollapsed_Glue") ) then
				for i = 1, numPartyInvites do
					dataProvider:Insert({id=i, buttonType=FRIENDS_BUTTON_TYPE_PARTY_INVITE});
				end
			end
		end
	end

        -- invites
        local numInvites = BNGetNumFriendInvites();
        if ( numInvites > 0 ) then
            dataProvider:Insert({buttonType=FRIENDS_BUTTON_TYPE_INVITE_HEADER});
            if ( not GetCVarBool("friendInvitesCollapsed") ) then
                for i = 1, numInvites do
                    dataProvider:Insert({id=i, buttonType=FRIENDS_BUTTON_TYPE_INVITE});
                end
                -- add divider before friends
                if ( numBNetTotal + numWoWTotal > 0 ) then
                    dataProvider:Insert({buttonType= FRIENDS_BUTTON_TYPE_DIVIDER});
                end
            end
        end

        local bnetFriendIndex = 0;
        -- favorite friends, online and offline
        for i = 1, numBNetFavorite do
            bnetFriendIndex = bnetFriendIndex + 1;
            dataProvider:Insert({id=bnetFriendIndex, buttonType=FRIENDS_BUTTON_TYPE_BNET});
        end
        if (numBNetFavorite > 0) then
            dataProvider:Insert({buttonType=FRIENDS_BUTTON_TYPE_DIVIDER});
        end

        -- online Battlenet friends
        for i = 1, numBNetOnline - numBNetFavoriteOnline do
            bnetFriendIndex = bnetFriendIndex + 1;
            dataProvider:Insert({id=bnetFriendIndex, buttonType=FRIENDS_BUTTON_TYPE_BNET});
        end

	if C_GameEnvironmentManager.GetCurrentGameEnvironment() ~= Enum.GameEnvironment.WoWLabs then
        -- online WoW friends
        for i = 1, numWoWOnline do
            dataProvider:Insert({id=i, buttonType=FRIENDS_BUTTON_TYPE_WOW});
        end
        -- divider between online and offline friends
        if ( (numBNetOnline > 0 or numWoWOnline > 0) and (numBNetOffline > 0 or numWoWOffline > 0) ) then
            dataProvider:Insert({buttonType=FRIENDS_BUTTON_TYPE_DIVIDER});
        end
    end;

        -- offline Battlenet friends
        for i = 1, numBNetOffline - numBNetFavoriteOffline do
            bnetFriendIndex = bnetFriendIndex + 1;
            dataProvider:Insert({id=bnetFriendIndex, buttonType=FRIENDS_BUTTON_TYPE_BNET});
        end

	if C_GameEnvironmentManager.GetCurrentGameEnvironment() ~= Enum.GameEnvironment.WoWLabs then
        -- offline WoW friends
        for i = 1, numWoWOffline do
            dataProvider:Insert({id=i+numWoWOnline, buttonType=FRIENDS_BUTTON_TYPE_WOW});
        end
    end

    local retainScrollPosition = not forceUpdate;
    FriendsListFrame.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition);

    if not FriendsFrame.selectedFriendType then
        local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
            return elementData.buttonType == FRIENDS_BUTTON_TYPE_WOW or elementData.buttonType == FRIENDS_BUTTON_TYPE_BNET;
        end);
        if elementData then
            FriendsFrame_SelectFriend(elementData.buttonType, elementData.id);
        elseif FriendsFrameSendMessageButton ~= nil then
            FriendsFrameSendMessageButton:Disable();
        end
    end

        -- RID warning, upon getting the first RID invite
        FriendsList_CheckRIDWarning();
    end
end

--------------------------------------------------------------------------------
-- Adding script to attach function FriendList_Update too
--------------------------------------------------------------------------------
local FriendSearchLiteOriginalOnMouseWheel = FriendsListFrame.ScrollBox:GetScript("OnMouseWheel")

FriendSearchBar:SetScript("OnTextChanged", function()
	FriendsList_Update()
end )

FriendsListFrame.ScrollBox:SetScript("OnMouseWheel", function(...)
	FriendSearchLiteOriginalOnMouseWheel(...)
	FriendsList_Update()
end )

FriendSearchBar:SetScript("OnEnterPressed", function()
	FriendSearchBar:SetAutoFocus(false)
	FriendSearchBar:ClearFocus()
	FriendsList_Update()
end )

FriendSearchBar:SetScript("OnHide", function()
	FriendSearchBar:SetText("")
	FriendSearchBar:SetAutoFocus(false)
	FriendSearchBar:ClearFocus()
end )

--------------------------------------------------------------------------------
-- Get Friend AccountInfo
--------------------------------------------------------------------------------
local function getDeprecatedAccountInfo(accountInfo)
	if accountInfo then
		local wowProjectID = accountInfo.gameAccountInfo.wowProjectID or 0;
		local clientProgram = accountInfo.gameAccountInfo.clientProgram ~= "" and accountInfo.gameAccountInfo.clientProgram or nil;
		return	accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.isBattleTagFriend,
				accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, clientProgram,
				accountInfo.gameAccountInfo.isOnline, accountInfo.lastOnlineTime, accountInfo.isAFK, accountInfo.isDND, accountInfo.customMessage, accountInfo.note, accountInfo.isFriend,
				accountInfo.customMessageTime, wowProjectID, accountInfo.rafLinkType == Enum.RafLinkType.Recruit, accountInfo.gameAccountInfo.canSummon, accountInfo.isFavorite, accountInfo.gameAccountInfo.isWowMobile;
	end
end

--------------------------------------------------------------------------------
-- return Friend AccountInfo with accountInfo parameter
--------------------------------------------------------------------------------
BNGetFriendInfo = function(friendIndex)
	local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex);
	return getDeprecatedAccountInfo(accountInfo);
end

--------------------------------------------------------------------------------
-- add associative array for class color in friend depending of the player class
--------------------------------------------------------------------------------
local function HexClassColor(r, g, b) 
	-- return white if class name losed when bnet broke
	if not r then return "|cffFFFFFF" end

	if type(r) == "table" then
		if(r.r) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

local ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	ClassList[v] = k
end


function FriendsList_CheckRIDWarning()
	local showRIDWarning = false;
	local numInvites = BNGetNumFriendInvites();
	if numInvites > 0 and not GetCVarBool("pendingInviteInfoShown") then
		local isRIDEnabled = select(7, BNGetInfo());
		if isRIDEnabled then
			for i = 1, numInvites do
				local isBattleTag = select(3, BNGetFriendInviteInfo(i));
				if not isBattleTag then
					showRIDWarning = true;
					break;
				end
			end
		end
	end

	FriendsListFrame.RIDWarning:SetShown(showRIDWarning);
end

function FriendsFrame_GetLastOnline(timeDifference, isAbsolute)
	if ( not isAbsolute ) then
		timeDifference = time() - timeDifference;
	end
	local year, month, day, hour, minute;

	if ( timeDifference < SECONDS_PER_MIN ) then
		return LASTONLINE_SECS;
	elseif ( timeDifference >= SECONDS_PER_MIN and timeDifference < SECONDS_PER_HOUR ) then
		return format(LASTONLINE_MINUTES, floor(timeDifference / SECONDS_PER_MIN));
	elseif ( timeDifference >= SECONDS_PER_HOUR and timeDifference < SECONDS_PER_DAY ) then
		return format(LASTONLINE_HOURS, floor(timeDifference / SECONDS_PER_HOUR));
	elseif ( timeDifference >= SECONDS_PER_DAY and timeDifference < SECONDS_PER_MONTH ) then
		return format(LASTONLINE_DAYS, floor(timeDifference / SECONDS_PER_DAY));
	elseif ( timeDifference >= SECONDS_PER_MONTH and timeDifference < SECONDS_PER_YEAR ) then
		return format(LASTONLINE_MONTHS, floor(timeDifference / SECONDS_PER_MONTH));
	else
		return format(LASTONLINE_YEARS, floor(timeDifference / SECONDS_PER_YEAR));
	end
end

local function BNet_GetBNetAccountName(accountInfo)
	if not accountInfo then
		return;
	end

	local name = accountInfo.accountName;
	if name == "" then
		name = BNet_GetTruncatedBattleTag(accountInfo.battleTag);
	end

	return name;
end

local function BNet_GetTruncatedBattleTag(battleTag)
	if battleTag then
		local symbol = string.find(battleTag, "#");
		if ( symbol ) then
			return string.sub(battleTag, 1, symbol - 1);
		else
			return battleTag;
		end
	else
		return "";
	end
end

local function BNet_GetValidatedCharacterName(characterName, battleTag, client, clientTextureSize)
	if (not characterName) or (characterName == "") or (client == BNET_CLIENT_HEROES) then
		return BNet_GetTruncatedBattleTag(battleTag);
	end
	return characterName;
end

function FriendsFrame_GetBNetAccountNameAndStatus(accountInfo, noCharacterName)
	if not accountInfo then
		return;
	end

	local nameText, nameColor, statusTexture;

	nameText = BNet_GetBNetAccountName(accountInfo);

	if not noCharacterName then
		local characterName = BNet_GetValidatedCharacterName(accountInfo.gameAccountInfo.characterName, nil, accountInfo.gameAccountInfo.clientProgram);
		local class = ClassList[accountInfo.gameAccountInfo.className]
		local classColor = HexClassColor((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class])
		if characterName ~= "" then
			if accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and CanCooperateWithGameAccount(accountInfo) then
				if FriendListHelper.db.profile.ShowFriendClassColor and not FriendListHelper.db.profile.ShowFriendLevelCustom then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor..characterName.."|r"..")"..FONT_COLOR_CODE_CLOSE;
				end
				if FriendListHelper.db.profile.ShowFriendLevelCustom and not FriendListHelper.db.profile.ShowFriendClassColor then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..characterName..")".." lvl "..accountInfo.gameAccountInfo.characterLevel..FONT_COLOR_CODE_CLOSE;
				end
				if FriendListHelper.db.profile.ShowFriendLevelCustom and FriendListHelper.db.profile.ShowFriendClassColor then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor..characterName.."|r"..")"..classColor.." lvl "..accountInfo.gameAccountInfo.characterLevel.."|r"..FONT_COLOR_CODE_CLOSE;
				end
				if not FriendListHelper.db.profile.ShowFriendLevelCustom and not FriendListHelper.db.profile.ShowFriendClassColor then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..characterName..")"..FONT_COLOR_CODE_CLOSE;
				end
			else
				if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") then
					characterName = accountInfo.gameAccountInfo.characterName..CANNOT_COOPERATE_LABEL;
				end
				if FriendListHelper.db.profile.ShowFriendClassColor and not FriendListHelper.db.profile.ShowFriendLevelCustom then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor..characterName.."|r"..")"..FONT_COLOR_CODE_CLOSE;
				end
				if FriendListHelper.db.profile.ShowFriendLevelCustom and not FriendListHelper.db.profile.ShowFriendClassColor then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..characterName..")".." lvl "..accountInfo.gameAccountInfo.characterLevel..FONT_COLOR_CODE_CLOSE;
				end
				if FriendListHelper.db.profile.ShowFriendLevelCustom and FriendListHelper.db.profile.ShowFriendClassColor then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor..characterName.."|r"..")"..classColor.." lvl "..accountInfo.gameAccountInfo.characterLevel.."|r"..FONT_COLOR_CODE_CLOSE;
				end
				if not FriendListHelper.db.profile.ShowFriendLevelCustom and not FriendListHelper.db.profile.ShowFriendClassColor then
					nameText = nameText.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..characterName..")"..FONT_COLOR_CODE_CLOSE;
				end
			end
			if FriendListHelper.db.profile.PutGreyNameOnFriendPlayingClassic then
				if accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
					nameText = BNet_GetBNetAccountName(accountInfo);
					nameText = nameText.." "..FRIENDS_OTHER_NAME_COLOR_CODE.."("..characterName..")"..FONT_COLOR_CODE_CLOSE;
				end
			end
		end
	end
	if accountInfo.gameAccountInfo.isOnline then
		if accountInfo.isAFK or accountInfo.gameAccountInfo.isGameAFK then
			statusTexture = FRIENDS_TEXTURE_AFK;
		elseif accountInfo.isDND or accountInfo.gameAccountInfo.isGameBusy then
			statusTexture = FRIENDS_TEXTURE_DND;
		else
			statusTexture = FRIENDS_TEXTURE_ONLINE;
		end
		nameColor = FRIENDS_BNET_NAME_COLOR;
	else
		statusTexture = FRIENDS_TEXTURE_OFFLINE;
		nameColor = FRIENDS_GRAY_COLOR;
	end

	return nameText, nameColor, statusTexture;
end

local function ShowRichPresenceOnly(client, wowProjectID, faction, realmID, areaName)
	if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
		-- If they are not in wow or in a different version of wow, always show rich presence only
		return true;
	elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= playerFactionGroup) or (realmID ~= playerRealmID)) then
		-- If we are both in wow classic and our factions or realms don't match, show rich presence only
		return true;
	else
		-- Otherwise show more detailed info about them
		return FORCE_RICH_PRESENCE or not areaName;
	end;
end

local function GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
	if not locationText then
		return UNKNOWN;
	end
	if isMobile then
		return LOCATION_MOBILE_APP;
	end
	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
		if rafLinkType == Enum.RafLinkType.Recruit then
			return RAF_RECRUIT_FRIEND:format(locationText);
		else
			return RAF_RECRUITER_FRIEND:format(locationText);
		end
	end

	return locationText;
end

function FriendsFrame_UpdateFriendButton(button, elementData)
	local id = elementData.id;
	local buttonType = elementData.buttonType;
	button.buttonType = buttonType;
	button.id = id;

	local nameText, nameColor, infoText, isFavoriteFriend, statusTexture;
	local hasTravelPassButton = false;
	local isCrossFactionInvite = false;
	local inviteFaction = nil;
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(id);
		if ( info.connected ) then
			button.background:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a);
			if ( info.afk ) then
				button.status:SetTexture(FRIENDS_TEXTURE_AFK);
			elseif ( info.dnd ) then
				button.status:SetTexture(FRIENDS_TEXTURE_DND);
			else
				button.status:SetTexture(FRIENDS_TEXTURE_ONLINE);
			end
			nameText = info.name..", "..format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className);
			nameColor = FRIENDS_WOW_NAME_COLOR;
			infoText = GetOnlineInfoText(BNET_CLIENT_WOW, info.mobile, info.rafLinkType, info.area);
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameText = info.name;
			nameColor = FRIENDS_GRAY_COLOR;
			infoText = FRIENDS_LIST_OFFLINE;
		end
		button.gameIcon:Hide();
		button.summonButton:ClearAllPoints();
		button.summonButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, -1);
		FriendsFrame_SummonButton_Update(button.summonButton);
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id);
		if accountInfo then
			nameText, nameColor, statusTexture = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
			isFavoriteFriend = accountInfo.isFavorite;

			button.status:SetTexture(statusTexture);

			isCrossFactionInvite = accountInfo.gameAccountInfo.factionName ~= playerFactionGroup;
			inviteFaction = accountInfo.gameAccountInfo.factionName;

			if accountInfo.gameAccountInfo.isOnline then
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID, accountInfo.gameAccountInfo.areaName) then
					infoText = GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName);
				end

				C_Texture.SetTitleIconTexture(button.gameIcon, accountInfo.gameAccountInfo.clientProgram, Enum.TitleIconVersion.Medium);

				local fadeIcon = (accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID);
				if fadeIcon then
					button.gameIcon:SetAlpha(0.6);
				else
					button.gameIcon:SetAlpha(1);
				end

				--Note - this logic should match the logic in FriendsFrame_ShouldShowSummonButton

				local shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton);
				button.gameIcon:SetShown(not shouldShowSummonButton);

				-- travel pass
				hasTravelPassButton = true;
				local restriction = FriendsFrame_GetInviteRestriction(button.id);
				if restriction == INVITE_RESTRICTION_NONE then
					button.travelPassButton:Enable();
				else
					button.travelPassButton:Disable();
				end
			else
				button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
				button.gameIcon:Hide();
				infoText = FriendsFrame_GetLastOnlineText(accountInfo);
			end
			button.summonButton:ClearAllPoints();
			button.summonButton:SetPoint("CENTER", button.gameIcon, "CENTER", 1, 0);
			FriendsFrame_SummonButton_Update(button.summonButton);

            if FriendListHelper.db.profile.FactionColorBackground then
				if accountInfo.gameAccountInfo.factionName == "Alliance" then
					button.background:SetColorTexture(0.10, 0.29, 0.67, 0.25);
				elseif accountInfo.gameAccountInfo.factionName == "Horde" then
					button.background:SetColorTexture(0.53, 0.20, 0.20, 0.25);
				end
			end
		end
	end

	if hasTravelPassButton then
		button.travelPassButton:Show();
	else
		button.travelPassButton:Hide();
	end

	local selected = (FriendsFrame.selectedFriendType == buttonType) and (FriendsFrame.selectedFriend == id);
	FriendsFrame_FriendButtonSetSelection(button, selected);

	-- finish setting up button if it's not a header
	if nameText then
		button.name:SetText(nameText);
		button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
		button.info:SetText(infoText);
		button:Show();

		if isFavoriteFriend then
			button.Favorite:Show();
			button.Favorite:ClearAllPoints()
			button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0);
		else
			button.Favorite:Hide();
		end
	else
		button:Hide();
	end
	-- update the tooltip if hovering over a button
	if (FriendsTooltip.button == button) or (GetMouseFocus() == button) then
		button:OnEnter();
	end

	if C_GameEnvironmentManager.GetCurrentGameEnvironment() ~= Enum.GameEnvironment.WoWLabs then
	-- show cross faction helptip on first online cross faction friend
	if hasTravelPassButton and isCrossFactionInvite and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE) then
		local helpTipInfo = {
			text = CROSS_FACTION_INVITE_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
		};
		crossFactionHelpTipInfo = helpTipInfo;
		crossFactionHelpTipButton = button;
		HelpTip:Show(FriendsFrame, helpTipInfo, button.travelPassButton);
	end
	end
	-- update invite button atlas to show faction for cross faction players, or reset to default for same faction players
	if hasTravelPassButton then
		if isCrossFactionInvite and inviteFaction == "Horde" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-horde-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-horde-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-horde-disabled");
		elseif isCrossFactionInvite and inviteFaction == "Alliance" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-alliance-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-alliance-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-alliance-disabled");
		else
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-default-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-default-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-default-disabled");
		end
	end
	return height;
end