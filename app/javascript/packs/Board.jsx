import React from "react";
import cx from "classnames";

export default function Board({ board, onBoardSelect }) {
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
                  "card--neutral": col === "X",
                  "card--bad": col > 8,
                  "card--meh": col > 4 && col <= 8,
                  "card--good": col > 0 && col <= 4,
                  "card--great": col <= 0,
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
