export type ConfigCategory = 'core' | 'service';

export interface VersionInfo {
	traefik: {
		version: string;
		needUpdate: boolean;
		latest: string;
	};
	cloudflared: {
		version: string;
		needUpdate: boolean;
		latest: string;
	};
}

export interface ConfigFile {
	id: string;
	label: string;
	filePath: string;
	category: ConfigCategory;
	exists: boolean;
	size?: number;
	updatedAt?: string;
	hosts?: string[];
}

export interface Summary {
	version: string;
	baseDomain: string;
	host: string;
	cloudflare: {
		enabled: boolean;
		tunnelId: string;
	};
	autoUpdate: boolean;
	path: {
		traefik: string;
		cloudflared: string;
		services: string;
	};
	counts: {
		services: number;
		core: number;
		total: number;
	};
}
