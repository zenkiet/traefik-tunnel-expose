<script lang="ts">
	import Button from '../ui/button.svelte';

	let { open, serviceName, fileName, errorMessage, onCancel, onConfirm } = $props<{
		open: boolean;
		serviceName: string;
		fileName: string;
		errorMessage: string;
		onCancel: () => void;
		onConfirm: () => void;
	}>();
</script>

{#if open}
	<div class="modal-backdrop">
		<button type="button" aria-label="Close modal" class="absolute inset-0" onclick={onCancel}
		></button>

		<div class="modal">
			<div class="flex items-center justify-between gap-2">
				<div>
					<p class="section-label">New service</p>
					<h3 class="section-title">Create conf.d entry</h3>
				</div>

				<Button size="icon" type="button" onclick={onCancel}>
					<i class="icon-[duotone--xmark] size-4"></i>
				</Button>
			</div>

			<div class="mt-4 flex flex-col space-y-3">
				<label class="flex flex-col space-y-1 text-sm">
					<span class="text-xs font-medium tracking-wide text-muted">Service name</span>
					<input class="input" placeholder="myservice" bind:value={serviceName} />
				</label>
				<label class="flex flex-col space-y-1 text-sm">
					<span class="text-xs font-medium tracking-wide text-muted">Filename (.yml)</span>
					<input class="input" placeholder="myservice.yml" bind:value={fileName} />
				</label>
				{#if errorMessage}
					<p class="text-xs text-[var(--destructive)]">{errorMessage}</p>
				{/if}
				<div class="flex justify-end gap-2 pt-2">
					<Button variant="outline" type="button" onclick={onCancel}>Cancel</Button>
					<Button type="button" onclick={onConfirm}>Create</Button>
				</div>
			</div>
		</div>
	</div>
{/if}
