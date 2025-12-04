import { json, type RequestHandler } from "@sveltejs/kit";
import { loadEnv } from "$lib/server/env";
import { buildSummary } from "$lib/server/summary";

const SAFE_ENV_KEYS = [
  // 'HOST',
  // 'BASE_DOMAIN',
  // 'CF_ZONE_ID',
  // 'CF_TUNNEL_ID',
  // 'CF_ACCOUNT_ID',
  // 'CONFIG_PATH',
  // 'DATA_PATH',
  // 'TAG',
  // 'CF_ENABLED',
  // 'AUTO_UPDATE'
] as const;

type SafeEnvKey = (typeof SAFE_ENV_KEYS)[number];

export const GET: RequestHandler = async () => {
  const summary = await buildSummary();
  const env = await loadEnv();

  const envSnapshot = Object.fromEntries(
    SAFE_ENV_KEYS.flatMap((key) =>
      env.values[key as SafeEnvKey]
        ? [[key, env.values[key as SafeEnvKey]]]
        : [],
    ),
  );

  return json({ summary, env: envSnapshot });
};
