<script lang="ts">
  import type { ConfigFile } from '$lib/types';

  let { services, selectedId, search, onSelect, onCreate } = $props<{
    services: ConfigFile[];
    selectedId: string;
    search: string;
    onSelect: (id: string) => void;
    onCreate: () => void;
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
</script>

<aside class="glass p-4 rounded-2xl relative flex flex-col gap-4">
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
		<button class="soft-button py-2.5" type="button" onclick={onCreate}>
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
</aside>
