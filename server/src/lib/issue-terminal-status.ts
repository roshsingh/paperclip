/**
 * Issue statuses where automated harness checkout must not run (PUR-5 / PUR-6).
 * Checkout mutates ownership and forces `in_progress`; terminal rows must stay terminal
 * until a governed reopen path runs.
 */
export function isTerminalHarnessIssueStatus(status: string | null | undefined): boolean {
  const normalized = typeof status === "string" ? status.trim().toLowerCase() : "";
  return normalized === "done" || normalized === "cancelled";
}
