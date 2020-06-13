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
