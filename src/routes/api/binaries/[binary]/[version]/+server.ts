import { updateBinary } from '$lib/server/binary';
import type { BINARY } from '$lib/types/binary';
import { error, json, type RequestHandler } from '@sveltejs/kit';

export const POST: RequestHandler = async ({ params }) => {
	const binary = params.binary as BINARY;
	const version = params.version;

	if (!binary || !version) {
		throw error(400, 'Binary name and version are required');
	}

	try {
		const result = await updateBinary(binary, version);
		return json({ result });
	} catch (err) {
		console.error(`Failed to update ${binary}:`, err);
		throw error(500, err instanceof Error ? err.message : 'Update failed');
	}
};

export const PATCH = POST;
