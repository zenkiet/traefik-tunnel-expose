export type ConfigCategory = "core" | "service";

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
  baseDomain: string;
  host: string;
  tunnelId: string;
  env: NodeJS.ProcessEnv;
  path: {
    traefik: string;
    cloudflared: string;
    services: string;
  }
  counts: {
    services: number;
    core: number;
    total: number;
  };
}
