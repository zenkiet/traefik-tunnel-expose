import { extractHosts, resolveEntry } from '$lib/server/configs';
import { readFile, writeFile, deleteFile } from '$lib/server/files';
import { getFileType } from '$lib/utils/file-type';
import { error, json, type RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async ({ params }) => {
	if (!params.id) {
		throw error(400, 'Missing config id');
	}

	const id = decodeURIComponent(params.id);
	const entry = await resolveEntry(id);

	if (!entry) {
		throw error(404, 'Config not found');
	}

	if (!entry.exists) {
		throw error(404, 'File does not exist yet');
	}

	const content = await readFile(entry.filePath);

	return json({
		entry: toPublicEntry(entry),
		content,
		hosts: getFileType(entry.filePath) === 'yaml' ? extractHosts(content) : []
	});
};

export const PUT: RequestHandler = async ({ params, request }) => {
	if (!params.id) {
		throw error(400, 'Missing config id');
	}

	const id = decodeURIComponent(params.id);
	const entry = await resolveEntry(id);

	if (!entry) {
		throw error(404, 'Config not found');
	}

	const payload = await request.json().catch(() => ({}));
	if (typeof payload.content !== 'string') {
		throw error(400, 'Missing content');
	}

	await writeFile(entry.filePath, payload.content);

	return json({ ok: true });
};

export const DELETE: RequestHandler = async ({ params }) => {
	if (!params.id) {
		throw error(400, 'Missing config id');
	}

	const id = decodeURIComponent(params.id);
	const entry = await resolveEntry(id);

	if (!entry) {
		throw error(404, 'Config not found');
	}

	if (entry.category !== 'service' && entry.id !== 'traefik' && entry.id !== 'cloudflared') {
		throw error(400, 'Deletion not allowed for this file');
	}

	await deleteFile(entry.filePath);

	return json({ ok: true });
};

function toPublicEntry(entry: NonNullable<Awaited<ReturnType<typeof resolveEntry>>>) {
	const { filePath, ...rest } = entry;
	void filePath;
	return rest;
}
