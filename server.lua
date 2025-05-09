-- Event when a player changes their gender
RegisterNetEvent('gender_select:genderChanged')
AddEventHandler('gender_select:genderChanged', function(gender)
    local source = source
    local playerName = GetPlayerName(source)
    
    -- Inform everyone about the gender change (optional)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(41, 41, 41, 0.6); border-radius: 3px;"><b>{0}</b> has changed their gender to {1}</div>',
        args = { playerName, gender }
    })
    
    -- You could save this to a database here if needed
end)
