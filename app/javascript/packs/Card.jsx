import React from "react";
import cx from "classnames";

const cardClass = (card, hoverable) =>
  cx({
    "cursor-pointer": hoverable,
    "card--neutral": card === "X",
    "card--neutral_hoverable": card === "X" && hoverable,
    "card--bad": card > 8,
    "card--bad_hoverable": card > 8 && hoverable,
    "card--meh": card > 4 && card <= 8,
    "card--meh_hoverable": card > 4 && card <= 8 && hoverable,
    "card--good": card > 0 && card <= 4,
    "card--good_hoverable": card > 0 && card <= 4 && hoverable,
    "card--great": (card ?? 1) <= 0,
    "card--great_hoverable": (card ?? 1) <= 0 && hoverable,
    border: card === null,
  });

export default function Card({
  tag = "div",
  card,
  hoverable,
  onClick,
  onlySmall,
}) {
  const Tag = tag;

  return (
    <Tag
      className={cx(
        "rounded shadow-inner",
        {
          "h-20 md:h-12 w-12 md:w-8 text-xl md:text-base": !onlySmall,
          "h-12 w-8": onlySmall,
          "flex justify-center items-center": tag === "div",
          "text-center": tag === "td",
        },
        cardClass(card, hoverable)
      )}
      onClick={onClick}
    >
      {card}
    </Tag>
  );
}
