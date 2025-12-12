<script lang="ts">
	import type { EditorView } from '@codemirror/view';
	import { formatRelativeDate } from '$lib/utils/dateformat';
	import type { ConfigFile } from '$lib/types';
	import YAML from 'yaml';

	let { selectedEntry, fileContent, onSave, onDelete, onContentChange } = $props<{
		selectedEntry: ConfigFile | null;
		fileContent: string;
		onSave: (event?: Event) => void | Promise<void>;
		onDelete: (file: ConfigFile) => void;
		onContentChange: (value: string) => void;
	}>();

	let editorEl = $state<HTMLDivElement | null>(null);
	let editor: EditorView | null = null;
	let patchingEditor = false;
	let previousFileId = $state<string | null>(null);

	const isValidYaml = $derived(() => validateYaml(fileContent));

	const isSaveDisabled = $derived(!selectedEntry || !isValidYaml);

	$effect(() => {
		if (editorEl && !editor) {
			initEditor();
		}
	});

	$effect(() => {
		return () => {
			if (editor) {
				editor.destroy();
				editor = null;
			}
		};
	});

	$effect(() => {
		const currentFileId = selectedEntry?.id ?? null;

		if (editor && currentFileId !== previousFileId) {
			previousFileId = currentFileId;

			if (!editor) return;

			const editorContent = editor.state.doc.toString();

			if (fileContent !== editorContent) {
				patchingEditor = true;
				editor.dispatch({
					changes: {
						from: 0,
						to: editor.state.doc.length,
						insert: fileContent
					}
				});
				queueMicrotask(() => (patchingEditor = false));
			}
		}
	});

	async function initEditor() {
		if (!editorEl || editor) return;

		try {
			const [{ EditorView }, { EditorState }, { basicSetup }, { yaml }, { oneDark }] =
				await Promise.all([
					import('@codemirror/view'),
					import('@codemirror/state'),
					import('codemirror'),
					import('@codemirror/lang-yaml'),
					import('@codemirror/theme-one-dark')
				]);

			const editorExtensions = [
				basicSetup,
				yaml(),
				oneDark,
				EditorView.lineWrapping,
				EditorView.updateListener.of((update) => {
					if (!patchingEditor && update.docChanged) {
						onContentChange(update.state.doc.toString());
					}
				})
			];

			editor = new EditorView({
				state: EditorState.create({
					doc: fileContent,
					extensions: editorExtensions
				}),
				parent: editorEl
			});
		} catch (error) {
			console.error('Failed to load editor:', error);
		}
	}

	function validateYaml(content: string) {
		try {
			YAML.parse(content || '{}');
			return true;
		} catch {
			return false;
		}
	}
</script>

<div class="glass rounded-2xl p-4">
	<div class="flex flex-wrap items-center justify-between gap-3">
		<div class="min-w-0">
			<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">Editor</p>
			<h3 class="truncate text-base font-semibold text-slate-50 md:text-lg">
				{selectedEntry?.label ?? 'Choose a file to start'}
			</h3>
			{#if selectedEntry}
				<p class="mt-0.5 flex flex-wrap items-center gap-1 text-xs text-slate-400">
					<span class="font-mono text-xs text-slate-300">{selectedEntry.relativePath}</span>
					{#if selectedEntry.updatedAt}
						<span class="text-slate-600">•</span>
						<span>updated {formatRelativeDate(selectedEntry.updatedAt)}</span>
						<span class="text-slate-600">•</span>
						<span class={`text-xs ${isValidYaml() ? 'text-emerald-300' : 'text-red-300'}`}>
							{#if isValidYaml()}
								✔ YAML is valid
							{:else}
								✖ YAML is invalid
							{/if}
						</span>
					{/if}
				</p>
			{/if}
		</div>

		<div class="flex flex-wrap items-center gap-2">
			{#if selectedEntry?.exists}
				<button
					class="soft-button bg-red-500/20! border-red-400/30! hover:bg-red-500/30! text-red-200!"
					type="button"
					onclick={() => selectedEntry && onDelete(selectedEntry)}
				>
					Delete
				</button>
			{/if}

			<button class="soft-button" onclick={onSave} disabled={isSaveDisabled}>
				<span>Save</span>
			</button>
		</div>
	</div>

	<div class="mt-3">
		<div
			class="relative rounded-xl border border-slate-800/80 bg-linear-to-b from-slate-950/90 to-slate-950/60 p-2"
		>
			<div class="h-120 overflow-hidden rounded-lg border border-slate-800/80 bg-black/95">
				<div class="h-full w-full overflow-y-auto" bind:this={editorEl}></div>
			</div>
		</div>
	</div>
</div>
