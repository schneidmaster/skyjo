import React, { useEffect, useReducer } from "react";
import cx from "classnames";
import produce from "immer";
import consumer from "../channels/consumer";
import Board from "./Board";
import Scoreboard from "./Scoreboard";
import { postRequest } from "./helpers";

function compareRounds(a, b) {
  if (a.round_number < b.round_number) {
    return -1;
  } else if (b.round_number < a.round_number) {
    return 1;
  } else {
    return 0;
  }
}

function reducer(state, action) {
  switch (action.type) {
    case "set_board":
      return produce(state, (draftState) => {
        const round = draftState.rounds[draftState.rounds.length - 1];
        const boardIdx = round.round_boards.findIndex(
          (board) => board.id === action.board.id
        );
        round.round_boards[boardIdx] = action.board;
      });
    case "set_rounds":
      return produce(state, (draftState) => {
        draftState.rounds = action.rounds.sort(compareRounds);
      });
    default:
      throw new Error();
  }
}

function sendMove({ game, round, move, x, y }) {
  postRequest(`/games/${game.id}/rounds/${round.id}/moves`, {
    move_type: move,
    x,
    y,
  });
}

function nextRound({ game }) {
  postRequest(`/games/${game.id}/rounds`);
}

export default function Game({ game, participant, ...initialState }) {
  const [state, dispatch] = useReducer(reducer, {
    rounds: game.rounds.sort(compareRounds),
  });

  const { rounds } = state;
  const round = rounds[rounds.length - 1];
  const boards = round.round_boards;
  const participants = game.game_participants;

  useEffect(() => {
    consumer.subscriptions.create(
      { channel: "MoveChannel", game_token: game.token },
      {
        received(board) {
          dispatch({
            type: "set_board",
            board,
          });
        },
      }
    );

    consumer.subscriptions.create(
      { channel: "RoundChannel", game_token: game.token },
      {
        received(rounds) {
          dispatch({
            type: "set_rounds",
            rounds,
          });
        },
      }
    );
  }, [game]);

  const ownBoard = boards.find(
    (board) => board.game_participant_id === participant.id
  );

  const yourTurn = round.game_participant_id === participant.id;

  const initialFlip =
    round.state === "initial" &&
    ownBoard.board.flat(2).filter((cell) => cell !== "X").length < 2;
  const onBoardSelect = (x, y) => {
    if (initialFlip && ownBoard.board[x][y] === "X") {
      sendMove({
        game,
        round,
        move: "initial_flip",
        x,
        y,
      });
    } else if (
      round.state === "in_progress" &&
      yourTurn &&
      (round.move_state === "drawn_card" ||
        round.move_state === "drawn_discard" ||
        round.move_state === "discarded_card")
    ) {
      sendMove({
        game,
        round,
        move: "select_card",
        x,
        y,
      });
    }
  };

  const currentParticipant = participants.find(
    (part) => part.id === round.game_participant_id
  );

  return (
    <div className="flex m-4">
      <div className="w-1/2">
        <div className="h-1/2 flex pb-4 border-b border-solid border-black">
          <div className="w-2/3">
            <p>
              <strong>{participant.name}</strong>
            </p>
            <Board board={ownBoard} onBoardSelect={onBoardSelect} />

            {initialFlip && <p>Flip two cards to start the round</p>}
            {round.state === "in_progress" && (
              <p>{yourTurn ? "Your" : `${currentParticipant.name}'s`} turn</p>
            )}
            {round.state === "in_progress" &&
              yourTurn &&
              round.move_state === "move_initial" && (
                <>
                  <p>Draw a card or draw from the discard</p>
                  <button
                    className="py-2 px-4 mr-4 rounded border-solid border border-black"
                    onClick={() =>
                      sendMove({
                        game,
                        round,
                        move: "draw_card",
                      })
                    }
                  >
                    Draw card
                  </button>
                  <button
                    className="py-2 px-4 rounded border-solid border border-black"
                    onClick={() =>
                      sendMove({
                        game,
                        round,
                        move: "draw_discard",
                      })
                    }
                  >
                    Draw discard
                  </button>
                </>
              )}
            {round.state === "in_progress" &&
              yourTurn &&
              (round.move_state === "drawn_card" ||
                round.move_state === "drawn_discard") && (
                <>
                  <p>Drew a {round.drawn_card}. Select a card to replace</p>
                  {round.move_state === "drawn_card" && (
                    <button
                      className="py-2 px-4 rounded border-solid border border-black"
                      onClick={() =>
                        sendMove({
                          game,
                          round,
                          move: "discard_card",
                        })
                      }
                    >
                      Discard card
                    </button>
                  )}
                </>
              )}
            {round.state === "in_progress" &&
              yourTurn &&
              round.move_state === "discarded_card" && (
                <p>Select a card to flip</p>
              )}
            {round.state === "finished" && game.state === "started" && (
              <button
                className="py-2 px-4 rounded border-solid border border-black"
                onClick={() => nextRound({ game })}
              >
                Next round
              </button>
            )}
            {game.state === "finished" && <p>Game over!</p>}
          </div>
          <div className="w-1/3">
            {round.state === "in_progress" && (
              <>
                <p>Current discard:</p>
                {round.current_discard !== null ? (
                  <div
                    className={cx("w-6 h-8 text-center pt-2", {
                      "card--bad": round.current_discard > 8,
                      "card--meh":
                        round.current_discard > 4 && round.current_discard <= 8,
                      "card--good":
                        round.current_discard > 0 && round.current_discard <= 4,
                      "card--great": round.current_discard <= 0,
                    })}
                  >
                    {round.current_discard}
                  </div>
                ) : (
                  "none"
                )}
              </>
            )}
          </div>
        </div>
        <div className="h-1/2 pt-4">
          <p>Scores</p>

          <Scoreboard participants={participants} rounds={rounds} />
        </div>
      </div>

      <div className="w-1/2">
        {boards
          .filter((board) => board.game_participant_id !== participant.id)
          .map((board) => (
            <div key={board.id}>
              <p>
                <strong>
                  {
                    participants.find(
                      (participant) =>
                        participant.id === board.game_participant_id
                    ).name
                  }
                </strong>
              </p>
              <Board board={board} />
            </div>
          ))}
      </div>
    </div>
  );

  return null;
}
