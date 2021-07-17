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
end
