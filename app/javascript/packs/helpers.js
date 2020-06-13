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

export const cardClass = (card) =>
  cx({
    "card--neutral": card === "X",
    "card--bad": card > 8,
    "card--meh": card > 4 && card <= 8,
    "card--good": card > 0 && card <= 4,
    "card--great": card <= 0,
  });
