# frozen_string_literal: true

require_relative './deck'

class Board
  attr_reader :cards

  def initialize(deck)
    @cards = []
    num_cards = 5
    temp_cards = deck.deal!(num_cards)
    temp_cards.each do |card|
      @cards.push(card)
    end
  end

  def display
    cards.map! do |card|
      card.to_s
    end
  end
end
