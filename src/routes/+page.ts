import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
	const [summaryRes, filesRes, binariesRes] = await Promise.all([
		fetch('/api/summary'),
		fetch('/api/files'),
		fetch('/api/binaries')
	]);

	const summary = summaryRes.ok ? await summaryRes.json() : {};
	const files = filesRes.ok ? await filesRes.json() : {};
	const versions = binariesRes.ok ? await binariesRes.json() : {};

	return {
		summary: summary.data,
		files: files.data,
		versions: versions.data
	};
};
