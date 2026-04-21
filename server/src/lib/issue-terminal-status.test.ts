import { describe, expect, it } from "vitest";
import { isTerminalHarnessIssueStatus } from "./issue-terminal-status.js";

describe("isTerminalHarnessIssueStatus", () => {
  it("returns true for done and cancelled (case-insensitive)", () => {
    expect(isTerminalHarnessIssueStatus("done")).toBe(true);
    expect(isTerminalHarnessIssueStatus("DONE")).toBe(true);
    expect(isTerminalHarnessIssueStatus(" cancelled ")).toBe(true);
  });

  it("returns false for non-terminal workflow statuses", () => {
    expect(isTerminalHarnessIssueStatus("todo")).toBe(false);
    expect(isTerminalHarnessIssueStatus("in_progress")).toBe(false);
    expect(isTerminalHarnessIssueStatus("in_review")).toBe(false);
    expect(isTerminalHarnessIssueStatus("blocked")).toBe(false);
    expect(isTerminalHarnessIssueStatus("backlog")).toBe(false);
  });

  it("returns false for nullish", () => {
    expect(isTerminalHarnessIssueStatus(null)).toBe(false);
    expect(isTerminalHarnessIssueStatus(undefined)).toBe(false);
    expect(isTerminalHarnessIssueStatus("")).toBe(false);
  });
});
