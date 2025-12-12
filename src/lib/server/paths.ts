import fs from 'node:fs';
import path from 'node:path';

const root = '/etc';

export const paths = {
	root,
	traefik: path.join(root, '/traefik', 'traefik.yaml'),
	cloudflared: path.join(root, '/cloudflared', 'cloudflared.yml'),
	services: path.join(root, '/traefik', 'conf.d')
};

export function isInside(base: string, target: string): boolean {
	const resolvedBase = path.resolve(base);
	const resolvedTarget = path.resolve(target);
	return resolvedTarget === resolvedBase || resolvedTarget.startsWith(resolvedBase + path.sep);
}

export function ensureConfPath(name: string): string {
	const safeName = path.basename(name);
	const full = path.join(paths.services, safeName);

	if (!isInside(paths.services, full)) {
		throw new Error('Invalid conf.d path');
	}

	return full;
}

export function pathExists(filePath: string): boolean {
	try {
		fs.accessSync(filePath, fs.constants.F_OK);
		return true;
	} catch {
		return false;
	}
}
