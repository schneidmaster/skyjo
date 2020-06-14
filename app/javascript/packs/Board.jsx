import React from "react";
import cx from "classnames";
import Card from "./Card";

export default function Board({ name, board, ownBoard, onBoardSelect }) {
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
              <Card
                key={colIdx}
                tag="td"
                card={col}
                hoverable={Boolean(onBoardSelect)}
                onlySmall={!ownBoard}
                onClick={() => onBoardSelect?.(rowIdx, colIdx)}
              />
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
