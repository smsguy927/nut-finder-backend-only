# frozen_string_literal: true

require_relative './deck'

class Board
  attr_reader :cards, :sorted_cards, :nut_combos, :nut_board, :one_card_nuts, :flush_suit, :rank_counts, :pair_type,
              :sf_type, :sf_pair_type, :sf_blocker_ranks, :straight_type

  BOARD_SIZE = 5
  QUADS_COUNTS_SIZE = 2
  QUADS_COUNT = 4
  PAIR_COUNT = 2
  ONE_CARD_NUT_SF_COUNT = 4
  MAX_GAPS_SF_STRAIGHT = 2
  MAX_GAPS_ONE_CARD_SF = 2
  MIN_RANKS_SF_STRAIGHT = 3

  SF_TYPES = {
    ZERO_GAPS: 0,
    ONE_GAP: 1,
    TWO_GAPS: 2,
    RF_STEEL: 3,
    ONE_CARD: 4,
    ONE_CARD_SW: 5,
    STEEL_WHEEL: 6
  }.freeze

  RANKS = %w[A K Q J T 9 8 7 6 5 4 3 2].freeze

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
    set_sf_types
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

  def wheel_card?(str)
    wheel_ranks = %w[2 3 4 5 A]
    wheel_ranks.include?(str)
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

  def set_sf_types
    return if flush_suit.nil?

    set_sf_pair_type if board_paired?
    set_sf_type
  end

  def board_paired?
    @rank_counts.any? { |rank| rank[1] >= PAIR_COUNT }
  end

  def set_sf_pair_type
    # TODO
  end

  def three_consecutive_sf_cards?(sf_ranks)
    i = 0
    i += 1 while sf_ranks[i] == 'A' || sf_ranks[i] == 'K'
    current_rank = sf_ranks[i]
    current_ranks_table_index = RANKS.index(current_rank)
    new_sf_ranks = []
    while i < sf_ranks.size
      if current_ranks_table_index == RANKS.index(current_rank)
        new_sf_ranks.push(current_rank)
        current_ranks_table_index += 1
      else
        new_sf_ranks.clear
        current_ranks_table_index = RANKS.index(sf_ranks[i])
        next
      end
      i += 1
      current_rank = sf_ranks[i]
    end
    new_sf_ranks.size >= MIN_RANKS_SF_STRAIGHT
  end

  def royal_flush_steel_wheel?(sf_ranks)
    return false unless sf_ranks.include?('A')

    broadway_cards = sf_ranks.filter { |rank| broadway_card?(rank) }.size
    wheel_cards = sf_ranks.filter { |rank| wheel_card?(rank) }.size
    broadway_cards >= MIN_RANKS_SF_STRAIGHT && wheel_cards >= MIN_RANKS_SF_STRAIGHT
  end

  def set_steel_wheel(sf_ranks)
    # code here
  end

  def set_sf_type
    sf_ranks = []
    sorted_cards.each do |card|
      sf_ranks.push(card.rank) if card.suit == flush_suit
    end
    if sf_ranks.size >= ONE_CARD_NUT_SF_COUNT
      set_one_card_sf(sf_ranks)
      return
    end
    if three_consecutive_sf_cards?(sf_ranks)
      @sf_type = SF_TYPES[:ZERO_GAPS]
      return
    end
    if royal_flush_steel_wheel?(sf_ranks)
      @sf_type = SF_TYPES[:RF_STEEL]
      puts 'abcabc'
      return
    end
    gaps = 0
    i = 0
    ranks_left = sf_ranks.size
    ranks_index = RANKS.index(sf_ranks[0])
    sf_blockers = []
    sf_cards = 0
    while i < sf_ranks.size - 1
      ranks_left -= 1
      next_rank = sf_ranks[i + 1]
      next_sf_ranks_index = RANKS.index(next_rank)
      gap_size = next_sf_ranks_index - 1 - ranks_index
      gaps += gap_size
      if gaps > MAX_GAPS_SF_STRAIGHT && ranks_left < MIN_RANKS_SF_STRAIGHT
        set_steel_wheel(sf_ranks)
        return
      end

      if gaps > MAX_GAPS_SF_STRAIGHT
        sf_blockers.clear
        gaps = 0
        sf_cards = 0
      else
        sf_cards += 1
        add_gaps(sf_blockers, gap_size, ranks_index + 1)
      end

      i += 1
      ranks_index = next_sf_ranks_index
      puts gaps
      break if sf_cards >= MIN_RANKS_SF_STRAIGHT
    end
    @sf_type = gaps
    set_sf_blockers(sf_blockers)
  end

  def set_one_card_steel_wheel(sf_ranks)
    # code here
  end

  def set_one_card_sf(sf_ranks)
    gaps = 0
    i = 0
    ranks_left = sf_ranks.size
    ranks_index = RANKS.index(sf_ranks[0])
    sf_blockers = []
    sf_cards = []
    while i < sf_ranks.size - 1
      sf_cards.push(sf_ranks[i])
      break if sf_cards.size >= ONE_CARD_NUT_SF_COUNT

      ranks_left -= 1
      next_rank = sf_ranks[i + 1]
      next_sf_ranks_index = RANKS.index(next_rank)
      gap_size = next_sf_ranks_index - 1 - ranks_index
      gaps += gap_size
      if gaps > MAX_GAPS_ONE_CARD_SF && ranks_left < MIN_RANKS_SF_STRAIGHT
        set_one_card_steel_wheel(sf_ranks)
        return
      end

      if gaps > MAX_GAPS_ONE_CARD_SF
        sf_blockers.clear
        gaps = 0
        sf_cards.clear
      else
        add_gaps(sf_blockers, gap_size, ranks_index + 1)
      end

      i += 1
      ranks_index = next_sf_ranks_index
    end
    puts 'tada'
    @sf_type = SF_TYPES[:ONE_CARD]
    set_sf_blockers(sf_blockers)

    @one_card_nuts = if sf_blockers.size.positive?
                       sf_blockers[0]
                     elsif sf_cards[0] == 'A'
                       'T'
                     else
                       RANKS[RANKS.index(sf_cards[0]) - 1]
                     end
  end

  def add_gaps(sf_blockers, gap_size, ranks_index)
    while gap_size.positive?
      sf_blockers.push(RANKS[ranks_index])
      gap_size -= 1
      ranks_index += 1
    end
  end

  def set_sf_blockers(sf_blockers)
    @sf_blocker_ranks = sf_blockers.join
  end
end
