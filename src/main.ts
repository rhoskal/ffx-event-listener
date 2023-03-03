import PubNub from "pubnub";

import { Elm } from "./Main.elm";
import "./globals.css";

const app = Elm.Main.init({
  node: document.querySelector<HTMLDivElement>("#root"),
  flags: null,
});

// app.ports.interopFromElm.subscribe((_fromElm) => { });

// app.ports.interopFromElm.unsubscribe((_fromElm) => { });

const pubnub = new PubNub({
  subscribeKey: "mySubscribeKey",
  userId: "myUniqueUUID",
  logVerbosity: import.meta.env.DEV,
});

pubnub.addListener({
  message: function (m) {
    console.log("message:", m.message);
  },
});

const JWT = "";
const token = pubnub.parseToken(JWT);
console.log(token);

pubnub.setToken(JWT);

pubnub.subscribe({
  channels: [""],
});
