# Credit Fomar0153 and Kalina

class Game_Battler
 
  attr_accessor :rough_skin
  attr_accessor :rough_skin_hp_damage
  attr_accessor :rough_skin_hp_damage_percent
  attr_accessor :rough_skin_sp_damage
  attr_accessor :rough_skin_sp_damage_percent
 
  alias rough_skin_initialize initialize
  def initialize
    rough_skin_initialize
    @rough_skin = false
    @rough_skin_hp_damage = 0
    @rough_skin_hp_damage_percent = 50
    @rough_skin_sp_damage = 0
    @rough_skin_sp_damage_percent = 50
  end
 
  alias rough_skin_attack_effect attack_effect
  def attack_effect(attacker)
    attack = rough_skin_attack_effect(attacker)
    if self.rough_skin == true
      attacker.rough_skin_hp_damage = (self.damage.to_i * self.rough_skin_hp_damage_percent)/100
      attacker.rough_skin_sp_damage = (self.damage.to_i * self.rough_skin_sp_damage_percent)/100
    end
    return attack
  end
end