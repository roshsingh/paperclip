import { describe, expect, it } from "vitest";
import {
  ISSUE_CONTINUATION_FAILURE_NEXT_ACTION,
  ISSUE_CONTINUATION_SUMMARY_MAX_BODY_CHARS,
  buildContinuationSummaryMarkdown,
} from "../services/issue-continuation-summary.js";

describe("issue continuation summaries", () => {
  it("builds bounded issue-local handoff context with required sections", () => {
    const body = buildContinuationSummaryMarkdown({
      issue: {
        id: "issue-1",
        identifier: "PAP-1579",
        title: "Add continuation summaries",
        description: [
          "## Objective",
          "",
          "Keep work resumable after adapter session reset.",
          "",
          "## Acceptance Criteria",
          "",
          "- Summary is issue-local",
          "- Wake context includes the summary",
        ].join("\n"),
        status: "in_progress",
        priority: "medium",
      },
      run: {
        id: "run-1",
        status: "succeeded",
        error: null,
        resultJson: {
          summary: "Updated server/src/services/heartbeat.ts and packages/adapter-utils/src/server-utils.ts.",
        },
        stdoutExcerpt: null,
        stderrExcerpt: null,
        finishedAt: new Date("2026-04-18T12:00:00.000Z"),
      },
      agent: {
        id: "agent-1",
        name: "CodexCoder",
        adapterType: "codex_local",
      },
    });

    expect(body).toContain("# Continuation Summary");
    expect(body).toContain("## Objective");
    expect(body).toContain("Keep work resumable after adapter session reset.");
    expect(body).toContain("## Acceptance Criteria");
    expect(body).toContain("- Summary is issue-local");
    expect(body).toContain("## Recent Concrete Actions");
    expect(body).toContain("Run `run-1` finished with status `succeeded`");
    expect(body).toContain("`server/src/services/heartbeat.ts`");
    expect(body).toContain("## Commands Run");
    expect(body).toContain("## Blockers / Decisions");
    expect(body).toContain("## Next Action");
    expect(body.length).toBeLessThanOrEqual(ISSUE_CONTINUATION_SUMMARY_MAX_BODY_CHARS);
  });

  it("uses failure state to point the next run at the error", () => {
    const body = buildContinuationSummaryMarkdown({
      issue: {
        id: "issue-1",
        identifier: "PAP-1579",
        title: "Add continuation summaries",
        description: null,
        status: "in_progress",
        priority: "medium",
      },
      run: {
        id: "run-2",
        status: "failed",
        error: "adapter failed",
        errorCode: "adapter_failed",
        resultJson: null,
      },
      agent: {
        id: "agent-1",
        name: "CodexCoder",
        adapterType: "codex_local",
      },
    });

    expect(body).toContain("Latest run error (adapter_failed): adapter failed");
    expect(body).toContain(ISSUE_CONTINUATION_FAILURE_NEXT_ACTION);
  });

  it("does not carry failure next-action text after a succeeded run", () => {
    const previousBody = [
      "# Continuation Summary",
      "",
      "## Next Action",
      "",
      `- ${ISSUE_CONTINUATION_FAILURE_NEXT_ACTION}`,
    ].join("\n");

    const body = buildContinuationSummaryMarkdown({
      issue: {
        id: "issue-1",
        identifier: "PAP-1579",
        title: "Recover after transient adapter failure",
        description: null,
        status: "in_progress",
        priority: "high",
      },
      run: {
        id: "run-ok",
        status: "succeeded",
        error: null,
        resultJson: { summary: "Green build; no adapter error." },
        finishedAt: new Date("2026-04-21T10:00:00.000Z"),
      },
      agent: {
        id: "agent-1",
        name: "Cursor",
        adapterType: "cursor",
      },
      previousSummaryBody: previousBody,
    });

    expect(body).toContain("Run `run-ok` finished with status `succeeded`");
    expect(body).not.toContain("Inspect the failed run");
  });
});
