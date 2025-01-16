FriendListHelper = LibStub("AceAddon-3.0"):NewAddon("FriendListHelper", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

FriendListHelper.defaults = {
    profile = {
        EnableFactionBackgroundColor = true,
        EnableClassColorNames = true
    }
}

--------------------------------------------------------------------------------
-- Utility: Hex Class Color and Class List
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

--------------------------------------------------------------------------------
-- Update Friend List Based on Search Text
--------------------------------------------------------------------------------
local function UpdateFriendList(searchText)
    local numBNetFriends = BNGetNumFriends()
    local dataProvider = CreateDataProvider()

    for i = 1, numBNetFriends do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo then
            local battleTag = (accountInfo.battleTag or ""):lower()
            local characterName = (accountInfo.gameAccountInfo.characterName or ""):lower()
            if #searchText == 0 or battleTag:find(searchText, 1, true) or characterName:find(searchText, 1, true) then
                dataProvider:Insert({id = i, buttonType = FRIENDS_BUTTON_TYPE_BNET})
            end
        end
    end

    FriendsListFrame.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

--------------------------------------------------------------------------------
-- Hook for Background and Character Name Coloring
--------------------------------------------------------------------------------
hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button, elementData)
    if not elementData or not elementData.buttonType or elementData.buttonType ~= FRIENDS_BUTTON_TYPE_BNET then
        return
    end

    local accountInfo = C_BattleNet.GetFriendAccountInfo(elementData.id)
    if not accountInfo then return end

    local displayedName = accountInfo.accountName or accountInfo.battleTag
    local isOnline = accountInfo.gameAccountInfo.isOnline
    local characterName = accountInfo.gameAccountInfo.characterName
    local localizedClassName = accountInfo.gameAccountInfo.className
    local classKey = localizedClassName and ClassList[localizedClassName]
    local isWoW = accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW
    local isRetail = accountInfo.gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE -- Retail WoW check

    if not isOnline then
        button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a)
        button.name:SetText(displayedName)
        return
    end

    if isWoW and not isRetail then
        if isOnline then
            button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a)
        else
            button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a)
        end

        if characterName and characterName ~= "" then
            displayedName = format("%s |cff808080(%s)|r", displayedName, characterName) -- Grey color
        end

        button.name:SetText(displayedName)
        return
    end

    if isOnline and isRetail and characterName and characterName ~= "" then
        if FriendListHelper.db.profile.EnableClassColorNames and classKey and RAID_CLASS_COLORS[classKey] then
            local classColor = RAID_CLASS_COLORS[classKey]
            local colorCode = HexClassColor(classColor)
            displayedName = format("%s %s(%s)|r", displayedName, colorCode, characterName)
        else
            displayedName = format("%s %s(%s)|r", displayedName, FRIENDS_WOW_NAME_COLOR_CODE, characterName)
        end
    end

    if FriendListHelper.db.profile.EnableFactionBackgroundColor and isRetail then
        local faction = accountInfo.gameAccountInfo.factionName
        if faction == "Alliance" then
            button.background:SetColorTexture(0.05, 0.2, 0.6, 0.3) -- Darker Blue for Alliance
        elseif faction == "Horde" then
            button.background:SetColorTexture(0.6, 0.1, 0.1, 0.3) -- Darker Red for Horde
        else
            button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a)
        end
    else
        button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a)
    end

    button.name:SetText(displayedName)
end)

--------------------------------------------------------------------------------
-- Add Search Bar to Friend List Frame
--------------------------------------------------------------------------------
local function AddSearchBar()
    if not FriendsListFrame then return end

    local searchBar = CreateFrame("EditBox", "FriendListHelper_SearchBar", FriendsListFrame, "InputBoxTemplate")
    searchBar:SetSize(325, 20)
    searchBar:SetPoint("BOTTOMLEFT", FriendsListFrame, "BOTTOMLEFT", 10, 5)
    searchBar:SetAutoFocus(false)
    searchBar:SetText("")
    searchBar:ClearFocus()
    searchBar:Show()

    local placeholder = searchBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    placeholder:SetPoint("LEFT", searchBar, "LEFT", 5, 0)
    placeholder:SetText("Search here ...")
    placeholder:SetTextColor(0.5, 0.5, 0.5, 0.7) -- Light gray color

    local function UpdatePlaceholder()
        if searchBar:GetText() == "" then
            placeholder:Show()
        else
            placeholder:Hide()
        end
    end

    searchBar:SetScript("OnTextChanged", function(self)
        UpdatePlaceholder()
        local searchText = self:GetText():lower()
        UpdateFriendList(searchText)
    end)

    searchBar:SetScript("OnEditFocusGained", function()
        placeholder:Hide()
    end)

    searchBar:SetScript("OnEditFocusLost", function()
        UpdatePlaceholder()
    end)

    local function ResetSearchBar()
        searchBar:SetText("")
        searchBar:SetAutoFocus(false)
        searchBar:ClearFocus()
        FriendsList_Update(true)
    end

    FriendsListFrame:HookScript("OnHide", function()
        ResetSearchBar()
    end)

    UpdatePlaceholder()

    return searchBar
end

--------------------------------------------------------------------------------
-- Create Settings Popup
--------------------------------------------------------------------------------
local function ShowSettingsPopup()
    if FriendListHelper.settingsWindow then
        FriendListHelper.settingsWindow:Show()
        return
    end

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("FriendListHelper Settings")
    frame:SetWidth(400)
    frame:SetHeight(300)
    frame:SetLayout("Flow")
    frame:SetStatusText("Thank you for the support")
    frame:EnableResize(true)
    FriendListHelper.settingsWindow = frame

    local blizzFrame = frame.frame
    if blizzFrame.CloseButton then
        local closeButton = blizzFrame.CloseButton
        closeButton:SetSize(32, 32)
        closeButton:ClearAllPoints()
        closeButton:SetPoint("TOPRIGHT", blizzFrame, "TOPRIGHT", -8, -8) 
    end

    local generalGroup = AceGUI:Create("InlineGroup")
    generalGroup:SetTitle("General Settings")
    generalGroup:SetFullWidth(true)
    generalGroup:SetLayout("Flow")
    frame:AddChild(generalGroup)

    local factionBackgroundCheckbox = AceGUI:Create("CheckBox")
    factionBackgroundCheckbox:SetLabel("Enable Faction Background Colors")
    factionBackgroundCheckbox:SetValue(FriendListHelper.db.profile.EnableFactionBackgroundColor)
    factionBackgroundCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        FriendListHelper.db.profile.EnableFactionBackgroundColor = value
        FriendsList_Update(true)
    end)
    factionBackgroundCheckbox:SetFullWidth(true)
    generalGroup:AddChild(factionBackgroundCheckbox)

    local classColorCheckbox = AceGUI:Create("CheckBox")
    classColorCheckbox:SetLabel("Enable Class Name Coloring")
    classColorCheckbox:SetValue(FriendListHelper.db.profile.EnableClassColorNames)
    classColorCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        FriendListHelper.db.profile.EnableClassColorNames = value
        FriendsList_Update(true)
    end)
    classColorCheckbox:SetFullWidth(true)
    generalGroup:AddChild(classColorCheckbox)

    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    frame:AddChild(spacer)
end

--------------------------------------------------------------------------------
-- Initialize Friend List Helper & Some Settings
--------------------------------------------------------------------------------
function FriendListHelper:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FriendListHelperDB", self.defaults, true)

    local commands = { "flh", "fl", "friendlist", "friendlisthelper" }
    for _, command in ipairs(commands) do
        self:RegisterChatCommand(command, function()
            self:OpenFriendListAndSettings()
        end)
    end

    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
end

function FriendListHelper:OpenFriendListAndSettings()
    if not FriendsFrame:IsShown() then
        ToggleFriendsFrame(1)
    end

    ShowSettingsPopup()
end

function FriendListHelper:OnPlayerLogin()
    print("|c0189ADB1FriendListHelper|r: Type |cfff58cba/flh|r or |cfff58cba/fl|r to open settings.")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    AddSearchBar()
end)
