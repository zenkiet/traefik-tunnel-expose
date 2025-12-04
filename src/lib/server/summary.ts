import type { Summary } from "$lib/types";
import { loadConfigs } from "./configs";
import { loadEnv } from "./env";
import { paths } from "./paths";

export async function buildSummary(): Promise<Summary> {
	const env = await loadEnv();
	const files = await loadConfigs();
	const services = files.filter((file) => file.category === 'service').length;
	const core = files.length - services;

	return {
		baseDomain: env.BASE_DOMAIN ?? 'localhost',
		host: env.HOST ?? '127.0.0.1',
		tunnelId: env.CF_TUNNEL_ID ?? '',
		env,
    path: {
      traefik: paths.traefik,
      cloudflared: paths.cloudflared,
      services: paths.services,
    },
		counts: {
			services,
			core,
			total: files.length
		}
	};
}
