class Board
  attr_accessor :grid
  
  def setup_grid
    @grid = Array.new(8){ Array.new(8) }
  end
  
  def initialize(fill_board = true)
    @grid = setup_grid
    place_pieces if fill_board
  end
  
  def dup
    dup_board = Board.new(false)

    pieces.each do |piece|
      piece.class.new(piece.pos, dup_board, piece.color, piece.king)
    end

    dup_board
  end
  
  def pieces
    @grid.flatten.compact
  end
  
  def place_pieces
    offset = false
    8.times do |row|
      color = (row < 3 ? :black : :red)
      8.times do |col|
        next if (offset ? col.odd? : col.even?) || row.between?(3,4)
        Piece.new([row, col], self, color)
      end
      offset = !offset
    end
  end
  
  def []=(pos, val)
    row, col = pos
    @grid[row][col] = val
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def display
    puts "   0  1  2  3  4  5  6  7"
    (0..7).each do |row|
      print row.to_s + " "
      (0..7).each do |col|
        
        if @grid[row][col] == nil
          print "   ".colorize(:background => :light_black) if (row + col).even? 
          print "   ".colorize(:background => :light_white) if (row + col).odd?
        else 
          if @grid[row][col].king
            print " \u2689 ".colorize(:color => @grid[row][col].color, 
                                      :background => :light_white)
          elsif !@grid[row][col].king
            print " \u2688 ".colorize(:color => @grid[row][col].color, 
                                      :background => :light_white)
          end
        end
        
      end
      puts
    end
  end
  
end
