import { getFileType, isYAMLFile } from '$lib/utils/file-type';
import fs from 'node:fs/promises';
import path from 'node:path';
import { isInside, paths } from './paths';
import { BACKUP_DIR } from '$lib/types/binary';

export async function createDirectory(dirPath: string): Promise<void> {
	await fs.mkdir(dirPath, { recursive: true });
}

export async function readFile(filePath: string): Promise<string> {
	return Bun.file(filePath).text();
}

export async function writeFile(filePath: string, data: string): Promise<void> {
	if (!isYAMLFile(filePath))
		return Promise.reject(new Error(`Unsupported file type: ${getFileType(filePath)}`));

	try {
		Bun.YAML.parse(data);
	} catch (err) {
		return Promise.reject(new Error('Invalid YAML content', { cause: err }));
	}

	if (!isInside(paths.root, filePath))
		return Promise.reject(new Error('Refusing to write outside project root'));

	await createDirectory(path.dirname(filePath));
	await Bun.write(filePath, data);
}

export async function deleteFile(filePath: string): Promise<void> {
	if (!isInside(paths.root, filePath))
		return Promise.reject(new Error('Refusing to delete outside project root'));

	try {
		await Bun.file(filePath).delete();
	} catch (err) {
		return Promise.reject(err);
	}

	// Cleanup empty directories
	const dir = path.dirname(filePath);
	if (!isInside(paths.services, dir)) return;

	try {
		const items = await fs.readdir(dir);
		if (!items.length) {
			await fs.rmdir(dir);
		}
	} catch {
		// ignore cleanup issues
	}
}

export async function moveFile(oldPath: string, newPath: string): Promise<void> {
	if (!isInside(paths.root, oldPath) || !isInside(paths.root, newPath))
		return Promise.reject(new Error('Refusing to move outside project root'));

	await createDirectory(path.dirname(newPath));
	await fs.rename(oldPath, newPath);
}

export async function existFile(filePath: string): Promise<boolean> {
	return await Bun.file(filePath).exists();
}

export async function listFiles(dirPath: string): Promise<string[]> {
	try {
		const glob = new Bun.Glob('*');
		const files: string[] = [];

		for await (const file of glob.scan({ cwd: dirPath, onlyFiles: true })) {
			files.push(path.join(dirPath, file));
		}
		return files;
	} catch (err) {
		console.error(`Error listing files in ${dirPath}:`, err);
		return [];
	}
}

export async function backupFile(filePath: string): Promise<string> {
	const backupPath = path.join(BACKUP_DIR, `${path.basename(filePath)}.backup.tar.gz`);

	try {
		await createDirectory(BACKUP_DIR);
		await zipFile(filePath, backupPath);
		console.log(`✓ Backup created: ${backupPath}`);
		return backupPath;
	} catch (error) {
		console.error(`Error creating backup for ${filePath}:`, error);
		throw error;
	}
}

export async function zipFile(sourcePath: string, zipPath: string): Promise<void> {
	const dir = path.dirname(sourcePath);
	const file = path.basename(sourcePath);

	await Bun.$`tar -czf ${zipPath} -C ${dir} ${file}`;
	console.log(`✓ Zipped to: ${zipPath}`);
}

export async function unzipFile(zipPath: string, outputDir: string): Promise<void> {
	await createDirectory(outputDir);

	await Bun.$`tar -xzf ${zipPath} -C ${outputDir}`;
	console.log(`✓ Unzipped to: ${outputDir}`);
}

export async function restoreFile(backupPath: string, targetPath: string): Promise<void> {
	await Bun.write(targetPath, Bun.file(backupPath));
}
