import * as t from "io-ts";

export const UserId = new t.Type<string, string, unknown>(
  "UserId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_usr_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_usr_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type UserId = t.TypeOf<typeof UserId>;

export const AccountId = new t.Type<string, string, unknown>(
  "AccountId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_acc_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_acc_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type AccountId = t.TypeOf<typeof AccountId>;

export const EnvironmentId = new t.Type<string, string, unknown>(
  "EnvironmentId ",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_env_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_env_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type EnvironmentId = t.TypeOf<typeof EnvironmentId>;

export const AgentId = new t.Type<string, string, unknown>(
  "AgentId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_ag_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_ag_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type AgentId = t.TypeOf<typeof AgentId>;

export const EventId = new t.Type<string, string, unknown>(
  "EventId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_evt_\w{16}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_evt_\w{16}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type EventId = t.TypeOf<typeof EventId>;

export const SpaceId = new t.Type<string, string, unknown>(
  "SpaceId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_sp_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_sp_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type SpaceId = t.TypeOf<typeof SpaceId>;

export const SpaceConfigId = new t.Type<string, string, unknown>(
  "SpaceConfigId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_sc_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_sc_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type SpaceConfigId = t.TypeOf<typeof SpaceConfigId>;

export const DocumentId = new t.Type<string, string, unknown>(
  "DocumentId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_dc_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_dc_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type DocumentId = t.TypeOf<typeof DocumentId>;

export const WorkbookId = new t.Type<string, string, unknown>(
  "WorkbookId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_wb_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_wb_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type WorkbookId = t.TypeOf<typeof WorkbookId>;

export const SheetId = new t.Type<string, string, unknown>(
  "SheetId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_sh_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_sh_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type SheetId = t.TypeOf<typeof SheetId>;

export const EventTopic = new t.Type<string, string, unknown>(
  "EventTopic",
  (input: unknown): input is string =>
    typeof input === "string" &&
    /^(?:space|workbook|user|upload|job|records|file|sheet)\:(?:added|removed|online|offline|started|failed|completed|waiting|updated|created|validated)$/g.test(
      input,
    ),
  (input, context) =>
    typeof input === "string" &&
    /^(?:space|workbook|user|upload|job|records|file|sheet)\:(?:added|removed|online|offline|started|failed|completed|waiting|updated|created|validated)$/g.test(
      input,
    )
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type EventTopic = t.TypeOf<typeof EventTopic>;

export const FileId = new t.Type<string, string, unknown>(
  "FileId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_fl_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_fl_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type FileId = t.TypeOf<typeof FileId>;

export const JobId = new t.Type<string, string, unknown>(
  "JobId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_jb_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_jb_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type JobId = t.TypeOf<typeof JobId>;

export const VersionId = new t.Type<string, string, unknown>(
  "VersionId",
  (input: unknown): input is string =>
    typeof input === "string" && /^(?:dev|us)_vr_\w{8}$/g.test(input),
  (input, context) =>
    typeof input === "string" && /^(?:dev|us)_vr_\w{8}$/g.test(input)
      ? t.success(input)
      : t.failure(input, context),
  t.identity,
);

export type VersionId = t.TypeOf<typeof VersionId>;

/*
 * Codecs
 */

export const workbookEventCodec = t.type({
  id: EventId,
  domain: t.literal("workbook"),
  topic: EventTopic,
  context: t.type({
    sheetId: SheetId,
    spaceId: SpaceId,
    accountId: AccountId,
    sheetSlug: t.string,
    versionId: VersionId,
    workbookId: WorkbookId,
    environmentId: EnvironmentId,
  }),
  payload: t.type({}),
  callbackUrl: t.string,
  dataUrl: t.string,
  createdAt: t.string,
  acknowledgedAt: t.union([t.string, t.null]),
});

export type WorkbookEvent = t.TypeOf<typeof workbookEventCodec>;

export const fileEventCodec = t.type({
  id: EventId,
  domain: t.literal("file"),
  topic: EventTopic,
  context: t.intersection([
    t.type({
      spaceId: SpaceId,
      accountId: AccountId,
      environmentId: EnvironmentId,
    }),
    t.partial({
      fileId: FileId,
    }),
  ]),
  payload: t.type({}),
  callbackUrl: t.string,
  dataUrl: t.string,
  createdAt: t.string,
  acknowledgedAt: t.union([t.string, t.null]),
});

export type FileEvent = t.TypeOf<typeof fileEventCodec>;

export const jobEventCodec = t.type({
  id: EventId,
  domain: t.literal("job"),
  topic: EventTopic,
  context: t.type({
    jobId: JobId,
    fileId: FileId,
    spaceId: SpaceId,
    accountId: AccountId,
    environmentId: EnvironmentId,
  }),
  payload: t.type({}),
  callbackUrl: t.string,
  dataUrl: t.string,
  createdAt: t.string,
  acknowledgedAt: t.union([t.string, t.null]),
});

export type JobEvent = t.TypeOf<typeof jobEventCodec>;

export const spaceEventCodec = t.type({
  id: EventId,
  domain: t.literal("space"),
  topic: EventTopic,
  context: t.type({
    spaceId: SpaceId,
    accountId: AccountId,
    environmentId: EnvironmentId,
  }),
  payload: t.type({}),
  callbackUrl: t.string,
  dataUrl: t.string,
  createdAt: t.string,
  acknowledgedAt: t.union([t.string, t.null]),
});

export type SpaceEvent = t.TypeOf<typeof spaceEventCodec>;
