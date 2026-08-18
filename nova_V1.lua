--// NOVA PLAYER PANEL V4 – LIVE DATA EDITION
--// Mobile / Delta-friendly
--// Fetches Country, Device, Join Code from player

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CLEAN OLD UI
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("NovaPlayerPanel")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- THEME
--==================================================

local Theme = {
    Background = Color3.fromRGB(7, 8, 13),
    Panel = Color3.fromRGB(13, 15, 22),
    Card = Color3.fromRGB(20, 22, 31),
    CardHover = Color3.fromRGB(28, 30, 42),

    Border = Color3.fromRGB(48, 51, 66),

    White = Color3.fromRGB(245, 246, 250),
    Grey = Color3.fromRGB(145, 149, 164),
    DarkGrey = Color3.fromRGB(82, 86, 101),

    Purple = Color3.fromRGB(132, 91, 255),
    Purple2 = Color3.fromRGB(92, 65, 220),

    Green = Color3.fromRGB(70, 220, 130),
    Red = Color3.fromRGB(245, 78, 96),
    Blue = Color3.fromRGB(75, 165, 255)
}

--==================================================
-- HELPERS
--==================================================

local function Create(class, properties)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function Round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local function AddStroke(object, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Parent = object

    return stroke
end

local function Animate(object, properties, time)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            time or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

local function GetAvatar(player)
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)

    if success then
        return image
    end

    return ""
end

--==================================================
-- 🧠 DATA FETCHING (Robust)
--==================================================

local function getPlayerInfo(player)
    local country = "N/A"
    local device = "N/A"
    local joinCode = "N/A"

    -- 1. Try direct properties
    if player:FindFirstChild("CountryCode") then
        country = player.CountryCode.Value
    elseif player:GetAttribute("CountryCode") then
        country = player:GetAttribute("CountryCode")
    elseif player.CountryCode then
        country = player.CountryCode
    end

    if player:FindFirstChild("DeviceType") then
        device = player.DeviceType.Value
    elseif player:GetAttribute("DeviceType") then
        device = player:GetAttribute("DeviceType")
    elseif player.DeviceType then
        device = player.DeviceType
    end

    if player:FindFirstChild("JoinCode") then
        joinCode = player.JoinCode.Value
    elseif player:GetAttribute("JoinCode") then
        joinCode = player:GetAttribute("JoinCode")
    elseif player.JoinCode then
        joinCode = player.JoinCode
    end

    -- 2. Check inside "Data" folder (common pattern)
    local dataFolder = player:FindFirstChild("Data")
    if dataFolder then
        if dataFolder:FindFirstChild("CountryCode") then
            country = dataFolder.CountryCode.Value
        elseif dataFolder:GetAttribute("CountryCode") then
            country = dataFolder:GetAttribute("CountryCode")
        end

        if dataFolder:FindFirstChild("DeviceType") then
            device = dataFolder.DeviceType.Value
        elseif dataFolder:GetAttribute("DeviceType") then
            device = dataFolder:GetAttribute("DeviceType")
        end

        if dataFolder:FindFirstChild("JoinCode") then
            joinCode = dataFolder.JoinCode.Value
        elseif dataFolder:GetAttribute("JoinCode") then
            joinCode = dataFolder:GetAttribute("JoinCode")
        end
    end

    -- 3. Fallback: async methods (if available)
    pcall(function()
        if player.GetCountryCodeAsync then
            local success, result = pcall(function()
                return player:GetCountryCodeAsync()
            end)
            if success and result and result ~= "" then
                country = result
            end
        end
    end)

    pcall(function()
        if player.GetDeviceType then
            local success, result = pcall(function()
                return player:GetDeviceType()
            end)
            if success and result and result ~= "" then
                device = result
            end
        end
    end)

    -- Debug output (console)
    print(string.format("[NOVA] Data for %s: Country='%s', Device='%s', JoinCode='%s'",
        player.Name, country, device, joinCode))

    return country, device, joinCode
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Create("ScreenGui", {
    Name = "NovaPlayerPanel",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 540, 0, 650),
    Position = UDim2.new(0.5, -270, 0.5, -325),

    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,

    Parent = ScreenGui
})

Round(Main, 22)
AddStroke(Main, Theme.Border, 0.1, 1)

--==================================================
-- TOP GRADIENT
--==================================================

local TopGradient = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 5),
    BackgroundColor3 = Theme.Purple,
    BorderSizePixel = 0,
    Parent = Main
})

Round(TopGradient, 5)

local Gradient = Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Purple),
        ColorSequenceKeypoint.new(0.5, Theme.Blue),
        ColorSequenceKeypoint.new(1, Theme.Purple2)
    }),
    Parent = TopGradient
})

--==================================================
-- HEADER
--==================================================

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 92),
    BackgroundTransparency = 1,
    Parent = Main
})

-- logo

local Logo = Create("Frame", {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Theme.Purple,
    BorderSizePixel = 0,
    Parent = Header
})

Round(Logo, 16)

local LogoGradient = Create("UIGradient", {
    Rotation = 45,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Purple),
        ColorSequenceKeypoint.new(1, Theme.Blue)
    }),
    Parent = Logo
})

Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,

    Text = "N",
    Font = Enum.Font.GothamBlack,
    TextSize = 26,
    TextColor3 = Theme.White,

    Parent = Logo
})

Create("TextLabel", {
    Size = UDim2.new(0, 300, 0, 27),
    Position = UDim2.new(0, 86, 0, 19),

    BackgroundTransparency = 1,

    Text = "NOVA PLAYERS",
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    TextColor3 = Theme.White,

    TextXAlignment = Enum.TextXAlignment.Left,

    Parent = Header
})

Create("TextLabel", {
    Size = UDim2.new(0, 300, 0, 20),
    Position = UDim2.new(0, 86, 0, 47),

    BackgroundTransparency = 1,

    Text = "LIVE PLAYER MONITOR",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Theme.Grey,

    TextXAlignment = Enum.TextXAlignment.Left,

    Parent = Header
})

-- online indicator

local OnlineDot = Create("Frame", {
    Size = UDim2.new(0, 7, 0, 7),
    Position = UDim2.new(0, 86, 0, 70),

    BackgroundColor3 = Theme.Green,
    BorderSizePixel = 0,

    Parent = Header
})

Round(OnlineDot, 7)

Create("TextLabel", {
    Size = UDim2.new(0, 100, 0, 15),
    Position = UDim2.new(0, 99, 0, 66),

    BackgroundTransparency = 1,

    Text = "SYSTEM ONLINE",
    Font = Enum.Font.GothamBold,
    TextSize = 8,
    TextColor3 = Theme.Green,

    TextXAlignment = Enum.TextXAlignment.Left,

    Parent = Header
})

-- minimize

local Minimize = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -105, 0, 20),

    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,

    Text = "−",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Theme.White,

    AutoButtonColor = false,

    Parent = Header
})

Round(Minimize, 12)

-- hide button

local HideButton = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -58, 0, 20),

    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,

    Text = "×",
    Font = Enum.Font.Gotham,
    TextSize = 23,
    TextColor3 = Theme.White,

    AutoButtonColor = false,

    Parent = Header
})

Round(HideButton, 12)

--==================================================
-- SEARCH
--==================================================

local SearchBox = Create("Frame", {
    Size = UDim2.new(1, -40, 0, 52),
    Position = UDim2.new(0, 20, 0, 105),

    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,

    Parent = Main
})

Round(SearchBox, 14)
AddStroke(SearchBox, Theme.Border, 0.35)

Create("TextLabel", {
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),

    BackgroundTransparency = 1,

    Text = "⌕",
    Font = Enum.Font.GothamBold,
    TextSize = 25,
    TextColor3 = Theme.Grey,

    Parent = SearchBox
})

local Search = Create("TextBox", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),

    BackgroundTransparency = 1,

    PlaceholderText = "Search username or display name...",
    PlaceholderColor3 = Theme.DarkGrey,

    Text = "",
    TextColor3 = Theme.White,

    Font = Enum.Font.Gotham,
    TextSize = 12,

    ClearTextOnFocus = false,

    TextXAlignment = Enum.TextXAlignment.Left,

    Parent = SearchBox
})

--==================================================
-- PLAYER COUNT
--==================================================

local Count = Create("TextLabel", {
    Size = UDim2.new(0.7, 0, 0, 28),
    Position = UDim2.new(0, 22, 0, 168),

    BackgroundTransparency = 1,

    Text = "0 PLAYERS",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Theme.Grey,

    TextXAlignment = Enum.TextXAlignment.Left,

    Parent = Main
})

--==================================================
-- PLAYER LIST
--==================================================

local PlayerList = Create("ScrollingFrame", {
    Size = UDim2.new(1, -40, 1, -225),
    Position = UDim2.new(0, 20, 0, 195),

    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Purple,

    AutomaticCanvasSize = Enum.AutomaticSize.Y,

    CanvasSize = UDim2.new(0, 0, 0, 0),

    Parent = Main
})

local ListLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,

    Parent = PlayerList
})

Create("UIPadding", {
    PaddingBottom = UDim.new(0, 15),
    Parent = PlayerList
})

--==================================================
-- DETAILS PANEL
--==================================================

local Details = Create("Frame", {
    Size = UDim2.new(0, 480, 0, 560),
    Position = UDim2.new(0.5, -240, 0.5, -280),

    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,

    Visible = false,
    ZIndex = 100,

    Parent = ScreenGui
})

Round(Details, 22)
AddStroke(Details, Theme.Border, 0.05, 1)

local Back = Create("TextButton", {
    Size = UDim2.new(0, 42, 0, 42),
    Position = UDim2.new(0, 16, 0, 16),

    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,

    Text = "‹",
    Font = Enum.Font.Gotham,
    TextSize = 29,
    TextColor3 = Theme.White,

    AutoButtonColor = false,

    ZIndex = 101,

    Parent = Details
})

Round(Back, 13)

Create("TextLabel", {
    Size = UDim2.new(0, 250, 0, 42),
    Position = UDim2.new(0, 70, 0, 16),

    BackgroundTransparency = 1,

    Text = "PLAYER PROFILE",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Theme.White,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 101,

    Parent = Details
})

-- avatar

local BigAvatar = Create("ImageLabel", {
    Size = UDim2.new(0, 130, 0, 130),
    Position = UDim2.new(0.5, -65, 0, 75),

    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,

    ZIndex = 101,

    Parent = Details
})

Round(BigAvatar, 65)
AddStroke(BigAvatar, Theme.Purple, 0.25, 2)

local DetailName = Create("TextLabel", {
    Size = UDim2.new(1, -40, 0, 28),
    Position = UDim2.new(0, 20, 0, 215),

    BackgroundTransparency = 1,

    Text = "Player",
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    TextColor3 = Theme.White,

    TextXAlignment = Enum.TextXAlignment.Center,

    ZIndex = 101,

    Parent = Details
})

local DetailUsername = Create("TextLabel", {
    Size = UDim2.new(1, -40, 0, 20),
    Position = UDim2.new(0, 20, 0, 243),

    BackgroundTransparency = 1,

    Text = "@username",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Theme.Grey,

    TextXAlignment = Enum.TextXAlignment.Center,

    ZIndex = 101,

    Parent = Details
})

--==================================================
-- INFO ROWS
--==================================================

local InfoContainer = Create("Frame", {
    Size = UDim2.new(1, -40, 0, 240),
    Position = UDim2.new(0, 20, 0, 280),

    BackgroundTransparency = 1,

    ZIndex = 101,

    Parent = Details
})

Create("UIListLayout", {
    Padding = UDim.new(0, 9),
    Parent = InfoContainer
})

local function InfoRow(title, value)
    local Row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),

        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,

        ZIndex = 102,

        Parent = InfoContainer
    })

    Round(Row, 13)

    Create("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),

        BackgroundTransparency = 1,

        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = Theme.Grey,

        TextXAlignment = Enum.TextXAlignment.Left,

        ZIndex = 103,

        Parent = Row
    })

    local Value = Create("TextLabel", {
        Size = UDim2.new(0.55, -15, 1, 0),
        Position = UDim2.new(0.42, 0, 0, 0),

        BackgroundTransparency = 1,

        Text = value,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.White,

        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,

        ZIndex = 103,

        Parent = Row
    })

    return Value
end

-- These will be updated with real data
local CountryValue = InfoRow("COUNTRY CODE", "Loading...")
local DeviceValue = InfoRow("DEVICE TYPE", "Loading...")
local JoinCodeValue = InfoRow("JOIN CODE", "Loading...")
local UserIdValue = InfoRow("USER ID", "000000000")

--==================================================
-- PLAYER CARD
--==================================================

local function CreatePlayerCard(player)

    local Card = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 82),

        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,

        Text = "",
        AutoButtonColor = false,

        Parent = PlayerList
    })

    Round(Card, 15)
    AddStroke(Card, Theme.Border, 0.45, 1)

    local Avatar = Create("ImageLabel", {
        Size = UDim2.new(0, 62, 0, 62),
        Position = UDim2.new(0, 10, 0.5, -31),

        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,

        Image = GetAvatar(player),

        Parent = Card
    })

    Round(Avatar, 14)

    -- online dot

    local Dot = Create("Frame", {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(0, 63, 1, -20),

        BackgroundColor3 = Theme.Green,
        BorderSizePixel = 0,

        Parent = Card
    })

    Round(Dot, 11)
    AddStroke(Dot, Theme.Background, 0, 2)

    Create("TextLabel", {
        Size = UDim2.new(1, -150, 0, 23),
        Position = UDim2.new(0, 84, 0, 15),

        BackgroundTransparency = 1,

        Text = player.DisplayName,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.White,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,

        Parent = Card
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -150, 0, 19),
        Position = UDim2.new(0, 84, 0, 40),

        BackgroundTransparency = 1,

        Text = "@" .. player.Name,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.Grey,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,

        Parent = Card
    })

    Create("TextLabel", {
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -50, 0.5, -17),

        BackgroundTransparency = 1,

        Text = "›",
        Font = Enum.Font.Gotham,
        TextSize = 27,
        TextColor3 = Theme.DarkGrey,

        Parent = Card
    })

    Card.MouseEnter:Connect(function()
        Animate(Card, {
            BackgroundColor3 = Theme.CardHover
        }, 0.1)
    end)

    Card.MouseLeave:Connect(function()
        Animate(Card, {
            BackgroundColor3 = Theme.Card
        }, 0.1)
    end)

    Card.MouseButton1Click:Connect(function()

        DetailName.Text = player.DisplayName
        DetailUsername.Text = "@" .. player.Name
        BigAvatar.Image = GetAvatar(player)
        UserIdValue.Text = tostring(player.UserId)

        -- 🔥 FETCH REAL DATA
        local country, device, joinCode = getPlayerInfo(player)
        CountryValue.Text = country
        DeviceValue.Text = device
        JoinCodeValue.Text = joinCode

        Details.Visible = true

        Details.Size = UDim2.new(0, 440, 0, 520)

        Animate(Details, {
            Size = UDim2.new(0, 480, 0, 560)
        }, 0.2)

    end)

end

--==================================================
-- REFRESH
--==================================================

local function RefreshPlayers()

    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local Query = string.lower(Search.Text)
    local Shown = 0

    for _, player in ipairs(Players:GetPlayers()) do

        local Username = string.lower(player.Name)
        local Display = string.lower(player.DisplayName)

        if Query == ""
            or string.find(Username, Query, 1, true)
            or string.find(Display, Query, 1, true) then

            CreatePlayerCard(player)

            Shown += 1
        end
    end

    Count.Text =
        tostring(#Players:GetPlayers())
        .. " PLAYERS  •  "
        .. tostring(Shown)
        .. " SHOWN"

end

Search:GetPropertyChangedSignal("Text"):Connect(RefreshPlayers)

--==================================================
-- BACK
--==================================================

Back.MouseButton1Click:Connect(function()

    Animate(Details, {
        Size = UDim2.new(0, 440, 0, 520)
    }, 0.15)

    task.wait(0.15)

    Details.Visible = false

end)

--==================================================
-- NOTIFICATIONS
--==================================================

local NotificationHolder = Create("Frame", {
    Size = UDim2.new(0, 310, 1, -30),
    Position = UDim2.new(0, 15, 0, 15),

    BackgroundTransparency = 1,

    Parent = ScreenGui
})

Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,

    Parent = NotificationHolder
})

local function Notify(title, message, joining)

    local Accent = joining and Theme.Green or Theme.Red

    local Notification = Create("Frame", {
        Size = UDim2.new(0, 295, 0, 70),

        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,

        Parent = NotificationHolder
    })

    Round(Notification, 14)
    AddStroke(Notification, Theme.Border, 0.25, 1)

    local Bar = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -20),
        Position = UDim2.new(0, 8, 0, 10),

        BackgroundColor3 = Accent,
        BorderSizePixel = 0,

        Parent = Notification
    })

    Round(Bar, 4)

    local Icon = Create("Frame", {
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0, 22, 0.5, -19),

        BackgroundColor3 = Accent,
        BorderSizePixel = 0,

        Parent = Notification
    })

    Round(Icon, 11)

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),

        BackgroundTransparency = 1,

        Text = joining and "+" or "−",

        Font = Enum.Font.GothamBold,
        TextSize = 21,
        TextColor3 = Theme.White,

        Parent = Icon
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 72, 0, 12),

        BackgroundTransparency = 1,

        Text = title,

        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.White,

        TextXAlignment = Enum.TextXAlignment.Left,

        Parent = Notification
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 72, 0, 35),

        BackgroundTransparency = 1,

        Text = message,

        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = Theme.Grey,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,

        Parent = Notification
    })

    Notification.Position =
        UDim2.new(0, -320, 0, 0)

    Animate(Notification, {
        Position = UDim2.new(0, 0, 0, 0)
    }, 0.25)

    task.delay(3.5, function()

        if Notification.Parent then

            Animate(Notification, {
                Position = UDim2.new(0, -320, 0, 0)
            }, 0.25)

            task.wait(0.25)

            if Notification then
                Notification:Destroy()
            end

        end

    end)

end

--==================================================
-- JOIN / LEAVE
--==================================================

Players.PlayerAdded:Connect(function(player)

    task.wait(0.2)

    RefreshPlayers()

    if player ~= LocalPlayer then
        Notify(
            "PLAYER JOINED",
            player.DisplayName .. " joined",
            true
        )
    end

end)

Players.PlayerRemoving:Connect(function(player)

    if player ~= LocalPlayer then
        Notify(
            "PLAYER LEFT",
            player.DisplayName .. " left",
            false
        )
    end

    task.wait(0.1)

    RefreshPlayers()

end)

--==================================================
-- FLOATING CIRCLE
--==================================================

local Circle = Create("TextButton", {
    Size = UDim2.new(0, 66, 0, 66),

    Position = UDim2.new(0, 20, 0.5, -33),

    BackgroundColor3 = Theme.Purple,

    BorderSizePixel = 0,

    Text = "N",

    Font = Enum.Font.GothamBlack,
    TextSize = 27,
    TextColor3 = Theme.White,

    AutoButtonColor = false,

    Visible = false,

    Parent = ScreenGui
})

Round(Circle, 33)
AddStroke(Circle, Theme.Blue, 0.15, 2)

local CircleGradient = Create("UIGradient", {
    Rotation = 45,

    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Purple),
        ColorSequenceKeypoint.new(1, Theme.Blue)
    }),

    Parent = Circle
})

--==================================================
-- HIDE / SHOW
--==================================================

local function HideMain()

    Details.Visible = false

    Animate(Main, {
        Size = UDim2.new(0, 30, 0, 30)
    }, 0.18)

    task.wait(0.18)

    Main.Visible = false
    Circle.Visible = true

end

local function ShowMain()

    Circle.Visible = false

    Main.Visible = true

    Main.Size = UDim2.new(0, 30, 0, 30)

    Animate(Main, {
        Size = UDim2.new(0, 540, 0, 650)
    }, 0.22)

end

Minimize.MouseButton1Click:Connect(HideMain)
HideButton.MouseButton1Click:Connect(HideMain)

--==================================================
-- DRAG MAIN
--==================================================

local MainDragging = false
local MainDragStart
local MainStartPosition

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        MainDragging = true

        MainDragStart = input.Position
        MainStartPosition = Main.Position

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not MainDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local Delta =
            input.Position - MainDragStart

        Main.Position = UDim2.new(
            MainStartPosition.X.Scale,
            MainStartPosition.X.Offset + Delta.X,

            MainStartPosition.Y.Scale,
            MainStartPosition.Y.Offset + Delta.Y
        )

    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        MainDragging = false

    end

end)

--==================================================
-- DRAG CIRCLE
--==================================================

local CircleDragging = false
local CircleMoved = false

local CircleStart
local CirclePosition

Circle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        CircleDragging = true
        CircleMoved = false

        CircleStart = input.Position
        CirclePosition = Circle.Position

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not CircleDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local Delta =
            input.Position - CircleStart

        if math.abs(Delta.X) > 6
            or math.abs(Delta.Y) > 6 then

            CircleMoved = true

        end

        Circle.Position = UDim2.new(
            CirclePosition.X.Scale,
            CirclePosition.X.Offset + Delta.X,

            CirclePosition.Y.Scale,
            CirclePosition.Y.Offset + Delta.Y
        )

    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if CircleDragging and not CircleMoved then
            ShowMain()
        end

        CircleDragging = false

    end

end)

--==================================================
-- MOBILE SIZE
--==================================================

pcall(function()

    local Camera = workspace.CurrentCamera

    if Camera and Camera.ViewportSize.X < 600 then

        Main.Size = UDim2.new(0.92, 0, 0, 610)

        Main.Position =
            UDim2.new(0.5, 0, 0.5, 0)

        Main.AnchorPoint =
            Vector2.new(0.5, 0.5)

        Details.Size =
            UDim2.new(0.90, 0, 0, 540)

        Details.Position =
            UDim2.new(0.5, 0, 0.5, 0)

        Details.AnchorPoint =
            Vector2.new(0.5, 0.5)

    end

end)

--==================================================
-- START
--==================================================

RefreshPlayers()

task.wait(0.3)

Notify(
    "NOVA READY",
    "Player monitor initialized",
    true
)

print("[NOVA V4] Loaded successfully. Click a player to see live data.")