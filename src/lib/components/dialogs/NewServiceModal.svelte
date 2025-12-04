<script lang="ts">
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
			class="absolute inset-0 bg-slate-900/70 backdrop-blur-sm transition-opacity"
			onclick={onCancel}
		></button>
		<div
			class="glass relative w-full max-w-md rounded-2xl border border-white/15 bg-slate-950/70 p-5 shadow-[0_22px_60px_rgba(15,23,42,0.95)] backdrop-blur-2xl"
		>
			<div class="flex items-center justify-between gap-2">
				<div>
					<p class="text-xs font-medium uppercase tracking-[0.22em] text-slate-400">New service</p>
					<h3 class="text-base font-semibold text-slate-50 md:text-lg">Create conf.d entry</h3>
				</div>
				<button class="soft-button" type="button" onclick={onCancel}> ✕ </button>
			</div>

			<div class="mt-4 space-y-3 flex flex-col">
				<label class="space-y-1 flex flex-col text-sm text-slate-200">
					<span class="text-xs font-medium tracking-wide text-slate-300">Service name</span>
					<input
						class="form-input w-full rounded-xl border border-slate-700/70 bg-slate-900/60 px-3 py-2 text-sm text-slate-100 outline-none ring-0 transition-all duration-200 placeholder:text-slate-500 focus:border-emerald-400/70 focus:bg-slate-900 focus:ring-2 focus:ring-emerald-500/40"
						placeholder="myservice"
						bind:value={serviceName}
					/>
				</label>
				<label class="space-y-1 flex flex-col text-sm text-slate-200">
					<span class="text-xs font-medium tracking-wide text-slate-300">Filename (.yml)</span>
					<input
						class="form-input w-full rounded-xl border border-slate-700/70 bg-slate-900/60 px-3 py-2 text-sm text-slate-100 outline-none ring-0 transition-all duration-200 placeholder:text-slate-500 focus:border-emerald-400/70 focus:bg-slate-900 focus:ring-2 focus:ring-emerald-500/40"
						placeholder="myservice.yml"
						bind:value={fileName}
					/>
				</label>
				{#if errorMessage}
					<p class="text-xs text-red-300">{errorMessage}</p>
				{/if}
				<div class="flex justify-end gap-2 pt-2">
					<button class="soft-button" type="button" onclick={onCancel}> Cancel </button>
					<button class="soft-button" type="button" onclick={onConfirm}> Create </button>
				</div>
			</div>
		</div>
	</div>
{/if}
