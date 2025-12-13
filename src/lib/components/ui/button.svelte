<script lang="ts">
	import { type VariantProps, tv, cn } from 'tailwind-variants';
	import type { HTMLButtonAttributes } from 'svelte/elements';

	const buttonVariants = tv({
		base: [
			'inline-flex items-center justify-center gap-2 whitespace-nowrap', // layout
			'select-none font-semibold text-sm', // typography
			'rounded-xl', // visuals
			'transition duration-150 cursor-pointer', // interactivity
			'disabled:pointer-events-none disabled:opacity-50 disabled:cursor-not-allowed focus-visible:outline-none' // states
		].join(' '),
		variants: {
			variant: {
				default: 'bg-glass border',
				destructive: 'bg-red-500/20 border-red-400/30 hover:bg-red-500/30 text-red-200',
				outline: 'border bg-transparent hover:bg-accent hover:text-accent-foreground',
				secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
				ghost: 'hover:bg-accent hover:text-accent-foreground',
				link: 'text-primary underline-offset-4 hover:underline'
			},
			size: {
				default: 'px-3 py-2',
				sm: 'rounded-md px-3',
				lg: 'rounded-md px-8',
				icon: 'h-9 w-9 p-0 rounded-xl'
			}
		},
		defaultVariants: {
			variant: 'default',
			size: 'default'
		}
	});

	type ButtonProps = HTMLButtonAttributes &
		VariantProps<typeof buttonVariants> & {
			ref?: HTMLButtonElement;
		};

	let {
		class: className,
		variant,
		size,
		children,
		ref = $bindable<HTMLButtonElement>(),
		...rest
	}: ButtonProps = $props();
</script>

<button bind:this={ref} class={cn(buttonVariants({ variant, size }), className)} {...rest}>
	{@render children?.()}
</button>
