<script lang="ts">
	import type { ConfigFile } from '$lib/types';
	import { toast } from '$lib/services/toast';
	import Button from './ui/button.svelte';

	let {
		services,
		selectedId,
		search,
		onSelect,
		onCreate,
		onRefresh = () => {}
	} = $props<{
		services: ConfigFile[];
		selectedId: string;
		search: string;
		onSelect: (id: string) => void;
		onCreate: () => void;
		onRefresh?: () => void | Promise<void>;
	}>();

	const filteredServices = $derived(
		services.filter((service: ConfigFile) => {
			if (!search) return true;
			const query = search.toLowerCase();
			return (
				service.label.toLowerCase().includes(query) ||
				service.filePath.toLowerCase().includes(query) ||
				service.hosts?.some((h) => h.toLowerCase().includes(query))
			);
		})
	);

	const acceptTypes = '.yml';
	let isImportOpen = $state(false);
	let isDragging = $state(false);
	let importing = $state(false);
	let selectedFiles = $state<File[]>([]);
	let fileInput: HTMLInputElement | null = $state(null);

	function closeImport() {
		isImportOpen = false;
		selectedFiles = [];
		isDragging = false;
	}

	function normalizeName(name: string) {
		return name
			.trim()
			.replace(/[^A-Za-z0-9._-]+/g, '-')
			.replace(/-{2,}/g, '-');
	}

	function addFiles(list?: FileList | File[]) {
		if (!list?.length) return;

		const valid: File[] = [];
		for (const file of Array.from(list)) {
			if (!file.name.match(/\.yml$/i)) {
				toast.warning('Invalid file type', `File "${file.name}" is not a YAML file.`);
				continue;
			}
			const safeName = normalizeName(file.name);
			const renamed =
				safeName !== file.name ? new File([file], safeName, { type: file.type }) : file;
			valid.push(renamed);
		}

		if (valid.length) {
			selectedFiles = [...selectedFiles, ...valid];
		}
	}

	function onDrop(event: DragEvent) {
		event.preventDefault();
		isDragging = false;
		if (event.dataTransfer?.files) addFiles(event.dataTransfer.files);
	}

	function handleBrowse(event: Event) {
		const input = event.target as HTMLInputElement;
		if (input?.files) {
			addFiles(input.files);
			input.value = '';
		}
	}

	async function importFiles() {
		if (!selectedFiles.length) {
			toast.info('No files selected', 'Please select at least one YAML file to import');
			return;
		}

		try {
			const formData = new FormData();
			selectedFiles.forEach((file) => formData.append('files', file, file.name));

			const res = await fetch('/api/services/import', {
				method: 'POST',
				body: formData
			});

			if (!res.ok) {
				toast.error('Import failed', 'Could not import services');
				throw new Error('Import failed');
			}

			const body = await res.json();
			const count = body?.imported?.length ?? selectedFiles.length;
			toast.success('Imported services', `${count} file(s) added`);
			await onRefresh?.();
			closeImport();
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Import failed';
			toast.error('Import failed', message);
		}
	}

	async function exportServices() {
		try {
			const res = await fetch('/api/services/export');
			const blob = await res.blob();
			if (!res.ok) {
				const text = await blob.text();
				toast.error('Export failed', text || 'Could not export services');
				return;
			}
			toast.success('Export ready', 'Downloaded services-conf.zip');
			const url = URL.createObjectURL(blob);
			const a = document.createElement('a');
			a.href = url;
			a.download = 'services-conf.zip';
			document.body.appendChild(a);
			a.click();
			a.remove();
			URL.revokeObjectURL(url);
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Export failed';
			toast.error('Export failed', message);
		}
	}
</script>

<aside class="panel relative flex h-full flex-col gap-4">
	<div class="flex items-center justify-between gap-2">
		<p class="section-label">Config</p>
		<span class="badge">{services.length} services</span>
	</div>

	<div class="mt-2 flex items-center gap-2">
		<div class="relative flex-1">
			<input
				class="input w-full"
				placeholder="Search services by name, host or path..."
				bind:value={search}
			/>
		</div>

		<div class="flex items-center gap-2">
			<Button size="icon" onclick={() => (isImportOpen = true)} title="Import services">
				<i class="icon-[duotone--upload] size-5"></i>
			</Button>

			<Button
				size="icon"
				onclick={exportServices}
				title="Export services"
				aria-label="Export services"
			>
				<i class="icon-[duotone--download] size-5"></i>
			</Button>
		</div>

		<Button size="icon" onclick={onCreate} title="Add service" aria-label="Add service">
			<i class="icon-[duotone--plus] size-5"></i>
		</Button>
	</div>

	<div class="panel-nested mt-3 h-full">
		<p class="section-label">Services</p>
		<div class="mt-3 grid gap-3 transition-all duration-200 sm:grid-cols-2">
			{#if filteredServices.length}
				{#each filteredServices as file (file.id)}
					<button
						class="service-card {selectedId === file.id ? 'active' : ''}"
						onclick={() => onSelect(file.id)}
					>
						<div class="flex w-full items-start justify-between gap-2">
							<div class="min-w-0">
								<p class="truncate text-[13px] font-semibold">{file.label}</p>
								<p class="mt-0.5 line-clamp-2 text-xs text-muted">
									{file.hosts?.join(', ') ?? file.relativePath}
								</p>
							</div>
						</div>
					</button>
				{/each}
			{:else}
				<p class="mt-1 text-xs text-hint">No services match your search.</p>
			{/if}
		</div>
	</div>

	{#if isImportOpen}
		<div class="modal-backdrop">
			<div
				class="modal-lg"
				role="region"
				ondragover={(event) => {
					event.preventDefault();
					isDragging = true;
				}}
				ondragleave={(event) => {
					event.preventDefault();
					isDragging = false;
				}}
				ondrop={onDrop}
			>
				<div class="flex items-start justify-between gap-3">
					<div>
						<p class="section-label">Import</p>
						<h3 class="section-title">Add Service files</h3>
						<p class="text-sm text-muted">Drag and drop or select multiple .yml files.</p>
					</div>

					<Button size="icon" type="button" aria-label="Close import" onclick={closeImport}>
						<i class="icon-[duotone--xmark] size-4"></i>
					</Button>
				</div>

				<div class="drop-zone mt-4 {isDragging ? 'active' : ''}">
					<div class="icon-box size-12 rounded-full text-[var(--emerald)]">
						<i class="icon-[duotone--download] size-5"></i>
					</div>
					<p class="text-sm">
						<span class="font-semibold text-[var(--emerald)]">Drag and drop</span> or
						<button
							type="button"
							class="link-accent cursor-pointer underline underline-offset-4"
							onclick={() => fileInput?.click()}
						>
							choose files
						</button>
					</p>
					<p class="text-xs text-hint">Support .yml files only</p>
					<input
						accept={acceptTypes}
						bind:this={fileInput}
						class="hidden"
						multiple
						type="file"
						onchange={handleBrowse}
					/>
				</div>

				{#if selectedFiles.length}
					<div class="panel-nested mt-4 text-sm">
						<p class="section-label">Selected files: ({selectedFiles.length})</p>
						<ul class="scrollable mt-2 max-h-48 space-y-1">
							{#each selectedFiles as file, idx (file.name)}
								<li
									class="flex items-center justify-between gap-2 rounded-lg px-2 py-1 hover:bg-[var(--card-hover)]"
								>
									<span class="truncate font-mono text-xs">{file.name}</span>
									<button
										class="cursor-pointer text-xs text-muted hover:text-[var(--destructive)]"
										type="button"
										onclick={() => (selectedFiles = selectedFiles.filter((_, i) => i !== idx))}
									>
										Remove
									</button>
								</li>
							{/each}
						</ul>
					</div>
				{/if}

				<div class="mt-5 flex flex-wrap items-center justify-end gap-2">
					<Button variant="outline" type="button" onclick={closeImport} disabled={importing}>
						Cancel
					</Button>

					<Button type="button" onclick={importFiles} disabled={importing}>
						{importing ? 'Importing...' : 'Import'}
					</Button>
				</div>
			</div>
		</div>
	{/if}
</aside>
