import React, { useEffect, useReducer } from "react";
import cx from "classnames";
import produce from "immer";
import consumer from "../channels/consumer";
import Board from "./Board";
import Scoreboard from "./Scoreboard";
import Card from "./Card";
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
  let onBoardSelect;
  if (
    initialFlip ||
    (round.state === "in_progress" &&
      yourTurn &&
      (round.move_state === "drawn_card" ||
        round.move_state === "drawn_discard" ||
        round.move_state === "discarded_card"))
  ) {
    onBoardSelect = (x, y) => {
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
          (round.move_state === "discarded_card" &&
            ownBoard.board[x][y] === "X"))
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
  }

  const currentParticipant = participants.find(
    (part) => part.id === round.game_participant_id
  );

  const deckDrawable =
    round.state === "in_progress" &&
    yourTurn &&
    round.move_state === "move_initial";
  const discardDrawable =
    round.state === "in_progress" &&
    yourTurn &&
    (round.move_state === "move_initial" || round.move_state === "drawn_card");

  return (
    <div className="flex flex-col md:flex-row h-full">
      <div className="border-r w-full md:w-64">
        <div className="flex justify-center m-4">
          <Board
            name={participant.name}
            board={ownBoard}
            onBoardSelect={onBoardSelect}
            ownBoard
          />
        </div>

        <div className="m-4 p-4 border rounded flex justify-between items-center">
          <div className="flex flex-col items-center">
            <p className="text-light-gray uppercase text-xs mb-2">Deck</p>
            <Card
              card="X"
              hoverable={deckDrawable}
              onClick={() =>
                deckDrawable &&
                sendMove({
                  game,
                  round,
                  move: "draw_card",
                })
              }
            />
          </div>
          <div className="flex flex-col items-center">
            <p className="text-light-gray uppercase text-xs mb-2">Discard</p>
            <Card
              card={round.current_discard}
              hoverable={discardDrawable}
              onClick={() => {
                if (round.move_state === "move_initial") {
                  sendMove({
                    game,
                    round,
                    move: "draw_discard",
                  });
                } else if (round.move_state === "drawn_card") {
                  sendMove({
                    game,
                    round,
                    move: "discard_card",
                  });
                }
              }}
            />
          </div>
        </div>

        <div className="mx-4 p-4 border rounded flex flex-col justify-center items-center">
          {initialFlip && <p>Flip two cards to start the round.</p>}
          {round.state === "in_progress" && (
            <p className={cx("mb-2", { "text-red font-bold": yourTurn })}>
              {yourTurn ? "Your" : `${currentParticipant.name}'s`} turn
              {yourTurn ? "!" : "."}
            </p>
          )}
          {round.state === "in_progress" &&
            yourTurn &&
            round.move_state === "move_initial" && (
              <p className="mb-2">Draw a card or draw from the discard.</p>
            )}
          {round.state === "in_progress" &&
            yourTurn &&
            (round.move_state === "drawn_card" ||
              round.move_state === "drawn_discard") && (
              <>
                <p>Card drawn:</p>
                <div className="my-2">
                  <Card card={round.drawn_card} />
                </div>
                <p className="mb-2">
                  Select a card to replace
                  {round.move_state === "drawn_card" &&
                    ", or discard the drawn card"}
                  .
                </p>
              </>
            )}
          {round.state === "in_progress" &&
            yourTurn &&
            round.move_state === "discarded_card" && (
              <p>Select a card to flip.</p>
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
      </div>

      <div className="flex-1 flex flex-col overflow-hiden">
        <div className="flex-1 flex md:flex-wrap overflow-x-scroll md:overflow-x-hidden md:overflow-y-scroll">
          {boards
            .filter((board) => board.game_participant_id !== participant.id)
            .map((board) => (
              <div key={board.id} className="w-64 flex-shrink-0">
                <div className="flex justify-center m-4">
                  <Board
                    name={
                      participants.find(
                        (participant) =>
                          participant.id === board.game_participant_id
                      ).name
                    }
                    board={board}
                  />
                </div>
              </div>
            ))}
        </div>
        <div className="h-48 overflow-y-scroll">
          <Scoreboard participants={participants} rounds={rounds} />
        </div>
      </div>
    </div>
  );

  return null;
}
