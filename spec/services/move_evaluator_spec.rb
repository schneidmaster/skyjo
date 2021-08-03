require "rails_helper"

RSpec.describe MoveEvaluator do
  let(:board) { create(:round_board) }
  let(:move_type) { nil }
  let(:coordinates) { {} }
  let(:params) { coordinates.merge(move_type: move_type) }
  let(:evaluator) { described_class.new(board: board, params: params) }

  context "when move is initial_flip" do
    let(:move_type) { :initial_flip }

    context "when round state is not initial" do
      before { board.round.in_progress! }

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when two cards have been flipped" do
      before do
        board.flip_card!(0, 0)
        board.flip_card!(0, 1)
      end

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when cards can been flipped" do
      let(:coordinates) { { x: 0, y: 0 } }

      context "when no cards have been flipped" do
        it "flips card but does not start the round" do
          expect { evaluator.call }.to have_broadcasted_to("moves_#{board.round.game.token}").with do |board|
            expect(board[0][0]).to_not eq("X")
          end
          expect(board.board[0][0]).to_not eq("X")
          expect(board.round.initial?).to eq(true)
        end
      end

      context "when one card has been flipped" do
        before { board.flip_card!(0, 1) }

        it "flips card but does not start the round" do
          expect { evaluator.call }.to have_broadcasted_to("moves_#{board.round.game.token}").with do |board|
            expect(board[0][0]).to_not eq("X")
          end
          expect(board.board[0][0]).to_not eq("X")
          expect(board.round.initial?).to eq(true)
        end

        context "when other boards have all been flipped" do
          before do
            board.round.round_boards.each do |other_board|
              next if board == other_board

              other_board.flip_card!(0, 0)
              other_board.flip_card!(0, 1)
            end
          end

           it "flips card and starts the round" do
            expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
              expect(rounds[0]["state"]).to eq("in_progress")
            end
            expect(board.board[0][0]).to_not eq("X")
            expect(board.round.in_progress?).to eq(true)
          end
        end
      end
    end
  end

  context "when move is draw_card" do
    let(:move_type) { :draw_card }

    context "when round state is not move_initial" do
      before { board.round.drawn_card! }

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when it is not the player's turn" do
      before do
        other_participant = create(:game_participant, game: board.round.game)
        board.round.update(game_participant: other_participant)
      end

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when the player can draw the card" do
      before do
        board.round.update(game_participant: board.game_participant)
        board.round.round_deck.update(deck: [1, 5])
      end

      it "draws card" do
        expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
          expect(rounds[0]["state"]).to eq("drawn_card")
        end
        expect(board.round.drawn_card?).to eq(true)
        expect(board.round.drawn_card).to eq(1)
      end
    end
  end

  context "when move is draw_discard" do
    let(:move_type) { :draw_discard }

    context "when round state is not move_initial" do
      before { board.round.drawn_card! }

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when it is not the player's turn" do
      before do
        other_participant = create(:game_participant, game: board.round.game)
        board.round.update(game_participant: other_participant)
      end

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when the player can draw the card" do
      before do
        board.round.update(game_participant: board.game_participant)
        board.round.update(current_discard: 4)
      end

      it "draws card" do
        expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
          expect(rounds[0]["state"]).to eq("drawn_card")
        end
        expect(board.round.drawn_discard?).to eq(true)
        expect(board.round.drawn_card).to eq(4)
      end
    end
  end

  context "when move is discard_card" do
    let(:move_type) { :discard_card }

    context "when round state is not drawn_card" do
      before { board.round.move_initial! }

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when it is not the player's turn" do
      before do
        other_participant = create(:game_participant, game: board.round.game)
        board.round.update(game_participant: other_participant)
      end

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when the player can discard the card" do
      before do
        board.round.update(game_participant: board.game_participant)
        board.round.update(drawn_card: 6)
        board.round.drawn_card!
      end

      it "draws card" do
        expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
          expect(rounds[0]["state"]).to eq("discarded_card")
        end
        expect(board.round.discarded_card?).to eq(true)
        expect(board.round.current_discard).to eq(6)
        expect(board.round.drawn_card).to eq(nil)
      end
    end
  end

  context "when move is select_card" do
    let(:move_type) { :select_card }

    context "when round state is move_initial" do
      before { board.round.move_initial! }

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when it is not the player's turn" do
      before do
        other_participant = create(:game_participant, game: board.round.game)
        board.round.update(game_participant: other_participant)
        board.round.drawn_card!
      end

      it "bails" do
        expect { evaluator.call }.to_not change { board }
      end
    end

    context "when the player can select the card" do
      before do
        board.round.update(game_participant: board.game_participant)
        board.round.update(drawn_card: 9)
        board.round.game.game_participants << board.game_participant
      end

      let(:coordinates) { { x: 0, y: 0 } }

      context "when card is drawn" do
        before { board.round.drawn_card! }

        it "replaces selected card" do
          expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
            expect(rounds[0]["state"]).to eq("move_initial")
          end
          expect(board.round.move_initial?).to eq(true)
          expect(board.round.game_participant).to_not eq(board.game_participant)
          expect(board.board[0][0]).to eq(9)
        end

        context "when column is finished" do
          before do
            board.board[0][1] = 9
            board.board[0][2] = 9
            board.save
          end

          it "removes column" do
            expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
              expect(rounds[0]["state"]).to eq("move_initial")
            end
            expect(board.round.move_initial?).to eq(true)
            expect(board.round.game_participant).to_not eq(board.game_participant)
            expect(board.board.count).to eq(3)
          end
        end

        context "when all cards are flipped" do
          before do
            board.update(board: [
              ['X', 2, 3], [3, 1, 5], [2, 3, 4], [1, 5, 6]
            ])
          end

          it "ends round" do
            expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
              expect(rounds[0]["state"]).to eq("finished")
            end
            expect(board.round.finished?).to eq(true)
          end
        end
      end

      context "when card is discarded" do
        before do
          board.round.discarded_card!
          board.round.round_deck.update(deck: [8] + board.round.round_deck.deck)
        end

        it "flips selected card" do
          expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
            expect(rounds[0]["move_state"]).to eq("move_initial")
          end
          expect(board.board[0][0]).to eq(8)
        end

        context "when column is finished" do
          before do
            board.board[0][1] = 8
            board.board[0][2] = 8
            board.save
          end

          it "removes column" do
            expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
              expect(rounds[0]["state"]).to eq("move_initial")
            end
            expect(board.round.move_initial?).to eq(true)
            expect(board.round.game_participant).to_not eq(board.game_participant)
            expect(board.board.count).to eq(3)
          end
        end

        context "when all cards are flipped" do
          before do
            board.update(board: [
              ['X', 2, 3], [3, 1, 5], [2, 3, 4], [1, 5, 6]
            ])
          end

          it "ends round" do
            expect { evaluator.call }.to have_broadcasted_to("rounds_#{board.round.game.token}").with do |rounds|
              expect(rounds[0]["state"]).to eq("finished")
            end
            expect(board.round.finished?).to eq(true)
          end
        end
      end
    end
  end
end
