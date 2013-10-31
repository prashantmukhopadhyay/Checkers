class Board
  attr_reader :tiles

  def initialize(to_fill, tiles = Array.new(8) { Array.new(8) } )
    @tiles = tiles
    fill_tiles(to_fill)
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

  def move_to(from, to)
    self[to[0], to[1]] = self[from[0], from[1]]
    self[from[0], from[1]] = nil
  end

  def fill_tiles(to_fill)
    if to_fill
      place_pieces
      display
    end
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
    duped_tiles = @tiles.collect do |el|
      if el.is_a?(Array)
        el.dup
      elsif el.is_a?(Piece)
        el.dup
      else
        nil
      end
    end
    Board.new(false, duped_tiles)
  end

  def display
    @tiles.each do |row|
      row.each do |tile|
        print (!tile.nil? ? tile.char : "").rjust(2)
      end
      puts
    end
  end

  def remove_jumped_piece(from, to)
    jumped = []
    (0..1).each do |idx|
      jumped[idx] = from[idx] + (to[idx] - from[idx]) / 2
    end

    self[jumped[0], jumped[1]] = nil
  end

end

class Piece
  DIRS = [[-1,1],[-1,-1],[1,1],[1,-1]]

  attr_reader :color, :pos, :char, :dirs

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

  def is_bound?(*pos)
    x, y = pos[0], pos[1]
    return x.between?(0,7) && y.between?(0,7)
  end

  def slide_moves(board)
    pieces = board.tiles.flatten.compact

    [].tap do |sliding_moves|
      @dirs.each do |dir|
        *tpos = pos[0] + dir[0], pos[1] + dir[1]
        condt = !board[*tpos].is_a?(Piece) && is_bound?(*tpos)
        sliding_moves << [tpos[0], tpos[1]] if condt
      end
    end
  end

  def jump_moves(board)
    pieces = board.tiles.flatten.compact

    [].tap do |jump_moves|
      @dirs.each do |dir|
        *mid_pos = pos[0] + dir[0], pos[1] + dir[1]
        *end_pos = pos[0] + (2 * dir[0]), pos[1] + (2 * dir[1])

        if !board[*mid_pos].nil? && board[*end_pos].nil? && is_bound?(*end_pos)
          row, col = end_pos[0], end_pos[1]
          jump_moves << [row, col] if board[*mid_pos].color != self.color
        end
      end
    end
  end

  def perform_slide(board, from, to)
    condt = !slide_moves(board).include?(to) || board[from[0], from[1]] != self
    raise InvalidMoveError if condt
    @pos = to
    board.move_to(from, to)
  end

  def perform_jump(board, from, to)
    condt = !jump_moves(board).include?(to) || board[from[0], from[1]] != self
    raise InvalidMoveError if condt
    @pos = to
    board.move_to(from, to)
    board.remove_jumped_piece(from, to)
  end


  def valid_move_sequence?(board, move_sequence)
    # p board.dupleganger == board
    perform_moves!(board.dupleganger, move_sequence)
    true
  end

  def perform_moves!(board, move_sequence)
    move_sequence.each do |move|
      case move_type(move)
      when 'slide'
        perform_slide(board, pos, move)
      when 'jump'
        perform_jump(board, pos, move)
      when nil
        raise InvalidMoveError
      end
    end
  end

  def perform_moves
  end

  def move_type(move)
    return nil if move.nil?
    (pos[0] - move[0]).abs == 1 ? 'slide' : 'jump'
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

end

b = Board.new(false)
#
p1 = b[4,3] = Piece.new(:white, 4, 3)
# p2 = b[2,1] = Piece.new(:black, 2, 1)
# p3 = b[1,2] = Piece.new(:black, 1, 2)
p4 = b[2,3] = Piece.new(:black, 2, 3)

b.display
p p4.valid_move_sequence?(b, [[3,4], [5,2], [6,1]])
# b.display
p4.perform_moves!(b, [[3,4], [5,2], [6,1]])
b.display
# p p1.jump_moves(b)
# p2.perform_jump(b, [2, 1], [0, 3])
# p3.perform_jump(b, [1, 2], [3, 4])
# p p4.jump_moves(b)
# b.display

class InvalidMoveError < ArgumentError
end
