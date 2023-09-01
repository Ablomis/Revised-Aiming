function Unit:CalcChanceToHit(target, action, args, chance_only)
    if not IsPoint(target) and (not IsValid(target) or not IsKindOf(target, "CombatObject")) then
      return 0
    end
    local weapon1, weapon2 = action:GetAttackWeapons(self)
    local weapon = args and args.weapon or weapon1
    if not weapon or IsKindOf(weapon, "Medicine") then
      return 0
    end
    if CheatEnabled("AlwaysHit") then
      return 100
    elseif CheatEnabled("AlwaysMiss") then
      return 0
    end
    local target_spot_group = args and args.target_spot_group or nil
    if type(target_spot_group) == "table" then
      target_spot_group = target_spot_group.id
    end
    target_spot_group = target_spot_group or g_DefaultShotBodyPart
    if type(target_spot_group) == "string" then
      target_spot_group = Presets.TargetBodyPart.Default[target_spot_group]
    end
    local aim = args and args.aim or 0
    local opportunity_attack = args and args.opportunity_attack
    local attacker_pos = args and (args.step_pos or args.goto_pos) or self:GetPos()
    local target_pos = args and args.target_pos or IsPoint(target) and target or target:GetPos()
    local base = 0
    local modifiers = not chance_only and {}
    local skill = self[weapon.base_skill]/2

    if action.id == "SteroidPunch" then
      skill = self.Strength
    end
    base = base + skill

    if args and not args.prediction then
      local effects = {}
      for i, effect in ipairs(self.StatusEffects) do
        effects[i] = effect.class
      end
      effects = table.concat(effects, ",")
      local target_effects = "-"
      if IsKindOf(target, "Unit") then
        target_effects = {}
        for i, effect in ipairs(target.StatusEffects) do
          target_effects[i] = effect.class
        end
        target_effects = table.concat(target_effects, ",")
      end
      NetUpdateHash("CalcChanceToHit_Base", self, target, action.id, weapon.class, weapon.id, base, effects, target_effects, weapon1 and weapon1.class, weapon1 and weapon1.id, weapon1 and weapon1.Condition, weapon1 and weapon1.MaxCondition, weapon2 and weapon2.class, weapon2 and weapon2.id, weapon2 and weapon2.Condition, weapon2 and weapon2.MaxCondition)
    end
    if modifiers then
      self.combat_cache = self.combat_cache or {}
      local key = "base_cth_" .. weapon.base_skill
      local skillmod = self.combat_cache[key]
      if not skillmod then
        local prop_meta = self:GetPropertyMetadata(weapon.base_skill)
        if prop_meta then
          skillmod = {
            name = prop_meta.name,
            value = skill
          }
        else
          skillmod = {
            name = T(462143455900, "Marksmanship"),
            value = skill
          }
        end
        self.combat_cache[key] = skillmod
      end
      table.insert(modifiers, skillmod)
    end
    local mod_data = {
      attacker = self,
      target = target,
      target_spot_group = target_spot_group,
      action = action,
      weapon1 = weapon1,
      weapon2 = weapon2,
      aim = aim,
      opportunity_attack = opportunity_attack,
      attacker_pos = attacker_pos,
      target_pos = target_pos
    }
    ForEachPreset("ChanceToHitModifier", function(mod)
      if mod.RequireTarget and not IsValidTarget(target) then
        return
      end
      local req_action = mod.RequireActionType
      if req_action == "Any Attack" then
        if action.ActionType == "Other" then
          return
        end
      elseif req_action == "Any Melee Attack" then
        if action.ActionType ~= "Melee Attack" then
          return
        end
      elseif req_action == "Any Ranged Attack" then
        if action.ActionType ~= "Ranged Attack" then
          return
        end
      elseif req_action ~= action.id then
        return
      end
      local lof = false
      local apply, value, nameOverride, metaText, idOverride = mod:CalcValue(self, target, target_spot_group, action, weapon, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
      if args and not args.prediction then
        NetUpdateHash("CalcChanceToHit_Modifier", mod.id, apply, value)
      end
      if not apply then
        return
      end
      mod_data.display_name = nameOverride or mod.display_name
      mod_data.meta_text = IsT(metaText) and {metaText} or metaText or nil
      value = self:GatherCTHModifications(mod.id, value, mod_data)
      if args and not args.prediction then
        NetUpdateHash("CalcChanceToHit_Modifier_Mods", mod.id, value)
      end
      local nameOverride = mod_data.display_name
      local metaText = #mod_data.meta_text > 0 and mod_data.meta_text
      base = base + value
      if modifiers then
        table.insert(modifiers, {
          name = nameOverride or mod.display_name,
          value = value,
          id = idOverride or mod.id,
          metaText = metaText
        })
      end
    end)
    for _, effect in ipairs(self.StatusEffects) do
      mod_data.display_name = effect.DisplayName
      mod_data.meta_text = nil
      local value = self:GatherCTHModifications(effect.class, 0, mod_data)
      if args and not args.prediction then
        NetUpdateHash("CalcChanceToHit_Effect_Mods", effect.class, value)
      end
      if value and value ~= 0 then
        base = base + value
        if modifiers then
          table.insert(modifiers, {
            name = mod_data.display_name,
            value = value,
            id = effect.id,
            metaText = mod_data.meta_text
          })
        end
      end
    end
    base = Max(0, base)
    local target_pos = IsPoint(target) and target or target:GetPos()
    local knife_throw = IsKindOf(weapon, "MeleeWeapon") and action.ActionType == "Ranged Attack"
    local penalty = weapon:GetAccuracy(attacker_pos:Dist(target_pos), self, action, knife_throw) - 100
    if action.ActionType == "Ranged Attack" and HasPerk(target, "LightningReaction") and target.stance ~= "Prone" and not target:HasStatusEffect("LightningReactionCounter") then
      if modifiers then
        modifiers[#modifiers + 1] = {
          name = T(530719772440, "Lightning Reactions"),
          value = -base,
          id = "Accuracy",
          uiHidden = true
        }
      end
      base = 0
    end
    local final = Clamp(base + penalty, 0, 100)
    if HasPerk(self, "Spiritual") then
      local minAcc = CharacterEffectDefs.Spiritual:ResolveValue("minAccuracy")
      final = Clamp(final, minAcc, 100)
    end
    if args and not args.prediction then
      NetUpdateHash("CalcChanceToHit_Final", final)
    end
    if chance_only then
      return final
    end
    if penalty ~= 0 then
      if action.ActionType == "Melee Attack" then
        modifiers[#modifiers + 1] = {
          name = T(660754354729, "Weapon Accuracy"),
          value = penalty,
          id = "Accuracy"
        }
      elseif penalty <= -100 then
        modifiers[#modifiers + 1] = {
          name = T(162704513413, "Out of Range"),
          value = penalty,
          id = "Range"
        }
      else
        modifiers[#modifiers + 1] = {
          name = T(301586030557, "Weapon Accuracy"),
          value = penalty,
          id = "Range"
        }
      end
    end
    return final, base, modifiers, penalty
  end