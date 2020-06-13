import React from "react";

export default function Scoreboard({ rounds, participants }) {
  const scoredRounds = rounds.filter((round) => round.state === "finished");

  return (
    <table>
      <thead>
        <tr>
          <td className="border">Round</td>
          {participants.map((part) => (
            <td className="border" key={part.name}>
              {part.name}
            </td>
          ))}
        </tr>
      </thead>
      <tbody>
        {scoredRounds.map((round) => (
          <tr key={round.id}>
            <td className="border">{round.round_number}</td>
            {participants.map((part) => (
              <td className="border" key={part.name}>
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
          <td className="border">Total</td>
          {participants.map((part) => (
            <td className="border" key={part.name}>
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
