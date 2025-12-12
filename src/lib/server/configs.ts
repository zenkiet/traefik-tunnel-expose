import fs from 'node:fs/promises';
import path from 'node:path';
import { ensureConfPath, pathExists, paths } from './paths';
import type { ConfigFile } from '$lib/types';

const SAFE_NAME = /^[A-Za-z0-9._-]+$/;

export async function loadConfigs(): Promise<ConfigFile[]> {
	await fs.mkdir(paths.services, { recursive: true });

	const baseEntries: ConfigFile[] = [
		{
			id: 'traefik',
			label: 'Traefik',
			filePath: paths.traefik,
			category: 'core',
			exists: pathExists(paths.traefik)
		},
		{
			id: 'cloudflared',
			label: 'Cloudflared',
			filePath: paths.cloudflared,
			category: 'core',
			exists: pathExists(paths.cloudflared)
		}
	];

	const dynamicEntries = await fs
		.readdir(paths.services, { withFileTypes: true })
		.catch(() => [])
		.then((entries) =>
			entries
				.filter((entry) => entry.isFile() && /\.(ya?ml)$/i.test(entry.name))
				.map((entry) => {
					const filePath = path.join(paths.services, entry.name);
					return {
						id: `service/${entry.name}`,
						label: entry.name,
						filePath,
						category: 'service',
						exists: true
					};
				})
		);

	const enrichedBase = await Promise.all(baseEntries.map((entry) => enrichWithStats(entry)));
	const enrichedDynamic = await Promise.all(
		dynamicEntries.map((entry) => enrichWithStats(entry as ConfigFile, true))
	);

	return [...enrichedBase, ...enrichedDynamic].sort((a, b) => a.label.localeCompare(b.label));
}

export async function resolveEntry(id: string): Promise<ConfigFile | null> {
	if (id.startsWith('service/')) {
		const name = id.replace(/^service\//, '');
		if (!SAFE_NAME.test(name)) return null;
		const filePath = ensureConfPath(name);

		return {
			id,
			label: name,
			filePath,
			category: 'service',
			exists: pathExists(filePath)
		};
	}

	return null;
}

export function extractHosts(content: string): string[] {
	const matches = [...content.matchAll(/Host\(`([^`]+)`\)/g)];
	return Array.from(new Set(matches.map((match) => match[1])));
}

async function enrichWithStats(entry: ConfigFile, includeHosts = false): Promise<ConfigFile> {
	try {
		const stat = await fs.stat(entry.filePath);

		const result: ConfigFile = {
			...entry,
			exists: true,
			size: stat.size,
			updatedAt: stat.mtime.toISOString()
		};

		if (includeHosts) {
			const content = await fs.readFile(entry.filePath, 'utf8').catch(() => '');
			const hosts = extractHosts(content);
			if (hosts.length) result.hosts = hosts;
		}

		return result;
	} catch {
		return { ...entry, exists: false };
	}
}
