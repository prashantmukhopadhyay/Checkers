class Board
  attr_reader :tiles

  def initialize(fill_board = true)
    fill_tiles(true)
    display
  end

  def perform_moves
  end

  protected

  def valid_move_sequence?
  end

  def fill_tiles(fill)
    @tiles = Array.new(8) { Array.new(8) }
    place_pieces if fill
  end

  def place_pieces
    #set white and black pieces on board
    (0..7).each do |row|
      @tiles.at(row).each_index do |idx|
        p "row #{row} + col #{idx} % 2 == chk #{col_chk = ( (row + idx) % 2 == 1 )} "
        col_chk = ( (row + idx) % 2 == 1 )
        @tiles[row][idx] = Piece.new(:black, row, idx) if row.between?(0,2) && col_chk
        @tiles[row][idx] = Piece.new(:white, row, idx) if row.between?(5,7) && col_chk
      end
      puts
    end
  end

  def dupleganger
    #double dup for board and pieces
    @tiles.map do |e|
      if e.is_a?(Array)
        e.dupleganger
      elsif e.is_a?(Piece)
        e.dup
      else
        nil
      end
    end
  end

  def display
    @tiles.each do |row|
      row.each do |tile|
        print (!tile.nil? ? tile.char : "").rjust(2)
      end
      puts
    end
  end

end

class Piece
  attr_reader :color, :pos, :char #:dirs

  def initialize(color, *pos)
    @color = color
    @pos = pos
    @char = ( color == :white ? "\u26AA" : "\u26AB" )
    dirs_indices = ( color == :white ? [0, 1] : [2, 3] )
    @dirs = [].tap do |dir|
      dirs_indices.each do |idx|
        dir << [[1,1],[1,-1],[-1,1],[-1,-1]][idx]
      end
    end
  end

  def slide_moves(board)

  end

  def jump_moves
  end

  def perform_slide
  end

  def perform_jump
  end

  def perform_moves!
  end

end

# p Piece.new(:white, 2, 3).pos
# p Piece.new(:white, 2, 3).color
# p Piece.new(:white, 2, 3).dirs

Board.new(true).tiles