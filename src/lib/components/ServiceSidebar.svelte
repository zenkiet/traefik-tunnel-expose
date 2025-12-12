<script lang="ts">
	import type { ConfigFile } from '$lib/types';
	import { toast } from '$lib/services/toast';

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

<aside class="glass p-4 rounded-2xl relative flex flex-col gap-4 h-full">
	<div class="flex items-center justify-between gap-2">
		<h1 class="text-lg font-semibold text-slate-50 md:text-xl">Config Dashboard</h1>
		<span
			class="rounded-full border border-emerald-400/40 bg-emerald-500/10 px-2.5 py-0.5 text-xs font-medium text-emerald-200"
		>
			{services.length} services
		</span>
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
			<button
				class="soft-button py-2 px-2"
				type="button"
				title="Import YAML"
				aria-label="Import YAML"
				onclick={() => (isImportOpen = true)}
			>
				<svg
					class="h-5 w-5 text-slate-100"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M4 17v2a1 1 0 001 1h14a1 1 0 001-1v-2"
					/>
					<path stroke-linecap="round" stroke-linejoin="round" d="M7 10l5-6 5 6" />
					<path stroke-linecap="round" stroke-linejoin="round" d="M12 4v12" />
				</svg>
			</button>

			<button
				class="soft-button py-2 px-2 disabled:opacity-50"
				type="button"
				title="Export services"
				aria-label="Export services"
				onclick={exportServices}
			>
				<svg
					class="h-5 w-5 text-slate-100"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M20 7V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2"
					/>
					<path stroke-linecap="round" stroke-linejoin="round" d="M7 14l5 6 5-6" />
					<path stroke-linecap="round" stroke-linejoin="round" d="M12 20V8" />
				</svg>
			</button>
		</div>
		<button class="soft-button py-2 px-2" type="button" onclick={onCreate}>
			<span class="text-base leading-none">＋</span>
		</button>
	</div>

	<div class="glass rounded-xl p-3 mt-3 h-full">
		<p class="text-xs font-medium uppercase tracking-[0.18em] text-slate-400">Services</p>
		<div class="mt-3 grid gap-3 transition-all duration-200 sm:grid-cols-2">
			{#if filteredServices.length}
				{#each filteredServices as file (file.id)}
					<div class="relative group">
						<button
							class={`soft-button group w-full text-left text-sm transition-all duration-200 ${
								selectedId === file.id
									? 'active'
									: 'border-slate-700/70 bg-slate-900/60 hover:border-emerald-400/60 hover:bg-slate-900'
							}`}
							onclick={() => onSelect(file.id)}
						>
							<div class="flex items-start justify-between gap-2 w-full">
								<div class="min-w-0">
									<p class="truncate text-[13px] font-semibold text-slate-50">{file.label}</p>
									<p class="mt-0.5 line-clamp-2 text-xs text-slate-400">
										{file.hosts?.join(', ') ?? file.relativePath}
									</p>
								</div>
							</div>
						</button>
					</div>
				{/each}
			{:else}
				<p class="mt-1 text-xs text-slate-500">No services match your search.</p>
			{/if}
		</div>
	</div>

	{#if isImportOpen}
		<div class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 px-3">
			<div
				class="glass relative w-full max-w-2xl rounded-2xl border border-white/10 bg-slate-950/90 p-6 shadow-2xl"
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
						<p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Import</p>
						<h3 id="import-title" class="text-xl font-semibold text-slate-50">Add Service files</h3>
						<p class="text-sm text-slate-400">Drag and drop or select multiple .yml files.</p>
					</div>
					<button
						class="soft-button px-2 py-1.5 text-xs"
						type="button"
						aria-label="Close import"
						onclick={closeImport}
					>
						Close
					</button>
				</div>

				<div
					class={`mt-4 flex flex-col items-center justify-center gap-3 rounded-2xl border-2 border-dashed p-6 text-center transition ${
						isDragging
							? 'border-emerald-400/80 bg-emerald-500/5'
							: 'border-white/10 bg-slate-900/60'
					}`}
				>
					<div
						class="flex h-12 w-12 items-center justify-center rounded-full bg-white/5 text-emerald-200"
					>
						<svg
							class="h-5 w-5 text-slate-100"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							stroke-width="2"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								d="M4 17v2a1 1 0 001 1h14a1 1 0 001-1v-2"
							/>
							<path stroke-linecap="round" stroke-linejoin="round" d="M7 10l5-6 5 6" />
							<path stroke-linecap="round" stroke-linejoin="round" d="M12 4v12" />
						</svg>
					</div>
					<p class="text-sm text-slate-200">
						<span class="font-semibold text-emerald-200">Drag and drop</span> or
						<button
							type="button"
							class="cursor-pointer underline underline-offset-4 decoration-emerald-400 hover:text-emerald-200"
							onclick={() => fileInput?.click()}
						>
							choose files
						</button>
					</p>
					<p class="text-xs text-slate-400">Support .yml files only</p>
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
					<div class="mt-4 space-y-2 rounded-xl border border-white/5 bg-slate-900/60 p-3 text-sm">
						<p class="text-xs font-semibold uppercase tracking-[0.2em] text-slate-400">
							Selected files: ({selectedFiles.length})
						</p>
						<ul class="max-h-48 space-y-1 overflow-y-auto text-slate-200">
							{#each selectedFiles as file, idx (file.name)}
								<li
									class="flex items-center justify-between gap-2 rounded-lg px-2 py-1 hover:bg-white/5"
								>
									<span class="truncate font-mono text-xs">{file.name}</span>
									<button
										class="text-xs text-slate-400 hover:text-red-200 cursor-pointer"
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
					<button class="soft-button bg-white/5 text-slate-200" type="button" onclick={closeImport}>
						Cancel
					</button>
					<button class="soft-button" type="button" onclick={importFiles} disabled={importing}>
						{importing ? 'Importing...' : 'Import'}
					</button>
				</div>
			</div>
		</div>
	{/if}
</aside>
