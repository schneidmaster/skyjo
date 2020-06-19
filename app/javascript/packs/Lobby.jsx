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

export default function Lobby({ game, participant, setParticipant }) {
  const [name, setName] = useState("");

  return (
    <div class="w-full h-full flex justify-center items-center">
      <div class="w-full md:w-1/2 h-full md:h-64 flex flex-col md:justify-between border rounded">
        <div className="m-8">
          <h1 className="mx-4 mb-4">Game lobby</h1>
          <p className="mx-4 my-2">
            Game code: <strong>{game.token}</strong>
          </p>
          <p className="mx-4 my-2">
            Current participants:{" "}
            {game.game_participants.map((part) => part.name).join(", ")}
            {game.game_participants.length === 0 && "None"}
          </p>

          {participant && (
            <button
              className="mx-4 my-2 py-2 px-4 rounded border-solid border border-black"
              onClick={() => nextRound({ game })}
            >
              Start game
            </button>
          )}

          {!participant && (
            <form
              className="m-4"
              onSubmit={(e) => {
                e.preventDefault();
                if (name !== "") joinGame({ game, name, setParticipant });
              }}
            >
              <input
                type="text"
                placeholder="Name"
                className="border rounded w-full mb-2 px-4 py-2"
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
      </div>
    </div>
  );
}
