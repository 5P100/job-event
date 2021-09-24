
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	Citizen.Wait(0)
    end  
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    Citizen.Wait(5000)
end)

------------------------- Blips --------------------------

local blips = {
    {title="Event", colour=1, id=326, x = 2521.4799, y = 1994.1451, z = 22.4086},
}
	  
Citizen.CreateThread(function()    
	Citizen.Wait(0)    
  local bool = true     
  if bool then    
		 for _, info in pairs(blips) do      
			 info.blip = AddBlipForCoord(info.x, info.y, info.z)
						 SetBlipSprite(info.blip, info.id)
						 SetBlipDisplay(info.blip, 4)
						 SetBlipScale(info.blip, 1.1)
						 SetBlipColour(info.blip, info.colour)
						 SetBlipAsShortRange(info.blip, true)
						 BeginTextCommandSetBlipName("STRING")
						 AddTextComponentString(info.title)
						 EndTextCommandSetBlipName(info.blip)
		 end        
	 bool = false     
   end
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- SCRIPT -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

function OpenBillingMenu()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'facture',
        {
            title = 'Donner une facture'
        },
        function(data, menu)

            local amount = tonumber(data.value)

            if amount == nil or amount <= 0 then
                ESX.ShowNotification('Montant invalide')
            else
                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification('Pas de joueurs proche')
                else
                    local playerPed        = GetPlayerPed(-1)

                    Citizen.CreateThread(function()
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                        Citizen.Wait(5000)
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_événement', 'Evénement', amount)
                        ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
                    end)
                end
            end
        end,
        function(data, menu)
            menu.close()
    end)
end

------ Coffre

function OpenGetStockspharmaMenu()
	ESX.TriggerServerCallback('job-event:prendreitem', function(items)
		local elements = {}

		for i=1, #items, 1 do
            table.insert(elements, {
                label = 'x' .. items[i].count .. ' ' .. items[i].label,
                value = items[i].name
            })
        end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'police',
			title    = 'stockage',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                css      = 'police',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('job-event:prendreitems', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStockspharmaMenu()
	ESX.TriggerServerCallback('job-event:inventairejoueur', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'job-event',
			title    = 'inventaire',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                css      = 'job-event',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('job-event:stockitem', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---------------------------------------------- Menu F6 ----------------------------------------------------------

local Fonctions = {
    'Réparer',
    'Nettoyer'
}
local menuf6 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Menu Event" },
    Data = { currentMenu = "by 5%#0002 and RevengeBack_#6969", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
        local slide = btn.slidenum 

            if btn.name == "Facturation" then   
                OpenBillingMenu()
            elseif btn.name == "Actions Patron" and PlayerData.job.grade_name == 'menuactions' then
                self:CloseMenu(true)
                TriggerEvent('esx_society:openmenuactionsMenu', 'event', function(data, menu)end)
            elseif btn.name == "~r~Fermer le menu" then 
                self:CloseMenu(true)  
            elseif btn.name == "Annonce" then
                OpenMenu("annonce")
            elseif btn.name == "Fonctions" then
                OpenMenu("Fonction")
            elseif btn.name == "Ouvert" then
                TriggerServerEvent("eventouvert")
            elseif btn.name == "Fermer" then
                TriggerServerEvent("eventfermer")
            elseif btn.name == "Fermer le menu" then
                CloseMenu()
            elseif btn.name == "Véhicule" and slide == 1 then
                RepairVeh()
            elseif btn.name == "Véhicule" and slide == 2 then
                ClearVeh()
            end 
    end,
},
    Menu = {
        ["by 5%#0002 and RevengeBack_#6969"] = {
            b = {
                {name = "Facturation", ask = '>>>', askX = true},
                {name = "Annonce", ask = '>>>', askX = true},
                {name = "Fonctions", ask = '>>>', askX = true},
            }
        },
        ["annonce"] = {
            b = {
                {name = "Ouvert", ask = '>>>', askX = true},
                {name = "Fermer", ask = '>>>', askX = true},
            }
        },
        ["Fonction"] = {
                    b = {
                {name = "Véhicule", slidemax = Fonctions},
            }
        }
    }
} 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(0,167) and PlayerData.job and PlayerData.job.name == 'event' then
			CreateMenu(menuf6)
		end
	end
end)

---------------------------------------------- Coffre -----------------------------------------------------------


local coffre = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 0, 0}, Title = "Frigo" },
    Data = { currentMenu = "Coffre :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Stock" then   
                OpenMenu("stock")
            elseif btn.name == "Coffre" then
                OpenMenu("coffre")
            elseif btn.name == "Prendre" then
                OpenGetStockspharmaMenu()
                CloseMenu()
            elseif btn.name == "Deposer" then
                OpenPutStockspharmaMenu()
                CloseMenu()
            elseif btn.name == "Pain" then
                TriggerServerEvent('prendre:pain')
                CloseMenu()
            elseif btn.name == "Eau" then
                TriggerServerEvent("prendre:eau")
                CloseMenu()
            elseif btn.name == "Fermer le menu" then
                CloseMenu()
            end 
    end,
},
    Menu = {
        ["Coffre :"] = {
            b = {
                {name = "Stock", ask = '>>>', askX = true},
                {name = "Coffre", ask = '>>>', askX = true},
            }
        },
        ["coffre"] = {
            b = {
                {name = "Prendre", ask = '>>>', askX = true},
                {name = "Deposer", ask = '>>>', askX = true},
            }
        },
        ["stock"] = {
            b = {
                {name = "Pain", ask = '>>>', askX = true},
                {name = "Eau", ask = '>>>', askX = true},
            }
        }
    }
} 

local stock = { 
    {x=2513.9602, y=2023.9487, z=22.4086} --Position coffre
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(stock) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, stock[k].x, stock[k].y, stock[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'event'  then
                DrawMarker(22, 2513.9602, 2023.9487, 22.4086, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.2, 0.1, 255, 0, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~r~Appuyez sur ~INPUT_PICKUP~ pour accéder au frigo")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(coffre)
         end end end end end)  

---------------------------------------------- GARAGE -----------------------------------------------------------

local voiture = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 0, 0}, Title = "GARAGE event" },
    Data = { currentMenu = "Liste des véhicules :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "4x4" then   
                spawnCar("brawler")
            elseif btn.name == "moto" then
                spawnCar("sanchez")
            end 
    end,
},
    Menu = {
        ["Liste des véhicules :"] = {
            b = {
                {name = "4x4", ask = '>>', askX = true},
                {name = "moto", ask = '>>', askX = true},
            }
        }
    }
} 


function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)   
    end


    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, 2521.4799, 1994.1451, 20.0042, 183.4673, true, false)   ---- spawn du vehicule (position)
    ESX.ShowNotification('~r~Garage Vous avez sorti un/une'..GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))..'')
    TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)
    SetEntityAsNoLongerNeeded(vehicle)
    SetVehicleNumberPlateText(vehicle, "event")





end 

local garageevent = { 
    {x=2523.6376, y=1999.7707, z=21.0071} -- Point pour sortir le vehicule
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(garageevent) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garageevent[k].x, garageevent[k].y, garageevent[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'event'  then
                DrawMarker(22, 2523.6376, 1999.7707, 21.0071, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.5, 0.1, 255, 0, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~r~Appuyez sur ~INPUT_PICKUP~ pour accéder au garage")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(voiture)
         end end end end end)   

-------------------------------------------------------- Suppression -------------------------------------------------------
local range = { 
    {x=2521.4799, y=1994.1451, z=20.0042} -- Suppression pos
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(range) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, range[k].x, range[k].y, range[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'event'  then
                DrawMarker(22, 2521.4799, 1994.1451, 20.0042, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.5, 0.1, 255, 0, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour ranger ton vehicule~s~")
                if IsControlJustPressed(1,38) then 			
                    TriggerEvent('esx:deleteVehicle')
         end end end end end)

-----------------------------Bossmenu------------------------------------------------------------------------
function OpenBossMenu()
local boss = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 0, 0}, Title = "Actions Boss" },
    Data = { currentMenu = "Boss", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)


        if btn.name == "action" then   
            OpenMenu("Action")
        elseif btn.name == "action boss" then   
            TriggerEvent('esx_society:openBossMenu', 'event', function(data, menu) menu.close()end)
            self:CloseMenu(force)
        end 
    end,
},

    Menu = {
        ["Boss"] = {
            b = {
                {name = "action", ask = '>>>', askX = true},
            }
        },
        ["Action"] = {
            b = {
                {name = "action boss", ask = '>>>', askX = true},
            }
        }
    }
}

CreateMenu(boss)
end


local boss = { 
    {x=2503.6733, y=2021.7788, z=22.3965} 
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(boss) do                                                            
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false) --x--------y-------z--
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, boss[k].x, boss[k].y, boss[k].z)
        if dist <= 1.8 and PlayerData.job and PlayerData.job.name == 'event' and PlayerData.job.grade_name == 'boss' then
            DrawMarker(22, 2503.6733, 2021.7788, 22.3965, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.5, 0.1, 255, 0, 0, 255, 0, 1, 2, 0, nil, nil, 0)
            ESX.ShowHelpNotification("~r~Appuyez sur ~INPUT_PICKUP~ pour acceder aux actions de la societé~s~.")
            if IsControlJustPressed(1,51) then 
                OpenBossMenu()
        end end end end end)


------------------vestiaire------------------------------------------------------------------------

local vestiaires = { 
    {x=2518.0212, y=2014.8576, z=21.0072} 
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(vestiaires) do                                                            
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false) --x--------y-------z--
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, vestiaires[k].x, vestiaires[k].y, vestiaires[k].z)
        if dist <= 1.8 and PlayerData.job and PlayerData.job.name == 'event' then
            DrawMarker(22, 2518.0212, 2014.8576, 21.0072, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.5, 0.1, 255, 0, 0, 255, 0, 1, 2, 0, nil, nil, 0)
            ESX.ShowHelpNotification("~r~Appuyez sur ~INPUT_PICKUP~ pour acceder aux vestiaires.")
            if IsControlJustPressed(1,51) then 
                OpenVestiairesMenu()
        end end end end end)


function OpenVestiairesMenu()
local slideclothes = {
    "Tenue Evenement",
    "Tenue Civil"
}
local vestiaires = {
        Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 0, 0}, Title = "Vestiaires" },
        Data = { currentMenu = "Vestiaires", "Vetements"},
        Events = {
            onSelected = function(self, _, btn, PMenu, menuData, result)
            local slide = btn.slidenum

            if btn.name == "Tenues" then   
                OpenMenu("Vetements dispo")
            elseif slide == 2 and btn.name == "Tenues Dispo" then   
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
				ESX.ShowAdvancedNotification("Evenement", "~h~Vestiaires~s~", "Vous avez remis votre tenue.", "CHAR_MP_BIKER_MECHANIC", 1)
				self:CloseMenu(true)
            elseif slide == 1 and btn.name == "Tenues Dispo" then
                ClothesEvent()
                self:CloseMenu(force)
            end
           
        end,
},
    
    Menu = {
        ["Vestiaires"] = {
            b = {
                {name = "Tenues", Description = "~g~Voir les tenues dispo", ask = '>>>', askX = true},
            }
        },
        ["Vetements dispo"] = {
            b = {
                {name = "Tenues Dispo", slidemax = slideclothes},
            }
        }
    }
}
    
CreateMenu(vestiaires)
end


function RepairVeh()
    local playerPed = PlayerPedId()
    local vehicle = ESX.Game.GetVehicleInDirection()
    local DoesExist = DoesEntityExist(vehicle)
    local IsPedSit = IsPedSittingInAnyVehicle(playerPed)
    local coords = GetEntityCoords(playerPed, false)

    if IsPedSit then
        ShowNotification("DEBUG")
        return
    end

    if DoesExist then
        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
        Citizen.CreateThread(function()
            Citizen.Wait(17000)

            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleEngineOn(vehicle, true, true)
            ClearPedTasksImmediately(playerPed)

            ESX.ShowNotification("~g~Véhicule bien réparé !~s~")
        end)
    else
        ESX.ShowNotification("~r~Aucun vehicule à proximité~s~")
    end
end

function ClearVeh()
    local playerPed = PlayerPedId()
    local vehicle = ESX.Game.GetVehicleInDirection()
    local DoesExist = DoesEntityExist(vehicle)
    local IsPedSit = IsPedSittingInAnyVehicle(playerPed)
    local coords = GetEntityCoords(playerPed, false)

    if IsPedSit then
        ESX.ShowNotification("DEBUG")
        return
    end

    if DoesEntityExist(vehicle) then
        isBusy = true
        TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
        Citizen.CreateThread(function()
            Citizen.Wait(10000)

                SetVehicleDirtLevel(vehicle, 0)
                ClearPedTasksImmediately(playerPed)

            ESX.ShowNotification("~g~Véhicule bien nettoyé !~s~")
        end)
    else
        ESX.ShowNotification("~r~Aucun vehicule à proximité~s~")
    end
end

function ClothesEvent()
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            if Config.Uniforms.event.male then
                TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.event.male)
                self:CloseMenu(true)
            end
        elseif skin.sex == 1 then
            if Config.Uniforms.event.female then
                TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.event.female)
                self:CloseMenu(true)
            end
        end
    end)
end

