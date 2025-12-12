import { writeFile } from '$lib/server/files';
import { ensureConfPath } from '$lib/server/paths';
import { error, json, type RequestHandler } from '@sveltejs/kit';
import path from 'node:path';

const SAFE_NAME = /^[A-Za-z0-9._-]+$/;

export const POST: RequestHandler = async ({ request }) => {
	const form = await request.formData();
	const files = form.getAll('files').filter((value): value is File => value instanceof File);

	if (!files.length) {
		throw error(400, 'No files uploaded');
	}

	const imported: string[] = [];
	const problems: string[] = [];

	for (const file of files) {
		const base = path.basename(file.name || 'service.yml');
		const safe = SAFE_NAME.test(base) && /\.ya?ml$/i.test(base);

		if (!safe) {
			problems.push(base);
			continue;
		}

		const targetPath = ensureConfPath(base);
		const content = await file.text();

		try {
			await writeFile(targetPath, content);
			imported.push(base);
		} catch (err) {
			problems.push(base);
			console.error(`Failed to import ${base}:`, err);
		}
	}

	if (!imported.length) {
		throw error(
			400,
			problems.length ? `Failed to import: ${problems.join(', ')}` : 'No valid files'
		);
	}

	return json({ imported, skipped: problems });
};
