import { json, type RequestHandler } from '@sveltejs/kit';
import { buildSummary } from '$lib/server/summary';

export const GET: RequestHandler = async () => {
	const data = await buildSummary();
	return json({ data });
};
