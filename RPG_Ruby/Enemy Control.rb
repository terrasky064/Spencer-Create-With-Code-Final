# CONSTANTS
class Game_Enemy < Game_Battler
  Type_1_success_rate = 75
  Type_2_success_rate = 50
  Type_3_success_rate = 25
  Type_4_success_rate = 0
  Type_1_enemies = [1, 2, 3, 4, 5, 6, 7, 8]
  Type_2_enemies = [9, 10, 11, 12, 13, 14, 15, 16]
  Type_3_enemies = [17, 18, 19, 20, 21, 22, 23, 24]
  Type_4_enemies = [25, 26, 27, 28, 29, 30, 31, 32]
  Control_ID = 17
end

class Window_Skill < Window_Selectable
  Enemy_Skills = [
  {'id'=>3, 'skills'=>[16]},
  {'id'=>4, 'skills'=>[33]}
  ]
end
# END OF CONSTANTS

class Game_Battler
 
  alias pre_control_attack_effect attack_effect
  def attack_effect(attacker)
    if attacker.is_a?(Game_Actor)
      if attacker.control_enemy >= 0
        enemy = $game_troop.enemies[attacker.control_enemy]
        unless enemy.dead?
          pre_control_attack_effect(enemy)
        else
          enemy.controlled = false
          attacker.control_enemy = -1
        end
        return
      end
    end
    pre_control_attack_effect(attacker)
  end
 
  alias pre_control_skill_effect skill_effect
  def skill_effect(user, skill)
    if user.is_a?(Game_Actor)
      if user.control_enemy >= 0
        enemy = $game_troop.enemies[user.control_enemy]
        unless enemy.dead?
          pre_control_skill_effect(enemy, skill)
        else
          enemy.controlled = false
          attacker.control_enemy = -1
        end
        return
      end
    end
    pre_control_skill_effect(user, skill)
  end
 
end



class Game_Actor < Game_Battler
 
  attr_accessor :control_enemy
 
  alias pre_control_initialize initialize
  def initialize(actor_id)
    pre_control_initialize(actor_id)
    @control_enemy = -1
  end
 
  alias pre_control_skill_can_use? skill_can_use?
  def skill_can_use?(skill_id)
    unless @control_enemy >= 0
      return pre_control_skill_can_use?(skill_id)
    else
      enemy = $game_troop.enemies[@control_enemy]
      unless enemy.skill_can_use?(skill_id)
        return false
      else
        return true
      end
    end
  end
 
end



class Game_Enemy < Game_Battler
 
  attr_accessor :controlled
 
  alias pre_control_initialize initialize
  def initialize(troop_id, member_index)
    pre_control_initialize(troop_id, member_index)
    @controlled = false
  end
 
  def movable?
    return (super and not @controlled)
  end
 
  def skill_effect(user, skill)
    super(user, skill)
    if skill.element_set.include?(Control_ID)
      x = rand(100) + 1
      if Type_1_enemies.include?(self.id) and x < Type_1_success_rate
        user.control_enemy = @member_index
        @controlled = true
        @current_action.clear
      end
      if Type_2_enemies.include?(self.id) and x < Type_2_success_rate
        user.control_enemy = @member_index
        @controlled = true
        @current_action.clear
      end
      if Type_3_enemies.include?(self.id) and x < Type_3_success_rate
        user.control_enemy = @member_index
        @controlled = true
        @current_action.clear
      end
      if Type_4_enemies.include?(self.id) and x < Type_4_success_rate
        user.control_enemy = @member_index
        @controlled = true
        @current_action.clear
      end
    end
  end
 
 
end



class Scene_Battle
 
  alias pre_control_start_phase3 start_phase3
  def start_phase3
    for actor in $game_party.actors
      if actor.control_enemy >= 0 and actor.dead?
        $game_troop.enemies[actor.control_enemy].controlled = false
        actor.control_enemy = -1
      end
    end
    pre_control_start_phase3
  end
 
  alias pre_control_start_phase5 start_phase5
  def start_phase5
    for actor in $game_party.actors
      actor.control_enemy = -1
    end
    pre_control_start_phase5
  end
 
  alias pre_control_phase3_setup_command_window phase3_setup_command_window
  def phase3_setup_command_window
    @actor_command_window.dispose
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    unless $game_party.actors[@actor_index].control_enemy >= 0
      s4 = $data_system.words.item
    else
      enemy = $game_troop.enemies[$game_party.actors[@actor_index].control_enemy]
      unless enemy.dead?
        s4 = 'Release'
      else
        s4 = $data_system.words.item
        enemy.controlled = false
        $game_party.actors[@actor_index].control_enemy = -1
      end
    end
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    pre_control_phase3_setup_command_window
  end
 
 
  def make_basic_action_result
    # If attack
    if @active_battler.current_action.basic == 0
      # Set anaimation ID
     
     
     
      # MODIFICATIONS IF YOU NEED TO MERGE THIS
      # ORGINALLY
      #@animation1_id = @active_battler.animation1_id
      #@animation2_id = @active_battler.animation2_id
     
      unless @active_battler.is_a?(Game_Actor) and @active_battler.control_enemy >= 0
        @animation1_id = @active_battler.animation1_id
        @animation2_id = @active_battler.animation2_id
      else
        enemy = $game_troop.enemies[@active_battler.control_enemy]
        @animation1_id = enemy.animation1_id
        @animation2_id = enemy.animation2_id
      end
     
     
      # END OF THE MODIFICATIONS
     
     
     
      # If action battler is enemy
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # If action battler is actor
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # Set array of targeted battlers
      @target_battlers = [target]
      # Apply normal attack results
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    # If guard
    if @active_battler.current_action.basic == 1
      # Display "Guard" in help window
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # If escape
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # Display "Escape" in help window
      @help_window.set_text("Escape", 1)
      # Escape
      @active_battler.escape
      return
    end
    # If doing nothing
    if @active_battler.current_action.basic == 3
      # Clear battler being forced into action
      $game_temp.forcing_battler = nil
      # Shift to step 1
      @phase4_step = 1
      return
    end
   
    # MODIFICATIONS IF YOU NEED TO MERGE THIS
    # If cancelling control of enemy
    if @active_battler.current_action.basic == 4
      enemy = $game_troop.enemies[@active_battler.control_enemy]
      text = @active_battler.name + ' releases his control over ' + enemy.name
      @wait_count = 20
      @help_window.set_text(text, 1)
      enemy.controlled = false
      @active_battler.control_enemy = -1
      return
    end
   
   
    # END OF THE MODIFICATIONS
   
  end
 
  def make_skill_action_result
    # Get skill
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # If not a forcing action
    unless @active_battler.current_action.forcing
      # If unable to use due to SP running out
      unless @active_battler.skill_can_use?(@skill.id)
        # Clear battler being forced into action
        $game_temp.forcing_battler = nil
        # Shift to step 1
        @phase4_step = 1
        return
      end
    end
    # Use up SP
   
   
   
    # MODIFICATIONS IF YOU NEED TO MERGE THIS
    # ORIGINALLY
    #@active_battler.sp -= @skill.sp_cost
    unless @active_battler.is_a?(Game_Actor) and @active_battler.control_enemy >= 0
      @active_battler.sp -= @skill.sp_cost
    else
      $game_troop.enemies[@active_battler.control_enemy].sp -= @skill.sp_cost
    end
   
    # END OF THE MODIFICATIONS
   
   
   
    # Refresh status window
    @status_window.refresh
    # Show skill name on help window
    @help_window.set_text(@skill.name, 1)
    # Set animation ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # Set command event ID
    @common_event_id = @skill.common_event_id
    # Set target battlers
    set_target_battlers(@skill.scope)
    # Apply skill effect
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
 
  def update_phase4_step3
    # Animation for action performer (if ID is 0, then white flash)
   
    # MODIFICATIONS IF YOU NEED TO MERGE THIS
    # ORIGINALLY
    #if @animation1_id == 0
    #  @active_battler.white_flash = true
    #else
    #  @active_battler.animation_id = @animation1_id
    #  @active_battler.animation_hit = true
    #end
    ## Shift to step 4
    #@phase4_step = 4
   
    unless @active_battler.is_a?(Game_Actor) and @active_battler.control_enemy >= 0
      if @animation1_id == 0
        @active_battler.white_flash = true
      else
        @active_battler.animation_id = @animation1_id
        @active_battler.animation_hit = true
      end
    else
      enemy = $game_troop.enemies[@active_battler.control_enemy]
      if @animation1_id == 0
        enemy.white_flash = true
      else
        enemy.animation_id = @animation1_id
        enemy.animation_hit = true
      end
    end
      # Shift to step 4
      @phase4_step = 4
   
    # END OF THE MODIFICATIONS
     
  end
 
 
  alias pre_control_start_item_select start_item_select
  def start_item_select
    unless @active_battler.control_enemy >= 0
      pre_control_start_item_select
    else
      @active_battler.current_action.kind = 0
      @active_battler.current_action.basic = 4
      phase3_next_actor
    end
  end
 
 
end


class Window_Skill < Window_Selectable
 
  alias pre_control_refresh refresh
  def refresh
   
    unless @actor.control_enemy >= 0
      pre_control_refresh
      return
    end
   
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    enemy = $game_troop.enemies[@actor.control_enemy]
    skills = []
    for i in 0...Enemy_Skills.size
      hash = Enemy_Skills[i]
      if hash['id'] == enemy.id
        skills = hash['skills']
      end
    end
    unless skills == []
      for i in skills
        skill = $data_skills[i]
        if skill != nil
          @data.push(skill)
        end
      end
    end
    # If item count is not 0, make a bit map and draw all items
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
 
end