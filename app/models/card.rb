class Card
    SUITS = %w[♠ ♥ ♦ ♣].freeze
    RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze
    
    attr_reader :suit, :rank
    
    def initialize(suit, rank)
      @suit = suit
      @rank = rank
    end
    
    def value
      case @rank
      when 'A' then 1  #A = 1
      when 'J' then 11
      when 'Q' then 12
      when 'K' then 13
      else @rank.to_i  #AJQK以外はそのまま整数に変換して返す
      end
    end
    
    def display_name
      "#{@suit}#{@rank}"  #♥Aなど
    end
    
    def color
      %w[♥ ♦].include?(@suit) ? 'red' : 'black'  #♥ ♦は赤でそれ以外は黒
    end
    
    # デッキ作成（クラスメソッド）
    def self.create_deck
      deck = []  #デッキの初期化
      SUITS.each do |suit|  #各スートに対してループを行う
        RANKS.each do |rank|  #各ランクにもループを行う。→ 各スートに対して全てのランクを組み合わせる。
          deck << new(suit, rank)  #deck配列に全てのスートとランクの組み合わせから作成されたカードが格納される。
        end
      end
      deck.shuffle  #デッキをシャッフルする
    end
  end
  