pfUI:RegisterModule("addonbuttons", function ()
  if not pfUI.minimap then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.panels ~= "-1" then
    default_border = C.appearance.border.panels
  end

  pfUI_cache["abuttons"] = pfUI_cache["abuttons"] or {}
  pfUI_cache["abuttons"]["add"] = pfUI_cache["abuttons"]["add"] or {}
  pfUI_cache["abuttons"]["del"] = pfUI_cache["abuttons"]["del"] or {}

  local ignored_icons = {
    "Note",
    "JQuest",
    "Naut_",
    "MinimapIcon",
    "GatherMatePin",
    "WestPointer",
    "Chinchilla_",
    "SmartMinimapZoom",
    "QuestieNote",
    "smm",
    "pfMiniMapPin",
    "MiniMapBattlefieldFrame",
    "pfMinimapButton",
    "GatherNote",
    "MiniNotePOI"
  }

  pfUI.addonbuttons = CreateFrame("Frame", "pfMinimapButtons", UIParent)
  CreateBackdrop(pfUI.addonbuttons)
  pfUI.addonbuttons:SetFrameStrata("HIGH")
  pfUI.addonbuttons:Hide()
  UpdateMovable(pfUI.addonbuttons)


  pfUI.addonbuttons.minimapbutton = CreateFrame("Button", "pfMinimapButton", UIParent)
  pfUI.addonbuttons.minimapbutton:SetFrameStrata("MEDIUM")
  pfUI.addonbuttons.minimapbutton:SetWidth(10)
  pfUI.addonbuttons.minimapbutton:SetHeight(10)
  CreateBackdrop(pfUI.addonbuttons.minimapbutton, C.appearance.border.default)
  UpdateMovable(pfUI.addonbuttons.minimapbutton)

  pfUI.addonbuttons.minimapbutton.icon = pfUI.addonbuttons.minimapbutton:CreateTexture("BACKGROUND")
  pfUI.addonbuttons.minimapbutton.icon:SetAllPoints(pfUI.addonbuttons.minimapbutton)
  pfUI.addonbuttons.minimapbutton.icon:SetVertexColor(1,1,1,1)

  pfUI.addonbuttons.minimapbutton:SetScript("OnClick", function()
    if pfUI.addonbuttons:IsShown() then
      pfUI.addonbuttons:Hide()
    else
      pfUI.addonbuttons:Show()
    end
  end)

  pfUI.addonbuttons.buttons = {}
  pfUI.addonbuttons.overrides = {}
  pfUI.addonbuttons.last_updated = 0
  pfUI.addonbuttons.rows = 1
  pfUI.addonbuttons.effective_scale = Minimap:GetEffectiveScale()
  pfUI.addonbuttons.max_button_size = 40

  pfUI.addonbuttons:RegisterEvent("PLAYER_LOGIN")
  pfUI.addonbuttons:RegisterEvent("PLAYER_REGEN_DISABLED")


  local function GetButtonSize()
    if C.abuttons.position == "bottom" then
      return (pfUI.minimap:GetWidth() - (tonumber(C.abuttons.spacing) * (tonumber(C.abuttons.rowsize) + 1))) / tonumber(C.abuttons.rowsize)
    else
      return (pfUI.minimap:GetHeight() - (tonumber(C.abuttons.spacing) * (tonumber(C.abuttons.rowsize) + 1))) / tonumber(C.abuttons.rowsize)
    end
  end

  local function GetNumButtons()
    local total_buttons = 0
    for i, v in ipairs(pfUI.addonbuttons.buttons) do
      total_buttons = total_buttons + 1
    end
    return total_buttons
  end

  local function GetStringSize()
    return (GetButtonSize() + tonumber(C.abuttons.spacing))
  end

  local function TableMatch(table, needle)
    for i,v in ipairs(table) do
      if (strlower(v) == strlower(needle)) then
        return i
      end
    end
    return false
  end

  local function TablePartialMatch(table, needle)
    for i,v in ipairs(table) do
      pos_start, pos_end = strfind(strlower(needle), strlower(v))
      if pos_start == 1 then
        return i
      end
    end
    return false
  end

  local function IsButtonValid(frame)
    if frame:GetName() ~= nil then
      if frame:IsVisible() then
        if frame:IsFrameType("Button") then
          if frame:GetScript("OnClick") ~= nil or frame:GetScript("OnMouseDown") ~= nil or frame:GetScript("OnMouseUp") ~= nil then
            if frame:GetHeight() < pfUI.addonbuttons.max_button_size and frame:GetWidth() < pfUI.addonbuttons.max_button_size then
              if not TablePartialMatch(ignored_icons, frame:GetName()) then
                return true
              end
            end
          end
        elseif frame:IsFrameType("Frame") and (strfind(strlower(frame:GetName()), "icon") or strfind(strlower(frame:GetName()), "button")) then
          if frame:GetScript("OnMouseDown") ~= nil or frame:GetScript("OnMouseUp") ~= nil then
            if frame:GetHeight() < pfUI.addonbuttons.max_button_size and frame:GetWidth() < pfUI.addonbuttons.max_button_size then
              if not TablePartialMatch(ignored_icons, frame:GetName()) then
                return true
              end
            end
          end
        end
      end
    end
    return false
  end

  local function FindButtons(frame)
    for i, frame_child in ipairs({frame:GetChildren()}) do
      -- check first level children
      if IsButtonValid(frame_child) and not TableMatch(pfUI.addonbuttons.buttons, frame_child:GetName()) then
        table.insert(pfUI.addonbuttons.buttons, frame_child:GetName())
      else
        if frame_child:GetNumChildren() > 0 then
          for j, child_child in ipairs({frame_child:GetChildren()}) do
            if IsButtonValid(child_child) and not TableMatch(pfUI.addonbuttons.buttons, child_child:GetName()) then
              table.insert(pfUI.addonbuttons.buttons, child_child:GetName())
            end
          end
        end
      end
    end
  end

  local function GetScale()
    local sum_size, buttons_count, calculated_scale
    sum_size = 0
    buttons_count = GetNumButtons()
    for i, button_name in ipairs(pfUI.addonbuttons.buttons) do
      if getglobal(button_name) ~= nil then
        sum_size = sum_size + getglobal(button_name):GetHeight()
      end
    end
    calculated_scale = GetButtonSize() / (sum_size / buttons_count)
    return calculated_scale > 1 and 1 or calculated_scale
  end

  local function ScanForButtons()
    FindButtons(Minimap)
    FindButtons(MinimapBackdrop)
  end

  local function SetupMainFrame()
    pfUI.addonbuttons:ClearAllPoints()
    pfUI.addonbuttons.minimapbutton:ClearAllPoints()
    if C.abuttons.position == "bottom" then
      pfUI.addonbuttons:SetWidth(pfUI.minimap:GetWidth())
      pfUI.addonbuttons:SetHeight(ceil((GetNumButtons() > 0 and GetNumButtons() or 1) / tonumber(C.abuttons.rowsize)) * GetStringSize() + tonumber(C.abuttons.spacing))
      pfUI.addonbuttons:SetPoint("TOP", pfUI.minimap, "BOTTOM", 0 , -default_border * 3)
      pfUI.addonbuttons.minimapbutton.icon:SetTexture("Interface\\AddOns\\pfUI\\img\\down.tga")
      pfUI.addonbuttons.minimapbutton:SetPoint("BOTTOM", pfUI.minimap, "BOTTOM", 0, 4)

    else
      pfUI.addonbuttons:SetWidth(ceil((GetNumButtons() > 0 and GetNumButtons() or 1) / tonumber(C.abuttons.rowsize)) * GetStringSize() + tonumber(C.abuttons.spacing))
      pfUI.addonbuttons:SetHeight(pfUI.minimap:GetHeight())
      pfUI.addonbuttons:SetPoint("TOPRIGHT", pfUI.minimap, "TOPLEFT", -default_border * 3, 0)
      pfUI.addonbuttons.minimapbutton.icon:SetTexture("Interface\\AddOns\\pfUI\\img\\left.tga")
      pfUI.addonbuttons.minimapbutton:SetPoint("LEFT", pfUI.minimap, "LEFT", 4, 0)
    end
    UpdateMovable(pfUI.addonbuttons)
    UpdateMovable(pfUI.addonbuttons.minimapbutton)
    pfUI.addonbuttons.minimapbutton:Show()

  end

  local function UpdatePanel()
    ScanForButtons()
    for i, button_name in ipairs(pfUI_cache["abuttons"]["add"]) do
      if not TableMatch(pfUI.addonbuttons.buttons, button_name) then
        if getglobal(button_name) ~= nil then
          table.insert(pfUI.addonbuttons.buttons, button_name)
        end
      end
    end
    for i, button_name in ipairs(pfUI_cache["abuttons"]["del"]) do
      if TableMatch(pfUI.addonbuttons.buttons, button_name) then
        table.remove(pfUI.addonbuttons.buttons, TableMatch(pfUI.addonbuttons.buttons, button_name))
      end
    end
    for i, button_name in ipairs(pfUI.addonbuttons.buttons) do
      if getglobal(button_name) == nil then
        table.remove(pfUI.addonbuttons.buttons, TableMatch(pfUI.addonbuttons.buttons, button_name))
      end
    end
    SetupMainFrame()
  end

  local function GetTopFrame(frame)
    if frame:GetParent() == Minimap or frame:GetParent() == UIParent then
      return frame
    else
      return GetTopFrame(frame:GetParent())
    end
  end

  local function BackupButton(frame)
    if frame.backup == nil then
      frame.backup = {}
      frame.backup.top_frame_name = GetTopFrame(frame):GetName()
      frame.backup.parent_name = GetTopFrame(frame):GetParent():GetName()
      frame.backup.is_clamped_to_screen = frame:IsClampedToScreen()
      frame.backup.is_movable = frame:IsMovable()
      frame.backup.point = {frame:GetPoint()}
      frame.backup.size = {frame:GetHeight(), frame:GetWidth()}
      frame.backup.scale = frame:GetScale()
      if frame:HasScript("OnDragStart") then
        frame.backup.on_drag_start = frame:GetScript("OnDragStart")
      end
      if frame:HasScript("OnDragStop") then
        frame.backup.on_drag_stop = frame:GetScript("OnDragStop")
      end
      if frame:HasScript("OnUpdate") then
        frame.backup.on_update = frame:GetScript("OnUpdate")
      end
      -- TODO: find a way to avoid such hardcoding
      if frame:GetName() == "MetaMapButton" then
        frame.backup.MetaMapButton_UpdatePosition = MetaMapButton_UpdatePosition
        pfUI.addonbuttons.overrides.MetaMapButton_UpdatePosition = function () return end
      end
    end
  end

  local function RestoreButton(frame)
    if frame.backup ~= nil then
      getglobal(frame.backup.top_frame_name):SetParent(frame.backup.parent_name)
      frame:SetClampedToScreen(frame.backup.is_clamped_to_screen)
      frame:SetMovable(frame.backup.is_movable)
      frame:SetScale(frame.backup.scale)
      frame:SetHeight(frame.backup.size[1])
      frame:SetWidth(frame.backup.size[2])
      frame:ClearAllPoints()
      frame:SetPoint(frame.backup.point[1], frame.backup.point[2], frame.backup.point[3], frame.backup.point[4], frame.backup.point[5])
      if frame.backup.on_drag_start ~= nil then
        frame:SetScript("OnDragStart", frame.backup.on_drag_start)
      end
      if frame.backup.on_drag_stop ~= nil then
        frame:SetScript("OnDragStop", frame.backup.on_drag_stop)
      end
      if frame.backup.on_update ~= nil then
        frame:SetScript("OnUpdate", frame.backup.on_update)
      end
      if frame.backup.MetaMapButton_UpdatePosition ~= nil then
        pfUI.addonbuttons.overrides.MetaMapButton_UpdatePosition = frame.backup.MetaMapButton_UpdatePosition
      end
    end
  end

  local function MoveButton(index, frame)
    local top_frame, row_index, offsetX, offsetY, final_scale
    top_frame = GetTopFrame(frame)
    final_scale = GetScale() / pfUI.addonbuttons.effective_scale
    row_index = floor((index-1)/tonumber(C.abuttons.rowsize))
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(false)
    frame:SetScript("OnDragStart", nil)
    frame:SetScript("OnDragStop", nil)
    frame:SetScript("OnUpdate", nil)
    frame:SetClampedToScreen(true)
    frame:SetMovable(false)
    frame:ClearAllPoints()

    if top_frame ~= pfUI.addonbuttons then
      top_frame:SetScale(final_scale)
      top_frame:ClearAllPoints()
      top_frame:SetParent(pfUI.addonbuttons)
    end

    if C.abuttons.position == "bottom" then
      offsetX = ((index - row_index * tonumber(C.abuttons.rowsize)) * (tonumber(C.abuttons.spacing))) + (((index - row_index * tonumber(C.abuttons.rowsize)) - 1) * GetButtonSize()) + (GetButtonSize() / 2)
      offsetY = -(((row_index + 1) * tonumber(C.abuttons.spacing)) + (row_index * GetButtonSize()) + (GetButtonSize() / 2))
      frame:SetPoint("CENTER", pfUI.addonbuttons, "TOPLEFT", offsetX/final_scale, offsetY/final_scale)
      if top_frame ~= pfUI.addonbuttons then
        top_frame:SetPoint("CENTER", pfUI.addonbuttons, "TOPLEFT", offsetX/final_scale, offsetY/final_scale)
      end
    else
      offsetX = -(((row_index + 1) * tonumber(C.abuttons.spacing)) + (row_index * GetButtonSize()) + (GetButtonSize() / 2))
      offsetY = -(((index - row_index * tonumber(C.abuttons.rowsize)) * (tonumber(C.abuttons.spacing))) + (((index - row_index * tonumber(C.abuttons.rowsize)) - 1) * GetButtonSize()) + (GetButtonSize() / 2))
      frame:SetPoint("CENTER", pfUI.addonbuttons, "TOPRIGHT", offsetX/final_scale, offsetY/final_scale)
      if top_frame ~= pfUI.addonbuttons then
        top_frame:SetPoint("CENTER", pfUI.addonbuttons, "TOPRIGHT", offsetX/final_scale, offsetY/final_scale)
      end
    end
  end

  local function ManualAddOrRemove(action)
    local button = GetMouseFocus()
    if action == "reset" then
      for i, button_name in ipairs(pfUI_cache["abuttons"]["add"]) do
        if getglobal(button_name) ~= nil then
          if TableMatch(pfUI.addonbuttons.buttons, button_name) then
            table.remove(pfUI.addonbuttons.buttons, TableMatch(pfUI.addonbuttons.buttons, button_name))
          end
          RestoreButton(getglobal(button_name))
        end
      end
      pfUI_cache["abuttons"]["add"] = {}
      pfUI_cache["abuttons"]["del"] = {}
      pfUI.addonbuttons:ProcessButtons()
      message("Lists of added and deleted buttons are cleared")
      return
    else
      if IsButtonValid(button) then
        if action == "add" then
          if TableMatch(pfUI_cache["abuttons"]["del"], button:GetName()) then
            table.remove(pfUI_cache["abuttons"]["del"], TableMatch(pfUI_cache["abuttons"]["del"], button:GetName()))
          end
          if not TableMatch(pfUI.addonbuttons.buttons, button:GetName()) and not TableMatch(pfUI_cache["abuttons"]["add"], button:GetName()) then
            table.insert(pfUI_cache["abuttons"]["add"], button:GetName())
            message("Added button: " .. button:GetName())
          else
            message("Button already exists in pfMinimapButtons frame")
            return
          end
        elseif action == "del" then
          if TableMatch(pfUI_cache["abuttons"]["add"], button:GetName()) then
            table.remove(pfUI_cache["abuttons"]["add"], TableMatch(pfUI_cache["abuttons"]["add"], button:GetName()))
          end
          if TableMatch(pfUI.addonbuttons.buttons, button:GetName()) then
            table.remove(pfUI.addonbuttons.buttons, TableMatch(pfUI.addonbuttons.buttons, button:GetName()))
          else
            message("Button not found in pfMinimapButtons frame")
            return
          end
          if not TableMatch(pfUI_cache["abuttons"]["del"], button:GetName()) then
            table.insert(pfUI_cache["abuttons"]["del"], button:GetName())
            RestoreButton(button)
            message("Removed button: " .. button:GetName())
          end
        else
          message("/abp add - to add button to the frame")
          message("/abp del - to remove button from the frame")
          message("/abp reset - to reset all manually added or ignored buttons")
          return
        end
        pfUI.addonbuttons:ProcessButtons()
        return
      end
      message("Not a valid button!")
    end
  end

  function pfUI.addonbuttons:ProcessButtons()
    UpdatePanel()
    for i, button_name in ipairs(pfUI.addonbuttons.buttons) do
      if getglobal(button_name) ~= nil then
        BackupButton(getglobal(button_name))
        MoveButton(i, getglobal(button_name))
      end
    end
  end

  function pfUI.addonbuttons:UpdateConfig()
    pfUI.addonbuttons:ProcessButtons()
    pfUI.addonbuttons:GetScript("OnEvent")()
  end

  pfUI.addonbuttons:SetScript("OnUpdate", function()
    pfUI.addonbuttons.last_updated = pfUI.addonbuttons.last_updated + arg1
    while (pfUI.addonbuttons.last_updated > tonumber(C.abuttons.updateinterval)) do
      pfUI.addonbuttons:ProcessButtons()
      pfUI.addonbuttons.last_updated = pfUI.addonbuttons.last_updated - tonumber(C.abuttons.updateinterval)
      for k, v in pfUI.addonbuttons.overrides do
        _G[k] = v
      end
    end
  end)

  pfUI.addonbuttons:SetScript("OnEvent", function()
    if event == "PLAYER_REGEN_DISABLED" then
      if C.abuttons.hideincombat == "1" and pfUI.addonbuttons:IsShown() then
        pfUI.addonbuttons:Hide()
      end
    else
      pfUI.addonbuttons:ProcessButtons()
      if not pfUI.addonbuttons:IsShown() and GetNumButtons() > 0 and event == "PLAYER_LOGIN" then
        pfUI.addonbuttons:Show()
      end
    end
  end)

  pfUI.addonbuttons:UpdateConfig()

  _G.SLASH_PFABP1 = "/abp"
  _G.SlashCmdList.PFABP = ManualAddOrRemove

end)