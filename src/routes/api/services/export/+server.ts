import fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { promisify } from 'node:util';
import { error, type RequestHandler } from '@sveltejs/kit';
import { paths } from '$lib/server/paths';

const execFile = promisify((await import('node:child_process')).execFile);

export const GET: RequestHandler = async () => {
	await fs.mkdir(paths.services, { recursive: true });

	const entries = await fs.readdir(paths.services, { withFileTypes: true }).catch(() => []);
	const files = entries
		.filter((entry) => entry.isFile() && /\.ya?ml$/i.test(entry.name))
		.map((entry) => entry.name);

	if (!files.length) {
		throw error(404, 'No YAML services to export');
	}

	const tempDir = await fs.mkdtemp(path.join(tmpdir(), 'services-export-'));
	const archivePath = path.join(tempDir, 'services-conf.tar.gz');

	await execFile('tar', ['-czf', archivePath, '-C', paths.services, ...files]);

	const buffer = await fs.readFile(archivePath);
	await fs.rm(tempDir, { recursive: true, force: true });

	return new Response(buffer, {
		headers: {
			'Content-Type': 'application/gzip',
			'Content-Disposition': 'attachment; filename="services-conf.tar.gz"'
		}
	});
};
