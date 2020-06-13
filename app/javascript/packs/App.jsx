import React, { useEffect, useState } from "react";
import produce from "immer";
import consumer from "../channels/consumer";
import Game from "./Game";
import Lobby from "./Lobby";

export default function App({
  game: initialGame,
  participant: initialParticipant,
  ...rest
}) {
  const [game, setGame] = useState(initialGame);
  const [participant, setParticipant] = useState(initialParticipant);

  useEffect(() => {
    consumer.subscriptions.create(
      { channel: "GameChannel", game_token: game.token },
      {
        received(newGame) {
          if (game.state === "initial" && newGame.state === "started") {
            window.location.reload();
          } else {
            setGame(newGame);
          }
        },
      }
    );
  });

  if (game.state === "initial") {
    return (
      <Lobby
        game={game}
        participant={participant}
        setParticipant={setParticipant}
      />
    );
  } else {
    return <Game game={game} participant={participant} {...rest} />;
  }
}
