import PubNub from "pubnub";
import * as E from "fp-ts/Either";
import * as IO from "fp-ts/IO";
import * as J from "fp-ts/Json";
import { pipe } from "fp-ts/function";
import { match } from "ts-pattern";

import { Elm } from "./Main.elm";
import * as C from "./codecs";
import "./globals.css";

const app = Elm.Main.init({
  node: document.querySelector<HTMLDivElement>("#root"),
  flags: null,
});

const openExternalLink =
  (url: string): IO.IO<void> =>
  () => {
    return window.open(url, "_blank")?.focus();
  };

app.ports.interopFromElm.subscribe((fromElm) => {
  return match(fromElm)
    .with({ tag: "openExternalLink" }, ({ data }) => openExternalLink(data.url)())
    .exhaustive();
});

app.ports.interopFromElm.unsubscribe((_fromElm) => {});

const pubnub = new PubNub({
  subscribeKey: "mySubscribeKey",
  userId: "myUniqueUUID",
  logVerbosity: import.meta.env.DEV,
});

pubnub.addListener({
  message: function (m) {
    // console.log("message:", m.message);

    pipe(
      J.parse(m.message),
      E.chainW((json) => {
        return pipe(
          C.workbookEventCodec.decode(json),
          E.altW(() => C.fileEventCodec.decode(json)),
          E.altW(() => C.jobEventCodec.decode(json)),
          E.altW(() => C.spaceEventCodec.decode(json)),
        );
      }),
      E.match(
        () => {
          console.warn("[DECODER] Unknown message:", m.message);
        },
        (m_) => {
          console.log(`[DECODER] Found: ${m_.domain}, ${m_.topic}`);
          app.ports.interopToElm.send(m_);
        },
      ),
    );
  },
});

const JWT = "";
const token = pubnub.parseToken(JWT);
console.log(token);

pubnub.setToken(JWT);

pubnub.subscribe({
  channels: ["space.X"],
});
