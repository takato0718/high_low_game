class Card
  SUITS = %w[♠ ♥ ♦ ♣].freeze
  RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

  SUIT_SYMBOLS = {
    'spades' => '♠',
    'hearts' => '♥',
    'diamonds' => '♦',
    'clubs' => '♣'
  }.freeze

  attr_reader :suit, :rank

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
  end

  def value
    return 0 if @rank.blank?
    case @rank
    when 'A' then 1  # A = 1
    when 'J' then 11
    when 'Q' then 12
    when 'K' then 13
    else @rank.to_i  # AJQK以外はそのまま整数に変換して返す
    end
  end

  def display_name
    return 'Unknown Card' if @rank.blank? || @suit.blank?
    "#{@suit}#{@rank}" # ♥Aなど
  end

  def color
    return 'black' if @suit.blank?
    %w[♥ ♦].include?(@suit) ? 'red' : 'black' # ♥ ♦は赤でそれ以外は黒
  end

  def suit_symbol
    @suit
  end

  def display_number
    @rank
  end

  def css_classes
    "playing-card #{color}"
  end

  def suit_name
    return 'spades' if @suit.blank?
    case @suit
    when '♠' then 'spades'
    when '♥' then 'hearts'
    when '♦' then 'diamonds'
    when '♣' then 'clubs'
    end
  end

  def sprite_class
    return 'card-unknown' if @rank.blank?
    card_value = case value
                 when 1 then 'A'
                 when 11 then 'J'
                 when 12 then 'Q'
                 when 13 then 'K'
                 else value.to_s
                 end

    "card-#{suit_name}-#{card_value}"
  end

  def image_path
    return 'cards/ace_of_spades.png' if @rank.blank? || @suit.blank? #nil,空文字チェックを行う

    rank_name = case @rank
                when 'A' then 'ace'
                when 'J' then 'jack'
                when 'Q' then 'queen'
                when 'K' then 'king'
                else @rank.to_s.downcase
                end

    "cards/#{rank_name}_of_#{suit_name}.png"
  end

  # デッキ作成（クラスメソッド）
  def self.create_deck
    deck = [] # デッキの初期化
    SUITS.each do |suit| # 各スートに対してループを行う
      RANKS.each do |rank| # 各ランクにもループを行う。→ 各スートに対して全てのランクを組み合わせる。
        deck << new(suit, rank) # deck配列に全てのスートとランクの組み合わせから作成されたカードが格納される。
      end
    end
    deck.shuffle # デッキをシャッフルする
  end
end
