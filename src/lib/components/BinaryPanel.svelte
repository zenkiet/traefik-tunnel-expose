<script lang="ts">
	import { getGithubApiUrl } from '$lib/utils/api';
	import type { VersionInfo } from '$lib/types';
	import { BINARY, BINARY_CONFIG } from '$lib/types/binary';
	import UpgradeIcon from './icons/UpgradeIcon.svelte';
	import { toast } from '$lib/services/toast';

	const input = $props<{ versions: VersionInfo; version: string }>();
	let data = $state(input.versions) as VersionInfo;

	const binaries: BINARY[] = Object.values(BINARY);

	let updating = $state({
		[BINARY.TRAEFIK]: false,
		[BINARY.CLOUDFLARED]: false
	});

	async function update(binary: BINARY, version: string) {
		if (!version || updating[binary]) return;

		updating = { ...updating, [binary]: true };

		await fetch(`/api/binaries/${binary}/${version}`, {
			method: 'POST'
		})
			.then((res) => {
				if (res.ok) {
					data = {
						...data,
						[binary]: {
							...data[binary],
							version,
							needUpdate: false
						}
					};
					toast.success(`Updated ${binary}`, `Successfully updated to version ${version}`);
				}
			})
			.catch((error) => toast.error(`Update ${binary} failed:`, error.message))
			.finally(() => (updating = { ...updating, [binary]: false }));
	}
</script>

<div class="glass rounded-2xl p-6">
	<div class="flex flex-wrap items-center justify-between gap-3">
		<span class="text-xs font-semibold uppercase tracking-[0.18em] text-emerald-200/80">
			Status
		</span>
		<div
			class="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-500/10 px-3 py-1.5 text-emerald-100"
		>
			<span class="inline-flex h-2 w-2 animate-pulse rounded-full bg-emerald-300"></span>
			<span class="text-xs font-medium">Live: {input.version}</span>
		</div>
	</div>

	<div class="mt-5 grid gap-4 md:grid-cols-2">
		{#each binaries as binary (binary)}
			{#if data[binary]}
				<article
					class="group relative overflow-hidden rounded-xl border border-slate-800 bg-slate-900/80 p-4 shadow-sm transition duration-200 hover:border-emerald-400/40"
				>
					<div
						class="absolute inset-y-0 left-0 w-1.5 bg-linear-to-b from-emerald-400/60 via-emerald-400/30 to-transparent"
					></div>

					<div class="flex items-start justify-between gap-4">
						<div class="flex items-center gap-3">
							<div
								class="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-950 text-sm font-semibold uppercase text-emerald-100 ring-1 ring-white/10"
							>
								<!-- {binary.slice(0, 2)} -->
								<img src={BINARY_CONFIG[binary].icon} alt={binary} class="h-6 w-6" />
							</div>
							<div class="space-y-0.5">
								<p class="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500">
									{BINARY_CONFIG[binary].name}
								</p>
								<p class="text-sm text-slate-300">
									Latest:
									<a
										href={getGithubApiUrl(BINARY_CONFIG[binary].githubRepo)}
										rel="external noopener noreferrer"
										target="_blank"
										class="text-emerald-200 underline-offset-2 hover:text-emerald-50 hover:underline"
									>
										{data[binary]?.latest ?? '-'}
									</a>
								</p>
							</div>
						</div>

						<button
							class={`relative inline-flex h-11 w-11 items-center justify-center rounded-full border border-white/10 bg-slate-950/80 text-emerald-100 transition duration-300 hover:border-emerald-300/70 hover:text-emerald-50 active:scale-95 disabled:cursor-not-allowed disabled:opacity-40 ${data[binary].needUpdate ? 'cursor-pointer' : 'hidden!'}`}
							type="button"
							title={data[binary].needUpdate
								? 'Update to latest version'
								: 'Already on latest version'}
							disabled={!data[binary].needUpdate || updating[binary]}
							onclick={async () => await update(binary, data[binary].latest)}
						>
							<UpgradeIcon isLoading={updating[binary]} />
						</button>
					</div>

					<div class="flex flex-wrap justify-between mt-3">
						<div class="flex flex-wrap items-center justify-between gap-3 text-sm text-slate-200">
							<div class="space-y-1">
								<p class="text-[11px] uppercase tracking-[0.16em] text-slate-500">Installed</p>
								<p class="font-semibold">{data[binary].version ?? 'Not installed'}</p>
							</div>
						</div>

						<div class="flex flex-wrap items-center justify-end w-100 gap-3 text-sm text-slate-200">
							<div class="space-y-1">
								<p class="text-[11px] uppercase tracking-[0.16em] text-slate-500 text-end">Path</p>
								<span
									class="rounded-md bg-slate-950/70 px-3 py-1 font-mono text-[11px] text-slate-400 ring-1 ring-white/5 line-clamp-1"
								>
									{BINARY_CONFIG[binary].path}
								</span>
							</div>
						</div>
					</div>
				</article>
			{/if}
		{/each}
	</div>
</div>
