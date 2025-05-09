local displayingUI = false
local timeoutThread = nil

-- Function to ensure NUI focus is properly reset
function ResetNUIFocus()
    SetNuiFocus(false, false)
    displayingUI = false
    
    -- Clear any existing timeout thread
    if timeoutThread then
        timeoutThread = nil
    end
end

-- Function to toggle UI visibility with better error handling
function ToggleGenderUI(show)
    -- Always reset focus first to clear any stuck state
    ResetNUIFocus()
    
    if show then
        -- Set focus for UI
        SetNuiFocus(true, true)
        displayingUI = true
        
        -- Ensure the UI is properly shown with config
        SendNUIMessage({
            type = "toggleUI",
            display = true,
            config = Config
        })
        
        -- Only create timeout if user interaction is required
        -- Commented out to prevent unwanted auto-closing
        -- The UI will stay open until user makes a selection or closes it manually
        
        -- If you want to keep the timeout but make it longer:
        timeoutThread = true
        Citizen.CreateThread(function()
            local threadId = timeoutThread
            Citizen.Wait(300000) -- 5 minutes timeout (increased from 20 seconds)
            
            -- Only execute if this is still the active timeout thread
            if timeoutThread == threadId and displayingUI then
                -- Force close if UI is still open after timeout
                ResetNUIFocus()
                SendNUIMessage({
                    type = "toggleUI",
                    display = false
                })
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"Gender Select", "UI was closed due to inactivity"}
                })
            end
        end)
    else
        -- Hide UI and reset focus
        SendNUIMessage({
            type = "toggleUI",
            display = false
        })
        ResetNUIFocus()
    end
end

-- Command to open gender selection UI - reduced resource usage
RegisterCommand('gender', function()
    -- Check if UI is already open to prevent issues
    if displayingUI then
        -- Force close the UI if it's already open
        ToggleGenderUI(false)
        Citizen.Wait(200) -- Shorter delay to ensure UI is closed properly
    end
    
    -- Now open the UI
    ToggleGenderUI(true)
end, false)

-- Function to safely set player model - optimized for performance
function SetModelSafe(model)
    -- Properly convert model to hash if it's a string
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    
    -- Always release the current model first to free memory
    local currentPed = PlayerPedId()
    local currentModel = GetEntityModel(currentPed)
    SetModelAsNoLongerNeeded(currentModel)
    
    -- Request the model
    RequestModel(modelHash)
    
    -- Create a timeout with less frequent checks
    local timeoutTimer = GetGameTimer() + 8000 -- 8 seconds timeout
    
    -- Wait for model to load with less frequent checks
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(150) -- Increased wait time to reduce CPU usage
        
        -- Break if timeout
        if GetGameTimer() > timeoutTimer then
            return false
        end
    end
    
    -- Store position and heading before changing model
    local x, y, z = table.unpack(GetEntityCoords(currentPed))
    local heading = GetEntityHeading(currentPed)
    
    -- Set the player model
    SetPlayerModel(PlayerId(), modelHash)
    
    -- Release the model immediately to free memory
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Get the new ped - only once to reduce overhead
    local newPed = PlayerPedId()
    
    -- Set the position to prevent teleporting
    SetEntityCoords(newPed, x, y, z, false, false, false, false)
    SetEntityHeading(newPed, heading)
    
    -- Check if model change was successful
    return (GetEntityModel(newPed) == modelHash)
end

-- Apply initial clothing to prevent naked character - using config
function ApplyDefaultClothing(gender)
    local ped = PlayerPedId()
    
    -- Store position before applying clothing
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local heading = GetEntityHeading(ped)
    
    -- Clear any existing variations
    ClearAllPedProps(ped)
    ClearPedDecorations(ped)
    ClearPedFacialDecorations(ped)
    
    -- Reset facial features and appearance
    for i = 0, 20 do
        SetPedFaceFeature(ped, i, 0.0)
    end
    
    -- Get clothing configuration for gender
    local genderConfig = gender == "male" and Config.Clothing.male or Config.Clothing.female
    
    -- Apply component variations from config
    for componentId, component in pairs(genderConfig.components) do
        SetPedComponentVariation(ped, componentId, component.drawable, component.texture, 0)
    end
    
    -- Apply prop variations from config
    for propId, prop in pairs(genderConfig.props) do
        if prop.drawable == -1 then
            ClearPedProp(ped, propId)
        else
            SetPedPropIndex(ped, propId, prop.drawable, prop.texture, true)
        end
    end
    
    -- Health and armor - single call
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 0)
    
    -- Force the model to refresh completely
    NetworkResurrectLocalPlayer(x, y, z, heading, true, false)
    SetPlayerInvincible(PlayerId(), false)
end

-- NUI Callback when gender is selected - optimized
RegisterNUICallback('selectGender', function(data, cb)
    -- Always respond to the callback immediately to prevent NUI hanging
    cb({status = "success"})
    
    -- Close UI first to prevent interactions during model load
    ToggleGenderUI(false)
    
    -- Make sure we have valid data
    if not data or not data.gender then
        return
    end
    
    -- Use a single thread for the entire model change process
    Citizen.CreateThread(function()
        local gender = data.gender -- 'male' or 'female'
        local modelName = (gender == "male") and "mp_m_freemode_01" or "mp_f_freemode_01"
        
        -- Save position once
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        -- Change model using our optimized function
        local success = SetModelSafe(modelName)
        
        if success then
            -- Apply clothing with reduced delay
            Citizen.Wait(300)
            ApplyDefaultClothing(gender)
            
            -- Restore position and heading
            local newPed = PlayerPedId()
            SetEntityCoords(newPed, coords, false, false, false, false)
            SetEntityHeading(newPed, heading)
            
            -- Notify the server about the gender change
            TriggerServerEvent('gender_select:genderChanged', gender)
        end
    end)
end)

-- NUI Callback when UI is closed - optimized
RegisterNUICallback('closeUI', function(data, cb)
    cb({status = "success"})
    ToggleGenderUI(false)
end)

-- Handle ESC key only when UI is displayed - much better performance
Citizen.CreateThread(function()
    local escControlIndex = 177 -- ESC key
    
    while true do
        -- Only check for key presses if UI is actually open
        if displayingUI then
            if IsControlJustReleased(0, escControlIndex) then
                ToggleGenderUI(false)
            end
            Citizen.Wait(10) -- Short wait when UI is open
        else
            Citizen.Wait(500) -- Long wait when UI is closed (saves CPU)
        end
    end
end)

-- Add an event handler for resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Reset NUI focus when resource starts
        ResetNUIFocus()
    end
end)

-- Add a global error handler
AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Reset NUI focus if resource stops
        SetNuiFocus(false, false)
    end
end)
