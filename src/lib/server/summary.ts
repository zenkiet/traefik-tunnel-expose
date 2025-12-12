import type { Summary } from '$lib/types';
import { loadConfigs } from './configs';
import { loadEnv } from './env';
import { paths } from './paths';

export async function buildSummary(): Promise<Summary> {
	const env = await loadEnv();
	const files = await loadConfigs();
	const services = files.filter((file) => file.category === 'service').length;
	const core = files.length - services;
	const version = '2.0.0';

	return {
		version,
		baseDomain: env.BASE_DOMAIN ?? 'localhost',
		host: env.HOST ?? '127.0.0.1',
		cloudflare: {
			enabled: env.CF_ENABLED === 'true' ? true : false,
			tunnelId: env.CF_TUNNEL_ID ?? ''
		},
		autoUpdate: env.AUTO_UPDATE === 'true' ? true : false,
		path: {
			traefik: paths.traefik,
			cloudflared: paths.cloudflared,
			services: paths.services
		},
		counts: {
			services,
			core,
			total: files.length
		}
	};
}
