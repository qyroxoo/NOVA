--// NOVA PLAYER PANEL V3
--// Mobile / Delta-friendly
--// Player browser + notifications + minimize circle

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CLEAN OLD VERSION
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("NovaPlayerPanel")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(9, 10, 15)
local PANEL = Color3.fromRGB(16, 18, 26)
local CARD = Color3.fromRGB(22, 24, 34)
local CARD_HOVER = Color3.fromRGB(30, 33, 45)

local BORDER = Color3.fromRGB(52, 55, 70)

local WHITE = Color3.fromRGB(245, 246, 250)
local GREY = Color3.fromRGB(145, 150, 165)
local DARK_GREY = Color3.fromRGB(90, 95, 110)

local PURPLE = Color3.fromRGB(130, 92, 255)
local GREEN = Color3.fromRGB(85, 220, 135)
local RED = Color3.fromRGB(240, 80, 95)
local BLUE = Color3.fromRGB(80, 165, 255)

--==================================================
-- HELPERS
--==================================================

local function New(class, properties)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function Corner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function Stroke(object, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function Tween(object, properties, duration)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    animation:Play()
    return animation
end

local function GetAvatar(player, size)
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            size or Enum.ThumbnailSize.Size100x100
        )
    end)

    if success then
        return image
    end

    return ""
end

local function SafeProperty(player, property)
    local success, value = pcall(function()
        return player[property]
    end)

    if success and value ~= nil then
        local stringValue = tostring(value)

        if stringValue ~= "" then
            return stringValue
        end
    end

    return "Unavailable"
end

local function GetJoinCode(player)
    local success, value = pcall(function()
        return player.JoinCode
    end)

    if success and value ~= nil then
        return tostring(value)
    end

    local attribute = player:GetAttribute("JoinCode")

    if attribute ~= nil then
        return tostring(attribute)
    end

    local object = player:FindFirstChild("JoinCode")

    if object and object:IsA("ValueBase") then
        return tostring(object.Value)
    end

    return "Unavailable"
end

--==================================================
-- GUI
--==================================================

local Gui = New("ScreenGui", {
    Name = "NovaPlayerPanel",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

--==================================================
-- MAIN WINDOW
--==================================================

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 520, 0, 620),
    Position = UDim2.new(0.5, -260, 0.5, -310),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Parent = Gui
})

Corner(Main, 20)
Stroke(Main, BORDER, 0.15, 1)

--==================================================
-- HEADER
--==================================================

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 88),
    BackgroundTransparency = 1,
    Parent = Main
})

local Logo = New("Frame", {
    Size = UDim2.new(0, 48, 0, 48),
    Position = UDim2.new(0, 19, 0, 18),
    BackgroundColor3 = PURPLE,
    BorderSizePixel = 0,
    Parent = Header
})

Corner(Logo, 14)

New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "N",
    Font = Enum.Font.GothamBlack,
    TextSize = 24,
    TextColor3 = WHITE,
    Parent = Logo
})

New("TextLabel", {
    Size = UDim2.new(0, 300, 0, 26),
    Position = UDim2.new(0, 80, 0, 17),
    BackgroundTransparency = 1,
    Text = "NOVA PLAYERS",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

New("TextLabel", {
    Size = UDim2.new(0, 330, 0, 20),
    Position = UDim2.new(0, 80, 0, 44),
    BackgroundTransparency = 1,
    Text = "PLAYER MONITOR  •  LIVE",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = GREY,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

-- minimize
local Minimize = New("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -105, 0, 20),
    BackgroundColor3 = CARD,
    BorderSizePixel = 0,
    Text = "−",
    Font = Enum.Font.GothamBold,
    TextSize = 23,
    TextColor3 = WHITE,
    AutoButtonColor = false,
    Parent = Header
})

Corner(Minimize, 12)

-- close
local Close = New("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -58, 0, 20),
    BackgroundColor3 = CARD,
    BorderSizePixel = 0,
    Text = "×",
    Font = Enum.Font.Gotham,
    TextSize = 24,
    TextColor3 = WHITE,
    AutoButtonColor = false,
    Parent = Header
})

Corner(Close, 12)

--==================================================
-- SEARCH
--==================================================

local SearchFrame = New("Frame", {
    Size = UDim2.new(1, -40, 0, 48),
    Position = UDim2.new(0, 20, 0, 98),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Parent = Main
})

Corner(SearchFrame, 13)
Stroke(SearchFrame, BORDER, 0.35)

New("TextLabel", {
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "⌕",
    Font = Enum.Font.GothamBold,
    TextSize = 25,
    TextColor3 = GREY,
    Parent = SearchFrame
})

local Search = New("TextBox", {
    Size = UDim2.new(1, -55, 1, 0),
    Position = UDim2.new(0, 48, 0, 0),
    BackgroundTransparency = 1,
    PlaceholderText = "Search players...",
    PlaceholderColor3 = DARK_GREY,
    Text = "",
    TextColor3 = WHITE,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SearchFrame
})

--==================================================
-- STATUS
--==================================================

local PlayerCount = New("TextLabel", {
    Size = UDim2.new(0.7, 0, 0, 28),
    Position = UDim2.new(0, 20, 0, 155),
    BackgroundTransparency = 1,
    Text = "0 PLAYERS",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = GREY,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Main
})

local Online = New("TextLabel", {
    Size = UDim2.new(0.3, -20, 0, 28),
    Position = UDim2.new(0.7, 0, 0, 155),
    BackgroundTransparency = 1,
    Text = "● ONLINE",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = GREEN,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = Main
})

--==================================================
-- PLAYER LIST
--==================================================

local List = New("ScrollingFrame", {
    Size = UDim2.new(1, -40, 1, -210),
    Position = UDim2.new(0, 20, 0, 185),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = PURPLE,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Main
})

local ListLayout = New("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = List
})

New("UIPadding", {
    PaddingBottom = UDim.new(0, 12),
    Parent = List
})

--==================================================
-- DETAIL WINDOW
--==================================================

local Details = New("Frame", {
    Size = UDim2.new(0, 470, 0, 530),
    Position = UDim2.new(0.5, -235, 0.5, -265),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50,
    Parent = Gui
})

Corner(Details, 20)
Stroke(Details, BORDER, 0.1)

local Back = New("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(0, 15, 0, 14),
    BackgroundColor3 = CARD,
    BorderSizePixel = 0,
    Text = "‹",
    Font = Enum.Font.Gotham,
    TextSize = 28,
    TextColor3 = WHITE,
    AutoButtonColor = false,
    ZIndex = 51,
    Parent = Details
})

Corner(Back, 12)

New("TextLabel", {
    Size = UDim2.new(0, 250, 0, 40),
    Position = UDim2.new(0, 67, 0, 14),
    BackgroundTransparency = 1,
    Text = "PLAYER DETAILS",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 51,
    Parent = Details
})

local BigAvatar = New("ImageLabel", {
    Size = UDim2.new(0, 125, 0, 125),
    Position = UDim2.new(0.5, -62, 0, 78),
    BackgroundColor3 = CARD,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = Details
})

Corner(BigAvatar, 63)

local DetailName = New("TextLabel", {
    Size = UDim2.new(1, -40, 0, 27),
    Position = UDim2.new(0, 20, 0, 215),
    BackgroundTransparency = 1,
    Text = "Player",
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
    Parent = Details
})

local DetailUsername = New("TextLabel", {
    Size = UDim2.new(1, -40, 0, 20),
    Position = UDim2.new(0, 20, 0, 243),
    BackgroundTransparency = 1,
    Text = "@username",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = GREY,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 51,
    Parent = Details
})

local InfoContainer = New("Frame", {
    Size = UDim2.new(1, -40, 0, 210),
    Position = UDim2.new(0, 20, 0, 280),
    BackgroundTransparency = 1,
    ZIndex = 51,
    Parent = Details
})

local InfoLayout = New("UIListLayout", {
    Padding = UDim.new(0, 8),
    Parent = InfoContainer
})

local function CreateInfoRow(title, initial)
    local Row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = CARD,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = InfoContainer
    })

    Corner(Row, 11)

    New("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 13, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = GREY,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
        Parent = Row
    })

    local Value = New("TextLabel", {
        Size = UDim2.new(0.55, -10, 1, 0),
        Position = UDim2.new(0.42, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = initial,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = WHITE,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 53,
        Parent = Row
    })

    return Value
end

local CountryValue = CreateInfoRow("COUNTRY", "Unavailable")
local DeviceValue = CreateInfoRow("DEVICE", "Unavailable")
local JoinCodeValue = CreateInfoRow("JOIN CODE", "Unavailable")
local UserIdValue = CreateInfoRow("USER ID", "Unavailable")

--==================================================
-- DETAIL UPDATER
--==================================================

local SelectedPlayer = nil

local function UpdateDetails()
    if not SelectedPlayer then
        return
    end

    if not SelectedPlayer.Parent then
        Details.Visible = false
        SelectedPlayer = nil
        return
    end

    CountryValue.Text = SafeProperty(SelectedPlayer, "CountryCode")
    DeviceValue.Text = SafeProperty(SelectedPlayer, "DeviceType")
    JoinCodeValue.Text = GetJoinCode(SelectedPlayer)
    UserIdValue.Text = tostring(SelectedPlayer.UserId)
end

local function ShowDetails(player)
    SelectedPlayer = player

    DetailName.Text = player.DisplayName
    DetailUsername.Text = "@" .. player.Name
    BigAvatar.Image = GetAvatar(player, Enum.ThumbnailSize.Size150x150)

    UpdateDetails()

    Details.Visible = true
    Details.Size = UDim2.new(0, 430, 0, 490)

    Tween(Details, {
        Size = UDim2.new(0, 470, 0, 530)
    }, 0.2)
end

Back.MouseButton1Click:Connect(function()
    Tween(Details, {
        Size = UDim2.new(0, 430, 0, 490)
    }, 0.15)

    task.wait(0.15)

    Details.Visible = false
    SelectedPlayer = nil
end)

--==================================================
-- PLAYER CARDS
--==================================================

local function CreateCard(player)
    local Card = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = CARD,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = List
    })

    Corner(Card, 14)
    Stroke(Card, BORDER, 0.55)

    local Avatar = New("ImageLabel", {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, 10, 0.5, -30),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Image = GetAvatar(player),
        Parent = Card
    })

    Corner(Avatar, 13)

    New("TextLabel", {
        Size = UDim2.new(1, -150, 0, 22),
        Position = UDim2.new(0, 82, 0, 15),
        BackgroundTransparency = 1,
        Text = player.DisplayName,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = WHITE,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Card
    })

    New("TextLabel", {
        Size = UDim2.new(1, -150, 0, 19),
        Position = UDim2.new(0, 82, 0, 39),
        BackgroundTransparency = 1,
        Text = "@" .. player.Name,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = GREY,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Card
    })

    local Arrow = New("TextLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -42, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "›",
        Font = Enum.Font.Gotham,
        TextSize = 25,
        TextColor3 = DARK_GREY,
        Parent = Card
    })

    Card.MouseEnter:Connect(function()
        Tween(Card, {
            BackgroundColor3 = CARD_HOVER
        }, 0.1)
    end)

    Card.MouseLeave:Connect(function()
        Tween(Card, {
            BackgroundColor3 = CARD
        }, 0.1)
    end)

    Card.MouseButton1Click:Connect(function()
        ShowDetails(player)
    end)

    return Card
end

--==================================================
-- REFRESH PLAYER LIST
--==================================================

local function Refresh()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local query = string.lower(Search.Text)
    local players = Players:GetPlayers()
    local shown = 0

    for _, player in ipairs(players) do
        local username = string.lower(player.Name)
        local displayName = string.lower(player.DisplayName)

        if query == ""
            or string.find(username, query, 1, true)
            or string.find(displayName, query, 1, true) then

            CreateCard(player)
            shown += 1
        end
    end

    PlayerCount.Text =
        tostring(#players) ..
        " PLAYERS  •  " ..
        tostring(shown) ..
        " SHOWN"
end

Search:GetPropertyChangedSignal("Text"):Connect(Refresh)

--==================================================
-- NOTIFICATION SYSTEM
--==================================================

local NotificationHolder = New("Frame", {
    Name = "Notifications",
    Size = UDim2.new(0, 300, 1, -30),
    Position = UDim2.new(0, 15, 0, 15),
    BackgroundTransparency = 1,
    Parent = Gui
})

local NotificationLayout = New("UIListLayout", {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificationHolder
})

local function Notify(title, message, isJoin)
    local color = isJoin and GREEN or RED
    local symbol = isJoin and "+" or "−"

    local Notification = New("Frame", {
        Size = UDim2.new(0, 285, 0, 67),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = NotificationHolder
    })

    Corner(Notification, 13)
    Stroke(Notification, BORDER, 0.25)

    local Bar = New("Frame", {
        Size = UDim2.new(0, 4, 1, -20),
        Position = UDim2.new(0, 9, 0, 10),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = Notification
    })

    Corner(Bar, 3)

    local Icon = New("TextLabel", {
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(0, 20, 0.5, -17),
        BackgroundColor3 = color,
        BackgroundTransparency = 1,
        Text = symbol,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = WHITE,
        Parent = Notification
    })

    Corner(Icon, 10)

    local Title = New("TextLabel", {
        Size = UDim2.new(1, -75, 0, 21),
        Position = UDim2.new(0, 65, 0, 13),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = WHITE,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })

    local Message = New("TextLabel", {
        Size = UDim2.new(1, -75, 0, 18),
        Position = UDim2.new(0, 65, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = GREY,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Notification
    })

    -- entrance
    Notification.Position = UDim2.new(0, -310, 0, 0)

    Tween(Notification, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0
    }, 0.25)

    Tween(Bar, {
        BackgroundTransparency = 0
    }, 0.2)

    Tween(Icon, {
        BackgroundTransparency = 0
    }, 0.2)

    task.delay(3.5, function()
        if Notification and Notification.Parent then
            Tween(Notification, {
                Position = UDim2.new(0, -310, 0, 0),
                BackgroundTransparency = 1
            }, 0.25)

            task.wait(0.25)

            if Notification then
                Notification:Destroy()
            end
        end
    end)
end

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerAdded:Connect(function(player)
    task.wait(0.25)

    Refresh()

    if player ~= LocalPlayer then
        Notify(
            "PLAYER JOINED",
            player.DisplayName .. " joined the server",
            true
        )
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player ~= LocalPlayer then
        Notify(
            "PLAYER LEFT",
            player.DisplayName .. " left the server",
            false
        )
    end

    task.wait(0.1)
    Refresh()
end)

--==================================================
-- AUTO UPDATE
--==================================================

task.spawn(function()
    while Gui.Parent do
        task.wait(1)

        -- update selected player's info
        if SelectedPlayer then
            UpdateDetails()
        end

        -- refresh player list
        if Gui.Parent then
            Refresh()
        end
    end
end)

--==================================================
-- DRAGGING MAIN WINDOW
--==================================================

local draggingMain = false
local mainDragStart
local mainStartPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingMain = true
        mainDragStart = input.Position
        mainStartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingMain then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - mainDragStart

        Main.Position = UDim2.new(
            mainStartPosition.X.Scale,
            mainStartPosition.X.Offset + delta.X,
            mainStartPosition.Y.Scale,
            mainStartPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingMain = false
    end
end)

--==================================================
-- MINIMIZE CIRCLE
--==================================================

local Circle = New("TextButton", {
    Name = "MiniCircle",
    Size = UDim2.new(0, 62, 0, 62),
    Position = UDim2.new(0, 20, 0.5, -31),
    BackgroundColor3 = PURPLE,
    BorderSizePixel = 0,
    Text = "N",
    Font = Enum.Font.GothamBlack,
    TextSize = 25,
    TextColor3 = WHITE,
    Visible = false,
    AutoButtonColor = false,
    Parent = Gui
})

Corner(Circle, 31)
Stroke(Circle, Color3.fromRGB(180, 160, 255), 0.2, 2)

local CircleGradient = New("UIGradient", {
    Rotation = 45,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PURPLE),
        ColorSequenceKeypoint.new(1, BLUE)
    }),
    Parent = Circle
})

local function MinimizeUI()
    Tween(Main, {
        Size = UDim2.new(0, 20, 0, 20)
    }, 0.2)

    task.wait(0.2)

    Main.Visible = false
    Circle.Visible = true

    Circle.Size = UDim2.new(0, 10, 0, 10)

    Tween(Circle, {
        Size = UDim2.new(0, 62, 0, 62)
    }, 0.2)
end

local function RestoreUI()
    Circle.Visible = false
    Main.Visible = true

    local targetSize = Main.Size

    Main.Size = UDim2.new(0, 20, 0, 20)

    Tween(Main, {
        Size = targetSize
    }, 0.2)
end

Minimize.MouseButton1Click:Connect(MinimizeUI)
Circle.MouseButton1Click:Connect(RestoreUI)

--==================================================
-- DRAG FLOATING CIRCLE
--==================================================

local circleDragging = false
local circleMoved = false
local circleStart
local circlePosition

Circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        circleDragging = true
        circleMoved = false
        circleStart = input.Position
        circlePosition = Circle.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not circleDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - circleStart

        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            circleMoved = true
        end

        Circle.Position = UDim2.new(
            circlePosition.X.Scale,
            circlePosition.X.Offset + delta.X,
            circlePosition.Y.Scale,
            circlePosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if circleDragging and not circleMoved then
            RestoreUI()
        end

        circleDragging = false
    end
end)

--==================================================
-- MOBILE RESIZE
--==================================================

local function Resize()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local size = camera.ViewportSize

    if size.X < 600 then
        Main.Size = UDim2.new(0.92, 0, 0, 590)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Main.AnchorPoint = Vector2.new(0.5, 0.5)

        Details.Size = UDim2.new(0.90, 0, 0, 510)
        Details.Position = UDim2.new(0.5, 0, 0.5, 0)
        Details.AnchorPoint = Vector2.new(0.5, 0.5)
    end
end

pcall(Resize)

pcall(function()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Resize)
end)

--==================================================
-- INITIAL LOAD
--==================================================

Refresh()

task.wait(0.2)

Notify(
    "NOVA READY",
    "Player monitor initialized",
    true
)

print("[NOVA] Player Panel loaded.")
