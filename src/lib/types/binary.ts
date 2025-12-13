import { getIcon } from '$lib/utils/icon';

export const BACKUP_DIR = '/tmp/backup';

export enum BINARY {
	TRAEFIK = 'traefik',
	CLOUDFLARED = 'cloudflared'
}

type BinaryConfig = {
	name: string;
	path: string;
	githubRepo: string;
	versionArgs: string[];
	getDownloadUrl: (version: string) => string;
	extractCommand: (downloadUrl: string, targetPath: string) => string;
};

export const BINARY_CONFIG: Record<BINARY, BinaryConfig> = {
	[BINARY.TRAEFIK]: {
		name: 'Traefik',
		// path: '/usr/local/bin/traefik',
		path: '/Users/kietle/Desktop/test/traefik',
		githubRepo: 'traefik/traefik',
		versionArgs: ['version'],
		getDownloadUrl: (version: string) => {
			const tag = version.startsWith('v') ? version : `v${version}`;
			return `https://github.com/traefik/traefik/releases/download/${tag}/traefik_${tag}_${process.platform}_${process.arch}.tar.gz`;
		},
		extractCommand: (downloadUrl: string, targetPath: string) =>
			`curl -L "${downloadUrl}" -o /tmp/traefik.tar.gz && tar -xzf /tmp/traefik.tar.gz -C /tmp/ && mv /tmp/traefik ${targetPath} && chmod +x ${targetPath}`
	},
	[BINARY.CLOUDFLARED]: {
		// path: '/usr/local/bin/cloudflared',
		name: 'Cloudflare Tunnel',
		path: '/Users/kietle/Desktop/test/cloudflared',
		githubRepo: 'cloudflare/cloudflared',
		versionArgs: ['version'],
		getDownloadUrl: (version: string) =>
			`https://github.com/cloudflare/cloudflared/releases/download/${version}/cloudflared-${process.platform}-${process.arch}.tgz`,
		extractCommand: (downloadUrl: string, targetPath: string) =>
			`curl -L "${downloadUrl}" -o /tmp/cloudflared.tgz && tar -xzf /tmp/cloudflared.tgz -C /tmp/ && mv /tmp/cloudflared ${targetPath} && chmod +x ${targetPath}`
	}
};
