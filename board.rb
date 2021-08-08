# frozen_string_literal: true

require_relative './deck'

class Board
  attr_reader :cards, :sorted_cards, :nut_combos, :flush_suit

  def initialize(deck)
    @cards = []
    @sorted_cards = []
    @nut_combos = []
    @flush_suit = ''
    num_cards = 5
    temp_cards = deck.deal!(num_cards)
    temp_cards.each do |card|
      @cards.push(card)
      @sorted_cards.push(card)
    end
    sort
    set_flush_suit
  end

  def display
    cards.map!(&:to_s)
  end

  private

  def sort
    sorted_cards.sort! { |first, second| second <=> first }
  end

  def set_flush_suit
    suit_counts = { c: 0, d: 0, h: 0, s: 0 }
    min_suit_count = 3
    sorted_cards.each do |card|
      suit_counts[card.suit.to_sym] += 1
    end
    suit_counts.filter! { |_key, val| val >= min_suit_count }
    puts suit_counts
    @flush_suit = suit_counts.keys[0].to_s unless suit_counts.empty?
  end
end
