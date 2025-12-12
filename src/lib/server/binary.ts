import { exec, execFile } from 'node:child_process';
import util from 'node:util';
import type { VersionInfo } from '$lib/types';
import { BINARY, BINARY_CONFIG } from '$lib/types/binary';
import { getGithubApiUrl } from '$lib/utils/api';
import { extractVersion } from '$lib/utils/regex';

const execFileAsync = util.promisify(execFile);
const execAsync = util.promisify(exec);

export async function getVersion(): Promise<VersionInfo> {
	const binaries = Object.values(BINARY);

	const [currentVersions, latestVersions] = await Promise.all([
		Promise.all(
			binaries.map(async (binary) => {
				const config = BINARY_CONFIG[binary];
				const { stdout } = await execFileAsync(config.path, config.versionArgs);
				return { binary, version: extractVersion(stdout) || 'unknown' };
			})
		),
		Promise.all(
			binaries.map(async (binary) => {
				const config = BINARY_CONFIG[binary];
				const apiUrl = getGithubApiUrl(config.githubRepo);
				const version = await getLatestVersion(apiUrl);
				return { binary, version: extractVersion(version) || version };
			})
		)
	]);

	return binaries.reduce((result, binary, i) => {
		const current = currentVersions[i].version;
		const latest = latestVersions[i].version;
		result[binary] = { version: current, needUpdate: current !== latest, latest };
		return result;
	}, {} as VersionInfo);
}

export async function getLatestVersion(link: string): Promise<string> {
	const response = await fetch(link, { redirect: 'manual' });
	const location = response.headers.get('location');
	if (!location) throw new Error('No redirect found');
	return location.split('/').pop() || '';
}

export async function updateBinary(binary: BINARY, version: string): Promise<VersionInfo[BINARY]> {
	const config = BINARY_CONFIG[binary];

	const downloadUrl = config.getDownloadUrl(version);

	const command = config.extractCommand(downloadUrl, config.path);
	await execAsync(command);

	const { stdout } = await execFileAsync(config.path, config.versionArgs);
	const result = extractVersion(stdout) || 'unknown';

	return {
		version: result,
		needUpdate: false,
		latest: result
	};
}
