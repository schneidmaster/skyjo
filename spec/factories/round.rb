FactoryBot.define do
  factory :round do
    game
    game_participant { build(:game_participant, game: game) }

    round_number { 1 }
    state { :initial }
    move_state { :move_initial }
    drawn_card { nil }
    current_discard { nil }
  end
end
