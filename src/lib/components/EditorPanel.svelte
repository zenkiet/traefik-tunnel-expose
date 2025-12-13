<script lang="ts">
	import { formatRelativeDate } from '$lib/utils/dateformat';
	import YAML from 'yaml';
	import { toast } from '$lib/services/toast';
	import type { ConfigFile } from '$lib/types';
	import type { EditorView } from '@codemirror/view';
	import Button from './ui/button.svelte';

	// Props
	let { selectedEntry, onDelete, onRefresh } = $props<{
		selectedEntry: ConfigFile | null;
		onRefresh?: () => void;
		onDelete: (file: ConfigFile) => void;
	}>();

	// State
	let editorInstance: EditorView | null = null;
	let isValidYaml = $state(true);
	let yamlError = $state<string | null>(null);

	// Derived
	const isSaveDisabled = $derived(!selectedEntry || !isValidYaml);

	function codemirror(node: HTMLElement) {
		let view: EditorView;

		(async () => {
			const [{ basicSetup }, { EditorView }, { yaml }, { oneDark }] = await Promise.all([
				import('codemirror'),
				import('@codemirror/view'),
				import('@codemirror/lang-yaml'),
				import('@codemirror/theme-one-dark')
			]);

			view = new EditorView({
				parent: node,
				extensions: [
					basicSetup,
					yaml(),
					oneDark,
					EditorView.lineWrapping,
					EditorView.updateListener.of((update) => {
						if (update.docChanged) validateYaml(update.state.doc.toString());
					})
				]
			});
			editorInstance = view;
		})();

		return {
			destroy() {
				view?.destroy();
				editorInstance = null;
			}
		};
	}

	$effect(() => {
		const id = selectedEntry?.id;
		if (!id || !editorInstance) {
			if (editorInstance) setEditorContent('');
			return;
		}

		const controller = new AbortController();
		fetch(`/api/files/${encodeURIComponent(id)}`, { signal: controller.signal })
			.then((res) => (res.ok ? res.json() : Promise.reject('Load failed')))
			.then((data) => setEditorContent(data.content || ''))
			.catch((err) => {
				if (err !== 'Load failed' && err.name !== 'AbortError') console.error(err);
			});

		return () => controller.abort();
	});

	function setEditorContent(text: string) {
		if (!editorInstance) return;
		const doc = editorInstance.state.doc.toString();
		if (doc !== text) {
			editorInstance.dispatch({ changes: { from: 0, to: doc.length, insert: text } });
			validateYaml(text);
		}
	}

	let debounceTimer: ReturnType<typeof setTimeout>;
	function validateYaml(content: string) {
		clearTimeout(debounceTimer);
		debounceTimer = setTimeout(() => {
			try {
				YAML.parse(content || '{}');
				isValidYaml = true;
				yamlError = null;
			} catch (err: unknown) {
				isValidYaml = false;
				yamlError = err?.message ?? 'Invalid YAML';
			}
		}, 300);
	}

	async function onSave() {
		if (!selectedEntry?.id || !editorInstance) return;
		const content = editorInstance.state.doc.toString();

		try {
			const res = await fetch(`/api/files/${encodeURIComponent(selectedEntry.id)}`, {
				method: 'PUT',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ content })
			});

			if (!res.ok) throw new Error(await res.text());

			toast.success('Saved', `${selectedEntry.label || 'File'} updated`);
			onRefresh?.();
		} catch (e: unknown) {
			toast.error('Save failed', e.message);
		}
	}
</script>

<div class="glass rounded-2xl p-4">
	<div class="flex flex-wrap items-center justify-between gap-3 mb-3">
		<div class="min-w-0">
			<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">Editor</p>
			<h3 class="truncate text-base font-semibold text-slate-50 md:text-lg">
				{selectedEntry?.label ?? 'Choose a file to start'}
			</h3>

			{#if selectedEntry}
				<p class="mt-0.5 flex flex-wrap items-center gap-1 text-xs text-slate-400">
					<span class="font-mono text-slate-300">{selectedEntry.relativePath}</span>
					{#if selectedEntry.updatedAt}
						<span class="text-slate-600">•</span>
						<span>updated {formatRelativeDate(selectedEntry.updatedAt)}</span>
					{/if}
					<span class="text-slate-600">•</span>
					<span class={isValidYaml ? 'text-emerald-300' : 'text-red-300'}>
						{isValidYaml ? '✔ YAML Valid' : '✖ YAML Invalid'}
					</span>
					{#if yamlError}<span class="text-slate-500 truncate max-w-105">({yamlError})</span>{/if}
				</p>
			{/if}
		</div>

		<div class="flex items-center gap-2">
			{#if selectedEntry?.exists}
				<Button variant="destructive" onclick={() => selectedEntry && onDelete(selectedEntry)}>
					Delete
				</Button>
			{/if}

			<Button disabled={isSaveDisabled} onclick={onSave}>Save</Button>
		</div>
	</div>

	<div
		class="relative rounded-xl border border-slate-800/80 bg-linear-to-b from-slate-950/90 to-slate-950/60 p-2"
	>
		<div class="h-120 overflow-hidden rounded-lg border border-slate-800/80 bg-black/95 relative">
			<div class="h-full w-full overflow-y-auto text-sm" use:codemirror></div>

			{#if !selectedEntry}
				<div class="absolute inset-0 bg-black/35 backdrop-blur-[1px] grid place-items-center z-10">
					<div class="text-xs text-slate-200">Select a file to edit</div>
				</div>
			{/if}
		</div>
	</div>
</div>
