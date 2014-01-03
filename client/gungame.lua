class 'Gungame'

function Gungame:__init()
    Events:Subscribe( "ModuleLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end



function Gungame:ModulesLoad()
    Events:FireRegisteredEvent( "HelpAddItem",
        {
            name = "Gungame",
            text = "Play a round of gungame, as inspired by the CounterStrike mod of the same name."
        } )
end

function Gungame:ModuleUnload()
    Events:FireRegisteredEvent( "HelpRemoveItem",
        {
            name = "Gungame"
        } )
end

gungame = Gungame()

