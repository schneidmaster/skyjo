import React from "react";
import cx from "classnames";
import { cardClass } from "./helpers";

export default function Board({ name, board, onBoardSelect }) {
  return (
    <table className="game-board">
      <thead>
        <tr>
          <td colSpan={4} className="text-center font-semibold">
            {name}
          </td>
        </tr>
      </thead>
      <tbody>
        {board.board.map((row, rowIdx) => (
          <tr key={rowIdx}>
            {row.map((col, colIdx) => (
              <td
                key={colIdx}
                className={cx(
                  "h-12 w-8 m-2 rounded shadow-inner text-center",
                  cardClass(col, Boolean(onBoardSelect))
                )}
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
