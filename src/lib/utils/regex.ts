export const SEMVER_REGEX =
	/(\d+)\.(\d+)\.(\d+)(?:-([\da-zA-Z-]+(?:\.[\da-zA-Z-]+)*))?(?:\+([\da-zA-Z-]+(?:\.[\da-zA-Z-]+)*))?/;

export function extractVersion(output: string): string | null {
	const match = output.match(SEMVER_REGEX);
	return match ? match[0] : null;
}
