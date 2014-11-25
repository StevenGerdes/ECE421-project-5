#if debug is true the game will be run via a debug console. If it is false it will run the UI
$DEBUG = false
require './game_main'
game = GameMain.new()

if $DEBUG
    puts 'input <player count> <otto_toot or connect4> Ex: 1 connect4'
    ans = gets.split
    game.start_game(ans[0].to_i, ans[1].to_sym)
end
