import { error, json, type RequestHandler } from '@sveltejs/kit';
import { getVersion } from '$lib/server/binary';

export const GET: RequestHandler = async () => {
	try {
		const data = await getVersion();
		return json({ data });
	} catch (err) {
		console.error('Failed to load binaries:', err);
		throw error(500, 'Unable to fetch binaries');
	}
};
