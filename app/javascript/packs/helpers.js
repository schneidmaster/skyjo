import cx from "classnames";

export const postRequest = (path, payload) =>
  fetch(path, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content"),
      "Content-Type": "application/json",
    },
    body: payload ? JSON.stringify(payload) : undefined,
  });

export const cardClass = (card, hoverable) =>
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
    "card--great": card <= 0,
    "card--great_hoverable": card <= 0 && hoverable,
  });
