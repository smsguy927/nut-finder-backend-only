# frozen_string_literal: true

require_relative './deck'

class Board
  attr_reader :cards, :sorted_cards, :nut_combos, :nut_board, :one_card_nuts, :flush_suit, :rank_counts, :pair_type,
              :sf_type, :sf_pair_type, :straight_type

  BOARD_SIZE = 5
  QUADS_COUNTS_SIZE = 2
  QUADS_COUNT = 4

  def initialize
    @cards = []
    @sorted_cards = []
    @nut_combos = []
    @nut_board = false
  end

  def make_board(deck)
    num_cards = 5
    temp_cards = deck.deal!(num_cards)
    temp_cards.each do |card|
      @cards.push(card)
      @sorted_cards.push(card)
    end
    set_board_attributes
  end

  def make_board_with(arr)
    ranks = %w[x x 2 3 4 5 6 7 8 9 T J Q K A]
    arr.each do |i|
      new_card = {}
      new_card[:rank_id] = ranks.index(i[0].upcase)
      new_card[:rank] = i[0].upcase
      new_card[:suit] = i[1].downcase
      @cards.push(PlayingCard.new(new_card))
      @sorted_cards.push(PlayingCard.new(new_card))
    end
    set_board_attributes
  end

  def display
    cards.map!(&:to_s)
  end

  private

  def sort
    sorted_cards.sort! { |first, second| second <=> first }
  end

  def set_board_attributes
    sort
    set_flush_suit
    set_nut_board
  end

  def set_flush_suit
    suit_counts = { c: 0, d: 0, h: 0, s: 0 }
    min_suit_count = 3
    sorted_cards.each do |card|
      suit_counts[card.suit.to_sym] += 1
    end
    suit_counts.filter! { |_key, val| val >= min_suit_count }
    @flush_suit = suit_counts.keys[0].to_s unless suit_counts.empty?
  end



  def set_nut_board
    set_rank_counts
    @nut_board = true if royal_flush_board?
    @nut_board = true if nut_quads_board?
    @nut_board = true if no_flush_broadway_board?
    puts "Nut Board: #{@nut_board}"
  end

  def set_rank_counts
    rank_counts = {}
    cards.each do |card|
      if rank_counts[card.rank].nil?
        rank_counts[card.rank]  = 1
      else
        rank_counts[card.rank] += 1
      end
    end
    @rank_counts = rank_counts
  end

  def broadway_card?(str)
    broadway_ranks = %w[A K Q J T]
    broadway_ranks.include?(str)
  end

  def royal_flush_board?
    @rank_counts.size == BOARD_SIZE && cards.all?(&:broadway_card?) && cards.all? { |card| card.suit == flush_suit }
  end

  def nut_quads_board?
    board_quads? && board_quads_ace? || board_quad_aces_king?
  end

  def board_quads?
    @rank_counts.any? { |rank| rank[1] == QUADS_COUNT }
  end

  def board_quads_ace?
    @rank_counts['A'] == 1
  end

  def board_quad_aces_king?
    bbb = @rank_counts['A']
    puts bbb
    @rank_counts['A'] == QUADS_COUNT && @rank_counts['K'] == 1
  end

  def no_flush_broadway_board?
    flush_suit.nil? && rank_counts.size == BOARD_SIZE && cards.all?(&:broadway_card?)
  end
end
