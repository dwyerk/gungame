class 'Gungame'

function Gungame:__init()
    self.vehicles = {}
    self.player_spawns          = {}

    -- Weapons to use
    self.one_handed             = { Weapon.Handgun, Weapon.Revolver, Weapon.SMG, 
                                    Weapon.SawnOffShotgun }

    self.two_handed             = { Weapon.Assault, Weapon.Shotgun, 
                                    Weapon.Sniper, Weapon.MachineGun,
                                    Weapon.GrenadeLauncher,
                                    Weapon.HeavyMachineGun,
                                    Weapon.PanayRocketLauncher,
                                  }

    self.ammo_counts            = {
        [2] = { 12, 60 }, [4] = { 7, 35 }, [5] = { 30, 90 },
        [6] = { 3, 18 }, [11] = { 20, 100 }, [13] = { 6, 36 },
        [14] = { 4, 32 }, [16] = { 3, 12 }, [17] = { 5, 5 },
        [28] = { 26, 130 }
    }

    -- didn't work for me:
    -- BigCannon, Airzooka, Cannon, ClusterBombLauncher, SignatureGun,

    -- works, but strangely
    -- Weapon.Minigun,
    -- Weapon.SAM,
    -- Weapon.SentryGun,
     --   Weapon.HeavyMachineGun,
    self.weapons = {
--[[
        Weapon.PanayRocketLauncher, -- shoots a lot faster
        Weapon.RocketLauncher,
--]]
        Weapon.MachineGun,
        Weapon.Shotgun,
        Weapon.SawnOffShotgun,
        Weapon.SMG,
        Weapon.Revolver,
        Weapon.Handgun,
        Weapon.GrenadeLauncher,
        Weapon.Assault,
        Weapon.Sniper,
--]]
    }

    self.scoreboard = {}

    -- Load spawns
    self:LoadSpawns( "spawns.txt" )

    -- Subscribe to events
    --Events:Subscribe( "ClientModuleLoad",   self, self.ClientModuleLoad )
    Events:Subscribe( "ModuleUnload",       self, self.ModuleUnload )
    Events:Subscribe( "ModulesLoad",        self, self.ModulesLoad )
    Events:Subscribe( "PlayerSpawn",        self, self.PlayerSpawn )
    Events:Subscribe( "PlayerChat",         self, self.PlayerChat )
    Events:Subscribe("PlayerDeath", self, self.PlayerDeath)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)

end

-- Functions to parse the spawns
function Gungame:LoadSpawns( filename )
    -- Open up the spawns
    print("Opening " .. filename)
    local file = io.open( filename, "r" )

    if file == nil then
        print( "No spawns.txt, aborting loading of spawns" )
        return
    end

    -- Start a timer to measure load time
    local timer = Timer()

    -- For each line, handle appropriately
    for line in file:lines() do
        if line:sub(1,1) == "V" then
            --self:ParseVehicleSpawn( line )
        elseif line:sub(1,1) == "P" then
            self:ParsePlayerSpawn( line )
        elseif line:sub(1,1) == "T" then
            self:ParseTeleport( line )
        end
    end

    print( string.format( "Loaded spawns, %.02f seconds", 
                            timer:GetSeconds() ) )

    file:close()
end

function Gungame:ParseVehicleSpawn( line )
    -- Remove start, end and spaces from line
    line = line:gsub( "VehicleSpawn%(", "" )
    line = line:gsub( "%)", "" )
    line = line:gsub( " ", "" )

    -- Split line into tokens
    local tokens = line:split( "," )   

    -- Model ID string
    local model_id_str  = tokens[1]

    -- Create tables containing appropriate strings
    local pos_str       = { tokens[2], tokens[3], tokens[4] }
    local ang_str       = { tokens[5], tokens[6], tokens[7], tokens[8] }

    -- Create vehicle args table
    local args = {}

    -- Fill in args table
    args.model_id       = tonumber( model_id_str )
    args.position       = Vector3(   tonumber( pos_str[1] ), 
                                    tonumber( pos_str[2] ),
                                    tonumber( pos_str[3] ) )

    args.angle          = Angle(    tonumber( ang_str[1] ),
                                    tonumber( ang_str[2] ),
                                    tonumber( ang_str[3] ),
                                    tonumber( ang_str[4] ) )

    if #tokens > 8 then
        if tokens[9] ~= "NULL" then
            -- If there's a template, set it
            args.template = tokens[9]
        end

        if #tokens > 9 then
            if tokens[10] ~= "NULL" then
                -- If there's a decal, set it
                args.decal = tokens[10]
            end
        end
    end

    -- Create the vehicle
    args.enabled = true
    local v = Vehicle.Create( args )

    -- Save to table
    self.vehicles[ v:GetId() ] = v
end

function Gungame:ParsePlayerSpawn( line )
    -- Remove start, spaces
    line = line:gsub( "P", "" )
    line = line:gsub( " ", "" )

    -- Split into tokens
    local tokens        = line:split( "," )
    -- Create table containing appropriate strings
    local pos_str       = { tokens[1], tokens[2], tokens[3] }
    -- Create vector
    local vector        = Vector3(tonumber( pos_str[1] ), 
                                  tonumber( pos_str[2] ),
                                  tonumber( pos_str[3] ) )

    -- Save to table
    table.insert( self.player_spawns, vector )
end

-- Functions for utility use
function Gungame:GiveRandomWeapons( p )
    -- Give random weapons from the predefined list
    p:ClearInventory()

    local one_id = table.randomvalue( self.one_handed )
    local two_id = table.randomvalue( self.two_handed )

    p:GiveWeapon( WeaponSlot.Right, 
        Weapon( one_id, 
            self.ammo_counts[one_id][1],
            self.ammo_counts[one_id][2] * 6 ) )
    p:GiveWeapon( WeaponSlot.Primary, 
        Weapon( two_id, 
            self.ammo_counts[two_id][1],
            self.ammo_counts[two_id][2] * 6 ) )
end

function Gungame:GiveCurrentWeapon(p)
    p:ClearInventory()

    if self.scoreboard[p:GetName()].current_weapon == nil then
        self.scoreboard[p:GetName()].current_weapon = 1
    end

    local current_idx = self.scoreboard[p:GetName()].current_weapon
    --print(current_idx)
    --print(self.weapons[current_idx])


--    p:GiveWeapon(WeaponSlot.Primary,
--        Weapon(self.weapons[current_idx], 10, 10))
    --p:GiveWeapon(WeaponSlot.Primary,
    --    Weapon(self.two_handed[1] ))
        --Weapon(Weapon.Minigun, 10, 10))


-- the rule is: two handed weapons go in Primary, one handed weapons go in Right
-- TODO: decide which slot to use based on the type of weapon
    p:GiveWeapon(WeaponSlot.Right,
        Weapon(self.weapons[current_idx]))
end

function Gungame:GiveNextWeapon(p)

    local status = self.scoreboard[p:GetName()]

    -- TODO: Test for victory here and end the game.
    print(#self.weapons)
    print(status.current_weapon)
    if #self.weapons == status.current_weapon then
        Chat:Broadcast(p:GetName() .. " wins gungame!", orange)
        self:Reset()
    end

    p:ClearInventory()

    status.current_weapon = status.current_weapon + 1

    self:GiveCurrentWeapon(p)
end

function Gungame:RandomizePosition( pos, magnitude, offset )
    if magnitude == nil then
        magnitude = 10
    end

    if offset == nil then
        offset = 250
    end

    return pos + Vector3(    math.random( -magnitude, magnitude ), 
                            math.random( -magnitude, 0 ) + offset, 
                            math.random( -magnitude, magnitude ) )
end

-- Chat handlers
-- Create table containing chat handlers

orange = Color(242, 105, 37)
ChatHandlers = {}

function ChatHandlers:gg (args)
    args.player:SendChatMessage("current gungame score", orange)
    for p, status in pairs(self.scoreboard) do
        args.player:SendChatMessage("  " .. p .. " " .. (status.current_weapon - 1), orange)
    end
end

-- Events
function Gungame:ClientModuleLoad( args )
    Network:Send( args.player, "Hotspots", self.hotspots )
end

function Gungame:ModuleUnload( args )
end

function Gungame:ModulesLoad()
    for _, v in ipairs(self.player_spawns) do
        Events:Fire( "SpawnPoint", v )
    end

    self:Reset()
end

function Gungame:PlayerSpawn( args )
    local default_spawn = true

    if self.scoreboard[args.player:GetName()] == nil then
        print(args.player:GetName() .. " joined")
        Chat:Broadcast(args.player:GetName() .. " is playing gungame!", orange)
        self.scoreboard[args.player:GetName()] = PlayerStatus()
    end

    if args.player:GetWorld() == DefaultWorld then
        -- If there are any player spawns, then teleport them
        if #self.player_spawns > 0 then
            local position = table.randomvalue( self.player_spawns )            

            args.player:SetPosition( self:RandomizePosition( position ) )
            default_spawn = false
        end

        self:GiveCurrentWeapon(args.player)
    end

    return default_spawn
end

function Gungame:PlayerChat( args )
    local msg = args.text

    if msg:sub(1, 1) ~= "/" then
        return true
    end

    -- Truncate the starting character
    msg = msg:sub(2)

    -- Split the message
    local cmd_args = msg:split(" ")
    local cmd_name = cmd_args[1]

    -- Remove the command name
    table.remove( cmd_args, 1 )
    cmd_args.player = args.player

    -- Grab the function
    local func = ChatHandlers[string.lower(cmd_name)]
    if func ~= nil then
        -- If it's valid, call it
        func( self, cmd_args )
    end

    return false
end

function Gungame:PlayerDeath(args)
    if args.killer ~= nil then
        self:GiveNextWeapon(args.killer)
    end
end

function Gungame:PlayerQuit(args)
    self.scoreboard[args.player:GetName()] = nil
    Chat:Broadcast(args.player:GetName() .. " has quit gungame!", orange)    
end

function Gungame:Reset(args)
    -- Everyone joins the fun!
    for player in Server:GetPlayers() do
        Chat:Broadcast(player:GetName() .. " is playing gungame!", orange)
        self.scoreboard[player:GetName()] = PlayerStatus()
        self:GiveCurrentWeapon(player)
    end
end

gungame = Gungame()
