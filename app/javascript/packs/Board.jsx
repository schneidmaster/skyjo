import React from "react";
import cx from "classnames";
import { cardClass } from "./helpers";

export default function Board({ board, onBoardSelect }) {
  return (
    <table>
      <tbody>
        {board.board.map((row, rowIdx) => (
          <tr key={rowIdx}>
            {row.map((col, colIdx) => (
              <td
                key={colIdx}
                className={cx(
                  "h-12 w-8 text-center",
                  {
                    "cursor-pointer": onBoardSelect,
                  },
                  cardClass(col)
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
