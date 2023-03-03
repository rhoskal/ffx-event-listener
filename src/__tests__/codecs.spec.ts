import * as E from "fp-ts/Either";
import * as t from "io-ts";

import * as C from "../codecs";

type BrandedResult<T> = E.Either<t.Errors, T>;

describe("Branded Types", () => {
  describe("[UserId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.UserId> = C.UserId.decode("us_usr_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.UserId> = C.UserId.decode("dev_usr_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.UserId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.UserId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.UserId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[AccountId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.AccountId> = C.AccountId.decode("us_acc_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.AccountId> = C.AccountId.decode("dev_acc_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.AccountId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.AccountId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.AccountId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[EnvironmentId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.EnvironmentId> = C.EnvironmentId.decode("us_env_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.EnvironmentId> = C.EnvironmentId.decode("dev_env_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.EnvironmentId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.EnvironmentId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.EnvironmentId.decode("us_acc_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[AgentId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.AgentId> = C.AgentId.decode("us_ag_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.AgentId> = C.AgentId.decode("dev_ag_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.AgentId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.AgentId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.AgentId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.AgentId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[EventId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.EventId> = C.EventId.decode("us_evt_jfGdpFr2bFVGzBeW");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.EventId> = C.EventId.decode("dev_evt_jfGdpFr2bFVGzBeW");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.EventId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.EventId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.EventId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.EventId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[SpaceId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.SpaceId> = C.SpaceId.decode("us_sp_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.SpaceId> = C.SpaceId.decode("dev_sp_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.SpaceId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.SpaceId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.SpaceId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.SpaceId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[SpaceConfigId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.SpaceConfigId> = C.SpaceConfigId.decode("us_sc_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.SpaceConfigId> = C.SpaceConfigId.decode("dev_sc_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.SpaceConfigId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.SpaceConfigId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.SpaceConfigId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.SpaceConfigId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[DocumentId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.DocumentId> = C.DocumentId.decode("us_dc_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.DocumentId> = C.DocumentId.decode("dev_dc_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.DocumentId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.DocumentId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.DocumentId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.DocumentId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[WorkbookId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.WorkbookId> = C.WorkbookId.decode("us_wb_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.WorkbookId> = C.WorkbookId.decode("dev_wb_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.WorkbookId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.WorkbookId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.WorkbookId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.WorkbookId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[SheetId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.SheetId> = C.SheetId.decode("us_sh_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.SheetId> = C.SheetId.decode("dev_sh_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.SheetId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.SheetId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.SheetId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.SheetId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[EventTopic]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.EventTopic> = C.EventTopic.decode("space:added");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.EventTopic.decode("asdf"))).toBe(false);
      expect(E.isRight(C.EventTopic.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.EventTopic.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.EventTopic.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[FileId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.FileId> = C.FileId.decode("us_fl_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.FileId> = C.FileId.decode("dev_fl_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.FileId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.FileId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.FileId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.FileId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[JobId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.JobId> = C.JobId.decode("us_jb_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.JobId> = C.JobId.decode("dev_jb_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.JobId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.JobId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.JobId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.JobId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });

  describe("[VersionId]", () => {
    it("should handle valid prod id", () => {
      const actual: BrandedResult<C.VersionId> = C.VersionId.decode("us_vr_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle valid dev id", () => {
      const actual: BrandedResult<C.VersionId> = C.VersionId.decode("dev_vr_a7Ws9cue");
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid ids", () => {
      expect(E.isRight(C.VersionId.decode("asdf"))).toBe(false);
      expect(E.isRight(C.VersionId.decode("us_usr_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.VersionId.decode("us_acc_a7Ws9cue"))).toBe(false);
      expect(E.isRight(C.VersionId.decode("us_env_a7Ws9cue"))).toBe(false);
    });
  });
});

describe("Codecs", () => {
  describe("[WorkbookEventCodec]", () => {
    it("should handle valid runtime obj", () => {
      const actual = C.workbookEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "workbook",
        topic: "records:updated",
        context: {
          sheetId: "us_sh_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          sheetSlug: "subscribers-workbook/SubscribersSheet",
          versionId: "us_vr_cRcJk6Vj",
          workbookId: "us_wb_QfIdoZ9u",
          environmentId: "us_env_R1Z2NjpQ",
        },
        payload: {},
        callbackUrl: "",
        dataUrl:
          "v1/workbooks/us_wb_QfIdoZ9u/sheets/us_sh_FXDXMkQt/records?versionId=us_vr_cRcJk6Vj&includeCounts=false",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid runtime obj", () => {
      const actual = C.workbookEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "workbook",
        topic: "records:updated",
        context: {
          sheetId: "us_sh_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          sheetSlug: "subscribers-workbook/SubscribersSheet",
          versionId: "us_vr_cRcJk6Vj",
          environmentId: "us_env_R1Z2NjpQ",
        },
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = false;

      expect(E.isRight(actual)).toBe(expected);
    });
  });

  describe("[FileEventCodec]", () => {
    it("should handle valid runtime obj", () => {
      const actual = C.fileEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "file",
        topic: "upload:completed",
        context: {
          fileId: "us_fl_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          environmentId: "us_env_R1Z2NjpQ",
        },
        payload: {},
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid runtime obj", () => {
      const actual = C.fileEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "workbook",
        topic: "records:updated",
        context: {
          sheetId: "us_sh_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          sheetSlug: "subscribers-workbook/SubscribersSheet",
          versionId: "us_vr_cRcJk6Vj",
          environmentId: "us_env_R1Z2NjpQ",
        },
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = false;

      expect(E.isRight(actual)).toBe(expected);
    });
  });

  describe("[JobEventCodec]", () => {
    it("should handle valid runtime obj", () => {
      const actual = C.jobEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "job",
        topic: "job:waiting",
        context: {
          jobId: "us_jb_H6hoPvWX",
          fileId: "us_fl_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          environmentId: "us_env_R1Z2NjpQ",
        },
        payload: {},
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid runtime obj", () => {
      const actual = C.jobEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "workbook",
        topic: "records:updated",
        context: {
          sheetId: "us_sh_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          sheetSlug: "subscribers-workbook/SubscribersSheet",
          versionId: "us_vr_cRcJk6Vj",
          environmentId: "us_env_R1Z2NjpQ",
        },
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = false;

      expect(E.isRight(actual)).toBe(expected);
    });
  });

  describe("[SpaceEventCodec]", () => {
    it("should handle valid runtime obj", () => {
      const actual = C.spaceEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "space",
        topic: "space:added",
        context: {
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          environmentId: "us_env_R1Z2NjpQ",
        },
        payload: {},
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = true;

      expect(E.isRight(actual)).toBe(expected);
    });

    it("should handle invalid runtime obj", () => {
      const actual = C.spaceEventCodec.decode({
        id: "us_evt_jfGdpFr2bFVGzBeW",
        domain: "workspace",
        topic: "records:updated",
        context: {
          sheetId: "us_sh_FXDXMkQt",
          spaceId: "us_sp_rwHEsNEE",
          accountId: "us_acc_IlxChIlJ",
          sheetSlug: "subscribers-workbook/SubscribersSheet",
          versionId: "us_vr_cRcJk6Vj",
          environmentId: "us_env_R1Z2NjpQ",
        },
        callbackUrl: "",
        dataUrl: "",
        createdAt: "2023-03-03T15:06:33.824Z",
        acknowledgedAt: null,
      });
      const expected: boolean = false;

      expect(E.isRight(actual)).toBe(expected);
    });
  });
});
