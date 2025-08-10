local currentWeather = "CLEAR"
local isMenuOpen = false

local timeElements = {
    {label = "Morning", value = 'set_day'},
    {label = "Afternoon", value = 'set_afternoon'},
    {label = "Evening", value = 'set_night'}
}

local weatherElements = {
    {label = "Clear", value = "CLEAR"},
    {label = "Extra Sunny", value = "EXTRASUNNY"},
    {label = "Clouds", value = "CLOUDS"},
    {label = "Rain", value = "RAIN"},
    {label = "Thunder", value = "THUNDER"},
    {label = "Foggy", value = "FOGGY"},
    {label = "Overcast", value = "OVERCAST"},
    {label = "Snow", value = "SNOW"},
    {label = "Xmas", value = "XMAS"},
}

ESX = nil

local currentHour = 12
local currentMinute = 0
local freezeTime = false

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

AddEventHandler('playerSpawned', function(spawn)
    currentWeather = "CLEAR"
    currentHour = 12
    currentMinute = 0
    freezeTime = true

    PauseClock(true)
    NetworkOverrideClockTime(currentHour, currentMinute, 0)
    SetOverrideWeather(currentWeather)
    SetWeatherTypeNow(currentWeather)
    SetWeatherTypeNowPersist(currentWeather)
    SetWeatherTypePersist(currentWeather)
end)

RegisterCommand(Config.Commands.ChangeTime, function()
    OpenMainMenu()
end)

RegisterCommand(Config.Commands.ChangeWeather, function()
    OpenMainMenu()
end)

function OpenMainMenu()
    ESX.UI.Menu.CloseAll()
    isMenuOpen = true

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_menu', {
        title = Config.MenuLabels.MainMenuTitle,
        align = "left",
        elements = Config.MenuLabels.MainMenuElements
    }, function(data, menu)
        if data.current.value == 'time' then
            OpenTimeMenu()
        elseif data.current.value == 'weather' then
            OpenWeatherMenu()
        end
    end, function(data, menu)
        menu.close()
        isMenuOpen = false
    end)
end

function OpenTimeMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'time_menu', {
        title = Config.MenuLabels.TimeMenuTitle,
        align = "left",
        elements = timeElements
    }, function(data, menu)
        if data.current.value == 'set_day' then
            currentHour = 12
            currentMinute = 0
            freezeTime = true
            ESX.ShowNotification("Time set to: Morning")
        elseif data.current.value == 'set_afternoon' then
            currentHour = 17
            currentMinute = 0
            freezeTime = true
            ESX.ShowNotification("Time set to: Afternoon")
        elseif data.current.value == 'set_night' then
            currentHour = 23
            currentMinute = 45
            freezeTime = true
            ESX.ShowNotification("Time set to: Evening")
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenWeatherMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weather_menu', {
        title = Config.MenuLabels.WeatherMenuTitle,
        align = "left",
        elements = weatherElements
    }, function(data, menu)
        currentWeather = data.current.value
        ESX.ShowNotification("Weather set to: " .. currentWeather)
    end, function(data, menu)
        menu.close()
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if freezeTime then
            PauseClock(true)
            NetworkOverrideClockTime(currentHour, currentMinute, 0)
        else
            PauseClock(false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        SetOverrideWeather(currentWeather)
        SetWeatherTypeNow(currentWeather)
        SetWeatherTypeNowPersist(currentWeather)
        SetWeatherTypePersist(currentWeather)
        SetForcePedFootstepsTracks(false)
        SetForceVehicleTrails(false)
    end
end)
