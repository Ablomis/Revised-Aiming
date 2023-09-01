PlaceObj('ChanceToHitModifier', {
CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
    local num = aim
    local min_bonus = 2
    --local min_dex = self:ResolveValue("MinDex")
    --local dex_scale = self:ResolveValue("DexScale")
    --local dex = attacker.Dexterity

    local aim_level_bonus = attacker.Marksmanship/6
    
    if IsKindOfClasses(weapon1, "FirearmProperties", "MeleeWeaponProperties") then
        min_bonus = weapon1.AimAccuracy
    end
    
    local modifyVal, compDef
    local metaText = {}
    
    -- Light Stock
    modifyVal, compDef = GetComponentEffectValue(weapon1, "ReduceAimAccuracy", "cth_penalty")
    if modifyVal then
        min_bonus = Max(1, MulDivRound(min_bonus, 100 - modifyVal, 100))
        metaText[#metaText + 1] = compDef.DisplayName
    end
    
    local bonus = Min(num * aim_level_bonus,100)
    
    -- target camo
    if IsKindOf(target, "Unit") then
        local armor = target:GetItemInSlot("Torso", "Armor")
        if armor and armor.Camouflage then
            bonus = MulDivRound(bonus, Max(0, 100 - const.Combat.CamoAimPenalty), 100)
            metaText[#metaText + 1] = T(396692757033, "Camouflaged - aiming is less effective")
        end
    end
    
    -- Forward Grip
    modifyVal, compDef = GetComponentEffectValue(weapon1, "FirstAimBonusModifier", "first_aim_bonus")
    if modifyVal then
        bonus = bonus + MulDivRound(min_bonus, modifyVal, 100)
        metaText[#metaText + 1] = compDef.DisplayName
    end
    
    -- Heavy Stock
    if IsFullyAimedAttack(num) then
        modifyVal, compDef = GetComponentEffectValue(weapon1, "BonusAccuracyWhenFullyAimed", "bonus_cth")
        if modifyVal then
            bonus = bonus + modifyVal
            metaText[#metaText + 1] = compDef.DisplayName
        end
    end
    
    -- Improved Sight
    modifyVal, compDef = GetComponentEffectValue(weapon1, "AccuracyBonusWhenAimed", "bonus_cth")
    if modifyVal then
        bonus = bonus + modifyVal
        metaText[#metaText + 1] = compDef.DisplayName
    end
    
    return num > 0, bonus,  T{762331260877, "Aiming (x<aim_mod>)", aim_mod = num}, #metaText ~= 0 and metaText
end,
Parameters = {
    PlaceObj('PresetParamNumber', {
        'Name', "MinBonus",
        'Value', 2,
        'Tag', "<MinBonus>",
    }),
    PlaceObj('PresetParamNumber', {
        'Name', "MinDex",
        'Value', 40,
        'Tag', "<MinDex>",
    }),
    PlaceObj('PresetParamPercent', {
        'Name', "DexScale",
        'Value', 10,
        'Tag', "<DexScale>%",
    }),
},
display_name = T(154175220541, --[[ChanceToHitModifier Default Aim display_name]] "Aiming"),
group = "Default",
id = "Aim",
param_bindings = {},
})

PlaceObj('ChanceToHitModifier', {
	CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
    if attacker and weapon1 and weapon1.PointBlankRange and attacker:IsPointBlankRange(target) then
        return true, attacker.Dexterity/2
    end

	end,
	Parameters = {
		PlaceObj('PresetParamPercent', {
			'Name', "bonus",
			'Value', 15,
			'Tag', "<bonus>%",
		}),
	},
	display_name = T(843386513579, --[[ChanceToHitModifier Default PointBlank display_name]] "Point-Blank Range"),
	group = "Default",
	id = "PointBlank",
})

PlaceObj('ChanceToHitModifier', {
	CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)

        local target_penalty = 100 - attacker.Marksmanship
        local distanceTiles = attacker:GetDist(target)/1000 - 10
        local penalty_per_tile = target_penalty/10.0
        local penalty = - round(penalty_per_tile * distanceTiles + 0.5,1)
        if penalty>-1 then return false,0 end
        
		return true, penalty
	end,
	Parameters = {
	},
	display_name = "Range",
	group = "Default",
	id = "RangePenalty",
})

PlaceObj('ChanceToHitModifier', {
	CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
		local dist = attacker:GetDist(target)/1000
		local cth_bonus = 0
        local diff


		if(weapon1:HasComponent("x5ScopeEffect")) then
			if(dist > GetComponentEffectValue(weapon1, "x5ScopeEffect", "min_dist")) then
				cth_bonus = GetComponentEffectValue(weapon1, "x5ScopeEffect", "cth_bonus")
                return true, cth_bonus
            else
                cth_bonus = -GetComponentEffectValue(weapon1, "x5ScopeEffect", "cth_bonus")
                return true, cth_bonus
            end
		elseif (weapon1:HasComponent("x10ScopeEffect")) then
			if(dist > GetComponentEffectValue(weapon1, "x10ScopeEffect", "min_dist")) then
				cth_bonus = GetComponentEffectValue(weapon1, "x10ScopeEffect", "cth_bonus")
                return true, cth_bonus
			end
		elseif (weapon1:HasComponent("ACOGScopeEffect")) then
			if(dist > GetComponentEffectValue(weapon1, "ACOGScopeEffect", "min_dist")) then
				cth_bonus = GetComponentEffectValue(weapon1, "ACOGScopeEffect", "cth_bonus")
                return true, cth_bonus
			end		
        end
        
        return false, 0
	end,
	group = "Default",
	display_name='Scope',
	id = "SniperScope",
})

PlaceObj('ChanceToHitModifier', {
	CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
    if target:HasStatusEffect("Unconscious") then
        return true, 50
    else
        return false, 0
    end

	end,
	Parameters = {
	},
	display_name = T(843386513579, --[[ChanceToHitModifier Default PointBlank display_name]] "Target Unconscious"),
	group = "Default",
	id = "Unconscious",
})

PlaceObj('ChanceToHitModifier', {
	CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
		if not IsPlayerEnemy(attacker) and IsKindOf(weapon1, "SniperRifle") and not (attacker.stance =='Prone') then
			return true, RevisedSniperConfigValues.NotPronePenalty
		end
		
		return false, 0
	end,
	group = "Default",
	display_name='Not prone',
	id = "WeaponNotDeployed",
}) 
