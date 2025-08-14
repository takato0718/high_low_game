class GamesController < ApplicationController
  def index
    # ゲーム開始画面
  end

  def show
    initialize_game_if_needed  #必要に応じてゲームを初期化
    
    @current_card = get_current_card  #現在のカード取得
    @score = session[:score]  # 連続正解数
    @remaining_cards = session[:deck].length - session[:current_card_index] - 1  #残りのカード数
    @used_cards = get_used_cards  # 使用済みカード一覧
    @game_over = session[:game_over] || false  #ゲーム終了サイン
    @perfect_clear = @remaining_cards == 0 && !@game_over  #完遂サイン
  end
  
  def guess
    prediction = params[:prediction]  #high or low
    
    initialize_game_if_needed
    return redirect_to game_path(id: 1) if session[:game_over]
    
    result = process_guess(prediction)  #予想結果を判定
    
    if result[:correct]
      session[:score] += 1  # 連続正解数を増やす
      session[:current_card_index] += 1  #次のカードへ進む
      
      # 全カード予想成功チェック
      if session[:current_card_index] >= session[:deck].length - 1  # 51番目のカード（index=50）まで正解すれば、52枚全て予想成功
        flash[:success] = "🎉 パーフェクト！全52枚予想成功！最終スコア: #{session[:score]}"
        session[:game_over] = true
      else
        flash[:success] = "🎯 正解！ #{result[:message]} (連続正解: #{session[:score]})"
      end
    else
      # 一度でも間違えたらゲームオーバー
      session[:game_over] = true
      flash[:error] = "💀 ゲームオーバー！ #{result[:message]} 最終スコア: #{session[:score]}"
    end
    
    redirect_to game_path(id: 1)
  end

  def reset_game_action
    reset_game
    redirect_to game_path(id: 1), notice: "🎮 新しいゲームを開始しました！"
  end
  
  private

  def initialize_game_if_needed
    if session[:deck].blank? || session[:current_card_index].blank?
      reset_game
    end
  end
  
  def reset_game
    deck = Card.create_deck  #52枚のシャッフル済みデッキ作成　（セッションに保存）
    session[:deck] = deck.map { |card| { suit: card.suit, rank: card.rank } }  #オブジェクトはセッションに保存できないので、ハッシュ形式にする。
    session[:current_card_index] = 0  #最初のカードから開始
    session[:score] = 0  #スコア初期化
    session[:game_over] = false  #ゲーム継続
  end
  
  def get_used_cards
    used_cards = []
    (0...session[:current_card_index]).each do |index|  #0から現在のカード未満まで
      card_data = session[:deck][index]
      used_cards << Card.new(card_data['suit'], card_data['rank'])  #オブジェクト復元
    end
    used_cards
  end

  def get_current_card
    card_data = session[:deck][session[:current_card_index]]
    Card.new(card_data['suit'], card_data['rank'])
  end

  def get_next_card
    next_index = session[:current_card_index] + 1
    return nil if next_index >= session[:deck].length
    
    card_data = session[:deck][next_index]
    Card.new(card_data['suit'], card_data['rank'])
  end
  
  def process_guess(prediction)
    current_card = get_current_card  #今表示されてるカード
    next_card = get_next_card  #次に表示されるカード
    
    return { correct: false, message: "山札が空です" } unless next_card
    
    is_higher = next_card.value > current_card.value  #次のカードが大きいか
    is_same = next_card.value == current_card.value  #同じ値か
    
    # 同じ値の場合の処理（引き分けルールを決める）
    if is_same
      # オプション1: 引き分けは正解扱い
      correct = true
      message = "#{current_card.display_name} → #{next_card.display_name} (同じ値！)"
      
      # オプション2: 引き分けは失敗扱い（より厳しいルール）
      # correct = false
      # message = "#{current_card.display_name} → #{next_card.display_name} (引き分けで失敗！)"
    else
      correct = (prediction == 'high' && is_higher) || (prediction == 'low' && !is_higher)  #予想がhighで数字が大きければ正解、予想がlowで数字が大きくなければ正解。
      message = "#{current_card.display_name} → #{next_card.display_name}"
    end
    # prediction = "high", is_higher = true  → 正解
    # prediction = "high", is_higher = false → 不正解
    # prediction = "low",  is_higher = true  → 不正解
    # prediction = "low",  is_higher = false → 正解
    { correct: correct, message: message }
  end
end