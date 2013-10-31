class Board
  attr_reader :tiles

  def initialize(fill_board = true)
    fill_tiles(fill_board)
    display
  end

  def perform_moves
  end

  # protected

  # def [](pos)
  #    puts "regular [[pos]] called"
  #    self[pos[0],pos[1]] if pos.is_a?(Array)
  # end

  def [](*pos)
    # puts "splat [*pos] called"
    @tiles[pos[0]][pos[1]]
  end

  def []=(*pos, val)
    @tiles[pos[0]][pos[1]] = val
  end

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
        col_chk = ( (row + idx) % 2 == 1 )
        @tiles[row][idx] = Piece.new(:black, row, idx) if row.between?(0,2) && col_chk
        @tiles[row][idx] = Piece.new(:white, row, idx) if row.between?(5,7) && col_chk
      end
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
  DIRS = [[-1,1],[-1,-1],[1,1],[1,-1]]

  attr_reader :color, :pos, :char #:dirs

  def initialize(color, *pos)
    @color = color
    @pos = pos
    @char = ( color == :white ? "\u26AA" : "\u26AB" )
    dirs_indices = ( color == :white ? [0, 1] : [2, 3] )
    @dirs = [].tap do |directions|
      dirs_indices.each do |idx|
        directions << DIRS[idx]
      end
    end
    @promoted = false
  end

  def slide_moves(board)
    pieces = board.tiles.flatten.compact

    [].tap do |sliding_moves|
      @dirs.each do |dir|
        *tpos = pos[0] + dir[0], pos[1] + dir[1]
        sliding_moves << [tpos[0], tpos[1]] unless board[*tpos].is_a?(Piece)
      end
    end
  end

  def can_promote?
    row = pos[0]
    color == :white ? ( row == 0 ? true : false ) : ( row == 7 ? true : false )
  end

  def promoted?
    @promoted
  end

  def promote
    @promoted = true
    @dirs = DIRS
  end

  # def adjacent_pieces(board)
  #   pieces = board.tiles.flatten.compact
  #
  #   diag_piece_positions.each do |diag_pos|
  #     diag_pieces = pieces.select { |piece| piece.pos == diag_pos }
  #   end
  #
  #   if promoted?
  #     str_piece_positions.each do |str_pos|
  #       str_pieces = pieces.select { |piece| piece.pos == str_pos }
  #     end
  #   else
  #     str_pieces = []
  #   end
  #
  #   diag_pieces + str_pieces
  # end

  def jump_moves(board)
    # can_kill = adjacent_pieces.select{ |piece| piece.color != self.color }

    pieces = board.tiles.flatten.compact

    [].tap do |jump_moves|
      @dirs.each do |dir|
        *mid_pos = pos[0] + dir[0], pos[1] + dir[1]
        *end_pos = pos[0] + (2 * dir[0]), pos[1] + (2 * dir[1])

        if !board[*mid_pos].nil? && board[*end_pos].nil?
          row, col = end_pos[0], end_pos[1]
          jump_moves << [row, col] if board[*mid_pos].color != self.color
        end
      end
    end
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

b = Board.new(false)
# p b[5,2].slide_moves(b)
# p b[6,1].slide_moves(b)
# p b[2,1].slide_moves(b)
# p b[0,1].slide_moves(b)

b[2,1] = Piece.new(:white, 2, 1)
b[2,3] = Piece.new(:white, 2, 1)
b[1,2] = Piece.new(:black, 1, 2)
b.display
#p b[2,1].jump_moves(b)
p b[1,2].jump_moves(b)
# p b[2,1].slide_moves(b)
# p b[1,2].slide_moves(b)

