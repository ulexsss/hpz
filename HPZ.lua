local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear la interfaz flotante (Cartel de Objeto Desconocido)
local gui = Instance.new("ScreenGui")
gui.Name = "TradeVisualSimulator"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(270, 190)
panel.BackgroundColor3 = Color3.fromRGB(20, 29, 38)
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 999 -- Se asegura de quedar por encima de la imagen del juego
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = panel

-- Encabezado
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(55, 75, 88)
header.Text = "Objeto Desconocido"
header.TextColor3 = Color3.new(1, 1, 1)
header.TextSize = 17
header.Font = Enum.Font.GothamBold
header.ZIndex = 1000
header.Parent = panel

-- Información
local info = Instance.new("TextLabel")
info.Position = UDim2.fromOffset(5, 43)
info.Size = UDim2.new(1, -10, 0, 70)
info.BackgroundTransparency = 1
info.Text = "Sin Verificar\n\nValor: ???"
info.TextColor3 = Color3.fromRGB(255, 220, 40)
info.TextSize = 17
info.Font = Enum.Font.GothamBold
info.ZIndex = 1000
info.Parent = panel

-- Mensaje
local description = Instance.new("TextLabel")
description.Position = UDim2.fromOffset(10, 112)
description.Size = UDim2.new(1, -20, 0, 42)
description.BackgroundTransparency = 1
description.TextWrapped = true
description.Text = "La vista previa del objeto no está disponible debido a modificaciones visuales activas."
description.TextColor3 = Color3.fromRGB(220, 220, 220)
description.TextSize = 10
description.ZIndex = 1000
description.Parent = panel

-- Aviso
local warning = Instance.new("TextLabel")
warning.Position = UDim2.fromOffset(5, 143)
warning.Size = UDim2.new(1, -10, 0, 38)
warning.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
warning.Text = "SIMULACIÓN: Si experimentas errores visuales en la oferta, visita la Plaza de intercambio para continuar con seguridad."
warning.TextColor3 = Color3.new(1, 1, 1)
warning.TextSize = 9
warning.TextWrapped = true
warning.Font = Enum.Font.GothamBold
warning.ZIndex = 1000
warning.Parent = panel

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 5)
warningCorner.Parent = warning

local menuActivo = false

-- Alternar activación con la tecla H
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.H then
		menuActivo = not menuActivo
		panel.Visible = menuActivo

		-- Si desactivamos, devolvemos la visibilidad a las imágenes del juego
		if not menuActivo then
			for _, guiObj in ipairs(playerGui:GetDescendants()) do
				if guiObj:IsA("ImageLabel") and guiObj.Parent ~= panel then
					guiObj.ImageTransparency = 0
				end
			end
		end
	end
end)

-- Bucle constante para seguir al mouse y ocultar la imagen del brainrot bajo el cursor
RunService.RenderStepped:Connect(function()
	if not menuActivo then return end

	local mousePosition = UserInputService:GetMouseLocation()

	-- Buscar elementos gráficos bajo la posición del cursor
	local objectsAtMouse = playerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y)

	for _, obj in ipairs(objectsAtMouse) do
		-- Ocultar imágenes del brainrot/ítem (ImageLabel o ViewportFrame si es modelo 3D)
		if (obj:IsA("ImageLabel") or obj:IsA("ViewportFrame")) and obj ~= header and obj.Parent ~= panel then
			obj.ImageTransparency = 1
		end
		
		-- Si la imagen está dentro de una tarjeta/marco del juego, ocultamos sus hijos tipo imagen
		if obj:IsA("Frame") and obj ~= panel then
			for _, child in ipairs(obj:GetDescendants()) do
				if child:IsA("ImageLabel") or child:IsA("ViewportFrame") then
					child.ImageTransparency = 1
				end
			end
		end
	end

	-- Posicionar el cartel de "Objeto Desconocido" cubriendo la zona del cursor
	local x = math.clamp(mousePosition.X + 10, 0, workspace.CurrentCamera.ViewportSize.X - 270)
	local y = math.clamp(mousePosition.Y + 10, 0, workspace.CurrentCamera.ViewportSize.Y - 190)

	panel.Position = UDim2.fromOffset(x, y)
end)
