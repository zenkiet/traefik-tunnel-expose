import { readdir } from 'node:fs/promises';
import { error, type RequestHandler } from '@sveltejs/kit';
import { paths } from '$lib/server/paths';

export const GET: RequestHandler = async () => {
	const entries = await readdir(paths.services, { withFileTypes: true }).catch(() => []);
	const files = entries
		.filter((entry) => entry.isFile() && /\.ya?ml$/i.test(entry.name))
		.map((entry) => entry.name);

	if (!files.length) {
		throw error(404, 'No YAML services to export');
	}

	const proc = Bun.spawn({
		cmd: ['tar', '-czf', '-', ...files],
		cwd: paths.services,
		stdout: 'pipe',
		stderr: 'ignore'
	});

	return new Response(proc.stdout, {
		headers: {
			'Content-Type': 'application/gzip',
			'Content-Disposition': 'attachment; filename="services-conf.tar.gz"'
		}
	});
};
