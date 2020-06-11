import consumer from "./consumer";

document.addEventListener("turbolinks:load", () => {
  if (document.querySelector("#participant_list")) {
    const token = window.location.pathname.replace("/games/", "");
    consumer.subscriptions.create(
      { channel: "ParticipantChannel", game_token: token },
      {
        received(data) {
          document.querySelector("#participant_list").innerText +=
            ", " + data.name;
        },
      }
    );
  }
});
