local SelectedIndex = 1
local Races = {"", "HUMAN", "DWARF", "NIGHTELF", "GNOME", "ORC", "UNDEAD", "TAUREN", "TROLL"}
local Classes = {"", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"}

--[[local Classes = {
	"", 
	LOCALIZED_CLASS_NAMES_MALE["DRUID"],
	LOCALIZED_CLASS_NAMES_MALE["HUNTER"],
	LOCALIZED_CLASS_NAMES_MALE["MAGE"],
	LOCALIZED_CLASS_NAMES_MALE["PALADIN"],
	LOCALIZED_CLASS_NAMES_MALE["PRIEST"],
	LOCALIZED_CLASS_NAMES_MALE["ROGUE"],
	LOCALIZED_CLASS_NAMES_MALE["SHAMAN"],
	LOCALIZED_CLASS_NAMES_MALE["WARLOCK"],
	LOCALIZED_CLASS_NAMES_MALE["WARRIOR"],
	LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"]
}]]

-- Inserts all of the UI elements
function BlackList:InsertUI()

	local tabID = 1
	while _G["FriendsTabHeaderTab" .. tabID] do
		tabID = tabID + 1
	end
	BLFrameID = tabID
	-- Create a new tab
    local tab = CreateFrame("Button", "FriendsTabHeaderTab" .. tabID, FriendsTabHeader, "TabButtonTemplate")
    tab:SetPoint("LEFT",
	_G["FriendsTabHeaderTab" .. (tabID - 1)]:IsShown() and _G["FriendsTabHeaderTab" .. (tabID - 1)] or
	_G["FriendsTabHeaderTab" .. (tabID - 2)], "RIGHT", 0, 0)
	tab:SetID(tabID)
	tab:SetText("BlackList")
	PanelTemplates_TabResize(tab, -10)
    --tab:SetID(100) -- Use a high ID to avoid conflict with existing tabs
    --tab:SetPoint("TOPRIGHT", FriendsTabHeader, "TOPRIGHT", 0, 0) -- Adjust as needed
    tab:SetScript("OnClick", function()
        BlackList:ShowBlackListFrame()
		BlackList:UpdateUI()
		FriendsFrameTitleText:SetText("Black List")
		--FriendsFrameInset:SetPoint("TOPLEFT", 4, -80)
		FriendsFrame_Update()
    end)

	-- Add the tab itself
	--tinsert(FRIENDSFRAME_SUBFRAMES, "BlackListFrame")

	function BlackList:ShowBlackListFrame()
        -- Hide other subframes
		for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
			if ( value == frameName ) then
				_G[value]:Show()
			elseif ( value == "RaidFrame" ) then
				if ( RaidFrame:GetParent() == FriendsFrame ) then
					RaidFrame:Hide();
				end
			elseif ( value == "CommunitiesFrame") then
				if ( CommunitiesFrame and CommunitiesFrame:IsVisible() ) then
					CommunitiesFrame:Hide();
				end
			else
				_G[value]:Hide();
			end
		end

		if not BlackListFrame:IsShown() then
			BlackListFrame:Show()
		end

		-- Check if nameHeader already exists, if not create it
		if not BlackListFrame.nameHeader then
			BlackListFrame.nameHeader = BlackListFrame:CreateFontString(nil, "OVERLAY")
			BlackListFrame.nameHeader:SetFontObject("GameFontHighlight")
			BlackListFrame.nameHeader:SetPoint("TOPLEFT", FriendsFrameBlackListScrollFrame, "TOPLEFT", -13, 20)
			BlackListFrame.nameHeader:SetText("Name")
		end
	
		-- Check if realmHeader already exists, if not create it
		if not BlackListFrame.realmHeader then
			BlackListFrame.realmHeader = BlackListFrame:CreateFontString(nil, "OVERLAY")
			BlackListFrame.realmHeader:SetFontObject("GameFontHighlight")
			BlackListFrame.realmHeader:SetPoint("TOPRIGHT", FriendsFrameBlackListScrollFrame, "TOPRIGHT", -20, 20)
			BlackListFrame.realmHeader:SetText("Realm")
		end
	if BLSyncFileExists == true then
		-- Check if syncHeader already exists, if not create it
		if not BlackListFrame.latestsyncHeader then
			BlackListFrame.latestsyncHeader = BlackListFrame:CreateFontString(nil, "OVERLAY")
			BlackListFrame.latestsyncHeader:SetFontObject("GameFontHighlight")
			BlackListFrame.latestsyncHeader:SetPoint("TOPLEFT", FriendsFrameBlackListScrollFrame, "TOPLEFT", 25, 60)
			BlackListFrame.latestsyncHeader:SetText("Latest sync date available: " .. LIGHTGREEN .. syncDate .. ColorClose)
		end

		-- Check if syncHeader already exists, if not create it
		if not BlackListFrame.yoursyncHeader then
			BlackListFrame.yoursyncHeader = BlackListFrame:CreateFontString(nil, "OVERLAY")
			BlackListFrame.yoursyncHeader:SetFontObject("GameFontHighlight")
			BlackListFrame.yoursyncHeader:SetPoint("TOPLEFT", FriendsFrameBlackListScrollFrame, "TOPLEFT", 25, 45)
			if BlackListConfig.date then
			NewSyncDate = BlackListConfig.date
			else
			NewSyncDate = LIGHTRED .. "NO SYNC" .. ColorClose
			end
			if isDate2Bigger(syncDate, NewSyncDate) then
			BlackListFrame.yoursyncHeader:SetText("Your sync date: " .. LIGHTGREEN .. NewSyncDate .. ColorClose)
			else
			BlackListFrame.yoursyncHeader:SetText("Your sync date: " .. DARKRED .. NewSyncDate .. ColorClose)
			end
		end

		if not BlackListFrame.syncButton then
		BlackListFrame.syncButton = CreateFrame("Button", nil, BlackListFrame)--, "GameMenuButtonTemplate")
		BlackListFrame.syncButton:SetSize(60, 20)
		BlackListFrame.syncButton:SetPoint("LEFT", BlackListFrame.yoursyncHeader, "RIGHT", 0, 0)
		BlackListFrame.syncButton:SetText("Sync Now?")
		BlackListFrame.syncButton:SetNormalFontObject("GameFontNormal")
		BlackListFrame.syncButton:SetHighlightFontObject("GameFontGreen")
		BlackListFrame.syncButton:SetScript("OnClick", function()
		BlackList:SyncPopup()
		end)
		end
	else
		if not BlackListFrame.latestsyncHeader then
			BlackListFrame.latestsyncHeader = BlackListFrame:CreateFontString(nil, "OVERLAY")
			BlackListFrame.latestsyncHeader:SetFontObject("GameFontHighlight")
			BlackListFrame.latestsyncHeader:SetPoint("TOPLEFT", FriendsFrameBlackListScrollFrame, "TOPLEFT", 25, 60)
			BlackListFrame.latestsyncHeader:SetText("No blacklist sync file detected in addon folder\nVisit Discord for more information")
		end
	end
        
	
        -- Set the title
        FriendsFrameTitleText:SetText("Black List")
        -- Update the tabs visually
        PanelTemplates_SetTab(FriendsFrame, 100)
    end

	--PanelTemplates_SetNumTabs(FriendsTabHeader, 3)
	--PanelTemplates_UpdateTabs(FriendsTabHeader)

	-- Create name prompt
	StaticPopupDialogs["BL_PLAYER"] = {
		text = "Enter name of Player to add in Black List:",
		button1 = ACCEPT,
		button2 = CANCEL,
		OnShow = function(self)
			self.editBox:SetText("")
		end,
		OnAccept = function(self)
			BlackList:AddPlayer(self.editBox:GetText())
		end,
		EditBoxOnEnterPressed = function(self)	
			BlackList:AddPlayer(self:GetParent().editBox:GetText())
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		hasEditBox = true,
		maxLetters = 50,
		timeout = 0,
		exclusive = true,
		whileDead = true,
		hideOnEscape = true
	}
	BlackListFrame:SetScript("OnHide", function()
		FriendsFrame_Update()
	end)
end


function BlackList:ClickBlackList(sel)
	index = sel:GetID()
	BlackList:SetSelectedBlackList(index)
	BlackList:UpdateUI()
 	BlackList:ShowDetails()
end

function BlackList:SetSelectedBlackList(index)
	SelectedIndex = index
end

function BlackList:GetSelectedBlackList()
	return SelectedIndex
end

function BlackList:ShowDetails()

	-- get player
	local player = "BLANK"
	player = BlackList:GetPlayerByIndex(BlackList:GetSelectedBlackList())

	-- update details
	_G["BlackListDetailsName"]:SetText("Black List Details of " .. player["name"])

	BlackListDetailsBlackListedText:SetText(date("%I:%M%p on %b %d, 20%y", player["added"]))
	BlackListDetailsFrameReasonTextBox:SetText(player["reason"])
	BlackListEditDetailsFrameLevel:SetText(player["level"])
	BlackListEditDetailsFrameRealm:SetText(player["realm"])
	BlackListEditDetailsFrameRace:SetText(player["race"])
	BlackListEditDetailsFrameClass:SetText(player["class"])
	BlackListDetailsFrame.hideOnEscape = true
	BlackListDetailsFrame:Show()
	
end

function BlackListEditDetailsSaveButton_OnClick()

	local index = BlackList:GetSelectedBlackList()
	local level = BlackListEditDetailsFrameLevel:GetText()
	local realm = BlackListEditDetailsFrameRealm:GetText()
	local class = BlackListEditDetailsFrameClass:GetText()
	local race = BlackListEditDetailsFrameRace:GetText()


	BlackList:UpdateDetails(index, realm, nil, level, class, race)
	BlackListDetailsFrame:Hide()
	BlackList:UpdateUI()
end

function BlackList:UpdateUI(setIndex)
	local numBlackLists = BlackList:GetNumBlackLists()
	local nameText, name, player, faction
	local blacklistButton
	local selectedBlackList = BlackList:GetSelectedBlackList()
	
	FauxScrollFrame_Update(FriendsFrameBlackListScrollFrame, numBlackLists, 19, 16)

	if (numBlackLists > 0) then
		if (selectedBlackList == 0 or selectedBlackList > numBlackLists) then
			BlackList:SetSelectedBlackList(1)
			selectedBlackList = 1
		end
		
		FriendsFrameRemovePlayerButton:Enable()
	else
		FriendsFrameRemovePlayerButton:Disable()
	end

	local blacklistOffset = FauxScrollFrame_GetOffset(FriendsFrameBlackListScrollFrame)
	local blacklistIndex
	
	for i=1, 19, 1 do
		blacklistIndex = i + blacklistOffset	
		
		player = BlackList:GetPlayerByIndex(blacklistIndex)
		if(player ~= nil) then
			faction = BlackList:GetFaction(player["race"])
			nameText = _G["FriendsFrameBlackListButton" .. i .. "TextName"]
			nameText:SetText(player["name"])
			
			realmText = _G["FriendsFrameBlackListButton" .. i .. "RealmName"]
			realmText:SetText("("..player["realm"]..")")
		end
		
		blacklistButton = _G["FriendsFrameBlackListButton" .. i]
		blacklistButton:SetID(blacklistIndex)
		
		if (faction ~= nil and faction > 0) then
			factionIcon = _G["FriendsFrameBlackListButton" .. i .. "FactionFrameInsignia"]
			if (faction == 1) then
				factionIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
				factionIcon:SetTexCoord(0, 0.5, 0, 1)
			else 
				factionIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
				factionIcon:SetTexCoord(0.5, 1, 0, 1)
			end
		end

		-- Update the highlight
		if (blacklistIndex == selectedBlackList) then
			blacklistButton:LockHighlight()
		else
			blacklistButton:UnlockHighlight()
		end

		if (blacklistIndex > numBlackLists) then
			blacklistButton:Hide()
		else
			blacklistButton:Show()
		end
	end
end
