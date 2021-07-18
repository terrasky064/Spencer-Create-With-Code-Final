class Game_Battler
 
  attr_accessor :barrier
 
  alias barrier_initialize initialize
  def initialize
    barrier_initialize
    @barrier = 0
  end
 
  alias skill_effects skill_effect
  def skill_effect(user, skill)
    if skill.id == 1
      self.barrier = self.int
      return true
    end
   
    return skill_effects(user, skill)
  end
 
end


class Scene_Battle
 
  alias barrier_start_phase5 start_phase5
  def start_phase5
    for actor in $game_party.actors
      actor.barrier = 0
    end
   
   
    barrier_start_phase5
  end
 
end

class Game_Battler
 
    def attack_effect(attacker)
    # Clear critical flag
    self.critical = false
    # First hit detection
    hit_result = (rand(100) < attacker.hit)
    # If hit occurs
    if hit_result == true
      # Calculate basic damage
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      # Element correction
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      # If damage value is strictly positive
      if self.damage > 0
        # Critical correction
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # Guard correction
        if self.guarding?
          self.damage /= 2
        end
      end
      # Dispersion
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Second hit detection
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # If hit occurs
    if hit_result == true
      # State Removed by Shock
      remove_states_shock
     
     
      # MODIFIED
      # was originally
      # Substract damage from HP
      #self.hp -= self.damage
     
      if self.barrier == 0
        self.hp -= self.damage
      else
        self.barrier -= self.damage
        if self.barrier < 0
          self.barrier = 0
          self.damage *= 3
          self.hp -= self.damage
        else
          self.damage = '[' + self.damage.to_s + ']'
        end
      end
     
      #END OF MODIFIED
     
      # State change
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # When missing
    else
      # Set damage to "Miss"
      self.damage = "Miss"
      # Clear critical flag
      self.critical = false
    end
    # End Method
    return true
  end
 
end