--// Custom Name Tag + Customizer GUI (client-side)
--// Config lives in getgenv().NameTag, so you can tweak it from other scripts too.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local env = getgenv()

-- Clean up a previous run so re-executing doesn't stack tags/GUIs
if env.NameTagCleanup then pcall(env.NameTagCleanup) end

----------------------------------------------------------------
-- CONFIG (stored in getgenv)
----------------------------------------------------------------
local defaults = {
	Enabled = true,
	Text = "",                          -- empty = use your display name
	TextColor = Color3.fromRGB(255, 255, 255),
	OutlineColor = Color3.fromRGB(0, 0, 0),
	Outline = true,
	Font = "GothamBold",
	Size = 24,
	Height = 3,                         -- studs above head
	Rainbow = false,
	HideDefault = true,                 -- hide Roblox's default name/health bar
}

env.NameTag = env.NameTag or {}
local cfg = env.NameTag
for k, v in pairs(defaults) do
	if cfg[k] == nil then cfg[k] = v end
end

local FONTS = {
	"GothamBold", "Gotham", "SourceSansBold", "Arcade", "Fantasy",
	"SciFi", "Bangers", "Creepster", "Oswald", "Ubuntu", "Code", "Cartoon",
}

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

local tagGui, tagLabel, tagStroke
local previewLabel, previewStroke

local function getText()
	if cfg.Text == nil or cfg.Text == "" then
		return player.DisplayName
	end
	return cfg.Text
end

local function getFont()
	local ok, font = pcall(function() return Enum.Font[cfg.Font] end)
	return ok and font or Enum.Font.GothamBold
end

----------------------------------------------------------------
-- APPLY CONFIG TO TAG + PREVIEW
----------------------------------------------------------------
local function apply()
	local color = cfg.TextColor

	for _, pair in ipairs({
		{ tagLabel, tagStroke },
		{ previewLabel, previewStroke },
	}) do
		local label, stroke = pair[1], pair[2]
		if label then
			label.Text = getText()
			label.Font = getFont()
			label.TextSize = cfg.Size
			label.TextColor3 = color
		end
		if stroke then
			stroke.Enabled = cfg.Outline
			stroke.Color = cfg.OutlineColor
		end
	end

	if tagGui then
		tagGui.Enabled = cfg.Enabled
		tagGui.StudsOffset = Vector3.new(0, cfg.Height, 0)
	end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = cfg.HideDefault
			and Enum.HumanoidDisplayDistanceType.None
			or Enum.HumanoidDisplayDistanceType.Viewer
	end
end

----------------------------------------------------------------
-- NAME TAG (BillboardGui on the head)
----------------------------------------------------------------
local function buildTag(char)
	if tagGui then tagGui:Destroy() end
	local head = char:WaitForChild("Head", 10)
	if not head then return end

	tagGui = Instance.new("BillboardGui")
	tagGui.Name = "CustomNameTag"
	tagGui.Adornee = head
	tagGui.AlwaysOnTop = true
	tagGui.Size = UDim2.new(0, 300, 0, 60)
	tagGui.StudsOffset = Vector3.new(0, cfg.Height, 0)
	tagGui.Parent = head

	tagLabel = Instance.new("TextLabel")
	tagLabel.BackgroundTransparency = 1
	tagLabel.Size = UDim2.new(1, 0, 1, 0)
	tagLabel.TextWrapped = false
	tagLabel.Parent = tagGui

	tagStroke = Instance.new("UIStroke")
	tagStroke.Thickness = 2
	tagStroke.Parent = tagLabel

	apply()
end

----------------------------------------------------------------
-- GUI HELPERS
----------------------------------------------------------------
local THEME = {
	bg = Color3.fromRGB(28, 28, 34),
	panel = Color3.fromRGB(40, 40, 48),
	accent = Color3.fromRGB(88, 130, 255),
	text = Color3.fromRGB(235, 235, 240),
	dim = Color3.fromRGB(150, 150, 160),
}

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
end

local function newLabel(parent, text, size, color, align)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamMedium
	l.TextSize = size or 13
	l.TextColor3 = color or THEME.text
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local function getGuiParent()
	local ok, ui = pcall(function() return gethui and gethui() end)
	if ok and ui then return ui end
	local ok2 = pcall(function() return CoreGui.Name end)
	if ok2 then return CoreGui end
	return player:WaitForChild("PlayerGui")
end

local screen = Instance.new("ScreenGui")
screen.Name = "NameTagCustomizer"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = getGuiParent()

local window = Instance.new("Frame")
window.Size = UDim2.new(0, 290, 0, 440)
window.Position = UDim2.new(0, 30, 0.5, -220)
window.BackgroundColor3 = THEME.bg
window.BorderSizePixel = 0
window.Parent = screen
corner(window, 10)

-- Title bar (drag handle)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = THEME.panel
titleBar.BorderSizePixel = 0
titleBar.Parent = window
corner(titleBar, 10)

local title = newLabel(titleBar, "Name Tag Customizer", 14)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold

local function titleButton(text, xOffset, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 24, 0, 24)
	b.Position = UDim2.new(1, xOffset, 0, 5)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = true
	b.Parent = titleBar
	corner(b, 6)
	return b
end

local closeBtn = titleButton("X", -30, Color3.fromRGB(200, 70, 70))
local minBtn = titleButton("-", -60, Color3.fromRGB(90, 90, 105))

-- Dragging
do
	local dragging, dragStart, startPos
	connect(titleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Live preview
local previewBox = Instance.new("Frame")
previewBox.Size = UDim2.new(1, -20, 0, 80)
previewBox.Position = UDim2.new(0, 10, 0, 42)
previewBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
previewBox.BorderSizePixel = 0
previewBox.ClipsDescendants = true
previewBox.Parent = window
corner(previewBox, 8)

local previewCaption = newLabel(previewBox, "LIVE PREVIEW", 10, THEME.dim)
previewCaption.Position = UDim2.new(0, 8, 0, 4)
previewCaption.Size = UDim2.new(1, -16, 0, 12)

previewLabel = Instance.new("TextLabel")
previewLabel.BackgroundTransparency = 1
previewLabel.Size = UDim2.new(1, 0, 1, 0)
previewLabel.Parent = previewBox

previewStroke = Instance.new("UIStroke")
previewStroke.Thickness = 2
previewStroke.Parent = previewLabel

-- Scrollable controls
local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, -20, 1, -136)
body.Position = UDim2.new(0, 10, 0, 128)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 4
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = window

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = body

local order = 0
local function nextOrder() order += 1 return order end

-- Control: text box
local function addTextBox(labelText, getter, setter, placeholder)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 52)
	row.BackgroundTransparency = 1
	row.LayoutOrder = nextOrder()
	row.Parent = body

	local l = newLabel(row, labelText, 12, THEME.dim)
	l.Size = UDim2.new(1, 0, 0, 16)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 30)
	box.Position = UDim2.new(0, 0, 0, 20)
	box.BackgroundColor3 = THEME.panel
	box.TextColor3 = THEME.text
	box.PlaceholderText = placeholder or ""
	box.PlaceholderColor3 = THEME.dim
	box.Text = getter()
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.Parent = row
	corner(box, 6)

	connect(box:GetPropertyChangedSignal("Text"), function()
		setter(box.Text)
		apply()
	end)
	return box
end

-- Control: toggle
local function addToggle(labelText, getter, setter)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 30)
	btn.BackgroundColor3 = THEME.panel
	btn.TextColor3 = THEME.text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = nextOrder()
	btn.Parent = body
	corner(btn, 6)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.Parent = btn

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 34, 0, 16)
	pill.Position = UDim2.new(1, -44, 0.5, -8)
	pill.BorderSizePixel = 0
	pill.Parent = btn
	corner(pill, 8)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = pill
	corner(knob, 6)

	local function refresh()
		local on = getter()
		btn.Text = labelText
		pill.BackgroundColor3 = on and THEME.accent or Color3.fromRGB(80, 80, 90)
		knob.Position = on and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)
	end
	refresh()

	connect(btn.MouseButton1Click, function()
		setter(not getter())
		refresh()
		apply()
	end)
end

-- Control: slider
local function addSlider(labelText, min, max, getter, setter, decimals)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 40)
	row.BackgroundTransparency = 1
	row.LayoutOrder = nextOrder()
	row.Parent = body

	local l = newLabel(row, "", 12, THEME.dim)
	l.Size = UDim2.new(1, 0, 0, 16)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 8)
	bar.Position = UDim2.new(0, 0, 0, 26)
	bar.BackgroundColor3 = THEME.panel
	bar.BorderSizePixel = 0
	bar.Parent = row
	corner(bar, 4)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = THEME.accent
	fill.BorderSizePixel = 0
	fill.Parent = bar
	corner(fill, 4)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = bar
	corner(knob, 7)

	local function fmt(v)
		if decimals and decimals > 0 then
			return string.format("%." .. decimals .. "f", v)
		end
		return tostring(math.floor(v + 0.5))
	end

	local function refresh()
		local v = getter()
		local a = (v - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		l.Text = labelText .. ": " .. fmt(v)
	end
	refresh()

	local dragging = false
	local function setFromX(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local v = min + (max - min) * a
		if not decimals or decimals == 0 then v = math.floor(v + 0.5) end
		setter(v)
		refresh()
		apply()
	end

	connect(bar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return refresh
end

-- Control: RGB slider group for a color field
local function addColorGroup(headerText, key)
	local header = newLabel(body, headerText, 13, THEME.text)
	header.Size = UDim2.new(1, -6, 0, 18)
	header.Font = Enum.Font.GothamBold
	header.LayoutOrder = nextOrder()

	local refreshers = {}
	for i, channel in ipairs({ "R", "G", "B" }) do
		refreshers[i] = addSlider(channel, 0, 255,
			function()
				local c = cfg[key]
				return ({ c.R, c.G, c.B })[i] * 255
			end,
			function(v)
				local c = cfg[key]
				local rgb = { c.R * 255, c.G * 255, c.B * 255 }
				rgb[i] = v
				cfg[key] = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
			end
		)
	end
	return refreshers
end

-- Control: button
local function addButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 30)
	btn.BackgroundColor3 = THEME.panel
	btn.TextColor3 = THEME.text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.Text = text
	btn.LayoutOrder = nextOrder()
	btn.Parent = body
	corner(btn, 6)
	connect(btn.MouseButton1Click, function() callback(btn) end)
	return btn
end

----------------------------------------------------------------
-- BUILD CONTROLS
----------------------------------------------------------------
addTextBox("Tag text (blank = display name)",
	function() return cfg.Text end,
	function(v) cfg.Text = v end,
	player.DisplayName)

addToggle("Show tag", function() return cfg.Enabled end, function(v) cfg.Enabled = v end)
addToggle("Rainbow text", function() return cfg.Rainbow end, function(v) cfg.Rainbow = v end)
addToggle("Outline", function() return cfg.Outline end, function(v) cfg.Outline = v end)
addToggle("Hide default name", function() return cfg.HideDefault end, function(v) cfg.HideDefault = v end)

addSlider("Text size", 10, 40, function() return cfg.Size end, function(v) cfg.Size = v end)
addSlider("Height (studs)", 1, 8, function() return cfg.Height end, function(v) cfg.Height = v end, 1)

addButton("Font: " .. cfg.Font, function(btn)
	local idx = table.find(FONTS, cfg.Font) or 0
	cfg.Font = FONTS[(idx % #FONTS) + 1]
	btn.Text = "Font: " .. cfg.Font
	apply()
end)

local textColorRefresh = addColorGroup("Text color", "TextColor")
local outlineRefresh = addColorGroup("Outline color", "OutlineColor")

addButton("Reset to defaults", function()
	for k, v in pairs(defaults) do cfg[k] = v end
	-- simplest: rebuild the GUI values by re-running the script
	apply()
	for _, r in ipairs(textColorRefresh) do r() end
	for _, r in ipairs(outlineRefresh) do r() end
end)

local destroyBtn = addButton("Destroy name tag + GUI", function() env.NameTagCleanup() end)
destroyBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)

-- Minimize / close
local minimized = false
connect(minBtn.MouseButton1Click, function()
	minimized = not minimized
	body.Visible = not minimized
	previewBox.Visible = not minimized
	window.Size = minimized and UDim2.new(0, 290, 0, 34) or UDim2.new(0, 290, 0, 440)
end)
connect(closeBtn.MouseButton1Click, function() screen.Enabled = false end)

-- Press RightShift to bring the GUI back after closing it
connect(UserInputService.InputBegan, function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
		screen.Enabled = not screen.Enabled
	end
end)

----------------------------------------------------------------
-- RAINBOW LOOP
----------------------------------------------------------------
connect(RunService.Heartbeat, function()
	if cfg.Rainbow then
		local c = Color3.fromHSV((tick() % 5) / 5, 1, 1)
		if tagLabel then tagLabel.TextColor3 = c end
		if previewLabel then previewLabel.TextColor3 = c end
	end
end)

----------------------------------------------------------------
-- CHARACTER HANDLING + CLEANUP
----------------------------------------------------------------
connect(player.CharacterAdded, buildTag)
if player.Character then task.spawn(buildTag, player.Character) end

apply()

env.NameTagCleanup = function()
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	table.clear(connections)
	if tagGui then pcall(function() tagGui:Destroy() end) end
	if screen then pcall(function() screen:Destroy() end) end
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
	env.NameTagCleanup = nil
end
