local painel = script.Parent.MainPanel
local janelaTrade = script.Parent.TradeWindow
local inventario = janelaTrade.PlayerOffer.ItemsContainer

-- Lendo os espaços vazios do seu Explorador (TargetOffer -> ItemsContainer)
local mesaTuOferta = janelaTrade.TargetOffer:FindFirstChild("ItemsContainer")

-- ==========================================
-- 1. SISTEMA DE ABAS (TROCANDO DE TELA)
-- ==========================================
painel.PlayersTab.MouseButton1Click:Connect(function()
	painel.ControlView.Visible = false
	painel.PlayersView.Visible = true
end)

painel.ControlTab.MouseButton1Click:Connect(function()
	painel.PlayersView.Visible = false
	painel.ControlView.Visible = true
end)

-- ==========================================
-- 2. SISTEMA DA LISTA DE JOGADORES (BLOCK)
-- ==========================================
local listaJogadores = painel.PlayersView
local moldeJogador = listaJogadores:FindFirstChild("PlayerTemplate")

if moldeJogador then
	local function criarJogadorNaLista(nomeJogador)
		local novaLinha = moldeJogador:Clone()
		novaLinha.Name = nomeJogador
		novaLinha.NomeLabel.Text = nomeJogador
		novaLinha.Visible = true
		novaLinha.Parent = listaJogadores

		novaLinha.BlockBtn.MouseButton1Click:Connect(function()
			print("[SISTEMA] Você bloqueou e removeu: " .. nomeJogador)
			novaLinha:Destroy() 
		end)
	end

	local nomesTeste = {"thomas70438", "coolkid452069", "Gabinha846"}
	for _, nome in pairs(nomesTeste) do
		criarJogadorNaLista(nome)
	end
end

-- ==========================================
-- 3. INVENTÁRIO: Sincroniza Nomes das Facas
-- ==========================================
for _, slot in pairs(inventario:GetChildren()) do
	if slot:IsA("Frame") then
		local etiqueta = slot:FindFirstChildOfClass("TextLabel")
		if etiqueta then
			etiqueta.Text = etiqueta.Name 
		end
	end
end

-- ==========================================
-- 4. START TRADE (Problema Resolvido!)
-- ==========================================
painel.ControlView.StartTradeBtn.MouseButton1Click:Connect(function()
	-- Procura exatamente pelo nome (Guilherme) que você colocou no Explorador
	local etiquetaNome = janelaTrade.TargetOffer:FindFirstChild("(Guilherme)")
	if etiquetaNome then
		etiquetaNome.Text = "(" .. painel.ControlView.TargetUsername.Text .. ")"
	end

	painel.Visible = false
	janelaTrade.Visible = true
end)

-- Botão de Fechar a Trade (X) se houver
local btnClose = janelaTrade:FindFirstChild("CloseBtn")
if btnClose then
	btnClose.MouseButton1Click:Connect(function()
		janelaTrade.Visible = false
		painel.Visible = true
	end)
end

-- ==========================================
-- 5. LÓGICA DE CLICAR NA ARMA (IDA E VOLTA)
-- ==========================================
for _, slot in pairs(inventario:GetChildren()) do
	local arma = slot:FindFirstChildOfClass("ImageButton")
	if arma then
		local slotOriginal = slot

		arma.MouseButton1Click:Connect(function()
			-- Se a faca está no inventário e a mesa foi encontrada
			if arma.Parent == slotOriginal and mesaTuOferta then
				for _, espaco in pairs(mesaTuOferta:GetChildren()) do
					if espaco.Name == "Frame" and not espaco:FindFirstChildOfClass("ImageButton") then
						arma.Parent = espaco
						break
					end
				end
				-- Se a faca está na mesa, ela volta
			else
				arma.Parent = slotOriginal
			end
		end)
	end
end

-- ==========================================
-- 6. BOTÃO DECLINAR (Devolver Armas)
-- ==========================================
-- Ele acha o botão independente de onde você colocou ele
local btnDeclinar = janelaTrade:FindFirstChild("DeclineBtn") or janelaTrade.TargetOffer:FindFirstChild("DeclineBtn")

if btnDeclinar then
	btnDeclinar.MouseButton1Click:Connect(function() 
		if mesaTuOferta then
			for _, espaco in pairs(mesaTuOferta:GetChildren()) do
				local faca = espaco:FindFirstChildOfClass("ImageButton")
				if faca then
					for _, slotInv in pairs(inventario:GetChildren()) do
						if slotInv:IsA("Frame") and not slotInv:FindFirstChildOfClass("ImageButton") then
							faca.Parent = slotInv
							break
						end
					end
				end
			end
		end
		janelaTrade.Visible = false
		painel.Visible = true
	end)
end
local main = script.Parent:WaitForChild("MainContainer")
local leftPanel = main:WaitForChild("LeftPanel")
local rightPanel = main:WaitForChild("RightPanel")
local inventory = leftPanel:WaitForChild("InvBg"):WaitForChild("InventoryContainer")
local rBg = rightPanel:WaitForChild("RBg")
local tuOferta = rBg:WaitForChild("TuOfertaContainer")

local aceptarBtn = rBg:WaitForChild("AceptarBtn")
local declinarBtn = rBg:WaitForChild("DeclinarBtn")
local statusLabel = rBg:WaitForChild("StatusLabel")

-- Lê o UIListLayout que está no SEU código
local listLayout = tuOferta:WaitForChild("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Numera as caixas originais
local slotIndex = 1
for _, slot in ipairs(tuOferta:GetChildren()) do
	if slot.Name == "EmptySlot" then
		slot.LayoutOrder = slotIndex
		slotIndex = slotIndex + 1
	end
end

-- ==========================================
-- 1. SISTEMA DE MOVER ARMAS (Substituindo os quadrados perfeitamente)
-- ==========================================
for _, item in ipairs(inventory:GetChildren()) do
	if item:IsA("ImageButton") and item.Name == "TradeItem" then

		item.MouseButton1Click:Connect(function()
			if item.Parent == inventory then
				local itemsInTrade = 0
				local targetSlot = nil
				local lowestOrder = 999

				for _, child in ipairs(tuOferta:GetChildren()) do
					if child.Name == "TradeItem" then
						itemsInTrade = itemsInTrade + 1
					elseif child.Name == "EmptySlot" and child.Visible == true then
						if child.LayoutOrder < lowestOrder then
							lowestOrder = child.LayoutOrder
							targetSlot = child
						end
					end
				end

				if itemsInTrade < 4 and targetSlot then
					targetSlot.Visible = false
					item.LayoutOrder = targetSlot.LayoutOrder
					item.Size = UDim2.new(0, 86, 0, 112) -- Fica do tamanho exato da caixa vazia
					item.Parent = tuOferta
				end

			elseif item.Parent == tuOferta then
				local occupiedOrder = item.LayoutOrder
				item.Parent = inventory
				-- (O tamanho volta ao normal automaticamente porque o Inventário usa grade)

				for _, child in ipairs(tuOferta:GetChildren()) do
					if child.Name == "EmptySlot" and child.LayoutOrder == occupiedOrder then
						child.Visible = true
						break
					end
				end
			end
		end)
	end
end

-- ==========================================
-- 2. ANIMAÇÃO DE CONTAGEM DO ACEPTAR
-- ==========================================
local estadoAceptar = 0 
local contagemAtiva = false

aceptarBtn.MouseButton1Click:Connect(function()
	if estadoAceptar == 0 then
		-- Inicia a contagem
		estadoAceptar = 1
		contagemAtiva = true
		aceptarBtn.Visible = false
		statusLabel.Visible = true
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

		task.spawn(function()
			for i = 5, 1, -1 do
				if not contagemAtiva then break end
				statusLabel.Text = "Por favor espera (" .. i .. ") antes de aceptar."
				task.wait(1)
			end

			if contagemAtiva then
				estadoAceptar = 2
				statusLabel.Visible = false
				aceptarBtn.Text = "¿CONFIRMAR?"
				aceptarBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
				aceptarBtn.Visible = true
			end
		end)

	elseif estadoAceptar == 2 then
		-- Confirma
		estadoAceptar = 3
		statusLabel.Text = "USTED HA ACEPTADO."
		statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
		statusLabel.Visible = true

		aceptarBtn.Text = "CANCELAR"
		aceptarBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)

	elseif estadoAceptar == 3 then
		-- Cancela (Volta ao início)
		estadoAceptar = 0
		contagemAtiva = false
		statusLabel.Visible = false
		aceptarBtn.Text = "ACEPTAR"
		aceptarBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
	end
end)

declinarBtn.MouseButton1Click:Connect(function()
	estadoAceptar = 0
	contagemAtiva = false
	statusLabel.Visible = false
	aceptarBtn.Visible = true
	aceptarBtn.Text = "ACEPTAR"
	aceptarBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
end)