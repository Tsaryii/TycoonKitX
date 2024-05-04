using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters}
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Teams }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters}
using { /UnrealEngine.com/Temporary/UI}
using { /Fortnite.com/UI}
using { /Verse.org/Colors/NamedColors}
using { /Verse.org/Colors}
using { /Verse.org/Random }
using {BeFu}
using { /Verse.org/Concurrency }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Curves }

# See _ _ _ for how to build using this verse device.

# A Verse-authored creative device that can be placed in a level

#█▀▀ █▀█ █▀▀ █▀▄ █ ▀█▀ █▀ ▀
#█▄▄ █▀▄ ██▄ █▄▀ █ ░█░ ▄█ ▄


<#  ████████╗░██████╗░█████╗░██████╗░  ░░░░██╗  ████████╗░██████╗░█████╗░██████╗░██████╗░██╗░░░██╗
    ╚══██╔══╝██╔════╝██╔══██╗██╔══██╗  ░░░██╔╝  ╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗╚██╗░██╔╝
    ░░░██║░░░╚█████╗░███████║██████╔╝  ░░██╔╝░  ░░░██║░░░╚█████╗░███████║██████╔╝██████╔╝░╚████╔╝░
    ░░░██║░░░░╚═══██╗██╔══██║██╔══██╗  ░██╔╝░░  ░░░██║░░░░╚═══██╗██╔══██║██╔══██╗██╔══██╗░░╚██╔╝░░
    ░░░██║░░░██████╔╝██║░░██║██║░░██║  ██╔╝░░░  ░░░██║░░░██████╔╝██║░░██║██║░░██║██║░░██║░░░██║░░░
    ░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝  ╚═╝░░░░  ░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░
                           Copyright: IN EULA AGREEMENT
                                DO NOT REDISTRIBUTE
                     Youtube Channel: Youtube.com/@TsarShorts                                   #> 
GameManagementHost:=module{
SuperKitX := class(creative_device):
    var PlayersMap:[agent]CustomPlayer = map{}
    var GlobalUserUniqueID:int = 1
    var Hashed:logic = false
    @editable var UniqueHash: int = 0
    var AllPlayersMap : [player]PlayerStats = map{}
    var DefaultVal: int = 0
    @editable var Teams: []Team = array{}
    @editable DebugParams: DebugOddsClass = DebugOddsClass{DebugOccurence := option{95.0}}
    OnBegin<override>()<suspends>:void=
        Hash:HashingAlgo = HashingAlgo{}
        Playspace := GetPlayspace().PlayerRemovedEvent().Subscribe(PlayerLeftManagement)
        set Hashed = Hash.Allow(UniqueHash)
        if(Hashed = true){spawn:
             PassedBegin(Hash.Hash)
        }
        else:
            PrintWOD("hased was false.")
    PlayerLeftManagement(Player:player):void={
        var found:logic=false
        for(ActiveTeam:Teams, not found?):
            if(Player = ActiveTeam.Owner?):
                set ActiveTeam.Owner = false; set ActiveTeam.Claimed = false; set found=true
                UnloadBase(ActiveTeam)
                PrintWOD("a player left team {ActiveTeam.TeamName}, Unloading their progress.")
            else:
                PrintWOD("The player who left did not own this checked base.")
        if(found=false){PrintWOD("The player who left did not own a base.")}

                

    }
    PassedBegin(Validity: int)<suspends>:void=
        PrintWOD("Hash Values match up! {Validity}")
        Hash:HashingAlgo = HashingAlgo{}
        if(Validity = Hash.Hash):

            spawn{GameManagement()}
    GameManagement()<suspends>:void=
        PrintWOD("Beginning game.")
        for(ActiveTeam:Teams): #await claiming for all teams
            AssignAgentStats()
            spawn{AwaitBaseClaiming(ActiveTeam)}
    AwaitBaseClaiming(ActiveTeam:Team)<suspends>:void={
        Agent := ActiveTeam.BaseSetup.BaseClaimer.AgentExitsEvent.Await() #await for the mutator zone to be entered.
        InitializeStartPositions(ActiveTeam)
        for(Conveyor:ActiveTeam.Conveyors):
            for(Dropper:Conveyor.Droppers):
                    set Dropper.DroppedPropResetLocation = Dropper.DroppedPropONCONVEYOR.GetTransform().Translation
                    Dropper.DroppedPropONCONVEYOR.Hide()
        UnloadBase(ActiveTeam)
        if(Player:player = player[Agent]){
        InitializePlayer(Player)
        set ActiveTeam.Owner = option{Player}
        InitializeCurrency(ActiveTeam, Player)} #set the accessable team owner to this player.
        set ActiveTeam.Claimed = true #Notify the system that this base has been calimed.
        PrintWOD("A player has claimed a base.")
        


    }
    GetPlayerName(Player:player):message=
        PlayerName : message = PlayerNameToMessage(Player)
        return PlayerName
    PlayerNameToMessage<localizes>(Agent:player)<computes>:message="{Agent}"
    InitializeCurrency(ActiveTeam:Team, Player:player):void={
        AgentStats := GetAgentStats(Player)
        for(Currenci:= 0..ActiveTeam.Currencies.Length-1):
            if(set AgentStats.AssociatedCurrencies[Currenci] = 0){PrintWOD("inits currencies")} 
            if(CurrentPlayerStats:=GetPlayerStats[Player]):
                AssociatedCurrencies := CurrentPlayerStats.CoinDex.AssociatedCurrencies
                if(AID :=AssociatedCurrencies[Currenci]):
                    if(set AgentStats.AssociatedCurrencies[Currenci] = AID){PrintWOD("inits currencies with persistence, PrintWOD AID is {AID}")} 
            Print(GetPlayerName(Player))
            set AgentStats.HasCurreny = true
        for(ActiveBuyItem:ActiveTeam.BuyableProps):
            spawn{AwaitBuyItemClaiming(ActiveBuyItem, ActiveTeam, AgentStats)}
            set ActiveBuyItem.Type = Parents.Prop
        for(Conveyor:ActiveTeam.Conveyors):
            set Conveyor.Type = Parents.Conveyor
            set Conveyor.ConveyorDex = option{Conveyor}
            spawn{AwaitBuyItemClaiming(Conveyor, ActiveTeam, AgentStats)}
            for(Dropper:Conveyor.Droppers):
                set Dropper.Type = Parents.Dropper
                set Dropper.ConveyorDex = option{Conveyor}
                spawn{AwaitBuyItemClaiming(Dropper, ActiveTeam, AgentStats)}
                

    }
    TotalMoveTime : float = 30.0
    RefreshRate : float = 1.0 / 30.0
    InitializeStartPositions(ActiveTeam:Team):void =
        for(Conveyor:ActiveTeam.Conveyors):
            set Conveyor.PlankList = array{}
            for(Dropper:Conveyor.Droppers):
                if(Dropper.Bought?):
                    set Conveyor.PlankList += array{Dropper.DroppedPropONCONVEYOR}
                    if(Dropper.DroppedPropONCONVEYOR.TeleportTo[Dropper.DroppedPropResetLocation, Dropper.DroppedPropONCONVEYOR.GetTransform().Rotation]){}
                    Print("Bought, adding to PlankList.")
            if (StartPlank := Conveyor.PlankList[0]):
                set Conveyor.StartConveyor = StartPlank.GetTransform().Translation

            
    MovePlanks(Conveyor:ConveyerLine)<suspends>:void =
        Print("Moving planks")
        Planks := Conveyor.PlankList
        # Calculate how much to increment the scalar per distance refresh
        ScalarTimeDelta : float = RefreshRate / TotalMoveTime
        PlanksCount : int = Planks.Length

        # The scalar is used to calculate the Lerp between points
        var ScalarStart : float = 0.0
        ScalarPositionDelta : float  = 1.0 / PlanksCount.ToFloat()
        MaxIndex : int = Planks.Length-1
        loop: 
            if(Planks.Length = Conveyor.PlankList.Length):
                for:
                    Index := 0..MaxIndex
                    InverseIndex: int = MaxIndex - Index
                    Plank := Planks[InverseIndex]  
                    
                do:
                    
                    # Move the last piece first or the next piece will overlap.
                    Rotation := Plank.GetTransform().Rotation
                    Scalar := (ScalarStart + (ScalarPositionDelta * InverseIndex)).WrapAroundScalar()
                    NewPosition := Lerp(Conveyor.StartConveyor, Conveyor.EndConveyor, Scalar)
                    if(V3 :=  Conveyor.Droppers[InverseIndex].DroppedPropResetLocation):
                        Plank.Show()
                        if(Scalar <= 0.001):
                            ShowSequence(Plank, V3)
                        
                    else if(Conveyor.ConveyorType = ConveyorTypeEnum.OAA_NEGTOPOSXONLY){Plank.Hide()}
                    #UPDATE THIS TO DETECT FOR ALL WAYS CONVEYORS MOVE
                        if(Plank.GetTransform().Translation.X > Conveyor.Droppers[InverseIndex].DroppedPropResetLocation.X):
                            
                    if(Plank.TeleportTo[NewPosition, Rotation]) {}
                    if(Scalar >= 1.0):
                        if(Plank.TeleportTo[X:= Conveyor.Droppers[InverseIndex].DroppedPropResetLocation, Rotation]) {
                            Print("Tping to {X}")
                            Plank.Show()
                        }
                # Increment and Wrap the scalar value for the next loop
                set ScalarStart += ScalarTimeDelta
                set ScalarStart = ScalarStart.WrapAroundScalar()
                Sleep(RefreshRate)
            else:
                Print("New props detected, restarting")
                spawn{MovePlanks(Conveyor)}; break
    ShowSequence(Prop:creative_prop, finalV:vector3)<suspends>:void={
        TR := Prop.GetTransform().Translation
        Prop.Show()
        if(Prop.TeleportTo[vector3{X:=TR.X, Y:=TR.Y, Z:=TR.Z+50.0}, rotation{}]){}
        Prop.MoveTo(finalV, rotation{}, 0.2)
    }
    AwaitBuyItemClaiming(ActiveBuyItem:BuyItem, ActiveTeam:Team, AgentStats:PlayerStats)<suspends>:void={
        var Enough:logic=false
        loop:
            Sleep(0.0)
            ActiveBuyItem.BuyZone.AgentEntersEvent.Await()
            if(ActiveBuyItem.Bought = false):
                        for(Key->Value : AgentStats.AssociatedCurrencies):
                            PrintWOD("Value {Value} at key {Key}")
                        if(BuyCurrency := AgentStats.AssociatedCurrencies[ActiveBuyItem.overrideBuyCurrencyID?]):
                            PrintWOD("{BuyCurrency}")
                            if(BuyCurrency >= ActiveBuyItem.ItemPrice):
                                set Enough = true
                                if(set AgentStats.AssociatedCurrencies[ActiveBuyItem.overrideBuyCurrencyID?] -= ActiveBuyItem.ItemPrice){}
                        else if(BuyCurrency := AgentStats.AssociatedCurrencies[ActiveTeam.Defaults.DefaultBuyCurrencyID]):
                                PrintWOD("{BuyCurrency}")
                                if(BuyCurrency >= ActiveBuyItem.ItemPrice):
                                    set Enough = true
                                    if(set AgentStats.AssociatedCurrencies[ActiveTeam.Defaults.DefaultBuyCurrencyID] -= ActiveBuyItem.ItemPrice){}
                        else:
                            PrintWOD("failed")
                        if(Enough = true): 
                            Print("Bought")
                            set ActiveBuyItem.Bought = true
                            for(Prop:ActiveBuyItem.Props):
                                BetterShow(Prop)
                                PrintWOD("Showing a prop.")
                            if(ActiveBuyItem.Type = Parents.Conveyor): #is Conveyor?
                                Print("Spawning dropper management")
                                if(ConveyorType := ActiveBuyItem.ConveyorDex?):
                                    spawn{DropperManagement(ConveyorType, ActiveTeam, AgentStats)}
                            else:
                                Print("NOT A Conveyor")
                            for(Parent:= 0..ActiveBuyItem.ParentChildMap.Length-1): #Gives indexes of all the Parents
                                    for(KnownChild:ActiveBuyItem.ParentChildMap[Parent].Children): #Child ID's
                                        if(ActiveBuyItem.ParentChildMap[Parent].ParentType = Parents.Prop): #If this parent is for props.
                                            for(FoundChild:= 0..ActiveTeam.BuyableProps.Length-1): #Then give index of all Buyable props
                                                    if(FoundChild = KnownChild): #if these match, unlock said buyables.
                                                    if(set ActiveTeam.BuyableProps[FoundChild].Bought = false){}
                                        
                                        if(ActiveBuyItem.ParentChildMap[Parent].ParentType = Parents.Conveyor): #If this parent is for Conveyors.
                                            for(FoundChild:= 0..ActiveTeam.Conveyors.Length-1): #Then give index of all Buyable props
                                                    if(FoundChild = KnownChild): #if these match, unlock said buyables.
                                                    if(set ActiveTeam.BuyableProps[FoundChild].Bought = false){}

                                        
                                        if(ActiveBuyItem.ParentChildMap[Parent].ParentType = Parents.Dropper): #If this parent is for Conveyors -> Droppers.
                                            for(ConveyorID:ActiveBuyItem.ParentChildMap[Parent].DropperParentConveyorIDs):
                                                if(FoundID := ConveyorID?, Conveyor := ActiveTeam.Conveyors[FoundID]):
                                                    for(FoundChild:= 0..Conveyor.Droppers.Length-1): #Then give index of all Buyable props
                                                            if(FoundChild = KnownChild): #if these match, unlock said buyables.
                                                            if(set ActiveTeam.BuyableProps[FoundChild].Bought = false){}
                                GrantCashManagement(ActiveBuyItem, ActiveTeam)
                            Sleep(0.0)
                            break #Ends subscription
                        else:
                            PrintWOD("Not enough money to buy")
            else:
                PrintWOD("Prop may be a child, thus buying is further disallowed until their parent is owned.")

    }
    DropperManagement(Conveyer:ConveyerLine, ActiveTeam:Team, AgentStats:PlayerStats)<suspends>:void={
            if(Conveyer.ConveyorType = ConveyorTypeEnum.OAA_NEGTOPOSXONLY or Conveyer.ConveyorType = ConveyorTypeEnum.Lerp_NEGTOPOSXONLY): #Is lerp type?
                InitializeStartPositions(ActiveTeam)
                spawn{MovePlanks(Conveyer)}
            else if(Conveyer.ConveyorType = ConveyorTypeEnum.TickVary_Based_spawn):
                Print("Tick vary based")
                TickVaryGlobalSpawn(Conveyer, ActiveTeam,AgentStats)

    }
    TickVaryGlobalSpawn(Conveyor:ConveyerLine, ActiveTeam:Team, AgentStats:PlayerStats)<suspends>:void={
        loop:
            Sleep(0.66)
            for(Dropper:Conveyor.Droppers):
                if(Dropper.Bought?):
                    if(not Dropper.IsActive?):
                        Print("not active, setting active and spawning")
                        set Dropper.IsActive = true
                        spawn{TickEventAwaitMain(Conveyor, Dropper, ActiveTeam, AgentStats)}
                else:
                    Print("Dropper isn't bought")
                        
                    
    }
    TickEventAwaitMain(Conveyor:ConveyerLine, Dropper:DropperItem, ActiveTeam:Team, AgentStats:PlayerStats)<suspends>:void=
        Print("main await")
        Prop := Dropper.DroppedPropONCONVEYOR
        Location := Prop.GetTransform().Translation
        Rotation := Prop.GetTransform().Rotation
        G0MoveTime := Distance(Location, Conveyor.EndConveyor)
        Dropper.DroppedPropONCONVEYOR.Hide()
        set Conveyor.MiniMetersSecondWithNoWeight -= (Pow(1.01, Dropper.Weight_Lbs)+(+1.0))+(Pow(Dropper.Weight_Lbs, 0.1)) #adding weight to the conveyor makes it slightly slower.
        loop:
            spawn{TickEventAwait(Location, Rotation, G0MoveTime, Conveyor, Dropper, ActiveTeam, AgentStats)}
            Event := spawn{Dropper.OnTick()}; Event.Await()
    TickEventAwait(Location: vector3, Rotation:rotation, G0MoveTime:float, Conveyor:ConveyerLine, Dropper:DropperItem, ActiveTeam:Team, AgentStats:PlayerStats)<suspends>:void={
        SpawnPropResult := SpawnProp(Dropper.DroppedPropSpawnEndPoint, vector3{}, rotation{})
        MaybeProp := SpawnPropResult(0)
        if(Prop := MaybeProp?){
        var StartLocation: vector3 = vector3{X := Location.X, Y:=Location.Y, Z:=Location.Z+Dropper.StartHeight}
        #Weight Chart
        #1 LBS -> Slow of 3.01 MMS
        #5 LBS -> Slow of 3.22 MMS
        #25 LBS -> Slow of 3.65 MMS
        #50 LBS -> Slow of 4.08 MMS
        #150 LBS -> Slow of 6.78 MMS
        #250 LBS -> Slow of 13.37 MMS
        #325 LBS -> Slow of 24.39 MMS
        #400 LBS -> Slow of 46.73 MMS
        #450 LBS -> Slow of 73.29 MMS
        #600 LBS -> Slow of 293.83 MMS
        #675 LBS -> Slow of 594.16 MMS
        #691 LBS -> Slow of 690.73 MMS
        #800 LBS -> Slow of 1930.73 MMS
        #999 LBS -> Slow of 12656.68 MMS
        #BEYOND THIS WHY???
        #Know Excel? Use this -> https://docs.google.com/spreadsheets/d/1vKy8MrTomCm9pLMqd1TGWBE8mZTAc0U8U_dRXRB4964/edit?usp=sharing

        var Meter_S: float = Conveyor.MiniMetersSecondWithNoWeight
        if(Meter_S <= 0.1):
            set Meter_S = 0.1
        
        Print("G0 Move time is {G0MoveTime}")
        Print("{Meter_S}Meters per second")
            set Meter_S = Conveyor.MiniMetersSecondWithNoWeight
            MoveTime:float = G0MoveTime/Meter_S
            Print("Move time is {MoveTime}")
            if(Prop.IsValid[]):
                if(Prop.TeleportTo[StartLocation, Rotation]){
                    Prop.MoveTo(Location, Rotation, Dropper.DropInterval/9.0)
                    MoveToResult := Prop.MoveTo(Conveyor.EndConveyor, Rotation, MoveTime)
                    if(MoveToResult = move_to_result.DestinationReached){
                        ActiveTeam.GrantMoney(Dropper.CashOnExit, Dropper.CashOnExitID)
                        Prop.Hide()
                        Prop.Dispose()
                        return #When a tick occurs.
                    }
                }
             
        }
    }
    (X:DropperItem).OnTick()<suspends>:void={Variance:float=GetRandomFloat(X.DropInterval-0.35, X.DropInterval+1.35); Sleep(Variance); return}
    GrantCashManagement(ActiveBuyItem:BuyItem, ActiveTeam:Team)<suspends>:void={
        if(Agent:agent = agent[ActiveTeam.Owner?]):
            PrintWOD("Grant Cash M is on!")
            AgentStats := GetAgentStats(Agent)
            Defaults := ActiveTeam.Defaults
            SessionSavingSettings := ActiveTeam.SessionSavingSettings
            var GrantCurrencyID:int = Defaults.DefaultGrantCurrencyID #ID of the currency you want to grant per Inteval time.
            var GrantPerInteval:int = Defaults.DefaultGrantPerInteval
            var GrantInverval:float = Defaults.DefaultGrantIntveral

            if(OrGrantCurrencyID := ActiveBuyItem.overrideGrantCurrencyID?){set GrantCurrencyID = OrGrantCurrencyID}
            else{set GrantCurrencyID = Defaults.DefaultGrantCurrencyID} #Failsafe reversion

            if(OrGrantPerInteval := ActiveBuyItem.overrideGrantPerInteval?){set GrantPerInteval = OrGrantPerInteval}
            else{set GrantPerInteval = Defaults.DefaultGrantPerInteval} #Failsafe reversion

            if(OrGrantInteval: float = ActiveBuyItem.overrideGrantInverval?){set GrantInverval = OrGrantInteval}
            else{set GrantInverval = Defaults.DefaultGrantIntveral} #Failsafe reversion
                if(CurrentPlayerStats:=GetPlayerStats[Agent]):
                    
                    set ActiveTeam.CashToClaim = CurrentPlayerStats.MainGold.CurrentValue
                    PrintWOD("Cash to claim: {ActiveTeam.CashToClaim}")
                    PrintWOD("Adding Overarching Gold")
                    PrintWOD("{CurrentPlayerStats.MainGold.CurrentValue}")
                    AssociatedCurrencies := CurrentPlayerStats.CoinDex.AssociatedCurrencies
                    if(AID :=AssociatedCurrencies[GrantCurrencyID]):
                        if(set AgentStats.AssociatedCurrencies[GrantCurrencyID] = AID){PrintWOD("AID val is {AID}")}
                        
                loop:
                    PrintWOD("Grant Currency ID {GrantCurrencyID}")
                        Sleep(GrantInverval)
                        if(not GrantCurrencyID = 0):
                            PrintWOD("Currency isn't index 1, adding to players automatically.")
                            
                            if(set AgentStats.AssociatedCurrencies[GrantCurrencyID] += GrantPerInteval){}
                            else{PrintWOD("Couldnt find ID")}
                            if(MoneyValue := AgentStats.AssociatedCurrencies[GrantCurrencyID]){PrintWOD("Has money: {MoneyValue}")
                            if(SessionSavingSettings.SaveAllCurrencyValues?):
                                RecordPlayerCoindDexStat(Agent, StatType.CoinDex, GrantCurrencyID, MoneyValue)
                            }
                                
                            else{PrintWOD("Couldnt find AID")}
                            
                        else:
                            set ActiveTeam.CashToClaim += GrantPerInteval
                                PrintWOD("CTC = {ActiveTeam.CashToClaim}")
                                if(SessionSavingSettings.SaveFirstCurrencyValue?):
                                    RecordPlayerStat(Agent, StatType.MainGold, ?ParsedValue:=ActiveTeam.CashToClaim)
                                    if(CurrentPlayerStats:=GetPlayerStats[Agent]):
                                        CurrentScore := CurrentPlayerStats.MainGold.CurrentValue
                        if(not ActiveTeam.Claimed = true){PrintWOD("breaking"); break}


    }
    (ActiveTeam:Team).GrantMoney(MoneyToGrant:int, GrantCurrencyID:int):void={
        if(Agent:agent = agent[ActiveTeam.Owner?]):
            AgentStats := GetAgentStats(Agent)
            if(CurrentPlayerStats:=GetPlayerStats[Agent]):
                SessionSavingSettings := ActiveTeam.SessionSavingSettings
                AssociatedCurrencies := CurrentPlayerStats.CoinDex.AssociatedCurrencies
                if(AID :=AssociatedCurrencies[GrantCurrencyID]):
                    if(set AgentStats.AssociatedCurrencies[GrantCurrencyID] = AID){PrintWOD("AID val is {AID}")}
                    if(not GrantCurrencyID = 0):
                        PrintWOD("Currency isn't index 1, adding to players automatically.")
                        
                        if(set AgentStats.AssociatedCurrencies[GrantCurrencyID] += MoneyToGrant){}
                        else{PrintWOD("Couldnt find ID")}
                        if(MoneyValue := AgentStats.AssociatedCurrencies[GrantCurrencyID]){PrintWOD("Has money: {MoneyValue}")
                        if(SessionSavingSettings.SaveAllCurrencyValues?):
                            RecordPlayerCoindDexStat(Agent, StatType.CoinDex, GrantCurrencyID, MoneyValue)
                        }
                            
                        else{PrintWOD("Couldnt find AID")}
                        
                    else:
                        set ActiveTeam.CashToClaim += MoneyToGrant
                            PrintWOD("CTC = {ActiveTeam.CashToClaim}")
                            if(SessionSavingSettings.SaveFirstCurrencyValue?):
                                RecordPlayerStat(Agent, StatType.MainGold, ?ParsedValue:=ActiveTeam.CashToClaim)
                                    CurrentScore := CurrentPlayerStats.MainGold.CurrentValue
    }

    #Prints based on debug odds. (Debug odds are used to not overflow print messages when print statements would occur a multitude of times /s)
    PrintWOD(String:string):void=if(DebugParams.DebugOccurence? > GetRandomFloat(0.0, 100.0)){Print("{String}")}

    AssignAgentStats<public>():void= #assign unique class to all players
        Players:=GetPlayspace().GetPlayers()
        for (Player : Players):
            if(PlayerTeam := GetPlayspace().GetTeamCollection().GetTeam[Player]):    
                if(Agent:agent = agent[Player]):
                    if(PlayerOBJ := player[Player]):
                        if(set AllPlayersMap[PlayerOBJ] = PlayerStats{}):
    UnloadBase(ActiveTeam:Team):void=
        UnloadBaseItemData(ActiveTeam.BuyableProps)
        UnloadBaseItemData(ActiveTeam.Conveyors)
        for(Conveyor:ActiveTeam.Conveyors):
            UnloadBaseItemData(Conveyor.Droppers)

         
    UnloadBaseItemData(BuyItemList:[]BuyItem):void=
        for(ActiveBuyables := 0..BuyItemList.Length-1): #For All Buyables
            if(set BuyItemList[ActiveBuyables].Bought = false){}
            for(ActiveProp := 0..BuyItemList[ActiveBuyables].Props.Length-1): #For all props in said buyables
                #sets 'children' to being system flagged as bought, therefore they cannot be bought until unlocked.
                if(Prop := BuyItemList[ActiveBuyables].Props[ActiveProp]){if(BetterHide[Prop]){}} #Hide All Props
        for(ActiveBuyables := 0..BuyItemList.Length-1):
            for(ParentValueValue:= 0..BuyItemList[ActiveBuyables].ParentChildMap.Length-1):
                for(ChildrenValue:BuyItemList[ActiveBuyables].ParentChildMap[ParentValueValue].Children):
                    if(set BuyItemList[ChildrenValue].Bought = true){
                        PrintWOD("setting BuyItemList = true")
                        
                    }

    OnPlayerSpawned(Agent:agent):void=
        if(CP:CustomPlayer = PlayersMap[Agent]):
            #Player associated with this map index already exists.
        else:
            #Append new player to map
            NewPlayer:CustomPlayer = CustomPlayer{MyAgentObj:=Agent}
            if(set PlayersMap[Agent] = NewPlayer):
                NewPlayer.InitializePlayer(GlobalUserUniqueID)
                set GlobalUserUniqueID += 1
                PrintWOD("New Player appended at {NewPlayer.UniqueID}")
    OnPlayerRemoved(Player:player):void=
        if(Agent:agent = agent[Player]):
            if(OldCustomPlayer:CustomPlayer = PlayersMap[Agent]):
                #remove player from map
                var TempAllPlayersMap:[agent]CustomPlayer = map{}
                for(Key -> Value : PlayersMap, Key <> Player):
                    set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})
                    set PlayersMap = TempAllPlayersMap
    GetAgentStats<public>(Agent: agent):PlayerStats=
            var AgentStats: PlayerStats = PlayerStats{}
                if(PlayerOBJ := player[Agent]):
                    if(t := AllPlayersMap[PlayerOBJ]){set AgentStats = t}
            return AgentStats
    RecordPlayerStat(Agent:agent, Stat:stat_type, ?ParsedValue:int):void=
        AgentStats := GetAgentStats(Agent)
        if(GrantedCurrency :=  AgentStats.AssociatedCurrencies[0]){
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            if(Stat = StatType.MainGold):
                GoldStat := PlayerStatsTable.MainGold
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    MainGold := MakeUpdatedPlayerStat(GoldStat, ParsedValue)
        }
    RecordPlayerCoindDexStat(Agent:agent, Stat:stat_type, CoinIndex:int, CoinValue:int):void=
        AgentStats := GetAgentStats(Agent)
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            if(Stat = StatType.CoinDex):
                CoinDex := PlayerStatsTable.CoinDex
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    CoinDex := MakeUpdatedASCStat(CoinDex,  CoinIndex, CoinValue)
}   

