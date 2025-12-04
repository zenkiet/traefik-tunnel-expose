import { json, type RequestHandler } from '@sveltejs/kit';
import { loadConfigs } from '$lib/server/configs';

export const GET: RequestHandler = async () => {
	const files = await loadConfigs();

	const data = files.map((file) => {
		const { filePath, ...rest } = file;
		void filePath;
		return rest;
	});

	return json({ data });
};
