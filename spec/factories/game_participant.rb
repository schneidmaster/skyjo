FactoryBot.define do
  factory :game_participant do
    game
    name { Faker::Name.first_name }
  end
end
