class GamesController < ApplicationController
  def index
    # ゲーム開始画面
  end

  def show
    initialize_game_if_needed # 必要に応じてゲームを初期化
    setup_game_variables
  end

  def guess
    prediction = params[:prediction] # high or low

    initialize_game_if_needed
    return redirect_to game_path(id: 1) if session[:game_over]

    process_user_guess(prediction) # 予想結果を判定
    redirect_to game_path(id: 1)
  end

  def reset_game_action
    reset_game
    redirect_to game_path(id: 1), notice: t('games.messages.new_game_started')
  end

  private

  def initialize_game_if_needed
    return unless session[:deck].blank? || session[:current_card_index].blank?

    reset_game
  end

  def reset_game
    deck = Card.create_deck # 52枚のシャッフル済みデッキ作成　（セッションに保存）
    session[:deck] = serialize_deck(deck)
    session[:current_card_index] = 0 # 最初のカードから開始
    session[:score] = 0 # スコア初期化
    session[:game_over] = false # ゲーム継続
  end

  def setup_game_variables
    @current_card = current_card #現在のカード取得
    @score = session[:score] #連続正解数
    @remaining_cards = calculate_remaining_cards #残りのカード
    @used_cards = used_cards #使用済みカード
    @game_over = session[:game_over] || false #ゲーム終了サイン
    @perfect_clear = perfect_clear? #完遂サイン
  end

  def process_user_guess(prediction)
    result = evaluate_guess(prediction)
    
    if result[:correct]
      handle_correct_guess(result)
    else
      handle_incorrect_guess(result)
    end
  end
#正解時の処理
  def handle_correct_guess(result)
    session[:score] += 1
    session[:current_card_index] += 1

    if perfect_game_completed?
      handle_perfect_completion
    else
      flash[:success] = t('games.messages.correct_answer', 
                         message: result[:message], 
                         score: session[:score])
    end
  end
#不正解時の処理
  def handle_incorrect_guess(result)
    session[:game_over] = true
    flash[:error] = t('games.messages.game_over', 
                     message: result[:message], 
                     score: session[:score])
  end
#パーフェクト時の処理
  def handle_perfect_completion
    flash[:success] = t('games.messages.perfect_clear', score: session[:score])
    session[:game_over] = true
  end

  def used_cards
    @used_cards ||= build_used_cards_array
  end

  def current_card
    @current_card ||= build_card_from_session(session[:current_card_index])
  end

  def next_card
    @next_card ||= build_card_from_session(session[:current_card_index] + 1)
  end

  def serialize_deck(deck)
    deck.map { |card| { suit: card.suit, rank: card.rank } }
  end


  def build_used_cards_array
    (0...session[:current_card_index]).map do |index|
      build_card_from_session(index)
    end
  end

  def build_card_from_session(index)
    return nil if index >= session[:deck].length
    
    card_data = session[:deck][index]
    Card.new(card_data['suit'], card_data['rank'])
  end

  def calculate_remaining_cards
    session[:deck].length - session[:current_card_index] - 1
  end

  def perfect_clear?
    calculate_remaining_cards.zero? && !session[:game_over]
  end

  def perfect_game_completed?
    session[:current_card_index] >= session[:deck].length - 1
  end

  #  予想評価ロジック
  def evaluate_guess(prediction)
    current = current_card
    next_card_obj = next_card

    return build_error_result('山札が空です') unless next_card_obj

    comparison_result = compare_cards(current, next_card_obj, prediction)
    build_success_result(current, next_card_obj, comparison_result)
  end

  def compare_cards(current_card, next_card, prediction)
    return :tie if next_card.value == current_card.value
    
    is_higher = next_card.value > current_card.value
    correct = (prediction == 'high' && is_higher) || (prediction == 'low' && !is_higher)
    
    correct ? :correct : :incorrect
  end

  def build_success_result(current_card, next_card, comparison_result)
    {
      correct: comparison_result != :incorrect,
      message: "#{current_card.display_name} → #{next_card.display_name}#{tie_message(comparison_result)}"
    }
  end

  def build_error_result(message)
    { correct: false, message: message }
  end

  def tie_message(comparison_result)
    comparison_result == :tie ? ' (同じ値！)' : ''
  end
end
