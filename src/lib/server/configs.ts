import path from 'node:path';
import { ensureConfPath, pathExists, paths } from './paths';
import type { ConfigFile } from '$lib/types';
import { createDirectory, readFile } from './files';

const SAFE_NAME = /^[A-Za-z0-9._-]+$/;

export async function loadConfigs(): Promise<ConfigFile[]> {
	await createDirectory(paths.services);

	const baseEntries: ConfigFile[] = [
		{
			id: 'traefik',
			label: 'Traefik',
			filePath: paths.traefik,
			category: 'core',
			exists: await pathExists(paths.traefik)
		},
		{
			id: 'cloudflared',
			label: 'Cloudflared',
			filePath: paths.cloudflared,
			category: 'core',
			exists: await pathExists(paths.cloudflared)
		}
	];

	const glob = new Bun.Glob('*.{yml,yaml}');
	const dynamicEntries: ConfigFile[] = [];

	for await (const fileName of glob.scan({ cwd: paths.services, onlyFiles: true })) {
		const filePath = path.join(paths.services, fileName);
		dynamicEntries.push({
			id: `service/${fileName}`,
			label: fileName,
			filePath,
			category: 'service',
			exists: true
		});
	}

	const [enrichedBase, enrichedDynamic] = await Promise.all([
		Promise.all(baseEntries.map((entry) => enrichWithStats(entry))),
		Promise.all(dynamicEntries.map((entry) => enrichWithStats(entry, true)))
	]);

	return [...enrichedBase, ...enrichedDynamic].sort((a, b) => a.label.localeCompare(b.label));
}

export async function resolveEntry(id: string): Promise<ConfigFile | null> {
	if (id.startsWith('service/')) {
		const label = id.replace(/^service\//, '');
		if (!SAFE_NAME.test(label)) return null;

		const filePath = ensureConfPath(label);
		const exists = await pathExists(filePath);

		return {
			id,
			label: label,
			filePath,
			category: 'service',
			exists
		};
	}

	return null;
}

export function extractHosts(content: string): string[] {
	const matches = [...content.matchAll(/Host\(`([^`]+)`\)/g)];
	return Array.from(new Set(matches.map((match) => match[1])));
}

async function enrichWithStats(entry: ConfigFile, includeHosts = false): Promise<ConfigFile> {
	if (!entry.exists) return entry;

	try {
		const file = Bun.file(entry.filePath);

		const size = file.size;
		const lastModified = file.lastModified;

		const result: ConfigFile = {
			...entry,
			size,
			updatedAt: new Date(lastModified).toISOString()
		};

		if (includeHosts) {
			const content = await file.text();
			const hosts = extractHosts(content);
			if (hosts.length) result.hosts = hosts;
		}

		return result;
	} catch {
		return { ...entry, exists: false };
	}
}
