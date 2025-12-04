<script lang="ts">
	import { EditorState } from '@codemirror/state';
	import { EditorView } from '@codemirror/view';
	import { basicSetup } from 'codemirror';
	import { yaml } from '@codemirror/lang-yaml';
	import { oneDark } from '@codemirror/theme-one-dark';
	import { formatRelativeDate } from '$lib/utils/dateformat';
	import { getFileType } from '$lib/utils/file-type';
	import type { ConfigFile } from '$lib/types';

	let {
		selectedEntry,
		fileContent,
		fileSaving,
		fileLoading,
		isValidYaml,
		validationMessage,
		fileError,
		fileMessage,
		onSave,
		onDelete,
		onContentChange
	} = $props<{
		selectedEntry: ConfigFile | null;
		fileContent: string;
		fileSaving: boolean;
		fileLoading: boolean;
		isValidYaml: boolean;
		validationMessage: string;
		fileError: string;
		fileMessage: string;
		onSave: (event?: Event) => void | Promise<void>;
		onDelete: (file: ConfigFile) => void;
		onContentChange: (value: string) => void;
	}>();

	let editorEl = $state<HTMLDivElement | null>(null);
	let editor: EditorView | null = null;
	let patchingEditor = false;
	let previousFileId = $state<string | null>(null);

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

	const isSaveDisabled = $derived(fileSaving || fileLoading || !selectedEntry || !isValidYaml);

	$effect(() => {
		if (editorEl && !editor) {
			editor = new EditorView({
				state: EditorState.create({
					doc: fileContent,
					extensions: editorExtensions
				}),
				parent: editorEl
			});
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

				queueMicrotask(() => patchingEditor = false);
			}
		}
	});
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
          {/if}
        </p>
      {/if}
    </div>

    <div class="flex flex-wrap items-center gap-2">
      {#if fileError}
        <span class="pill bg-red-500/15 text-xs font-medium text-red-200 ring-1 ring-red-400/40">
          {fileError}
        </span>
      {/if}
      {#if fileMessage}
        <span class="pill animate-fade-in bg-emerald-500/15 text-xs font-medium text-emerald-200 ring-1 ring-emerald-400/40">
          {fileMessage}
        </span>
      {/if}

      {#if selectedEntry?.exists}
        <button
          class="soft-button bg-red-500/20! border-red-400/30! hover:bg-red-500/30! text-red-200!"
          type="button"
          onclick={() => selectedEntry && onDelete(selectedEntry)}
        >
          Delete
        </button>
      {/if}

      <button
        class="soft-button"
        onclick={onSave}
        disabled={isSaveDisabled}
      >
        <span>Save</span>
      </button>
    </div>
  </div>

  <div class="mt-3 grid gap-3 md:grid-cols-[minmax(0,2.1fr)_minmax(0,1fr)]">
    <div class="relative rounded-xl border border-slate-800/80 bg-linear-to-b from-slate-950/90 to-slate-950/60 p-2">
      <div class="h-[480px] overflow-hidden rounded-lg border border-slate-800/80 bg-black/95">
        <div class="h-full w-full overflow-y-auto" bind:this={editorEl}></div>
      </div>
    </div>

    <div class="space-y-2 flex flex-col rounded-xl border border-slate-800/80 bg-slate-950/80 p-3 text-sm">
      <p class="text-xs font-semibold uppercase tracking-[0.2em] text-slate-400">File info</p>
      <p class="text-xs text-slate-300">
        <span class="text-slate-500">Path:</span>
        <span class="font-mono text-xs text-slate-200">
          {selectedEntry?.relativePath ?? '—'}
        </span>
      </p>
      <p class="text-xs text-slate-300">
        <span class="text-slate-500">Kind:</span>
        <span class="ml-1 font-semibold text-slate-100">
          {getFileType(selectedEntry?.filePath) ?? '—'}
        </span>
      </p>
      <p class="text-xs text-slate-300">
        <span class="text-slate-500">Hosts:</span>
        <span class="ml-1">
          {selectedEntry?.hosts?.join(', ') ?? '—'}
        </span>
      </p>
      <p class="text-xs text-slate-300">
        <span class="text-slate-500">Updated:</span>
        {#if selectedEntry?.updatedAt}
          <span class="ml-1" title={new Date(selectedEntry.updatedAt).toLocaleString()}>
            {formatRelativeDate(selectedEntry.updatedAt)}
          </span>
        {:else}
          <span class="ml-1">—</span>
        {/if}
      </p>
      <p class={`text-xs ${isValidYaml ? 'text-emerald-300' : 'text-red-300'}`}>
        {validationMessage}
      </p>
    </div>
  </div>
</div>
