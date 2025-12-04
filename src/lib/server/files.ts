import YAML from "yaml";
import { getFileType, isYAMLFile } from "$lib/utils/file-type";
import fs from "node:fs/promises";
import path from "node:path";
import { isInside, paths } from "./paths";

export async function readConfig(filePath: string): Promise<string> {
  return fs.readFile(filePath, "utf8");
}

export async function writeConfig(
  filePath: string,
  data: string,
): Promise<void> {
  if (!isYAMLFile(filePath))
    return Promise.reject(
      new Error(`Unsupported file type: ${getFileType(filePath)}`),
    );

  YAML.parse(data);
  if (!isInside(paths.root, filePath))
    return Promise.reject(new Error("Refusing to write outside project root"));

  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(filePath, data, "utf8");
}

export async function deleteConfig(filePath: string): Promise<void> {
  if (!isInside(paths.root, filePath))
    return Promise.reject(new Error("Refusing to delete outside project root"));

  try {
    await fs.unlink(filePath);
  } catch (err) {
    return Promise.reject(err);
  }

  // clearup empty directories
  const dir = path.dirname(filePath);
  if (!isInside(paths.services, dir)) return;

  try {
    const items = await fs.readdir(dir);
    if (!items.length) {
      await fs.rmdir(dir);
    }
  } catch {
    // ignore cleanup issues
  }
}
