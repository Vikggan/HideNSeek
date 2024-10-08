local UI = CreateFrame("Frame", "HnSframe", UIParent, "UIPanelDialogTemplate");
UI:SetPoint("TOPLEFT", UIParent, 0, 300);
UI:SetMovable(true);
UI:SetUserPlaced(true);
UI:EnableMouse(true);
UI:RegisterForDrag("LeftButton");
UI:SetScript("OnDragStart", UI.StartMoving);
UI:SetScript("OnDragStop", UI.StopMovingOrSizing);
HnS_WIDTH = 270;
HnS_HEIGHT = 145;
UI:SetSize(HnS_WIDTH, HnS_HEIGHT);
UI.Title:SetText("Hide N Seek");
UI:SetShown(false);
UI:SetClampedToScreen(true);

UI:RegisterEvent("PLAYER_TARGET_CHANGED");

UI:SetScript('OnEvent', function(self, event, arg1, arg2, ...)
    if HnS_playing then
        HnS_findTarget();
    end
end
);
local exportParent = CreateFrame("Frame", "HnS_export", UIParent, "UIPanelDialogTemplate")
exportParent:SetPoint("CENTER", UIParent);
exportParent:SetSize(320,320);
exportParent:EnableMouse(true)
exportParent.Title:SetText("Export")
local exportFrame = CreateFrame("ScrollFrame", "MyMultiLineEditBox", 
exportParent, "InputScrollFrameTemplate")
exportFrame:SetPoint("TOPLEFT", exportParent, 10, -30)
exportFrame:SetPoint("BOTTOMRIGHT", exportParent, -10, 10)
exportFrame.EditBox:SetFontObject("ChatFontNormal")
exportFrame.EditBox:SetText("Test")
exportFrame.CharCount:Hide()
local editboxParent = exportFrame.EditBox:GetParent();
exportFrame.EditBox:SetWidth(280)
exportParent:SetShown(false);


HnS_playing = false;

local xPoint = 0;
local yPoint = 0;
--local addPlayer = UI:CreateFontString("addPlayer", UI, "GameFontNormal");
--addPlayer:SetText("Add");
--addPlayer:SetTextColor(1,1,1);
--addPlayer:SetPoint("TOPLEFT", 15, yPoint);
addPlayerButton = CreateFrame("Button", "addPlayerButton", UI, "UIPanelButtonTemplate");
addPlayerButton:SetText("Add Player");
addPlayerButton:SetWidth(addPlayerButton:GetTextWidth() + 20);
addPlayerButton:SetPoint("BOTTOMRIGHT", UI,"BOTTOMRIGHT", -10,  35);
addPlayerButton:SetScript("OnClick", function ()
    HnS_addTarget();
end
);

clearButton = CreateFrame("Button", "clearButton", UI, "UIPanelButtonTemplate");
clearButton:SetText("Clear List");
clearButton:SetWidth(clearButton:GetTextWidth() + 20);
clearButton:SetPoint("TOPLEFT", UI, "TOPLEFT", 10, -30)
clearButton:SetScript("OnClick", function ()
    HnS_Players = {}
    HnS_updateText()
end
);

resetButton = CreateFrame("Button", "resetButton", UI, "UIPanelButtonTemplate");
resetButton:SetText("Reset Found Status");
resetButton:SetWidth(resetButton:GetTextWidth() + 20);
resetButton:SetPoint("BOTTOMLEFT", UI, "BOTTOMLEFT", 10, 35)
resetButton:SetScript("OnClick", function ()
    HnS_clearFind()
    HnS_updateText()
end
);

startButton = CreateFrame("Button", "startButton", UI, "UIPanelButtonTemplate");
startButton:SetText("Start Game");
startButton:SetPoint("BOTTOMRIGHT", UI, "BOTTOMRIGHT", -10, 10);
startButton:SetPoint("BOTTOMLEFT", UI, "BOTTOMLEFT", 10, 10);
startButton:SetScript("OnClick", function ()
    if(HnS_playing) then
        HnS_playing = false;
        startButton:SetText("Start Game");
    else
        HnS_playing = true;
        startButton:SetText("Stop Game");
    end
end);

exportButton = CreateFrame("Button", "exportButton", UI, "UIPanelButtonTemplate");
exportButton:SetText("Export");
exportButton:SetWidth(exportButton:GetTextWidth() + 20);
exportButton:SetPoint("TOPRIGHT", UI, "TOPRIGHT", -10, -30);
exportButton:SetScript("OnClick", function ()
    exportParent:Show();
    local exportString = "";
    for i,n in ipairs(HnS_Players) do
        exportString = exportString .. n.name .. "," .. tostring(n.count) .. "\n";
    end
    exportFrame.EditBox:SetText(exportString)
    exportFrame.EditBox:SetFocus();
    exportFrame.EditBox:HighlightText();
end);

foundCounter = UI:CreateFontString("addPlayer", "OVERLAY", "GameFontNormal");
foundCounter:SetPoint("TOP", 0, -60);
foundCounter:SetText("Found: 0/0")

HnS_Players = {}
HnS_found = 0;
local textpool = {}
local textinuse = {}

function HnS_addTarget()
    local name, realm = UnitName("target");
    if(name == nil) then
        print("No target");
        return;
    end

    if(realm ~= nil) then
        name = name .. " - " .. realm;
    end

    if(not HnS_has_value(HnS_Players, name)) then
        table.insert(HnS_Players, {name = name, found = false, count = 0});
    end
    HnS_updateText()
end

function HnS_findTarget()
    local name, realm = UnitName("target");
    if(name == nil) then
        return;
    end
    if(realm ~= nil) then
        name = name .. " - " .. realm;
    end
    for index, value in ipairs(HnS_Players) do
        if value.name == name then
            if not value.found then
                value.found = true;
                value.count = value.count +1;
            end
        end
    end
    HnS_updateText();
end

function HnS_clearFind()
    for index, value in ipairs(HnS_Players) do
            value.found = false;
    end
end

function HnS_updateText()
    HnS_clearText();
    HnS_found = 0;
    for i,n in ipairs(HnS_Players) do
        local f = HnS_getframe();
        table.insert(textinuse, f);
        f:SetText(n.name .. " : " .. tostring(n.count));
        if(n.found == true)then
            f:SetTextColor(0,1,0);
            HnS_found = HnS_found + 1;
        else
            f:SetTextColor(1,1,1);
        end

        f:SetPoint("TOPLEFT", 15, i * -20 - 60)
        f:Show()
    end
    foundCounter:SetText("Found: " .. tostring(HnS_found) .. "/" .. tostring(table.getn(HnS_Players)));
    UI:SetHeight(HnS_HEIGHT + table.getn(textinuse) * 20);
end

function HnS_clearText()
    while(table.getn(textinuse) > 0) do
        local f = table.remove(textinuse)
        f:Hide();
        table.insert(textpool, f)
    end
end


SLASH_HNS1 = '/hns'
SlashCmdList['HNS'] = function()
    UI:SetShown(true);
    HnS_updateText();
end



function HnS_has_value (tab, val)
    for index, value in ipairs(tab) do
        if value.name == val then
            return true
        end
    end

    return false
end

     
local function removeframe(f)
    f:Hide()
    tremove(textinuse)
    tinsert(textpool, f)
end
 
function HnS_getframe()
    local f = table.remove(textpool)
    if not f then
        --Create your frame here and assign it to f
        f = UI:CreateFontString("addPlayer", "Overlay", "GameFontNormal");
    else
        --revert any unique changes you may have made to the frame before sticking it in the framepool
    end
    return f
end