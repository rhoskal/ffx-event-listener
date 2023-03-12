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
  flags: null,
});

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN ?? "",
  integrations: [new BrowserTracing()],

  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for performance monitoring.
  // We recommend adjusting this value in production
  tracesSampleRate: 1.0,
});

const isProd = (): boolean => import.meta.env.PROD ?? false;

const css: string = "color: #ffffff; background-color: #4c48ef; padding: 4px;";

export const prettyPrint = (
  level: "info" | "warn" | "error",
  title: string,
  messages: ReadonlyArray<string>,
) => {
  match(level)
    .with("info", () => {
      console.group(`%c[crispy-critters] ${title} ⥤`, css);
      messages.map(console.log);
      console.groupEnd();
    })
    .with("warn", () => {
      console.group(`%c[crispy-critters] ${title} ⥤`, css);
      messages.map(console.warn);
      console.groupEnd();
    })
    .with("error", () => {
      console.group(`%c[crispy-critters] ${title} ⥤`, css);
      messages.map(console.error);
      console.groupEnd();
    })
    .exhaustive();
};

const openExternalLink =
  (url: string): IO.IO<void> =>
  () => {
    return window.open(url, "_blank")?.focus();
  };

const reportIssue =
  (msg: string, context?: any): IO.IO<void> =>
  () => {
    if (isProd()) {
      Sentry.captureException(msg);

      if (context !== null || context !== undefined) {
        Sentry.setContext("message", context);
      }
    }

    return;
  };

app.ports.interopFromElm.subscribe((fromElm) => {
  return match(fromElm)
    .with({ tag: "openExternalLink" }, ({ data }) => openExternalLink(data.url)())
    .with({ tag: "reportIssue" }, ({ data }) => reportIssue(data.message)())
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

                reportIssue("Unable to parse PubNub JSON", m.message)();
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
