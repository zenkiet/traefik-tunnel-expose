export function getFileType(fileName: string): string {
	if (!fileName) {
		return 'unknown';
	}
	const lowerName = fileName.toLowerCase();
	if (lowerName.startsWith('.env')) {
		return 'env';
	}
	const ext = lowerName.split('.').pop();
	if (!ext || ext === lowerName) {
		return 'unknown';
	}

	if (ext === 'yml') {
		return 'yaml';
	}

	return ext;
}

export function isYAMLFile(fileName: string): boolean {
	const fileType = getFileType(fileName);
	return fileType === 'yaml' || fileType === 'yml';
}
