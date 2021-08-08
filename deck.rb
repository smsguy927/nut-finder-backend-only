# frozen_string_literal: true

require_relative './playing_card'

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    min_rank_id = 2
    max_rank_id = 14
    ranks = %w[x x 2 3 4 5 6 7 8 9 T J Q K A]
    suits = %w[c d h s]

    (min_rank_id..max_rank_id).each do |i|
      suits.each do |j|
        new_card = {}
        new_card[:rank_id] = i
        new_card[:rank] = ranks[i]
        new_card[:suit] = j
        @cards.push(PlayingCard.new(new_card))
      end
    end
  end

  def deal!(num_cards = 1)
    cards.shift(num_cards)
  end

  # def to_s
  #   cards.map do |card|
  #     card
  #   end
  # end

  def shuffle
    cards.shuffle!(random: Random.new)
  end
end
