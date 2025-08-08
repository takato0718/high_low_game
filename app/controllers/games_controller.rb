class GamesController < ApplicationController
  def index
    reset_game
    redirect_to action: :show
  end

  def show
    @current_card = session[:current_card] || rand(1..13)
    @score = session[:score] || 0
    @message = session[:message] || "ゲームスタート！"
    @game_over = session[:game_over] || false
    
    # メッセージを一度表示したらクリア
    session[:message] = nil if session[:message]
  end
  def guess
    current_card = session[:current_card]
    next_card = rand(1..13)
    guess_type = params[:guess]
    
    # 判定ロジック
    correct = case guess_type
              when "high"
                next_card >= current_card
              when "low"
                next_card <= current_card
              else
                false
              end
    
    # スコア更新とメッセージ設定
    if correct
      session[:score] = (session[:score] || 0) + 1
      session[:message] = "正解！🎉 #{current_card} → #{next_card}"
    else
      session[:message] = "残念...😢 #{current_card} → #{next_card}"
      session[:game_over] = true
    end
    
    session[:current_card] = next_card
    redirect_to action: :show
  end
  
  def new
    reset_game
    redirect_to action: :show
  end
  
  private
  
  def reset_game
    session[:current_card] = rand(1..13)
    session[:score] = 0
    session[:message] = "新しいゲームを開始しました！"
    session[:game_over] = false
  end
end
