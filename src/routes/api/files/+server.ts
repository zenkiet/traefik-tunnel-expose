import { json, type RequestHandler } from "@sveltejs/kit";
import { loadConfigs } from "$lib/server/configs";

export const GET: RequestHandler = async () => {
  const files = await loadConfigs();
  return json({ files: files.map(stripPath) });
};

function stripPath<T extends { filePath?: string }>(entry: T) {
  const { filePath, ...rest } = entry;
  void filePath;
  return rest;
}
