import YAML from 'yaml';
import { getFileType, isYAMLFile } from '$lib/utils/file-type';
import fs from 'node:fs/promises';
import path from 'node:path';
import { isInside, paths } from './paths';
import { BACKUP_DIR } from '$lib/types/binary';
import util from 'node:util';

const { exec } = await import('node:child_process');
const execAsync = util.promisify(exec);

export async function readFile(filePath: string): Promise<string> {
	return fs.readFile(filePath, 'utf8');
}

export async function writeFile(filePath: string, data: string): Promise<void> {
	if (!isYAMLFile(filePath))
		return Promise.reject(new Error(`Unsupported file type: ${getFileType(filePath)}`));

	YAML.parse(data);
	if (!isInside(paths.root, filePath))
		return Promise.reject(new Error('Refusing to write outside project root'));

	await fs.mkdir(path.dirname(filePath), { recursive: true });
	await fs.writeFile(filePath, data, 'utf8');
}

export async function deleteFile(filePath: string): Promise<void> {
	if (!isInside(paths.root, filePath))
		return Promise.reject(new Error('Refusing to delete outside project root'));

	try {
		await fs.unlink(filePath);
	} catch (err) {
		return Promise.reject(err);
	}

	// clearup empty directories
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
	await fs.mkdir(path.dirname(newPath), { recursive: true });
	await fs.rename(oldPath, newPath);
}

export async function existFile(filePath: string): Promise<boolean> {
	try {
		await fs.access(filePath, fs.constants.F_OK);
		return true;
	} catch {
		return false;
	}
}

export async function listFiles(dirPath: string): Promise<string[]> {
	try {
		const entries = await fs.readdir(dirPath, { withFileTypes: true });
		return entries.filter((entry) => entry.isFile()).map((entry) => path.join(dirPath, entry.name));
	} catch (err) {
		if ((err as NodeJS.ErrnoException).code === 'ENOENT') {
			return [];
		}
		throw err;
	}
}

export async function backupFile(filePath: string): Promise<string> {
	const backupPath = path.join(BACKUP_DIR, `${path.basename(filePath)}.backup.tar.gz`);

	try {
		await fs.mkdir(BACKUP_DIR, { recursive: true });
		await zipFile(filePath, backupPath);
		console.log(`✓ Backup created: ${backupPath}`);
		return backupPath;
	} catch (error) {
		console.error(`Error creating backup for ${filePath}:`, error);
		throw error;
	}
}

export async function zipFile(sourcePath: string, zipPath: string): Promise<void> {
	await execAsync(
		`tar -czf ${zipPath} -C ${path.dirname(sourcePath)} ${path.basename(sourcePath)}`
	);
	console.log(`✓ Zipped to: ${zipPath}`);
}

export async function unzipFile(zipPath: string, outputDir: string): Promise<void> {
	await fs.mkdir(outputDir, { recursive: true });
	await execAsync(`tar -xzf ${zipPath} -C ${outputDir}`);
	console.log(`✓ Unzipped to: ${outputDir}`);
}

export async function restoreFile(backupPath: string, targetPath: string): Promise<void> {
	await fs.copyFile(backupPath, targetPath);
}
