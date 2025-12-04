import { error, json, type RequestHandler } from '@sveltejs/kit';
import { loadEnv, upsertEnvValues } from '$lib/server/env';

export const GET: RequestHandler = async () => {
	return json({
		env: await loadEnv()
	});
};

export const PATCH: RequestHandler = async ({ request }) => {
	const payload = await request.json().catch(() => ({}));
	return persistEnv(payload);
};

export const POST: RequestHandler = async ({ request }) => {
	const payload = await request.json().catch(() => ({}));
	return persistEnv(payload);
};

async function persistEnv(payload: unknown) {
	if (!payload || typeof payload !== 'object') {
		throw error(400, 'Invalid payload');
	}

	const updates: Record<string, string> = {};
	Object.entries(payload).forEach(([key, value]) => {
		if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
			updates[key] = String(value);
		}
	});

	if (!Object.keys(updates).length) {
		throw error(400, 'No valid keys to update');
	}

	const env = await upsertEnvValues(updates);

	return json({ env });
}
