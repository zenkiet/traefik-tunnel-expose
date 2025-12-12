<script lang="ts">
	import { cubicOut } from 'svelte/easing';
	import { fly } from 'svelte/transition';
	import { flip } from 'svelte/animate';
	import { type ToastIntent, toast, type ToastMessage } from '$lib/services/toast';

	const theme: Record<
		ToastIntent,
		{ gradient: string; ring: string; iconBg: string; accent: string; progress: string }
	> = {
		success: {
			gradient: 'from-emerald-500/12 via-slate-950/50 to-slate-950',
			ring: 'ring-emerald-400/30',
			iconBg: 'bg-emerald-500/15 text-emerald-100',
			accent: 'from-emerald-400/90 via-emerald-300/70 to-emerald-500/60',
			progress: 'bg-gradient-to-r from-emerald-400/90 via-emerald-300/70 to-emerald-400/60'
		},
		info: {
			gradient: 'from-sky-500/12 via-slate-950/50 to-slate-950',
			ring: 'ring-sky-400/30',
			iconBg: 'bg-sky-500/15 text-sky-100',
			accent: 'from-sky-400/90 via-sky-300/70 to-sky-500/60',
			progress: 'bg-gradient-to-r from-sky-400/90 via-sky-300/70 to-sky-400/60'
		},
		warning: {
			gradient: 'from-amber-400/12 via-slate-950/50 to-slate-950',
			ring: 'ring-amber-300/35',
			iconBg: 'bg-amber-500/15 text-amber-100',
			accent: 'from-amber-400/90 via-amber-300/70 to-amber-500/60',
			progress: 'bg-gradient-to-r from-amber-400/90 via-amber-300/70 to-amber-400/60'
		},
		error: {
			gradient: 'from-rose-500/15 via-slate-950/50 to-slate-950',
			ring: 'ring-rose-400/35',
			iconBg: 'bg-rose-500/15 text-rose-100',
			accent: 'from-rose-400/90 via-rose-300/70 to-rose-500/60',
			progress: 'bg-gradient-to-r from-rose-400/90 via-rose-300/70 to-rose-400/60'
		}
	};

	const icons: Record<ToastIntent, string> = {
		success: 'M5 13l4 4L19 7',
		info: 'M12 7h.01M12 11v6',
		warning: 'M12 8v4m0 4h.01',
		error: 'M6 6l12 12M6 18L18 6'
	};

	const handleDismiss = (id: string) => toast.dismiss(id);

	const handleAction = async (item: ToastMessage) => {
		try {
			await item.action?.callback?.();
		} catch (err) {
			console.error('Toast action failed', err);
		}
		if (item.action?.dismiss !== false) {
			toast.dismiss(item.id);
		}
	};
</script>

<div class="pointer-events-none fixed inset-0 z-50 flex flex-col items-end gap-3 px-4 py-6 sm:px-6">
	{#each $toast as item (item.id)}
		<div
			animate:flip={{ duration: 300 }}
			in:fly={{ x: 32, duration: 200, easing: cubicOut }}
			out:fly={{ x: 28, duration: 180, easing: cubicOut }}
			class="w-full max-w-[420px]"
		>
			<article
				class={`group pointer-events-auto isolate relative w-full overflow-hidden rounded-2xl border border-white/10 bg-slate-950/90 shadow-[0_20px_60px_-25px_rgba(0,0,0,0.65)] backdrop-blur-xl ring-1 ring-white/10 ${theme[item.intent].ring}`}
				role={item.intent === 'error' ? 'alert' : 'status'}
				aria-live={item.intent === 'error' ? 'assertive' : 'polite'}
			>
				<div
					class={`absolute inset-0 opacity-80 bg-linear-to-br ${theme[item.intent].gradient}`}
				></div>

				<div
					class={`absolute inset-y-0 left-0 w-1.5 bg-linear-to-b ${theme[item.intent].accent}`}
				></div>

				<div class="relative flex gap-3 p-4">
					<div
						class={`mt-0.5 flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border border-white/10 shadow-inner ${theme[item.intent].iconBg}`}
					>
						<svg
							class="h-5 w-5"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							stroke-width="2"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d={icons[item.intent]} />
						</svg>
					</div>

					<div class="min-w-0 flex-1 space-y-2">
						<div class="flex items-start gap-3">
							<div class="min-w-0 flex-1">
								<p class="text-sm font-semibold text-slate-50">{item.title}</p>
								{#if item.description}
									<p class="mt-0.5 text-sm text-slate-300">{item.description}</p>
								{/if}
							</div>

							{#if item.dismissible}
								<button
									class="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-white/5 bg-white/5 text-slate-300 transition hover:border-white/15 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40"
									aria-label="Dismiss notification"
									onclick={() => handleDismiss(item.id)}
								>
									<svg
										class="h-3.5 w-3.5"
										viewBox="0 0 20 20"
										fill="none"
										stroke="currentColor"
										stroke-width="2"
									>
										<path stroke-linecap="round" stroke-linejoin="round" d="M5 5l10 10M15 5L5 15" />
									</svg>
								</button>
							{/if}
						</div>

						{#if item.action}
							<button
								class="inline-flex items-center gap-2 rounded-lg border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-semibold text-slate-100 transition hover:border-white/20 hover:bg-white/10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40"
								onclick={() => handleAction(item)}
							>
								<span>{item.action.label}</span>
								<svg
									class="h-3 w-3"
									viewBox="0 0 20 20"
									fill="none"
									stroke="currentColor"
									stroke-width="2"
								>
									<path stroke-linecap="round" stroke-linejoin="round" d="M7 5l6 5-6 5" />
								</svg>
							</button>
						{/if}
					</div>
				</div>

				{#if Number.isFinite(item.duration) && item.duration > 0}
					<div class="relative mx-4 mb-4 h-1.5 overflow-hidden rounded-full bg-white/5">
						<span
							class={`progress-bar block h-full w-full ${theme[item.intent].progress}`}
							style={`animation-duration: ${item.duration}ms;`}
						></span>
					</div>
				{/if}
			</article>
		</div>
	{/each}
</div>

<style>
	.progress-bar {
		transform-origin: left;
		animation: toast-progress linear forwards;
	}

	:global(.group:hover .progress-bar) {
		animation-play-state: paused;
	}

	@keyframes toast-progress {
		from {
			transform: scaleX(1);
		}
		to {
			transform: scaleX(0);
		}
	}
</style>
