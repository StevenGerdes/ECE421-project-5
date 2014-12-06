require 'mysql'

UserInfo = Struct.new(:user_name, :played, :wins, :losses)
GameListElement = Struct.new(:id, :user1, :user2, :type)

class Database
  def initialize
    @db = Mysql.new("mysqlsrv.ece.ualberta.ca", "ece421grp3" , "W10mJODQ", "ece421grp3", 13010)
  end

  def close()
    @db.close()
  end

  def get_game_id()
    res = @db.query("SELECT MAX(GameID) FROM SavedGames;");
    row = res.fetch_row
    row[0].to_i
  end

  def record_results(winner, loser, is_tie)
    if !user_exist?(winner)
      add_user(winner)
    end
    if !user_exist?(loser)
      add_user(loser)
    end

    increment_field(winner, 'Played')
    increment_field(loser, 'Played')
    if !is_tie
      increment_field(winner, 'Wins')
      increment_field(loser, 'Losses')
    end
  end

  def get_stats()
    result = Array.new()
    res = @db.query("SELECT * FROM UserStats;")
    while row = res.fetch_row do
      result.push(UserInfo.new(row[0], row[1], row[2], row[3]))
    end
    result
  end

  def get_game_count(username)
    get_count(username, 'Played')
  end

  def get_win_count(username)
    get_count(username, 'Wins')
  end

  def get_loss_count(username)
    get_count(username, 'Losses')
  end

  def print_stats_table()
    res = @db.query("SELECT * FROM UserStats;")
    while row = res.fetch_row do
      printf "%s %s\n", row[0], row[1], row[2], row[3]
    end
  end

  def save_game(game_id, user1, user2, game_state)
    delete_saved_game(game_id)
    @db.query("INSERT INTO SavedGames 
      (GameID, User1, User2, GameType, Board, Turn, LastPlayed)
      VALUES (#{game_id},
             '#{user1}',
             '#{user2}',
             '#{game_state.type}',
             '#{get_board(game_state)}',
              #{game_state.player_turn},
             '#{game_state.last_played.row} #{game_state.last_played.column}');")
  end

  def delete_saved_game(game_id)
    @db.query("DELETE FROM SavedGames WHERE GameID = #{game_id};")
  end

  def get_saved_game(game_id)
    res = @db.query("SELECT Board, GameType, Turn, LastPlayed FROM SavedGames WHERE GameID = #{game_id};")
    row = res.fetch_row
    rows, columns = get_col_row(row[0])
    gs = GameState.new(2, row[1].to_sym, rows, columns)
    set_board(gs, row[0], rows, columns)
    coord = row[3].split
    gs.last_played = Coordinate.new(coord[0].to_i, coord[1].to_i)
    gs.player_turn = row[2].to_i
    gs
  end

  def get_saved_games_list(username)
    result = Array.new()
    res = @db.query("SELECT DISTINCT GameID, User1, User2, GameType FROM SavedGames WHERE User1 = '#{username}' OR User2 = '#{username}';")
    while row = res.fetch_row do
      result.push(GameListElement.new(row[0], row[1], row[2], row[3]))
puts(row[3])
    end
    result
  end

private
  def get_board(game_state)
    result = "#{game_state.rows} #{game_state.columns} "
    (game_state.rows - 1).downto(0) { |i|
      row_matrix = game_state.row i
      for j in 0..game_state.columns - 1
        if row_matrix[j].nil?
          result = result + '-'
        else
          result = result + row_matrix[j].value
        end
      end
      result
    }
  result
  end

  def get_col_row(board)
    splitboard = board.split
    return splitboard[0].to_i, splitboard[1].to_i
  end

  def set_board(gs, board, rows, columns)
    splitboard = board.split
    splittokens = splitboard[2].split(//)
    for i in 0..(rows - 1)
      for j in 0..(columns - 1)
        if splittokens[i*(columns) + j] != '-'
          gs.play(Token.new(splittokens[(i * columns) + j]), Coordinate.new(i, j))
        end
      end
    end
  end

  def increment_field(username, field)
    @db.query("UPDATE UserStats SET #{field} = #{field} + 1 WHERE UserName = '#{username}';")
  end

  def user_exist?(username)
    @db.query("SELECT * FROM UserStats WHERE UserName = '#{username}';")
    @db.affected_rows > 0
  end

  def add_user(username)
    @db.query("INSERT INTO UserStats (UserName) VALUES ('#{username}');");
  end

  def get_count(username, type)
    (@db.query("SELECT #{type} FROM UserStats WHERE UserName = '#{username}';")).fetch_row[0]
  end
end
