local Tinkr = ...
local Routine = Tinkr.Routine

-- MaxDps to Tinkr Bridge for Death Knight
-- Load with: /routine load maxdps_dk

-----------------------------
-- Death Knight Spell IDs
-----------------------------
local IceboundFortitude = 48792
local AntiMagicShell = 48707
local DeathStrike = 49998
local LichborneSpell = 49039
local VampiricBlood = 55233  -- Blood spec

-----------------------------
-- Ground-Targeted Spells (need atcursor)
-----------------------------
local GroundTargetSpells = {
    [43265] = true,  -- Death and Decay
    [152280] = true, -- Defile (replaces D&D talent)
    [324128] = true, -- Death's Due (Necrolord ability)
}

-----------------------------
-- Self-Cast Spells
-----------------------------
local SelfCastSpells = {
    [48792] = true,  -- Icebound Fortitude
    [48707] = true,  -- Anti-Magic Shell
    [55233] = true,  -- Vampiric Blood
    [49039] = true,  -- Lichborne
    [47568] = true,  -- Empower Rune Weapon
    [46585] = true,  -- Raise Dead
    [51271] = true,  -- Pillar of Frost
    [207289] = true, -- Unholy Assault
    [315443] = true, -- Abomination Limb
    [279302] = true, -- Frostwyrm's Fury
    [152279] = true, -- Breath of Sindragosa
    [196770] = true, -- Remorseless Winter
    [42650] = true,  -- Army of the Dead
    [63560] = true,  -- Dark Transformation
}

-----------------------------
-- Health Potions (Item IDs)
-----------------------------
local HealthPotions = {
    244835, -- Invigorating Healing Potion (Midnight PTR)
    212241, -- Algari Healing Potion (TWW)
    191380, -- Refreshing Healing Potion (DF)
    5512,   -- Healthstone
}

-----------------------------
-- Settings (adjustable)
-----------------------------
local DEFENSIVE_HP_THRESHOLD = 50  -- Use defensives below this HP %
local POTION_HP_THRESHOLD = 35     -- Use health potion below this HP %

-----------------------------
-- Helper: Use item by ID
-----------------------------
local function useItem(itemId)
    if GetItemCount(itemId) > 0 then
        local start, duration = GetItemCooldown(itemId)
        if start == 0 or (GetTime() - start) >= duration then
            return RunMacroText('/use item:' .. itemId)
        end
    end
    return false
end

-----------------------------
-- Helper: Smart cast spell
-----------------------------
local function smartCast(spellId)
    if not spellId or spellId == 0 then return end

    -- Ground-targeted spells: cast at cursor (target's feet)
    if GroundTargetSpells[spellId] then
        if castable(spellId) then
            return cast(spellId, 'none'):clickunit('target')
        end
        return
    end

    -- Self-cast spells
    if SelfCastSpells[spellId] then
        if castable(spellId) then
            return cast(spellId)
        end
        return
    end

    -- Normal offensive spells: try target first
    if castable(spellId, target) then
        return cast(spellId, target)
    elseif castable(spellId, player) then
        return cast(spellId, player)
    elseif castable(spellId) then
        return cast(spellId)
    end
end

Routine:RegisterRoutine(function()
    -- Ensure MaxDps is loaded
    if not MaxDps or not MaxDps.FrameData then return end

    -- Don't dismount
    if mounted() then return end

    -- Only run in combat
    if not combat() then return end

    local hp = health()

    -----------------------------
    -- Defensive Logic (off-GCD abilities, always check)
    -----------------------------
    -- Health Potion (emergency)
    if hp <= POTION_HP_THRESHOLD then
        for _, itemId in ipairs(HealthPotions) do
            if useItem(itemId) then return end
        end
    end

    -- Icebound Fortitude (off-GCD)
    if hp <= DEFENSIVE_HP_THRESHOLD and castable(IceboundFortitude) then
        return cast(IceboundFortitude)
    end

    -- Vampiric Blood (off-GCD, Blood spec only)
    if hp <= DEFENSIVE_HP_THRESHOLD and castable(VampiricBlood) then
        return cast(VampiricBlood)
    end

    -- Anti-Magic Shell (off-GCD)
    if hp <= DEFENSIVE_HP_THRESHOLD and castable(AntiMagicShell) then
        return cast(AntiMagicShell)
    end

    -----------------------------
    -- MaxDps Rotation (GCD-locked abilities)
    -----------------------------
    -- Only proceed with rotation if GCD is available
    if gcd() > latency() then return end

    -- Require a valid attackable target for rotation
    if not UnitExists(target) then return end
    if not UnitCanAttack(player, target) then return end

    -- Death Strike for self-healing when low (on GCD)
    if hp <= 60 and castable(DeathStrike, target) then
        return cast(DeathStrike, target)
    end

    -- Prepare MaxDps frame data
    MaxDps:PrepareFrameData()
    MaxDps:UpdateAuraData()

    -- Get the next spell from MaxDps
    local nextSpell = MaxDps:NextSpell()

    -- Cast the suggested spell with smart targeting
    return smartCast(nextSpell)

end, Routine.Classes.DeathKnight, 'maxdps_dk')
