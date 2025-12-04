<script lang="ts">
	import type { ConfigFile } from '$lib/types';

	let { open, target, onCancel, onConfirm } = $props<{
		open: boolean;
		target: ConfigFile | null;
		onCancel: () => void;
		onConfirm: () => void;
	}>();
</script>

{#if open && target}
	<div class="fixed inset-0 z-50 flex items-center justify-center px-4 animate-fade-in">
		<button
			type="button"
			aria-label="Close modal"
			class="absolute inset-0 bg-slate-900/70 backdrop-blur-sm transition-opacity"
			onclick={onCancel}
		></button>
		<div
			class="glass relative w-full max-w-md rounded-2xl border border-white/15 bg-slate-950/70 p-5 shadow-[0_22px_60px_rgba(15,23,42,0.95)] backdrop-blur-2xl"
		>
			<div class="flex items-center justify-between gap-2">
				<div>
					<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">Delete</p>
					<h3 class="text-base font-semibold text-slate-50 md:text-lg">Remove this file?</h3>
				</div>
				<button class="soft-button" type="button" onclick={onCancel}> ✕ </button>
			</div>
			<div class="mt-3 space-y-2 text-sm text-slate-200">
				<p>File: <span class="font-mono text-xs">{target.relativePath}</span></p>
				<p class="text-slate-400">This will permanently remove the file from disk.</p>
				<div class="flex justify-end gap-2 pt-3">
					<button class="soft-button" type="button" onclick={onCancel}>Cancel</button>
					<button class="soft-button bg-red-600 text-white" type="button" onclick={onConfirm}>
						Delete
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
