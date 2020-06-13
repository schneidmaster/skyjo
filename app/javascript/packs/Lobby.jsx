import React, { useState } from "react";
import { postRequest } from "./helpers";

function joinGame({ game, name, setParticipant }) {
  postRequest(`/games/${game.id}/game_participants`, { name })
    .then((res) => res.json())
    .then(setParticipant);
}

function nextRound({ game }) {
  postRequest(`/games/${game.id}/rounds`);
}

export default function Lobby({
  game,
  participant,
  participants,
  setParticipant,
}) {
  const [name, setName] = useState("");

  return (
    <div>
      <p>
        Current participants: {participants.map((part) => part.name).join(", ")}
      </p>

      {participant && (
        <button
          className="py-2 px-4 rounded border-solid border border-black"
          onClick={() => nextRound({ game })}
        >
          Start game
        </button>
      )}

      {!participant && (
        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (name !== "") joinGame({ game, name, setParticipant });
          }}
        >
          <input
            type="text"
            placeholder="Name"
            onChange={(e) => setName(e.target.value)}
            value={name}
          />
          <button
            disabled={name === ""}
            className="py-2 px-4 rounded border-solid border border-black"
          >
            Join game
          </button>
        </form>
      )}
    </div>
  );
}
