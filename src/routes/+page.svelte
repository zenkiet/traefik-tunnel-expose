<script lang="ts">
	import { toast } from '$lib/services/toast';
	import ServiceSidebar from '$lib/components/ServiceSidebar.svelte';
	import EnvironmentForm from '$lib/components/EnvironmentForm.svelte';
	import BinaryPanel from '$lib/components/BinaryPanel.svelte';
	import EditorPanel from '$lib/components/EditorPanel.svelte';
	import NewServiceModal from '$lib/components/dialogs/NewServiceModal.svelte';
	import DeleteConfirmModal from '$lib/components/dialogs/DeleteConfirmModal.svelte';
	import AppHeader from '$lib/components/AppHeader.svelte';
	import { initAppState } from '$lib/state';
	import type { ConfigFile, Summary } from '$lib/types';
	import type { PageData } from './$types';
	import type { SubmitFunction } from '@sveltejs/kit';
	import { untrack } from 'svelte';

	const { data }: { data: PageData } = $props();
	initAppState();

	/** States */
	let summary = $state<Summary>(untrack(() => data.summary));
	let files = $state<ConfigFile[]>(untrack(() => data.files));
	const versions = $derived(data.versions);

	// File editor state
	let selectedId = $state('');

	// UI state
	let search = $state('');
	let showNewModal = $state(false);
	let modalFileName = $state('');
	let modalServiceName = $state('');
	let newServiceError = $state('');
	let showDeleteModal = $state(false);
	let deleteTarget = $state<ConfigFile | null>(null);

	/** Derived */
	const services = $derived(files.filter((f) => f.category === 'service'));
	const selectedEntry = $derived(files.find((f) => f.id === selectedId) ?? null);
	// const configDir = $derived((envValues.CONFIG_DIR || 'conf.d').replace(/\/+$/, ''));

	/** API */
	async function refresh() {
		const [filesRes, summaryRes] = await Promise.all([
			await fetch('/api/files'),
			await fetch('/api/summary')
		]);

		if (filesRes.ok) {
			const payload = await filesRes.json();
			files = payload.files ?? files;
		} else {
			toast.error('Refresh failed', 'Unable to fetch files');
		}

		if (summaryRes.ok) {
			const payload = await summaryRes.json();
			summary = payload.summary ?? summary;
		} else {
			toast.error('Refresh failed', 'Unable to fetch summary');
		}
	}

	const handleEnvSubmit: SubmitFunction = async ({ cancel, formData }) => {
		cancel();

		await fetch('/api/env', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(Object.fromEntries(formData.entries()))
		})
			.then(async (res) => {
				if (res.ok) {
					await refresh();
					toast.success('Saved environment', 'Updated .env values');
				}
			})
			.catch((err) => {
				const message = err instanceof Error ? err.message : 'Failed to save .env';
				toast.error('Failed to save .env', message);
			});
	};

	// Utility functions
	const slugify = (name: string): string =>
		name
			.toLowerCase()
			.replace(/[^a-z0-9-]+/g, '-')
			.replace(/-{2,}/g, '-')
			.replace(/^-+|-+$/g, '');

	const serviceTemplate = (service: string, domain: string): string => {
		const svc = service || 'service';
		const dom = domain || 'example.com';

		return `http:
  routers:
    ${svc}:
      rule: "Host(\`${svc}.${dom}\`)"
      service: "${svc}-svc"
      middlewares:
        - default-headers

  services:
    ${svc}-svc:
      loadBalancer:
        servers:
          - url: "http://${svc}:80"
        passHostHeader: true

  middlewares:
    default-headers:
      headers:
        sslRedirect: true
        frameDeny: true
        browserXssFilter: true
`;
	};

	// Service management
	function createService(name: string, fileName?: string) {
		const slug = slugify(name.replace(/\.(yml|yaml)$/i, ''));
		if (!slug) {
			newServiceError = 'Invalid service name';
			return;
		}

		const finalFile = fileName?.match(/\.(yml|yaml)$/i) ? fileName : `${slug}.yml`;
		const id = `service/${finalFile}`;

		if (files.find((f) => f.id === id)) {
			newServiceError = 'Service already exists';
			return;
		}

		const entry: ConfigFile = {
			id,
			label: finalFile,
			filePath: `${summary.path.services}/${finalFile}`,
			category: 'service',
			exists: false
		};

		files = [...files, entry];
		selectedId = id;
		// fileContent = serviceTemplate(slug, summary.baseDomain);
		newServiceError = '';
		toast.info('New service draft', `${finalFile} ready to edit`);
	}

	// Modal handlers
	function openNewModal() {
		showNewModal = true;
		modalFileName = '';
		modalServiceName = '';
		newServiceError = '';
	}

	function confirmCreateService() {
		const name = (modalServiceName || modalFileName).trim();
		console.log('Creating service:', name, modalFileName);
		if (!slugify(name)) {
			newServiceError = 'Provide a valid service name';
			return;
		}
		createService(name, modalFileName?.trim() || undefined);
		showNewModal = false;
	}

	function promptDelete(file: ConfigFile) {
		deleteTarget = file;
		showDeleteModal = true;
	}

	function cancelDelete() {
		showDeleteModal = false;
		deleteTarget = null;
	}

	async function confirmDeleteFile() {
		if (!deleteTarget) return;
		const targetLabel = deleteTarget.label;

		// Handle non-existent files (templates)
		if (!deleteTarget.exists) {
			files = files.filter((f) => f.id !== deleteTarget?.id);
			if (selectedId === deleteTarget?.id) {
				const next = files.find((f) => f.exists) ?? files[0];
				selectedId = next?.id ?? '';
				// if (next?.id) await loadFile(next.id);
				// else fileContent = '';
			}
			toast.info('Draft removed', targetLabel ? `${targetLabel} discarded` : 'Draft removed');
			cancelDelete();
			return;
		}

		try {
			const res = await fetch(`/api/files/${encodeURIComponent(deleteTarget.id)}`, {
				method: 'DELETE'
			});

			if (!res.ok) {
				throw new Error((await res.text()) || 'Unable to delete file');
			}

			files = files.filter((f) => f.id !== deleteTarget?.id);
			toast.success('Deleted file', targetLabel ? `${targetLabel} removed` : 'File removed');

			if (selectedId === deleteTarget.id) {
				const next = files.find((f) => f.exists) ?? files[0];
				selectedId = next?.id ?? '';
				// if (next?.id) await loadFile(next.id);
				// else fileContent = '';
			}
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Failed to delete file';
			toast.error('Delete failed', message);
		} finally {
			cancelDelete();
		}
	}
</script>

<main>
	<AppHeader />

	<div class="mx-auto max-w-full px-4 lg:px-6">
		<section class="py-6 lg:py-8 grid grid-cols-1 gap-5 lg:grid-cols-2">
			<div class="flex flex-col gap-4">
				<BinaryPanel {versions} version={summary.version} />
				<ServiceSidebar
					{services}
					{selectedId}
					{search}
					onSelect={(id) => (selectedId = id)}
					onCreate={openNewModal}
					onRefresh={refresh}
				/>
			</div>

			<div class="flex flex-col gap-4">
				<EnvironmentForm {summary} {handleEnvSubmit} />

				<EditorPanel {selectedEntry} onRefresh={refresh} onDelete={promptDelete} />
			</div>
		</section>
	</div>
</main>

<NewServiceModal
	open={showNewModal}
	serviceName={modalServiceName}
	fileName={modalFileName}
	errorMessage={newServiceError}
	onCancel={() => (showNewModal = false)}
	onConfirm={confirmCreateService}
/>

<DeleteConfirmModal
	open={showDeleteModal}
	target={deleteTarget}
	onCancel={cancelDelete}
	onConfirm={confirmDeleteFile}
/>
