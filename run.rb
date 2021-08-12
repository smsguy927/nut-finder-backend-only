# frozen_string_literal: true

require_relative './deck'
require_relative './board'

my_deck = Deck.new
my_deck.shuffle
my_board = Board.new
# my_board.make_board(my_deck)
my_board.make_board_with(%w[4s Qd Qc Qh Kc])
puts 'Board: '
puts my_board.display
puts 'SF Type: '
puts Board::SF_TYPES.key(my_board.sf_type)
puts 'SF Special Type: '
puts Board::SF_SPECIAL_TYPES.key(my_board.sf_special_type)
puts 'Straight Type: '
puts Board::STRAIGHT_TYPES.key(my_board.straight_type)
puts 'Gap Ranks: '
puts my_board.gap_ranks
puts 'Flush Suit: '
puts my_board.flush_suit
puts 'Nut Type: '
puts Board::NUT_TYPES.key(my_board.nut_type)
puts 'Nut Combos: '
puts my_board.nut_combos
puts 'Rank Counts: '
puts my_board.rank_counts
my_deck.sort
# puts 'Deck: '
# puts my_deck.display
puts 'hello'
