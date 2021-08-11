# frozen_string_literal: true

require_relative './deck'
require_relative './board'

my_deck = Deck.new
my_deck.shuffle
my_board = Board.new
# my_board.make_board(my_deck)
my_board.make_board_with(%w[As Ks Qs Jc Jd])
puts 'Board: '
puts my_board.display
puts 'SF Type: '
puts Board::SF_TYPES.key(my_board.sf_type)
puts 'SF Blocker Ranks: '
puts my_board.sf_blocker_ranks
puts 'Flush Suit: '
puts my_board.flush_suit
puts 'Rank Counts: '
puts my_board.rank_counts
my_deck.sort
# puts 'Deck: '
# puts my_deck.display
puts 'hello'
