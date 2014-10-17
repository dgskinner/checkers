require_relative 'board'
require_relative 'piece'
require 'colorize' # ruby gem needed to properly display the board

class FormattingError < StandardError ; end

class NilPieceError < StandardError ; end

class WrongColorError < StandardError ; end

class InvalidMoveError < StandardError ; end

class Game
  attr_reader :board, :current_player, :players
  
  def initialize
    @board = Board.new
    @players = { red: HumanPlayer.new(:red), black: HumanPlayer.new(:black) }
    @current_player = @players[:red]
  end
  
  def play
    system "clear"
    intro_message
    
    until winner?
      begin
        system "clear"
        @board.display
        move_seq = @current_player.get_move
        formatting_error?(move_seq)
        moving_piece_error?(move_seq)
        @board[move_seq[0]].perform_moves(move_seq[1..-1])
      rescue FormattingError
        puts "Must enter coordinate pairs in the correct format."
        sleep(1.5)
        retry
      rescue NilPieceError
        puts "Must choose a space with a piece on it."
        sleep(1.5)
        retry
      rescue WrongColorError
        puts "Must move a piece of your own color."
        sleep(1.5)
        retry
      rescue InvalidMoveError
        puts "Must enter a valid move or sequence of moves."
        sleep(1.5)
        retry
      rescue ArgumentError
        puts "Must enter valid numbers."
        sleep(1.5)
        retry
      end
      
      next_player
    end
    
    @board.display
    puts winner? + " wins!\n\n"
  end
  
  def intro_message
    puts "Welcome!"
    
    yes_no = "n"
    until yes_no == "y"
      puts "\nPlease enter moves as sequences of coordinate"
      puts "pairs separated by spaces. Type the row first"
      puts "and then the column. e.g. '5,2 3,4 1,2' would"
      puts "be a double-jump sequence of moves.\n\n"
      sleep(2.5)
      puts "Got it? (y/n)\n\n"
      yes_no = gets.chomp[0].downcase
    end
  end
  
  def next_player
    if @current_player.color == :red 
      @current_player = @players[:black] 
    else
      @current_player = @players[:red]
    end
  end
  
  def winner?
    return "Red" if @board.pieces.all?{ |piece| piece.color == :red }
    return "Black" if @board.pieces.all?{ |piece| piece.color == :black } 
    false
  end
  
  def formatting_error?(move_seq)
    unless move_seq.length >= 2 && move_seq.all? { |pair| pair.length == 2 }
      raise FormattingError.new
    end
  end
  
  def moving_piece_error?(move_seq)
    raise NilPieceError.new if @board[move_seq[0]].nil?
    raise WrongColorError.new if @board[move_seq[0]].color != @current_player.color
  end
end

class HumanPlayer
  attr_reader :color
  
  def initialize(color)
    @color = color
  end
  
  def get_move
    puts "\nCurrent player: #{color.to_s.capitalize.colorize(color)}"
    puts "Please enter your move.\n\n" 
    move_seq = gets.split(" ").map! do |pair|
      pair.split(",").map! { |n| Integer(n) }
    end
    move_seq
  end
  
end