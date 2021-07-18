# Script By Fomar0153
class Game_Battler
 
  Hit_by_attacks_removes_blink = false
  Hit_by_skill_removes_blink = true
  Blink_guards_attacks = true
  Blink_guards_skills = false
  Skill_blinks = [
  {'id'=>1, 'blinks'=>1},
  {'id'=>2, 'blinks'=>2},
  {'id'=>3, 'blinks'=>3}
  ]
 
  attr_accessor :blinks
 
  alias before_blink_initialize initialize
  def initialize
    before_blink_initialize
    @blinks = 0
  end
 
  alias before_blink_skill_effect skill_effect
  def skill_effect(user, skill)
    if Hit_by_skill_removes_blink == true
      @blinks = 0
    end
   
    if @blinks == 0 or Blink_guards_skills == false
     
      for blink_skill in Skill_blinks
        if blink_skill['id'] == skill.id
          @blinks += blink_skill['blinks']
        end
      end
     
      return before_blink_skill_effect(user, skill)
    else
      @blinks -= 1
      self.critical = false
      self.damage = 'Miss'
      return false
    end
   
  end
 
  alias before_blink_attack_effect attack_effect
  def attack_effect(attacker)
    if Hit_by_attacks_removes_blink == true
      @blinks = 0
    end
   
    if @blinks == 0 or Blink_guards_attacks == false
      return before_blink_attack_effect(attacker)
    else
      @blinks -= 1
      self.critical = false
      self.damage = 'Miss'
      return false
    end
  end
 
end