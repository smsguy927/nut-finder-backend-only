# frozen_string_literal: true

require_relative './deck'

class Board
  attr_reader :cards, :sorted_cards, :nut_combos, :nut_board, :one_card_nuts, :flush_suit, :rank_counts, :pair_type,
              :nut_type, :sf_type, :sf_special_type, :sf_alt_nuts, :sf_blocker_ranks, :straight_type

  BOARD_SIZE = 5
  QUADS_COUNTS_SIZE = 2
  QUADS_COUNT = 4
  PAIR_COUNT = 2
  TRIPS_COUNT = 3
  FIRST_CARD_INDEX = 0
  SECOND_CARD_INDEX = 1
  MIDDLE_CARD_INDEX = 2
  FOURTH_CARD_INDEX = 3
  LAST_CARD_INDEX = 4
  ONE_CARD_NUT_SF_COUNT = 4
  MAX_GAPS_SF_STRAIGHT = 2
  MAX_GAPS_ONE_CARD_SF = 2
  MIN_RANKS_SF_STRAIGHT = 3

  SF_TYPES = {
    NOT_A_SF: -1,
    ZERO_GAPS: 0,
    ONE_GAP: 1,
    TWO_GAPS: 2,
    RF_STEEL: 3,
    ONE_CARD: 4,
    ONE_CARD_SW: 5,
    STEEL_WHEEL: 6,
    ROYAL_FLUSH: 7,
    KQJ: 8,
    FOUR_THREE_TWO: 9
  }.freeze

  NUT_TYPES = {
    NUT_BOARD: 0,
    ONE_CARD: 1,
    STRAIGHT_FLUSH: 2,
    QUADS_FULL_HOUSE: 3,
    FLUSH: 4,
    STRAIGHT: 5,
    SET: 6
  }.freeze

  PAIR_TYPES = {
    NO_PAIR: -1,
    PAIR_FIRST_CARD: 0,
    PAIR_SECOND_CARD: 2,
    PAIR_THIRD_CARD: 3,
    PAIR_FOURTH_CARD: 4,
    TWO_PAIR_KICK_FIRST: 5,
    TWO_PAIR_KICK_SECOND: 6,
    TWO_PAIR_KICK_THIRD: 7,
    TRIPS_FIRST_CARD: 8,
    TRIPS_SECOND_CARD: 9,
    TRIPS_THIRD_CARD: 10,
    TRIPS_FOURTH_CARD: 11,
    FULL_HOUSE_TRIPS_HIGH: 12,
    FULL_HOUSE_TRIPS_LOW: 13,
    QUADS: 14,
    QUAD_ACES: 15
  }.freeze

  SF_SPECIAL_TYPES = {
    NONE: -1,
    TRIPS: 0,
    TOP_PAIRED_NEXT_GAP: 1,
    PAIR_IN_GAP: 2,
    FIVES_ON_432: 3,
    TENS_ON_KQJ: 4
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

    set_sf_type
    if sf_type >= SF_TYPES[:ONE_GAP]
      set_sf_alt_nuts
    end
  end

  def board_paired?
    @rank_counts.any? { |rank| rank[1] >= PAIR_COUNT }
  end

  def three_consecutive_sf_cards?(sf_ranks)
    i = 0
    i += 1 while sf_ranks[i] == 'A'
    current_rank = sf_ranks[i]
    current_ranks_table_index = RANKS.index(current_rank)
    new_sf_ranks = []
    while i < sf_ranks.size
      if current_ranks_table_index == RANKS.index(current_rank)
        new_sf_ranks.push(current_rank)
        return true if new_sf_ranks.size >= MIN_RANKS_SF_STRAIGHT

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
    filtered_ranks = find_wheel_ranks(sf_ranks)
    if filtered_ranks.size >= MIN_RANKS_SF_STRAIGHT
      sw_gaps = find_sw_gaps(filtered_ranks)
      set_sf_blockers(sw_gaps)
      @sf_type = SF_TYPES[:STEEL_WHEEL]
    end
  end

  def find_broadway_ranks(sf_ranks)
    sf_ranks.filter { |rank| broadway_card?(rank) }
  end

  def find_rf_gaps(filtered_ranks)
    rf_ranks = %w[A K Q J T]
    rf_ranks.filter { |rank| !filtered_ranks.include?(rank) }
  end

  def set_royal_flush(sf_ranks)
    filtered_ranks = find_broadway_ranks(sf_ranks)
    sw_gaps = find_rf_gaps(filtered_ranks)
    set_sf_blockers(sw_gaps)
  end

  def find_wheel_ranks(ranks)
    ranks.filter { |rank| wheel_card?(rank) }
  end

  def royal_flush?(sf_ranks)
    return false unless sf_ranks.include?('A')

    broadway_cards = sf_ranks.filter { |rank| broadway_card?(rank) }.size
    broadway_cards >= MIN_RANKS_SF_STRAIGHT
  end

  def kqj_straight_flush?(sf_ranks)
    sf_ranks.include?('K') && sf_ranks.include?('Q') && sf_ranks.include?('J')
  end

  def four_32_sf?(sf_ranks)
    sf_ranks.include?('4') && sf_ranks.include?('3') && sf_ranks.include?('2')
  end

  def set_three_consecutive_sf_type(sf_ranks)
    if kqj_straight_flush?(sf_ranks)
      SF_TYPES[:KQJ]
    elsif four_32_sf?(sf_ranks)
      SF_TYPES[:FOUR_THREE_TWO]
    else
      SF_TYPES[:ZERO_GAPS]
    end
  end

  def set_sf_type
    sf_ranks = []
    sorted_cards.each do |card|
      sf_ranks.push(card.rank) if card.suit == flush_suit
    end
    if sf_ranks.size >= ONE_CARD_NUT_SF_COUNT
      set_one_card_sf(sf_ranks)
      return unless @sf_type.nil?
    end
    if three_consecutive_sf_cards?(sf_ranks)
      @sf_type = set_three_consecutive_sf_type(sf_ranks)
      return
    end
    if royal_flush_steel_wheel?(sf_ranks)
      @sf_type = SF_TYPES[:RF_STEEL]
      return
    end
    if royal_flush?(sf_ranks)
      @sf_type = SF_TYPES[:ROYAL_FLUSH]
      set_royal_flush(sf_ranks)
      return
    end
    gaps = 0
    i = 0
    ranks_left = sf_ranks.size
    ranks_index = RANKS.index(sf_ranks[0])
    sf_blockers = []
    sf_cards = 0
    while i < sf_ranks.size - 1
      sf_cards += 1
      break if sf_cards >= MIN_RANKS_SF_STRAIGHT

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

        add_gaps(sf_blockers, gap_size, ranks_index + 1)
      end

      i += 1
      ranks_index = next_sf_ranks_index
      puts gaps

    end

    @sf_type = gaps
    set_sf_blockers(sf_blockers)
  end

  def find_sw_gaps(filtered_ranks)
    sw_ranks = %w[5 4 3 2 A]
    sw_ranks.filter { |rank| !filtered_ranks.include?(rank) }
  end

  def set_one_card_steel_wheel(sf_ranks)
    # code here
    filtered_ranks = sf_ranks.filter do |rank|
      wheel_card?(rank)
    end
    if filtered_ranks.size >= ONE_CARD_NUT_SF_COUNT
      sw_gaps = find_sw_gaps(filtered_ranks)
      set_sf_blockers(sw_gaps)
      @sf_type = SF_TYPES[:ONE_CARD_SW]
    end
  end

  def set_one_card_sf(sf_ranks)
    # TODO: FIX THIS, As Qd 7s 6s 5s is NOT a one card sf!!!
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

    @one_card_nuts = calc_one_card_sf_nuts(sf_blockers, sf_cards)
  end

  def calc_one_card_sf_nuts(sf_blockers, sf_cards)
    if sf_blockers.size.positive?
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

  ###############################################################################################
  def set_sf_alt_nuts
    set_sf_special_type
  end

  def board_trips?
    rank_counts.any?{|rank| rank[1] >= TRIPS_COUNT}
  end

  def top_paired_next_gap?
    rank_counts[sorted_cards[FIRST_CARD_INDEX].rank] == PAIR_COUNT && sorted_cards[MIDDLE_CARD_INDEX].suit != flush_suit && sorted_cards[FOURTH_CARD_INDEX].suit == flush_suit && sorted_cards[LAST_CARD_INDEX].suit == flush_suit
  end

  def pair_in_gap?
    (sorted_cards[FIRST_CARD_INDEX].suit == flush_suit && sorted_cards[LAST_CARD_INDEX].suit == flush_suit && sorted_cards[SECOND_CARD_INDEX].rank == sorted_cards[MIDDLE_CARD_INDEX].rank || sorted_cards[MIDDLE_CARD_INDEX].rank == sorted_cards[FOURTH_CARD_INDEX].rank) || (sorted_cards[FIRST_CARD_INDEX].suit == flush_suit && sorted_cards[SECOND_CARD_INDEX].suit == flush_suit && sorted_cards[MIDDLE_CARD_INDEX].suit == flush_suit && (sorted_cards[FOURTH_CARD_INDEX].rank == 'J' || sorted_cards[FOURTH_CARD_INDEX].rank == 'T') && sorted_cards[FOURTH_CARD_INDEX].rank == sorted_cards[LAST_CARD_INDEX].rank)
  end

  def fives_on_432?
    sorted_cards[FIRST_CARD_INDEX].rank == '5' && sorted_cards[SECOND_CARD_INDEX].rank == '5' && sf_type == SF_TYPES[:FOUR_THREE_TWO]
  end

  def tens_on_kqj?
    sf_type == SF_TYPES[:KQJ] && sorted_cards[FOURTH_CARD_INDEX].rank == 'T' && sorted_cards[LAST_CARD_INDEX].rank == 'T'
  end

  def set_sf_special_type

    return unless board_paired?

    if board_trips?
      @sf_special_type = SF_SPECIAL_TYPES[:TRIPS]
    elsif top_paired_next_gap?
      @sf_special_type = SF_SPECIAL_TYPES[:TOP_PAIRED_NEXT_GAP]
    elsif pair_in_gap?
      @sf_special_type = SF_SPECIAL_TYPES[:PAIR_IN_GAP]
    elsif fives_on_432?
      @sf_special_type = SF_SPECIAL_TYPES[:FIVES_ON_432]
    elsif tens_on_kqj?
      @sf_special_type = SF_SPECIAL_TYPES[:TENS_ON_KQJ]
    end
  end
end
