# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_17_042622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_participants", force: :cascade do |t|
    t.bigint "game_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_participants_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "token"
    t.integer "state", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "round_boards", force: :cascade do |t|
    t.bigint "game_participant_id"
    t.bigint "round_id"
    t.json "board"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_participant_id"], name: "index_round_boards_on_game_participant_id"
    t.index ["round_id"], name: "index_round_boards_on_round_id"
  end

  create_table "round_decks", force: :cascade do |t|
    t.bigint "round_id"
    t.json "deck"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "discard", default: []
    t.index ["round_id"], name: "index_round_decks_on_round_id"
  end

  create_table "round_scores", force: :cascade do |t|
    t.bigint "game_participant_id"
    t.bigint "round_id"
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_participant_id"], name: "index_round_scores_on_game_participant_id"
    t.index ["round_id"], name: "index_round_scores_on_round_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "game_participant_id"
    t.integer "round_number"
    t.integer "state", default: 0
    t.integer "move_state", default: 0
    t.integer "drawn_card"
    t.integer "current_discard"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_rounds_on_game_id"
    t.index ["game_participant_id"], name: "index_rounds_on_game_participant_id"
  end

end
