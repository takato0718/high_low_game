module GamesHelper
  def card_image_tag(card, size: 'normal')
    css_class = case size
                when 'small' then 'playing-card card-small'
                when 'mini' then 'playing-card card-mini'
                when 'large' then 'playing-card card-large'
                else 'playing-card'
                end

    image_tag card.image_path,
              alt: card.display_name,
              class: "#{css_class} #{card.css_classes}"
  end

  # 🆕 ゲーム結果メッセージ　(のちに結果をスコアにした時に使うかも)
  #   def game_result_message(previous_card, current_card, guess, correct)
  #     result_class = correct ? 'result-correct' : 'result-incorrect'
  #     emoji = correct ? '🎉' : '😢'
  #     comparison = guess == 'high' ? '>' : '<'

  #     content_tag :div, class: "game-result-message #{result_class}" do
  #       "#{previous_card.display_name} #{comparison} #{current_card.display_name} : #{correct ? '正解！' : '不正解...'} #{emoji}"
  #     end
  #   end

  # 🆕 スコア表示
  def score_display(score, remaining_cards)
    content_tag :div, class: 'score-section' do
      content_tag(:h2, "連続正解数: #{score}") +
        content_tag(:p, "残りカード: #{remaining_cards}枚")
    end
  end

  # 🆕 使用済みカード表示エリア
  def used_cards_display(used_cards)
    return if used_cards.empty?

    content_tag :div, class: 'used-cards-section' do
      content_tag(:h4, '使用済みカード') +
        content_tag(:div, class: 'cards-grid') do
          used_cards.map { |card| card_image_tag(card, size: 'mini') }.join.html_safe
        end
    end
  end

  def twitter_share_url(score)
    base_url = 'https://twitter.com/intent/tweet'
    text = generate_tweet_text(score)
    hashtags = 'HighLowゲーム,カードゲーム,プログラミング'

    params = {
      text: text,
      hashtags: hashtags,
      url: request.original_url
    }.to_query

    "#{base_url}?#{params}"
  end

  private

  def generate_tweet_text(score)
    case score
    when 0..2
      "🃏 High & Lowゲームで#{score}回連続正解！まだまだだね"
    when 3..5
      "🃏 High & Lowゲームで#{score}回連続正解！結構やるじゃん？"
    when 6..9
      "🃏 High & Lowゲームで#{score}回連続正解！すごい調子だ！"
    when 10..15
      "🃏 High & Lowゲームで#{score}回連続正解！神がかってる！"
    else
      "🃏 High & Lowゲームで#{score}回連続正解！ああんもお！すんごいい！"
    end
  end
end
