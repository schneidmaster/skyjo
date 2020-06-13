import React from "react";

export default function Scoreboard({ rounds, participants }) {
  const scoredRounds = rounds.filter((round) => round.state === "finished");

  return (
    <table className="mt-4">
      <thead>
        <tr>
          <td className="border p-2 font-semibold">Round</td>
          {participants.map((part) => (
            <td className="border p-2 font-semibold" key={part.name}>
              {part.name}
            </td>
          ))}
        </tr>
      </thead>
      <tbody>
        {scoredRounds.map((round) => (
          <tr key={round.id}>
            <td className="border p-2">{round.round_number}</td>
            {participants.map((part) => (
              <td className="border p-2" key={part.name}>
                {
                  round.round_scores.find(
                    (score) => score.game_participant_id === part.id
                  ).score
                }
              </td>
            ))}
          </tr>
        ))}
        <tr>
          <td className="border p-2">Total</td>
          {participants.map((part) => (
            <td className="border p-2" key={part.name}>
              {scoredRounds.reduce((score, round) => {
                return (
                  score +
                  round.round_scores.find(
                    (score) => score.game_participant_id === part.id
                  ).score
                );
              }, 0)}
            </td>
          ))}
        </tr>
      </tbody>
    </table>
  );
}
