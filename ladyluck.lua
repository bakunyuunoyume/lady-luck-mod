--- STEAMODDED HEADER
--- MOD_NAME: Lady Luck
--- MOD_ID: lady
--- MOD_AUTHOR: [Yume Flamigiri]
--- MOD_DESCRIPTION: A set of pretty Joker ladies
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: F42069
--- DISPLAY_NAME: Lady Luck
--- PRIORITY: 69

----------------------------------------------
------------MOD CODE -------------------------
_RELEASE_MODE = false -- DEBUG MODE :: REMOVE IN RELEASE

SMODS.Atlas{
    key = "jokers",
    path = "jokers.png",
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = "modicon",
    path = "icon.png",
    px = 32,
    py = 32
}

function G.UIDEF.ll_speech_bubble(text_key, loc_vars) 
  local text = {}
  if loc_vars and loc_vars.quip then
    localize{type = 'quips', key = text_key or 'lq_1', vars = loc_vars or {}, nodes = text}
  else
    localize{type = 'tutorial', key = text_key or 'sb_1', vars = loc_vars or {}, nodes = text}
  end
  local row = {}
  for k, v in ipairs(text) do
    row[#row+1] =  {n=G.UIT.R, config={align = "cm"}, nodes=v}
  end
  local t = {n=G.UIT.ROOT, config = {align = "cm", minh = 1,r = 0.3, padding = 0.07, minw = 1, colour = G.C.JOKER_GREY, shadow = true}, nodes={
                {n=G.UIT.C, config={align = "cm", minh = 1,r = 0.2, padding = 0.1, minw = 1, colour = G.C.WHITE}, nodes={
                {n=G.UIT.C, config={align = "cm", minh = 1,r = 0.2, padding = 0.03, minw = 1, colour = G.C.WHITE}, nodes=row}}
                }
              }}
  return t
end

function Card:ll_add_speech_bubble(text_key, align, loc_vars)
    if self.children.speech_bubble then self.children.speech_bubble:remove(); self.children.speech_bubble = nil end
    self.config.speech_bubble_align = {align=align or 'bm', offset = {x=0,y=0},parent = self}
    self.children.speech_bubble = 
    UIBox{
        definition = G.UIDEF.ll_speech_bubble(text_key, loc_vars),
        config = self.config.speech_bubble_align
    }
    self.children.speech_bubble:set_role{
        role_type = 'Minor',
        xy_bond = 'Weak',
        r_bond = 'Strong',
        major = self,
    }
    self.children.speech_bubble.states.visible = false
end

function Card:ll_remove_speech_bubble()
    if self.children.speech_bubble then self.children.speech_bubble:remove(); self.children.speech_bubble = nil end
end

function Card:ll_say_stuff(n, not_first)
    self.talking = true
    if not not_first then 
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                if self.children.speech_bubble then self.children.speech_bubble.states.visible = true end
                self:ll_say_stuff(n, true)
              return true
            end
        }))
    else
        if n <= 0 then self.talking = false; return end
        local new_said = math.random(1, 11)
        while new_said == self.last_said do 
            new_said = math.random(1, 11)
        end
        self.last_said = new_said
        play_sound('voice'..math.random(1, 11), G.SPEEDFACTOR*(math.random()*0.2+1), 0.5)
        self:juice_up()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blockable = false, blocking = false,
            delay = 0.13,
            func = function()
                self:ll_say_stuff(n-1, true)
            return true
            end
        }), 'tutorial')
    end
end

Lady = {
    C = {
		stella = HEX('4EAA3B'),
		fefay = HEX('0F7FFF'),
		somni = HEX('4E3D9F'),
		timpani = HEX('FF3262'),
	}
}

local get_badge_colour_hook = get_badge_colour
function get_badge_colour(_c, _default)
    return Lady.C[_c] or get_badge_colour_hook(_c, _default)
end

-- Cheerleader
SMODS.Joker{
    key = "cheerleader",
    name = "Cheerleader",
    rarity = 1,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 0, y = 0},
    cost = 6,
	
	config = {
	},
    loc_vars = function(self, info_queue, card)
		return {
			vars = {
			}
		}
    end,
	
    loc_txt = {
        name = "Cheerleader",
        text = {
			"Each {C:attention}2{}, {C:attention}4{}, {C:attention}6{}, and {C:attention}8{}",
			"held in hand adds",
			"{C:attention}half{} its rank to Mult"
        }
    },
	
    calculate = function (self, card, context)
		if context.individual and not context.repitition and context.cardarea == G.hand and not context.end_of_round then
			if context.other_card:get_id() == 2 or context.other_card:get_id() == 4 or context.other_card:get_id() == 6 or context.other_card:get_id() == 8 then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED,
						card = card,
					}
				else
					return {
						h_mult = context.other_card:get_id() / 2,
						card = card
					}
				end
			end
		end
    end,
    atlas = "jokers"
}


-- Transformation
SMODS.Joker{
    key = "transformation",
    name = "Transformation",
    rarity = 3,
    discovered = true,
	blueprint_compat = false,
    pos = {x = 1, y = 0},
    cost = 7,
	
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome 
    end,
	
    loc_txt = {
        name = "Transformation",
        text = {
            "If {C:attention}deck{} is empty",
			"when hand is played,",
			"all base edition {C:attention}Jokers{}",
			"become {C:dark_edition}Polychrome{}",
			"{S:1.1,C:red,E:2}self destructs{}"
        }
    },
	
    calculate = function (self, card, context)
		if #G.deck.cards <= 0 and not context.blueprint and not context.repetition and context.before then
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound('tarot1')
					card:start_dissolve()
					return true
				end
			}))
			SMODS.calculate_effect({
				message = "Transform!",
				colour = G.C.RED
			}, card)
			for k, v in ipairs(G.jokers.cards) do
				if v ~= card and not v.edition and (v.area and v.area == G.jokers) then
					v:set_edition({polychrome = true}, true)
				end
			end
		end
    end,
    atlas = "jokers"
}

-- NSFW Joker
SMODS.Joker{
    key = "nsfw_joker",
    name = "NSFW Joker",
    rarity = 2,
    discovered = true,
	blueprint_compat = false,
    pos = {x = 2, y = 0},
    cost = 6,
	
	config = {
		extra = {
			odds = 12,
			x_mult = 2,
		}
	},
	
	loc_vars = function(self, info_queue, card)
        return {
			vars = {
				G.GAME.probabilities.normal,
				card.ability.extra.odds,
				card.ability.extra.x_mult,
			}
		}
    end,
	
    loc_txt = {
        name = "NSFW Joker",
        text = {
			"{X:mult,C:white}X#3#{} Mult, {C:green}#1# in #2#{}",
            "chance to instead",
			"set money to {C:money}$0{}",
			"and {S:1.1,C:red,E:2}self destruct{}",
        }
    },
	
    calculate = function (self, card, context)
		if context.joker_main and not context.repetition and not context.blueprint then
			if pseudorandom("NSFW Joker #2#") < G.GAME.probabilities.normal / card.ability.extra.odds then
				G.E_MANAGER:add_event(Event({
					func = function()
						G.hand_text_area.blind_chips:juice_up()
						G.hand_text_area.game_chips:juice_up()
						play_sound('tarot1')
						if G.GAME.dollars ~= 0 then
							ease_dollars(-G.GAME.dollars, true)
						end
						card:start_dissolve()
						return true
					end
				}))
				return {
					colour = G.C.RED,
					message = "Fell!",
				}
			else
				return {
					message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
					Xmult_mod = card.ability.extra.x_mult, 
					colour = G.C.RED
				}
			end
        end	
    end,
    atlas = "jokers"
}

-- Barista
SMODS.Joker{
    key = "barista",
    name = "Barista",
    rarity = 1,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 3, y = 0},
    cost = 6,
	
	config = {
		extra = {
			h_req = 6,
			h_unused = 0,
		}
	},
	
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_TAGS.tag_voucher
        return {
			vars = {
				card.ability.extra.h_req,
				card.ability.extra.h_unused,
			}
		}
    end,
	
    loc_txt = {
        name = "Barista",
        text = {
            "Create a free {C:attention}Voucher Tag{}",
			"at end of the round for",
			"every {C:chips}#1#{} unused {C:attention}hands{}",
			"{C:inactive}(Currently {}{C:chips}#2#{}{C:inactive}/#1#){}"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Stella Masu', get_badge_colour('stella'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if not context.individual and not context.repetition and context.end_of_round and not context.before and not context.after then
			if not context.blueprint then
				card.ability.extra.h_unused = card.ability.extra.h_unused + G.GAME.current_round.hands_left
				if card.ability.extra.h_unused < card.ability.extra.h_req and card.ability.extra.h_unused ~= 0 then
					return {
						colour = G.C.CHIPS,
						message = card.ability.extra.h_unused.."/"..card.ability.extra.h_req,
					}
				end
			end
			while card.ability.extra.h_unused >= card.ability.extra.h_req do
				if not context.blueprint then
					card.ability.extra.h_unused = card.ability.extra.h_unused - card.ability.extra.h_req
				end
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.4,
					func = (function()
						add_tag(Tag('tag_voucher'))
						play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						if context.blueprint then
							context.blueprint_card:juice_up(0.3, 0.2)
						else
							card:juice_up(0.3, 0.2)
						end
						return true
					end)
				}))
			end
		end
    end,
    atlas = "jokers"
}

-- Goddess of Granite
SMODS.Joker{
    key = "goddess_of_granite",
    name = "Goddess of Granite",
    rarity = 3,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 4, y = 0},
    cost = 8,
	
	config = {
		extra = {
			x_mult = 1,
			a_mult = 1,
		}
	},
	
    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {
			vars = {
				card.ability.extra.x_mult,
				card.ability.extra.a_mult,
			}
		}
    end,
	
    loc_txt = {
        name = "Goddess of Granite",
        text = {
			"{X:mult,C:white}X#1#{} Mult if played hand",
			"contains a {C:attention}Stone Card{},",
			"gains {X:mult,C:white}X#2#{} Mult when a",
			"{C:attention}Stone Card{} is destroyed"
        }
    },
	
    calculate = function (self, card, context)
		if context.joker_main and not context.repetition then
			local stone = false
			for k, v in ipairs(context.scoring_hand) do
				if v.ability.name == 'Stone Card' then stone = true end
            end
			if stone then 
				return {
					message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
					Xmult_mod = card.ability.extra.x_mult, 
					colour = G.C.RED
				}
			end
        end
		
		if context.remove_playing_cards and not context.blueprint then
			local stone_cards = 0
			for k, v in ipairs(context.removed) do
				if v.ability.name == 'Stone Card' then stone_cards = stone_cards + 1 end
			end
			if stone_cards > 0 then
				card.ability.extra.x_mult = card.ability.extra.x_mult + stone_cards*card.ability.extra.a_mult
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.RED
				}
			end
			return
		end
    end,
    atlas = "jokers"
}

-- Downward Dog
SMODS.Joker{
    key = "downward_dog",
    name = "Downward Dog",
    rarity = 2,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 5, y = 0},
    cost = 7,
	
	config = {
		extra = {
			chips = 0,
			a_chips = 12,
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.chips,
				card.ability.extra.a_chips,
			}
		}
    end,
	
    loc_txt = {
        name = "Downward Dog",
        text = {
            "This Joker gains {C:chips}+#2#{} Chips",
			"if played hand is exactly",
			"a {C:attention}face card{}, {C:attention}Ace{}, and {C:attention}2{}",
			"arranged in that {C:attention}order{}",
			"{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Fefay Damia', get_badge_colour('fefay'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
			if #context.full_hand == 3 and context.full_hand[1]:is_face() and context.full_hand[2]:get_id() == 14 and context.full_hand[3]:get_id() == 2 then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.a_chips
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.CHIPS,
					card = card
				}
			end
		end
		
		if context.joker_main and not context.repetition and card.ability.extra.chips > 0 then
            return {
				message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
				chip_mod = card.ability.extra.chips, 
				colour = G.C.CHIPS
			}
        end	
    end,
    atlas = "jokers"
}

-- Swim Ring
SMODS.Joker{
    key = "swim_ring",
    name = "Swim Ring",
    rarity = 1,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 6, y = 0},
    cost = 4,
	
	config = {
		extra = {
			hands = 1
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.hands
			}
		}
    end,
	
    loc_txt = {
        name = "Swim Ring",
        text = {
			"When {C:attention}Boss Blind{}",
			"is selected,",
			"gain {C:chips}+#1#{} Hand"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Fefay Damia', get_badge_colour('fefay'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.setting_blind and not card.getting_sliced and context.blind.boss then
			ease_hands_played(card.ability.extra.hands)
			SMODS.calculate_effect({
				message = "+"..card.ability.extra.hands.." Hand",
				colour = G.C.CHIPS,
			}, context.blueprint_card or card)
		end
    end,
    atlas = "jokers"
}

-- Solar System
SMODS.Joker{
    key = "solar_system",
    name = "Solar System",
    rarity = 3,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 7, y = 0},
    cost = 8,
	
	config = {
		extra = {
			chosen_card = nil,
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.chosen_card
			}
		}
    end,
	
    loc_txt = {
        name = "Solar System",
        text = {
            "In {C:attention}first hand{} of round, a ",
			"{C:attention}random{} scored {C:attention}number card{}",
			"creates its rank's {C:planet}Planet{} card",
			"{C:inactive}(ex:{} {C:attention}A{} {C:inactive}->{} {C:planet}Mercury{}{C:inactive}, {C:attention}2{} {C:inactive}->{} {C:planet}Venus{}{C:inactive}){}",
			"{C:inactive}(Must have room){}"
        }
    },
	
    calculate = function (self, card, context)
		if context.cardarea == G.jokers and context.before and not context.repetition and G.GAME.current_round.hands_played == 0 then
			local numbers = {}
			for i = 1, #context.scoring_hand do
				if (context.scoring_hand[i]:get_id() >= 2 and context.scoring_hand[i]:get_id() <= 10) or context.scoring_hand[i]:get_id() == 14 then
					numbers[#numbers+1] = context.scoring_hand[i]
				end
			end
			if #numbers > 0 then 
				card.ability.extra.chosen_card = pseudorandom_element(numbers, pseudoseed('Solar System'))
			end
		end
		
		if context.individual and not context.repetition and context.cardarea == G.play and context.other_card == card.ability.extra.chosen_card and G.GAME.current_round.hands_played == 0 then
			local chosen_number = context.other_card:get_id()
			if chosen_number == 14 then chosen_number = 1 end
			local planet = nil
			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				local card_type = 'Planet'
				G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
				G.E_MANAGER:add_event(Event({
					trigger = 'before',
					delay = 0.0,
					func = (function()
						local _planet = 'c_pluto'
						if chosen_number == 1 then
							_planet = 'c_mercury'
						elseif chosen_number == 2 then
							_planet = 'c_venus'
						elseif chosen_number == 3 then
							_planet = 'c_earth'
						elseif chosen_number == 4 then
							_planet = 'c_mars'
						elseif chosen_number == 5 then
							_planet = 'c_jupiter'
						elseif chosen_number == 6 then
							_planet = 'c_saturn'
						elseif chosen_number == 7 then
							_planet = 'c_uranus'
						elseif chosen_number == 8 then
							_planet = 'c_neptune'
						elseif chosen_number == 10 and G.GAME.hands["Five of a Kind"].played > 0 then
							_planet = 'c_planet_x'
						end
						local card = create_card(card_type,G.consumeables, nil, nil, nil, nil, _planet, nil)
						card:add_to_deck()
						G.consumeables:emplace(card)
						G.GAME.consumeable_buffer = 0
						return true
					end)}))
				card_eval_status_text(context.other_card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
			end
		end
    end,
    atlas = "jokers"
}

-- Sheet Ghost
function SMODS.current_mod.process_loc_text()
    G.localization.descriptions.Other['perish_in_rounds'] = {
        name = 'Perishable',
        text = {
            "Debuffed after",
            "{C:attention}#1#{} round",
        }
    }
end

SMODS.Joker{
    key = "sheet_ghost",
    name = "Sheet Ghost",
    rarity = 3,
    discovered = true,
	blueprint_compat = false,
    pos = {x = 8, y = 0},
    cost = 8,
	
	config = {
		extra = {
		}
	},
	
    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        return {
			vars = {
				colours = {HEX('4f5da1')}
			},
		}
    end,
	
    loc_txt = {
        name = "Sheet Ghost",
        text = {
			"Each {C:attention}base edition{} Joker",
			"creates a {C:dark_edition}Negative{}, {C:money}$0{} sell",
			"value copy of itself when sold,",
			"{C:attention}destroys{} all {C:dark_edition}Negative{} Jokers at",
			"end of round, and when sold"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Somni Obake', get_badge_colour('somni'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.selling_card and not context.blueprint then
			if context.card.ability.set == 'Joker' then
				if context.card.ability.name ~= "Sheet Ghost" then
					if not context.card.edition then
						local make_card = copy_card(context.card, nil, nil, nil, nil)
						make_card:set_edition({negative = true}, true)
						make_card.sell_cost = 0
						make_card:add_to_deck()
						G.jokers:emplace(make_card)
						SMODS.calculate_effect({
							message = "Haunted!",
							colour = G.C.PURPLE
						}, card)
					end
				end
			end
		end
		
		if context.selling_self and not context.blueprint then 
			for k, v in ipairs(G.jokers.cards) do
				if (v.edition and v.edition.negative) and not (v.ability and v.ability.eternal) then
					v.getting_sliced = true
					G.E_MANAGER:add_event(Event({func = function()
					   v:start_dissolve({G.C.RED}, nil, 1.6)
					return true end }))
				end
			end
			SMODS.calculate_effect({
				message = "Busted!",
				colour = G.C.RED
			}, card)
		end
		
		if context.end_of_round and not context.repetition and not context.blueprint then
			local destroyed = 0
			for k, v in ipairs(G.jokers.cards) do
				if v.ability.name ~= "Sheet Ghost" and (v.area and v.area == G.jokers) and (v.edition and v.edition.negative) and not (v.ability and v.ability.eternal) and not v.getting_sliced then
					v.getting_sliced = true
					destroyed = destroyed + 1
                    G.E_MANAGER:add_event(Event({func = function()
                       v:start_dissolve({G.C.RED}, nil, 1.6)
                    return true end }))
				end
			end
			if destroyed > 0 then
				destroyed = 0
				SMODS.calculate_effect({
					message = "Busted!",
					colour = G.C.RED
				}, card)
			end
		end
    end,
    atlas = "jokers"
}

-- Rabbit Hole
SMODS.Joker{
    key = "rabbit_hole",
    name = "Rabbit Hole",
    rarity = 1,
    discovered = true,
	blueprint_compat = false,
    pos = {x = 9, y = 0},
    cost = 3,
	
	config = {
		extra = {
			dollars = 15,
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.dollars
			}
		}
    end,
	
    loc_txt = {
        name = "Rabbit Hole",
        text = {
            "If out of hands,",
			"lose {C:money}$#1#{} to get",
			"{C:attention,E:1,S:1.1}one more hand{}"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Somni Obake', get_badge_colour('somni'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.before then
			if card.children.speech_bubble then card:ll_remove_speech_bubble() end
		end
		if context.cardarea == G.jokers and context.after and not context.blueprint and not context.repetition then
			if G.GAME.current_round.hands_left == 0 and G.GAME.chips + (hand_chips * mult) < G.GAME.blind.chips then
				if G.GAME.dollars >= card.ability.extra.dollars then
					ease_hands_played(1)
					G.E_MANAGER:add_event(Event({
					trigger = 'before',
					delay = 0.0,
					func = (function()
						ease_dollars(-card.ability.extra.dollars, true)
						return true
					end)}))
					
					local s_key = 'll_rabbit_hole_'..pseudorandom("Rabbit Hole",1,8)
					local text = {}
					localize{type = 'quips', key = s_key, vars = {}, nodes = text}
					local phrase = #text or 1
					
					card:ll_say_stuff(phrase)
					card:ll_add_speech_bubble(s_key, 'bm', {quip = true, text_alignment = "cm"})					
				end
			end
			return false
		end
    end,
    atlas = "jokers"
}

-- Cheeseburger
SMODS.Joker{
    key = "cheeseburger",
    name = "Cheeseburger",
    rarity = 1,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 0, y = 1},
    cost = 4,
	
	config = {
		extra = {
			dollars = 3,
			percent = 25,
			last_hand = 929,
			hit = false,
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.dollars,
				card.ability.extra.percent,
				card.ability.extra.last_hand,
			}
		}
    end,
	
    loc_txt = {
        name = "Cheeseburger",
        text = {
			"Earn {C:money}$#1#{} if played hand",
			"scores {C:attention}less than #2#%{} of",
			"previous hand's chips",
			"{C:inactive}(Currently <{C:inactive}{C:chips}#3#{}{C:inactive}){}"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Stella Masu', get_badge_colour('stella'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.cardarea == G.jokers and not context.repetition and context.before then
			card.ability.extra.hit = false
		end
		
		if context.cardarea == G.jokers and not context.joker_main and not context.repetition and not context.before and context.after then
			if (card.ability.extra.last_hand ~= 0 and (hand_chips * mult) < card.ability.extra.last_hand) or card.ability.extra.hit then
				card.ability.extra.hit = true
				card.ability.extra.last_hand = (hand_chips * mult) * (card.ability.extra.percent / 100)
				return {
					dollars = card.ability.extra.dollars,
					colour = G.C.MONEY
				}
			end
        end
    end,
    atlas = "jokers"
}

-- Gamer Girl
SMODS.Joker{
    key = "gamer_girl",
    name = "Gamer Girl",
    rarity = 2,
    discovered = true,
	blueprint_compat = false,
    pos = {x = 1, y = 1},
    cost = 5,
	
	config = {
		extra = {
			active = false,
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.active
			}
		}
    end,
	
    loc_txt = {
        name = "Gamer Girl",
        text = {
			"After each shop's",
			"first {C:attention}reroll{}, the next",
			"{C:attention}consumable{} card",
			"becomes {C:dark_edition}Negative{}",
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Somni Obake', get_badge_colour('somni'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
			card.ability.extra.active = true
		end 
		
		if card.ability.extra.active and context.reroll_shop then 
			for k, v in ipairs(G.shop_jokers.cards) do
				if card.ability.extra.active and v.ability.consumeable and not v.edition then
					v:set_edition({negative = true}, true)
					card.ability.extra.active = false
				end
			end
		end
    end,
    atlas = "jokers"
}

-- Hypnosis
SMODS.Joker{
    key = "hypnosis",
    name = "Hypnosis",
    rarity = 1,
    discovered = true,
	blueprint_compat = false,
    pos = {x = 2, y = 1},
	soul_pos = {x = 3, y = 1},
    cost = 3,
	
	config = {
		extra = {
		}
	},
	
    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.c_trance
		info_queue[#info_queue+2] = G.P_CENTERS.blue_seal
        return {
			vars = {
				colours = {HEX('4f5da1')}
			},
		}
    end,
	
    loc_txt = {
        name = "Hypnosis",
        text = {
            "{C:spectral}Spectral Packs{} always",
			"contain {C:spectral}Trance{}"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Fefay Damia', get_badge_colour('fefay'), nil, 1)
    end,
	
    calculate = function (self, card, context)
    end,
    atlas = "jokers"
}

SMODS.Booster:take_ownership_by_kind('Spectral', {
    create_card = function(self, card, i)
        if next(SMODS.find_card('j_lady_hypnosis')) and i == 1 then
			return {set = "Spectral", area = G.pack_cards, skip_materialize = true, soulable = true, key = 'c_trance', key_append = "spe"}
		else
			return {set = "Spectral", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "spe"}
		end
    end,
})

-- No Pants Club
SMODS.Joker{
    key = "no_pants_club",
    name = "No Pants Club",
    rarity = 2,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 4, y = 1},
    cost = 6,
	
	config = {
		extra = {
			x_mult = 1,
			x_mult_mod = 0.05,
		}
	},
	
    loc_vars = function(self, info_queue, card)
        return {
			vars = {
				card.ability.extra.x_mult,
				card.ability.extra.x_mult_mod,
			}
		}
    end,
	
    loc_txt = {
        name = "No Pants Club",
        text = {
            "This Joker gains {X:mult,C:white}X#2#{} Mult",
			"per {C:attention}consecutive{} played",
			"{C:attention}poker hand{} that does",
			"not contain a {C:attention}Pair{}",
			"{C:inactive}(Currently{} {X:mult,C:white}X#1#{}{C:inactive} Mult){}"
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Timpani Katsu', get_badge_colour('timpani'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
			if not next(context.poker_hands['Pair']) then
				card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_mod
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.RED,
					card = card
				}
			elseif card.ability.extra.x_mult ~= 1 then
				card.ability.extra.x_mult = 1
				return {
					message = localize('k_reset'),
					colour = G.C.RED,
					card = card
				}
			end
		end
		
		if context.joker_main and not context.repetition then
            return {
				message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
				Xmult_mod = card.ability.extra.x_mult, 
				colour = G.C.RED
			}
        end	
    end,
    atlas = "jokers"
}

-- Celebrity
SMODS.Joker{
    key = "celebrity",
    name = "Celebrity",
    rarity = 1,
    discovered = true,
	blueprint_compat = true,
    pos = {x = 5, y = 1},
    cost = 4,
	
	config = {
		extra = {
			mult = 0,
			mult_mod = 1,
		}
	},
	
    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return {
			vars = {
				card.ability.extra.mult,
				card.ability.extra.mult_mod,
			}
		}
    end,
	
    loc_txt = {
        name = "Celebrity",
        text = {
            "Each played {C:attention}Wild Card{}",
			"gives {C:mult}+#2#{} Mult when",
			"scored for each Wild",
			"Card in your {C:attention}full deck{}",
			"{C:inactive}(Currently {C:red}+#1#{}{C:inactive} Mult){}",
        }
    },
	
	set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Fefay Damia', get_badge_colour('fefay'), nil, 1)
    end,
	
    calculate = function (self, card, context)
		if G.STAGE == G.STAGES.RUN then
			card.ability.extra.mult = 0
            for k, v in pairs(G.playing_cards) do
                if v.ability.name == 'Wild Card' then card.ability.extra.mult = card.ability.extra.mult+card.ability.extra.mult_mod end
            end
		end
		if context.individual then
			if context.other_card.ability.name == 'Wild Card' then
				if context.cardarea == G.play then
					if not context.other_card.debuff then
						return {
							mult = card.ability.extra.mult,
							card = card
						}
					end
				end
			end
		end
    end,
	
    atlas = "jokers"
}

----------------------------------------------
------------MOD CODE END----------------------
