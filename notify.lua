local lib = {}
local b = {drawings = {}, hidden = {}, preloaded_images = {}}
do
    function lib:Draw(c, d, e, f)
        f = f or false
        local g = Drawing.new(c)
        local h = {}
        rawset(h, "__OBJECT_EXIST", true)
        setmetatable(
            h,
            {__index = function(self, i)
                    if rawget(h, "__OBJECT_EXIST") then
                        return g[i]
                    end
                end, __newindex = function(self, i, j)
                    if rawget(h, "__OBJECT_EXIST") then
                        g[i] = j
                        if i == "Position" then
                            for k, l in pairs(rawget(h, "children")) do
                                l.Position = h.Position + l.GetOffset()
                            end
                        end
                    end
                end}
        )
        rawset(
            h,
            "Remove",
            function()
                if rawget(h, "__OBJECT_EXIST") then
                    g:Remove()
                    rawset(h, "__OBJECT_EXIST", false)
                end
            end
        )
        rawset(
            h,
            "GetType",
            function()
                return c
            end
        )
        rawset(
            h,
            "GetOffset",
            function()
                return d or Vector2.new()
            end
        )
        rawset(
            h,
            "SetOffset",
            function(m)
                d = m or Vector2.new()
                h.Position = e.Parent.Position + h.GetOffset()
            end
        )
        rawset(h, "children", {})
        rawset(
            h,
            "Lerp",
            function(n, o)
                if not rawget(h, "__OBJECT_EXIST") then
                    return
                end
                local p = 0
                local q = {}
                local r
                for s, l in pairs(n) do
                    q[s] = h[s]
                end
                local function t()
                    for s, l in pairs(n) do
                        h[s] = (l - q[s]) * p / o + q[s]
                    end
                end
                r =
                    rs.RenderStepped:Connect(
                    function(u)
                        if p < o then
                            p = p + u
                            t()
                        else
                            r:Disconnect()
                        end
                    end
                )
                table.insert(b.connections, r)
            end
        )
        local v = {["Parent"] = function(w)
                table.insert(rawget(w, "children"), h)
            end}
        if c == "Square" then
            h.Thickness = 1
            h.Filled = true
        end
        h.Visible = true
        if e ~= nil then
            for i, j in pairs(e) do
                if v[i] == nil then
                    h[i] = j
                else
                    v[i](j)
                end
            end
            if e.Parent then
                h.Position = e.Parent.Position + h.GetOffset()
            end
            if e.Parent and e.From then
                h.From = e.Parent.Position + h.GetOffset()
            end
            if e.Parent and e.To then
                h.To = e.Parent.Position + h.GetOffset()
            end
        end
        if not f then
            table.insert(b.drawings, {h, e["Transparency"] or 1})
        else
            table.insert(b.hidden, {h, e["Transparency"] or 1})
        end
        return h
    end
    function lib:ScreenSize()
        return workspace.CurrentCamera.ViewportSize
    end
    function lib:RoundVector(x)
        return Vector2.new(math.floor(x.X), math.floor(x.Y))
    end
    function lib:MouseOverDrawing(w)
        local y = {w.Position, w.Position + w.Size}
        local z = uis:GetMouseLocation()
        return z.X >= y[1].X and z.Y >= y[1].Y and z.X <= y[2].X and z.Y <= y[2].Y
    end
    function lib:MouseOverPosition(y)
        local z = uis:GetMouseLocation()
        return z.X >= y[1].X and z.Y >= y[1].Y and z.X <= y[2].X and z.Y <= y[2].Y
    end
    function lib:Image(w, A)
        local B = b.preloaded_images[A] or game:HttpGet(A)
        if b.preloaded_images[A] == nil then
            b.preloaded_images[A] = B
        end
        w.Data = B
    end
    function lib:Connect(r, C)
        local D = r:Connect(C)
        table.insert(b.connections, D)
        return D
    end
end

function drawingTween(Target,newPosition,easeStyle,easeDirection,easeTime)
   local x,y=Instance.new("IntValue"),Instance.new("IntValue")
   x.Value=Target.Position.X;y.Value=Target.Position.Y
   local ti=TweenInfo.new(easeTime,Enum.EasingStyle[easeStyle],Enum.EasingDirection[easeDirection])
   game:GetService("TweenService"):Create(x,ti,{Value=newPosition.X}):Play()
   game:GetService("TweenService"):Create(y,ti,{Value=newPosition.Y}):Play()
   x:GetPropertyChangedSignal("Value"):Connect(function()Target.Position=Vector2.new(x.Value,y.Value)end)
   y:GetPropertyChangedSignal("Value"):Connect(function()Target.Position=Vector2.new(x.Value,y.Value)end)
end

local notifications = {
    accent = Color3.fromRGB(255,255,255)
}
function notify(text,delay)
local notification_toggled = false
local background_frame = lib:Draw("Square", nil,{
    Color = Color3.fromRGB(22, 13, 13),
    Size = Vector2.new(150,25),
    Position = lib:RoundVector(lib:ScreenSize()/2) - Vector2.new(1000,280)
})

local background_frame_outline = lib:Draw("Square",Vector2.new(-1,-1),{
    Color = notifications.accent,
      Size =  background_frame.Size + Vector2.new(2, 2) , Filled =false,Position= background_frame.Position  })


local text_name = lib:Draw("Text", nil, {
    Color = Color3.fromRGB(255,255,255),
    Font = 2,
    Text = text,
    Size = 15,
    Center = true
})

drawingTween(background_frame,lib:RoundVector(lib:ScreenSize()/2) - Vector2.new(840,280),"Sine","InOut",delay)
 notification_toggled = true

game:GetService("RunService").RenderStepped:Connect(function()
            if  notification_toggled == true then
    background_frame_outline.Position = background_frame.Position
            task.wait()
    text_name.Position = background_frame.Position + Vector2.new(75,5)
                end
             notification_toggled = false
 end)


task.wait(delay)
background_frame_outline:Remove()
background_frame:Remove()
text_name:Remove()

 notification_toggled = true
end
