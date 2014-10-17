class Piece

  attr_reader :pos, :color, :king
  
  UNIT_MOVES_RED = [[-1, 1], [-1, -1]]
  UNIT_MOVES_BLACK = [[1, 1], [1, -1]]
  UNIT_JUMPS_RED = [[-2, 2], [-2, -2]]
  UNIT_JUMPS_BLACK = [[2, 2], [2, -2]]
  
  def initialize(pos, board, color, king = false)
    @pos = pos
    @board = board
    @color = color
    @king = king
    @board[pos] = self
  end
  
  def perform_moves(move_seq)
    raise InvalidMoveError.new unless valid_move_seq?(move_seq)
    perform_moves!(move_seq)
    @king = true if promote?
  end
  
  def perform_moves!(move_seq)
    split_into_single_moves(move_seq).each do |pos_pair|
      start_pos, end_pos = pos_pair[0], pos_pair[1]
      
      if move_seq.length == 1
        move_made = @board[start_pos].perform_jump(end_pos) ||
                    @board[start_pos].perform_slide(end_pos)
      else
        move_made = @board[start_pos].perform_jump(end_pos)
      end

      return false unless move_made
    end
    
    true
  end
  
  def split_into_single_moves(move_seq)
    single_moves = [[@pos, move_seq[0]]]
    (move_seq.length - 1).times do |i|
      single_moves << [move_seq[i], move_seq[i + 1]]
    end
    
    single_moves
  end
  
  def valid_move_seq?(move_seq)
    dup_board = @board.dup
    dup_piece = dup_board[@pos]
    return true if dup_piece.perform_moves!(move_seq)
    false
  end
  
  def perform_slide(new_pos)
    return false unless valid_ending_pos?(new_pos) 
    return false unless unit_slides.include?(change_in_pos(new_pos))
    
    @board[@pos] = nil
    @board[new_pos] = self
    @pos = new_pos
    true
  end
  
  def perform_jump(new_pos)
    index = unit_jumps.index(change_in_pos(new_pos))
    
    return false unless valid_ending_pos?(new_pos)
    return false if index.nil? || @board[halfway_pos(index)].nil?
    return false if @board[halfway_pos(index)].color == @color
    
    @board[@pos] = nil
    @board[halfway_pos(index)] = nil
    @board[new_pos] = self
    @pos = new_pos
    true
  end
  
  def valid_ending_pos?(new_pos)
    return false unless on_board?(new_pos) && @board[new_pos].nil?
    true
  end
  
  def on_board?(new_pos)
    new_pos.all? { |i| (0..7).cover?(i) }
  end
  
  def halfway_pos(index)
    [ @pos[0] + unit_slides[index][0], @pos[1] + unit_slides[index][1] ]
  end
  
  def change_in_pos(new_pos)
    [(new_pos[0] - @pos[0]), (new_pos[1] - @pos[1])]
  end
  
  def unit_slides
    return UNIT_MOVES_RED + UNIT_MOVES_BLACK if @king
    @color == :red ? UNIT_MOVES_RED : UNIT_MOVES_BLACK 
  end
  
  def unit_jumps
    return UNIT_JUMPS_RED + UNIT_JUMPS_BLACK if @king
    @color == :red ? UNIT_JUMPS_RED : UNIT_JUMPS_BLACK
  end
  
  def promote?
    return true if @color == :red && @pos[0] == 0
    return true if @color == :black && @pos[0] == 7
    false
  end
end