FactoryBot.define do
  factory :game do
    state { :initial }

    after(:create) do |game|
      create_list(:game_participant, 4, game: game)
    end
  end
end
