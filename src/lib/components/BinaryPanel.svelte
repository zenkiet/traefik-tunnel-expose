<script lang="ts">
	import { getGithubApiUrl } from '$lib/utils/api';
	import type { VersionInfo } from '$lib/types';
	import { BINARY, BINARY_CONFIG } from '$lib/types/binary';
	import UpgradeIcon from './icons/UpgradeIcon.svelte';
	import { toast } from '$lib/services/toast';

	const input = $props<{ versions: VersionInfo; version: string }>();
	let data = $state<VersionInfo>({
		traefik: {
			version: '',
			needUpdate: false,
			latest: ''
		},
		cloudflared: {
			version: '',
			needUpdate: false,
			latest: ''
		}
	});

	$effect(() => {
		console.log('input.versions', input.versions);
		data = { ...input.versions };
	});

	const binaries: BINARY[] = Object.values(BINARY);

	let updating = $state({
		[BINARY.TRAEFIK]: false,
		[BINARY.CLOUDFLARED]: false
	});

	async function update(binary: BINARY, version: string) {
		if (!version || updating[binary]) return;

		updating = { ...updating, [binary]: true };
		try {
			const res = await fetch(`/api/binaries/${binary}/${version}`, { method: 'POST' });

			if (res.ok) {
				data = { ...data, [binary]: { ...data[binary], version, needUpdate: false } };
				toast.success(`Updated ${binary}`, `Successfully updated to version ${version}`);
			} else {
				const message = (await res.text()) || res.statusText;
				toast.error(`Update ${binary} failed:`, message);
			}
		} catch (error: unknown) {
			toast.error(
				`Update ${binary} failed:`,
				error instanceof Error ? error.message : String(error)
			);
		} finally {
			updating = { ...updating, [binary]: false };
		}
	}
</script>

<div class="panel">
	<div class="grid gap-4 md:grid-cols-2">
		{#each binaries as binary (binary)}
			{#if data[binary]}
				<article class="binary-card group">
					<div class="accent-bar"></div>

					<div class="flex items-start justify-between gap-4">
						<div class="flex items-center gap-3">
							<div class="icon-box size-10 text-sm font-semibold uppercase text-[var(--emerald)]">
								{#if binary === BINARY.CLOUDFLARED}
									<i class="size-6 icon-[brand--cloudflare]"></i>
								{:else if binary === BINARY.TRAEFIK}
									<i class="size-6 icon-[brand--traefik]"></i>
								{/if}
							</div>
							<div class="space-y-0.5">
								<p class="text-[11px] font-semibold uppercase tracking-[0.16em] text-hint">
									{BINARY_CONFIG[binary].name}
								</p>
								<p class="text-sm text-muted">
									Latest:
									<a
										href={getGithubApiUrl(BINARY_CONFIG[binary].githubRepo)}
										rel="external noopener noreferrer"
										target="_blank"
										class="link-accent"
									>
										{data[binary]?.latest ?? '-'}
									</a>
								</p>
							</div>
						</div>

						<button
							class="icon-box size-10 cursor-pointer text-[var(--emerald)] transition duration-300 hover:border-[var(--border-hover)] active:scale-95 disabled:cursor-not-allowed disabled:opacity-40
								{data[binary].needUpdate ? '' : 'hidden!'}"
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

					<div class="mt-3 flex flex-wrap justify-between">
						<div class="space-y-1">
							<p class="text-[11px] uppercase tracking-[0.16em] text-hint">Installed</p>
							<p class="text-sm font-semibold">
								{data[binary].version ?? 'Not installed'}
							</p>
						</div>

						<div class="space-y-1 text-end">
							<p class="text-[11px] uppercase tracking-[0.16em] text-hint">Path</p>
							<span class="code-inline">{BINARY_CONFIG[binary].path}</span>
						</div>
					</div>
				</article>
			{/if}
		{/each}
	</div>
</div>
