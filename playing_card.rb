class PlayingCard
  attr_reader :rank_id, :rank, :suit

  def initialize(obj)
    @rank_id = obj[:rank_id]
    @rank = obj[:rank]
    @suit = obj[:suit]
  end

  def to_s
    "#{rank}#{suit}"
  end
end
