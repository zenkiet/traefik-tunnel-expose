export function getGithubApiUrl(repo: string, version = 'latest'): string {
	return `https://github.com/${repo}/releases/${version}`;
}
