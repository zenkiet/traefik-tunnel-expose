const VALID_ENV = /^[A-Za-z_][A-Za-z0-9_]*$/;

// const SAFE_ENV_KEYS = [
// 	'HOST',
// 	'BASE_DOMAIN',
// 	'CF_ZONE_ID',
// 	'CF_TUNNEL_ID',
// 	'CF_ACCOUNT_ID',
// 	'CONFIG_PATH',
// 	'DATA_PATH',
// 	'TAG',
// 	'CF_ENABLED',
// 	'AUTO_UPDATE'
// ] as const;

// type SafeEnvKey = (typeof SAFE_ENV_KEYS)[number];

export async function loadEnv(): Promise<NodeJS.ProcessEnv> {
	const values: Record<string, string> = {};
	Object.keys(process.env).forEach((key) => {
		const value = process.env[key];
		if (value !== undefined) {
			values[key] = value;
		}
	});
	return values;
}

export async function upsertEnvValues(
	updates: Record<string, string | undefined>
): Promise<NodeJS.ProcessEnv> {
	for (const [key, value] of Object.entries(updates)) {
		if (value === undefined) {
			delete process.env[key];
		} else {
			if (!VALID_ENV.test(key)) {
				throw new Error(`Invalid environment variable name: ${key}`);
			}
			process.env[key] = String(value);
		}
	}

	return await loadEnv();
}
