import type { ConfigFile, Summary } from "$lib/types";
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ fetch }) => {
  const [summaryRes, filesRes] = await Promise.all([
    fetch("/api/summary"),
    fetch("/api/files"),
  ]);

  const summaryData = summaryRes.ok ? await summaryRes.json() : {};
  const filesData = filesRes.ok ? await filesRes.json() : {};

  return {
    summary: (summaryData.summary ?? {}) as Summary,
    files: (filesData.files ?? []) as ConfigFile[],
  };
};
