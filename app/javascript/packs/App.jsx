import React, { useEffect, useState } from "react";
import produce from "immer";
import consumer from "../channels/consumer";
import Game from "./Game";
import Lobby from "./Lobby";

export default function App({
  game,
  participants: initialParticipants,
  participant: initialParticipant,
  ...rest
}) {
  const [participant, setParticipant] = useState(initialParticipant);
  const [participants, setParticipants] = useState(initialParticipants);

  useEffect(() => {
    consumer.subscriptions.create(
      { channel: "GameChannel", game_token: game.token },
      {
        received(newGame) {
          if (game.state === "initial" && newGame.state === "started")
            window.location.reload();
        },
      }
    );

    consumer.subscriptions.create(
      { channel: "ParticipantChannel", game_token: game.token },
      {
        received(newParticipant) {
          setParticipants(
            produce(participants, (draftParticipants) => {
              draftParticipants.push(newParticipant);
            })
          );
        },
      }
    );
  });

  if (game.state === "initial") {
    return (
      <Lobby
        game={game}
        participant={participant}
        participants={participants}
        setParticipant={setParticipant}
      />
    );
  } else {
    return (
      <Game
        game={game}
        participant={participant}
        participants={participants}
        {...rest}
      />
    );
  }
}
