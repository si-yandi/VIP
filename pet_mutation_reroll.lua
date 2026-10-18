repeat task.wait(7) until game:IsLoaded()

local   Players = game:GetService("Players")
local   LocalPlayer = Players.LocalPlayer
local   TeleportService = game:GetService("TeleportService")
local   ReplicatedStorage = game:GetService("ReplicatedStorage")
local   Workspace = game:GetService("Workspace")
local   HttpService = game:GetService("HttpService")

local   MAX_VERSION = 1681
local   mutation_wanted = "Rainbow"
local   PLACE_ID = game.PlaceId
local   cam = Workspace.CurrentCamera
local   remote = ReplicatedStorage.GameEvents.PetMutationMachineService_RE
local   webhook_url = "https://discord.com/api/webhooks/..." -- replace this

local function force_rejoin()
      local success = pcall(function()
            TeleportService:Teleport(PLACE_ID, LocalPlayer)
      end)
      if not success then
            LocalPlayer:Kick("Unable to rejoin this server")
      end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VersionNotifier"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local indicator = Instance.new("Frame")
indicator.Size = UDim2.new(0, 20, 0, 20)
indicator.Position = UDim2.new(0, 10, 0, 10)
indicator.BackgroundColor3 = Color3.new(1, 0, 0)
indicator.BorderSizePixel = 0
indicator.Parent = screenGui

if game.PlaceVersion > MAX_VERSION then
      indicator.BackgroundColor3 = Color3.new(1, 0, 0)
      force_rejoin()
      return
else
      indicator.BackgroundColor3 = Color3.new(0, 1, 0)
end

local function wait_for_load()
      while not LocalPlayer:GetAttribute("Finished_Loading") do task.wait() end
      while not LocalPlayer:GetAttribute("DataFullyLoaded") do task.wait() end
      while not LocalPlayer:GetAttribute("Setup_Finished") do task.wait() end
      ReplicatedStorage.GameEvents.Finish_Loading:FireServer()
      ReplicatedStorage.GameEvents.LoadScreenEvent:FireServer(LocalPlayer)
      while not LocalPlayer:GetAttribute("Loading_Screen_Finished") do
            task.wait()
      end
      task.wait(1)
end

if not LocalPlayer:GetAttribute("Loading_Screen_Finished") then
      wait_for_load()
end

local function send_hook(mutation)
      if not webhook_url or webhook_url == "" or webhook_url:find("...", 1, true) then return end
      local data = {
            username = "toes hub",
            avatar_url = "https://cdn.discordapp.com/attachments/1390989755327578163/1402302319269253251/74f64afff9748d2c64d01b021ffcf288.jpg",
            embeds = {{
                  title = "**🐾 Mutation Rolled 🐾**",
                  description = string.format("🎨 **Mutation:** `%s`", mutation),
                  type = "rich",
                  color = 0x9b59b6,
                  footer = {
                        text = "Auto Reroll",
                        icon_url = "https://cdn.discordapp.com/attachments/1390989755327578163/1402302319269253251/74f64afff9748d2c64d01b021ffcf288.jpg"
                  }
            }}
      }
      local payload = {
            Url = webhook_url,
            Body = HttpService:JSONEncode(data),
            Method = "POST",
            Headers = {["content-type"] = "application/json"}
      }
      pcall(function()
            local req = http_request or request or HttpPost or (syn and
syn.request)
            if req then req(payload) end
      end)
end

local all_mutations = {
      "Shiny", "Inverted", "Frozen", "Windy", "Mega", "Tiny", "Golden",
      "IronSkin", "Rainbow", "Shocked", "Radiant", "Ascended"
}

local function check_pet(pet)
      if pet:IsA("Model") and pet.Parent == cam then
            local start = tick()
            local found = nil
            while tick() - start < 0.2 do
                  for _, mutation in ipairs(all_mutations) do
                        if pet:GetAttribute(mutation) then
                              found = mutation
                              break
                        end
                  end
                  if found then break end
                  task.wait()
            end
            if found == mutation_wanted then
                  send_hook(found)
                  return true
            else
                  force_rejoin()
                  return false
            end
      end
      return false
end

local conn
conn = cam.DescendantAdded:Connect(function(child)
      if check_pet(child) then
            conn:Disconnect()
      end
end)

remote:FireServer("ClaimMutatedPet")

