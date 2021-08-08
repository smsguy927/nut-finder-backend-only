# frozen_string_literal: true

require_relative './deck'
require_relative './board'

my_deck = Deck.new
my_deck.shuffle
my_board = Board.new(my_deck)
puts my_board.display

puts my_deck.to_s
puts 'hello'
