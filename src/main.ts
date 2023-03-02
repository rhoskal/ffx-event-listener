import * as IO from "fp-ts/IO";
import { match } from "ts-pattern";

import { Elm } from "./Main.elm";
import "./globals.css";

const app = Elm.Main.init({
  node: document.querySelector<HTMLDivElement>("#root"),
  flags: null,
});

app.ports.interopFromElm.subscribe((fromElm) => {});

app.ports.interopFromElm.unsubscribe((fromElm) => {});
