# frozen_string_literal: true

class PlayingCard
  include Comparable
  attr_reader :rank_id, :rank, :suit

  def initialize(obj)
    @rank_id = obj[:rank_id]
    @rank = obj[:rank]
    @suit = obj[:suit]
  end

  def broadway_card?
    broadway_ranks = %w[A K Q J T]
    broadway_ranks.include?(rank)
  end

  def to_s
    "#{rank}#{suit}"
  end

  def <=>(other)
    return rank_id <=> other.rank_id if rank_id != other.rank_id 

    suit <=> other.suit
  end
end
