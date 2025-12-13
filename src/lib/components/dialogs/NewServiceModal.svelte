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
	<div class="fixed inset-0 z-50 flex items-center justify-center px-4 animate-fade-in">
		<button
			type="button"
			aria-label="Close modal"
			class="absolute inset-0 backdrop-blur-sm transition-opacity"
			onclick={onCancel}
		></button>

		<div
			class="glass relative w-full max-w-md rounded-2xl border border-white/15 p-5 shadow-[0_22px_60px_rgba(15,23,42,0.95)] backdrop-blur-2xl"
		>
			<div class="flex items-center justify-between gap-2">
				<div>
					<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">New service</p>
					<h3 class="text-base font-semibold text-slate-50 md:text-lg">Create conf.d entry</h3>
				</div>

				<Button size="icon" type="button" onclick={onCancel}>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-4 w-4"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
						stroke-width="2"
					>
						<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
					</svg>
				</Button>
			</div>

			<div class="mt-4 space-y-3 flex flex-col">
				<label class="space-y-1 flex flex-col text-sm text-slate-200">
					<span class="text-xs font-medium tracking-wide text-slate-300">Service name</span>
					<input class="input" placeholder="myservice" bind:value={serviceName} />
				</label>
				<label class="space-y-1 flex flex-col text-sm text-slate-200">
					<span class="text-xs font-medium tracking-wide text-slate-300">Filename (.yml)</span>
					<input class="input" placeholder="myservice.yml" bind:value={fileName} />
				</label>
				{#if errorMessage}
					<p class="text-xs text-red-300">{errorMessage}</p>
				{/if}
				<div class="flex justify-end gap-2 pt-2">
					<Button variant="outline" type="button" onclick={onCancel}>Cancel</Button>
					<Button type="button" onclick={onConfirm}>Create</Button>
				</div>
			</div>
		</div>
	</div>
{/if}
