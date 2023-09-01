return PlaceObj('ModDef', {
	'title', "Revised Aiming",
	'description', "[b]WHY[/b]: do you know that in vanilla JA3, Hitman with 88 marksmanship gets almost no benefit from aiming? And that Mouse (with 69 marksmanship) when fully aimed is as accurate as Hitman? And if you add more aiming levels she will be more accurate? This is because aiming bonus is powered by Dexterity not marksmanship.\n\n[b]WHAT[/b]: This mod changes aiming mechanics to make mercs more diverse and true to their profiles.Snipers should be able to take precise shots and skirmishers to be better at reflex shooting.\n\n[b]HOW[/b]\n[list]\n    [*]An unaimed shot is based of merc's dexterity and marksmanship. So mercs with higher dexterity will be better at reflex shots.\n	[*]Aiming is based on Experience, Marksmanship and Weapon accuracy\n	[*]A merc with high marksmanship will get more bonus from aiming\n	[*]A merc with high dexterity will be a better reflex shooter\n	[*]It slightly lowers CTH across the board that will be especially noticable for mercs that a poor shooters.\n[/list]\n[b]CTH DETAILS[/b]\n[list]\n    [*]Base accuracy: Marksmanship/2\n	[*]PointBlank bonus is Dexterity/2 (siginifcant bonus for hi dex mercs)\n	[*]Aim increase per level is Marksmanship/6\n	[*]Gun AimAccuracy now impacts range penalty\n\nThe mod doesn't interfere with any CTH modifiers besides aiming, so other mods can be used together.\n\nCompatibility restrictions: not compatible with mods that make changes to CalcChanceToHit method",
	'image', "Mod/HjsFasU/JA3Revised-Recovered.png",
	'last_changes', "Bumped unconscious mod",
	'id', "HjsFasU",
	'author', "Ablomis",
	'version', 44,
	'lua_revision', 233360,
	'saved_with_revision', 340446,
	'code', {
		"Code/CTH.lua",
		"Code/CalcChanceToHit.lua",
		"Code/Config.lua",
		"Code/GetRangeAccuracy.lua",
	},
	'saved', 1693458576,
	'code_hash', -8657176309357473464,
	'steam_id', "3024750899",
})