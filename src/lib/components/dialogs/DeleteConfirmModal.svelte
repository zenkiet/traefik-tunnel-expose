<script lang="ts">
	import type { ConfigFile } from '$lib/types';
	import Button from '../ui/button.svelte';

	let { open, target, onCancel, onConfirm } = $props<{
		open: boolean;
		target: ConfigFile | null;
		onCancel: () => void;
		onConfirm: () => void;
	}>();
</script>

{#if open && target}
	<div class="modal-backdrop">
		<button type="button" aria-label="Close modal" class="absolute inset-0" onclick={onCancel}
		></button>

		<div class="modal">
			<div class="flex items-center justify-between gap-2">
				<div>
					<p class="section-label">Delete</p>
					<h3 class="section-title">Remove this file?</h3>
				</div>

				<Button size="icon" type="button" onclick={onCancel}>
					<i class="icon-[duotone--xmark] size-4"></i>
				</Button>
			</div>
			<div class="mt-3 space-y-2 text-sm">
				<p class="text-muted">This will permanently remove the file from disk.</p>
				<div class="flex justify-end gap-2 pt-3">
					<Button variant="outline" type="button" onclick={onCancel}>Cancel</Button>
					<Button variant="destructive" type="button" onclick={onConfirm}>Delete</Button>
				</div>
			</div>
		</div>
	</div>
{/if}
