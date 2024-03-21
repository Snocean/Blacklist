-- Sync Date, update the date below in the same format
syncDate = "Feb 15 2024"
BLSyncFileExists = false -- Change this to true to enable this feature or replace this file with an already working Sync list


-- DO NOT TOUCH ANYTHING FROM HERE UNTIL YOU GET TO THE BLACKLIST TABLE 

-- Sync function
function BlackList:SyncPopup(data)
	BlackList:AddMessage("***PLEASE MAKE SURE YOU'VE BACKED UP YOUR CURRENT BLACKLIST TO AVOID HAVING TO WIPE AND RESTART***", "red")
	BlackList:AddMessage("How to use:", "yellow")
	BlackList:AddMessage("Clicking on Import will import the list.", "yellow")
    local SyncFrame = CreateFrame("Frame", "BlackListSyncFrame", UIParent, "BasicFrameTemplateWithInset")
    SyncFrame:SetSize(500, 300)
    SyncFrame:SetPoint("CENTER", 0, 200)
    SyncFrame.title = SyncFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    SyncFrame.title:SetPoint("CENTER", SyncFrame.TitleBg, "CENTER", 0, 0)
    SyncFrame.title:SetText("BlackList Sync")
	SyncFrame:SetMovable(true)
    SyncFrame:EnableMouse(true)
    SyncFrame:RegisterForDrag("LeftButton")
    SyncFrame:SetScript("OnDragStart", SyncFrame.StartMoving)
    SyncFrame:SetScript("OnDragStop", SyncFrame.StopMovingOrSizing)

    local scrollFrame = CreateFrame("ScrollFrame", "BlackListSyncScrollFrame", SyncFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(430, 220)
    scrollFrame:SetPoint("TOP", SyncFrame, "TOP", 0, -30)

    SyncFrame.editBox = CreateFrame("EditBox", nil, scrollFrame)
    SyncFrame.editBox:SetMultiLine(true)
    SyncFrame.editBox:SetFontObject(ChatFontNormal)
    SyncFrame.editBox:SetWidth(430)
    SyncFrame.editBox:SetAutoFocus(true)
    SyncFrame.editBox:SetText(BlackList:GenerateSyncCSV()) -- Set the default text if provided
	SyncFrame.editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

    scrollFrame:SetScrollChild(SyncFrame.editBox)

    SyncFrame.SyncButton = CreateFrame("Button", nil, SyncFrame, "UIPanelButtonTemplate")
    SyncFrame.SyncButton:SetSize(100, 25)
    SyncFrame.SyncButton:SetText("Sync")
    SyncFrame.SyncButton:SetPoint("BOTTOMLEFT", SyncFrame, "BOTTOMLEFT", 20, 20)
    SyncFrame.SyncButton:SetScript("OnClick", function()
        BlackList:ProcessImportData(SyncFrame.editBox:GetText())
        BlackListOptions:SetCurrentSyncDate()
        local NewSyncDate = BlackListConfig.date
        BlackListFrame.yoursyncHeader:SetText("Your sync date: " .. LIGHTGREEN .. NewSyncDate .. ColorClose)
        SyncFrame:Hide()
    end)

    SyncFrame.closeButton = CreateFrame("Button", nil, SyncFrame, "UIPanelButtonTemplate")
    SyncFrame.closeButton:SetSize(100, 25)
    SyncFrame.closeButton:SetText("Close")
    SyncFrame.closeButton:SetPoint("BOTTOMRIGHT", SyncFrame, "BOTTOMRIGHT", -20, 20)
    SyncFrame.closeButton:SetScript("OnClick", function() SyncFrame:Hide() end)

    SyncFrame:Show()
end

-- Generate CSV content for Sync Popup
function BlackList:GenerateSyncCSV()
    local syncData = {
	
	-- BLACKLIST TABLE
	-- input blacklisted players below formated in CSV style in quotations followed by a comma, 5 examples below
	-- There are 6 fields that must be accounted for every player, if a field is blank it must be included as a comma still
	-- The format is Name,Level,Class,Race,Reason,Server
	-- You must have the name and the server for the addon to work properly, so at a minimum it must be "Name,,,,,Server"
	-- Examples:
	-- "John,25,Priest,Human,Did something bad,MyServer"
	-- "Joe,,,,Did something bad also,MyServer"
	-- There are several communities that manage their own blacklist files which you can download and replace within the addon folder.
	-- Change the 5 entries below to be the names and reasons and servers of the players you wish to have in the sync list
	
"Testing1,,,,Did something,SomeServer",
"Testing2,,,,Did something,SomeServer",
"Testing3,,,,Did something,SomeServer",
"Testing4,,,,Did something,SomeServer",
"Testing5,,,,Did something,SomeServer"

-- End of blacklist additions

		}
    return table.concat(syncData, "\n")
end