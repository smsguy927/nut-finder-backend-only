# frozen_string_literal: true

require_relative './deck'
require_relative './board'

my_deck = Deck.new
my_deck.shuffle
my_board = Board.new(my_deck)
puts 'Board: '
puts my_board.display
puts 'Flush Suit: '
puts my_board.flush_suit
my_deck.sort
puts 'Deck: '
puts my_deck.display
puts 'hello'
