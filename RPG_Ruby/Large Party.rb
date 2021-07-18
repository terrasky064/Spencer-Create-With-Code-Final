class Game_Party
 
  Max_Party = 5
 
  def max_party
    return Max_Party
  end
 
  def add_actor(actor_id)
    actor = $game_actors[actor_id]
    if not @actors.include?(actor) and $game_party.actors.size < Max_Party
      @actors.push(actor)
      $game_player.refresh
    end
  end
end


class Window_BattleStatus < Window_Base
 
  def initialize
    super(0, 320, 640, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    unless $game_party.actors.size > 4
      @level_up_flags = [false, false, false, false]
    else
      @level_up_flags = []
      for i in 0...$game_party.actors.size
        @level_up_flags.push(false)
      end
    end
    refresh
  end
 
  def refresh
    self.contents.clear
    @item_max = $game_party.actors.size
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      unless $game_party.actors.size > 4
        actor_x = i * 160 + 4
      else
        actor_x = i * (4 + (640/ $game_party.actors.size))
      end
      draw_actor_name(actor, actor_x, 0)
      draw_actor_hp(actor, actor_x, 32, 120)
      draw_actor_sp(actor, actor_x, 64, 120)
      if @level_up_flags[i]
        self.contents.font.color = normal_color
        self.contents.draw_text(actor_x, 96, 120, 32, "LEVEL UP!")
      else
        draw_actor_state(actor, actor_x, 96)
      end
    end
  end
end


class Game_Actor < Game_Battler
  def screen_x
    if self.index != nil
      unless $game_party.actors.size > 4
        return self.index * 160 + 80
      else
        return self.index * (640/ $game_party.actors.size) + (80/($game_party.actors.size/2))
      end
    else
      return 0
    end
  end
end


class Scene_Battle
  def phase3_setup_command_window
    @party_command_window.active = false
    @party_command_window.visible = false
    @actor_command_window.active = true
    @actor_command_window.visible = true
    unless $game_party.actors.size > 4
      @actor_command_window.x = @actor_index * 160
    else
      @actor_command_window.x = @actor_index * (640/$game_party.actors.size)
      if @actor_command_window.x > 480
        @actor_command_window.x = 480
      end
    end
    @actor_command_window.index = 0
  end
end

class Window_MenuStatus < Window_Selectable
 
  def initialize
    unless $game_party.actors.size > 4
      super(0, 0, 480, 480)
    else
      super(0, 0, 480, 160 * $game_party.actors.size)
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
    self.active = false
    self.index = -1
  end
 
  alias large_refresh refresh
  def refresh
    large_refresh
    self.height = 480
  end
 
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cursor_width = self.width / @column_max - 32
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 116 - self.oy
    self.cursor_rect.set(x, y, cursor_width, 96)
  end
 
  def top_row
    return self.oy / 116
  end
 
  def top_row=(row)
    if row < 0
      row = 0
    end
    if row > row_max - 1
      row = row_max - 1
    end
    self.oy = row * 116
  end
 
  def page_row_max
    return 4
  end
end