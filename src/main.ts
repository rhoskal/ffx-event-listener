import PubNub from "pubnub";
import * as E from "fp-ts/Either";
import * as IO from "fp-ts/IO";
import * as J from "fp-ts/Json";
import { pipe } from "fp-ts/function";
import { match } from "ts-pattern";
import * as Sentry from "@sentry/browser";
import { BrowserTracing } from "@sentry/tracing";

import { Elm } from "./Main.elm";
import "./globals.css";
import "./devs";

const app = Elm.Main.init({
  node: document.querySelector<HTMLDivElement>("#root"),
  flags: {
    accessToken: localStorage.getItem("accessToken"),
  },
});

const isProd = (): boolean => import.meta.env.PROD ?? false;

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN ?? "",
  debug: !isProd(),
  integrations: [new BrowserTracing()],

  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for performance monitoring.
  // We recommend adjusting this value in production
  tracesSampleRate: 1.0,
});

const css: string = "color: #ffffff; background-color: #4c48ef; padding: 4px;";

export const prettyPrint = (
  level: "info" | "warn" | "error",
  title: string,
  messages: ReadonlyArray<string>,
): void => {
  console.group(`%c[crispy-critters] ${title} ⥤`, css);

  match(level)
    .with("info", () => {
      messages.forEach((msg) => console.log(msg));
    })
    .with("warn", () => {
      messages.forEach((msg) => console.warn(msg));
    })
    .with("error", () => {
      messages.forEach((msg) => console.error(msg));
    })
    .exhaustive();

  console.groupEnd();
};

const openExternalLink = (url: string): IO.IO<void> => {
  return () => {
    return window.open(url, "_blank")?.focus();
  };
};

const reportIssue = (msg: string, producer: "fromElm" | "fromJs"): IO.IO<void> => {
  return () => {
    if (isProd()) {
      Sentry.withScope(function (scope) {
        scope.setTag("producer", producer);
        scope.setContext(producer, { message: msg });

        Sentry.captureMessage(msg);
      });
    }
  };
};

app.ports.interopFromElm.subscribe((fromElm) => {
  return match(fromElm)
    .with({ tag: "openExternalLink" }, ({ data }) => openExternalLink(data.url)())
    .with({ tag: "reportIssue" }, ({ data }) => reportIssue(data.message, "fromElm")())
    .with({ tag: "subscriptionCreds" }, ({ data }) => {
      const pubnub = new PubNub({
        subscribeKey: data.subscribeKey,
        userId: data.accountId,
        // logVerbosity: !isProd(),
      });

      pubnub.addListener({
        message: function (m) {
          if (!isProd()) {
            prettyPrint("info", "PubNub Event", [m.message]);
          }

          pipe(
            J.parse(m.message),
            E.match(
              () => {
                prettyPrint("warn", "JSON parse", [m.message]);

                reportIssue("Unable to parse PubNub JSON\n\n".concat(m.message), "fromJs")();
              },
              (json) => {
                app.ports.interopToElm.send(json as any);
              },
            ),
          );
        },
      });

      pubnub.setToken(data.token);

      pubnub.subscribe({
        channels: [`space.${data.spaceId}`],
      });
    })
    .exhaustive();
});

// app.ports.interopFromElm.unsubscribe((_fromElm) => {});
