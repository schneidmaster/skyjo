import React, { useEffect, useReducer } from "react";
import cx from "classnames";
import produce from "immer";
import consumer from "../channels/consumer";

function reducer(state, action) {
  switch (action.type) {
    case "set_board":
      return produce(state, (draftState) => {
        const boardIdx = draftState.boards.findIndex(
          (board) => board.id === action.board.id
        );
        draftState.boards[boardIdx] = action.board;
      });
    case "set_round":
      return produce(state, (draftState) => {
        draftState.round = action.round;
      });
    default:
      throw new Error();
  }
}

function sendMove({ game, round, move, x, y }) {
  fetch(`/games/${game.id}/rounds/${round.id}/moves`, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content"),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      move_type: move,
      x,
      y,
    }),
  });
}

function nextRound({ game }) {
  fetch(`/games/${game.id}/rounds`, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content"),
      "Content-Type": "application/json",
    },
  });
}

function GameBoard({ board, onBoardSelect }) {
  return (
    <table>
      <tbody>
        {board.board.map((row, rowIdx) => (
          <tr key={rowIdx}>
            {row.map((col, colIdx) => (
              <td
                key={colIdx}
                className={cx("p-4", {
                  "cursor-pointer": onBoardSelect,
                })}
                onClick={() => onBoardSelect?.(rowIdx, colIdx)}
              >
                {col}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default function Board({
  game,
  participant,
  participants,
  ...initialState
}) {
  const [state, dispatch] = useReducer(reducer, {
    participants,
    ...initialState,
  });

  const { boards, round } = state;

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
        received(round) {
          dispatch({
            type: "set_round",
            round,
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
        <p>
          <strong>{participant.name}</strong>
        </p>
        <GameBoard board={ownBoard} onBoardSelect={onBoardSelect} />

        {initialFlip && <p>Flip two cards to start the round</p>}
        {round.state === "in_progress" && (
          <p>{yourTurn ? "Your" : `${currentParticipant.name}'s`} turn</p>
        )}
        {round.state === "in_progress" && (
          <p>Current discard: {round.current_discard ?? "none"}</p>
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
          round.move_state === "discarded_card" && <p>Select a card to flip</p>}
        {round.state === "finished" && (
          <button
            className="py-2 px-4 rounded border-solid border border-black"
            onClick={() => nextRound({ game })}
          >
            Next round
          </button>
        )}
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
              <GameBoard board={board} />
            </div>
          ))}
      </div>
    </div>
  );

  return null;
}
