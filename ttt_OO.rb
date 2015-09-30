class Player
  attr_accessor :name, :letter
  
  def initialize(name)
    @name = name
  end
  
  def to_s
    "#{name} wins!"
  end
  
  def valid_tile?(board)
    puts "Which tile do you select?"
    tile = gets.chomp.to_i
    loop do
      valid_tile = tile_one_thru_nine?(tile)
      unplayed_tiles = tile_already_played?(board, tile)
      break if valid_tile && unplayed_tiles
      puts "Tile #{tile} is not between 1-9 or has already been played."
      puts "Please enter a valid tile number:"
      tile = gets.chomp.to_i
    end
    tile
  end
  
  def tile_one_thru_nine?(tile)
    (1..9).any? { |number| number == tile }
  end

  def tile_already_played?(board, tile)
    %w(X O).none? { |letter| letter == board.tiles[tile] }
  end
  
  def wins?(board, letter)
    Board::WINNING_LINES.each do |line|
      return name if board.tiles.values_at(*line).count(letter) == 3
    end
  nil
  end
end

class User < Player
  def get_name
    system 'clear'
    puts "Welcome to Tic, Tac, Toe!\nWhat is your name?"
    user_name = gets.chomp.capitalize
    while user_name.empty?
      puts "Name must not be blank. What's your name?"
      user_name = gets.chomp.capitalize
    end
    self.name = user_name
  end
  
  def get_letter
    system 'clear'
    puts "Would you like to play as X's or O's? (X/O):"
    user_letter = gets.chomp.upcase
    while ['X', 'O'].none? { |letter| letter == user_letter }
      puts "Invalid selection, select either 'X' or 'O' for your letter:"
      user_letter = gets.chomp.upcase
    end
    self.letter = user_letter
  end
  
  def pick_tile(board, user_letter)
    user_tile = valid_tile?(board)
    board.tiles[user_tile] = user_letter
  end
end

class Computer < Player
  def get_letter(user_letter)
    if user_letter == 'X'
      self.letter = 'O'
    else
      self.letter = 'X'
    end
  end

  def pick_tile(board, comp_letter, user_letter)
    puts "Computer is thinking..."
    sleep 2
    if Board::WINNING_LINES.any? do |two| 
      board.tiles.values_at(*two).count(comp_letter) == 2 && 
      board.tiles.values_at(*two).include?(" ")
    end
      get_smart_tile(board, comp_letter, user_letter)
    elsif Board::WINNING_LINES.any? do |two| 
      board.tiles.values_at(*two).count(user_letter) == 2 && 
      board.tiles.values_at(*two).include?(" ")
    end
      get_smart_tile(board, user_letter, comp_letter, 1)
    else
      get_random_tile(board, comp_letter)
    end
  end
  
  def get_smart_tile(board, letter1, letter2, marker = 0)
    two_in_row = Board::WINNING_LINES.select do |two| 
      board.tiles.values_at(*two).count(letter1) == 2
    end
    two_in_row_open = two_in_row.select do |two| 
      two.none? do |number| 
        board.tiles.values_at(number).include? letter2
      end
    end
    third_tile = two_in_row_open.sample
    third_tiles = third_tile.select { |tile| " " == board.tiles[tile] }
    comp_tile = third_tiles.sample
    if marker == 0
      board.tiles[comp_tile] = letter1
    else
      board.tiles[comp_tile] = letter2
    end
  end

  def get_random_tile(board, comp_letter)
    comp_tile = board.tiles.select { |k, v| " " == v }.keys.sample
    board.tiles[comp_tile] = comp_letter
  end
end

class Board
  attr_reader :tiles
  WINNING_LINES = [[1,2,3], [4,5,6], [7,8,9], [1,4,7], 
                  [2,5,8], [3,6,9], [1,5,9], [3,5,7]]
  
  def initialize
    @tiles = { 1 => " ", 2 => " ", 3 => " ", 4 => " ", 5 => " ", 
                6 => " ", 7 => " ", 8 => " ", 9 => " " }
  end

  def draw_board
    system 'clear'
    puts " #{tiles[1]} | #{tiles[2]} | #{tiles[3]} "
    puts "---+---+---"
    puts " #{tiles[4]} | #{tiles[5]} | #{tiles[6]} "
    puts "---+---+---"
    puts " #{tiles[7]} | #{tiles[8]} | #{tiles[9]} "
  end
  
  def draw_example_board
    system 'clear'
    puts " 1 | 2 | 3 "
    puts "---+---+---"
    puts " 4 | 5 | 6 "
    puts "---+---+---"
    puts " 7 | 8 | 9 "
  end
  
  def open_tiles?
    tiles.values.any? { |tile| tile == " " }
  end
end

class PlayTTT
  attr_reader :user, :computer, :board
  
  def initialize
    @user = User.new("")
    @computer = Computer.new("Computer")
  end
  
  def play_again?
    begin
      puts "Play again? (Y/N):"
      play_again = gets.chomp.upcase
    end until %w(Y N).include? play_again
    play_again
  end
  
  def play
    user.get_name
    begin
      @board = Board.new
      user.get_letter
      computer.get_letter(user.letter)
      board.draw_example_board
      loop do
        user.pick_tile(board, user.letter)
        board.draw_board
        if user.wins?(board, user.letter)
          puts user
          break
        elsif board.open_tiles?
          computer.pick_tile(board, computer.letter, user.letter)
          board.draw_board
          if computer.wins?(board, computer.letter)
            puts computer
            break
          end
        else
          puts "It's a tie."
          break
        end
      end
    end until play_again? == 'N'
  end
end

PlayTTT.new.play