import { writable } from 'svelte/store';

export type ToastIntent = 'info' | 'success' | 'warning' | 'error';

export type ToastAction = {
	label: string;
	callback?: () => void | Promise<void>;
	dismiss?: boolean;
};

export type ToastOptions = {
	id?: string;
	title: string;
	description?: string;
	intent?: ToastIntent;
	duration?: number;
	dismissible?: boolean;
	action?: ToastAction;
};

export type ToastMessage = Required<Pick<ToastOptions, 'id' | 'title'>> & {
	intent: ToastIntent;
	description?: string;
	duration: number;
	dismissible: boolean;
	action?: ToastAction;
};

const DEFAULT_DURATION = 4200;

const timers = new Map<string, ReturnType<typeof setTimeout>>();
const store = writable<ToastMessage[]>([]);

const resolveId = (provided?: string): string => {
	if (provided) return provided;
	if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) return crypto.randomUUID();
	return `toast-${Date.now().toString(36)}-${Math.random().toString(16).slice(2)}`;
};

const cleanupTimer = (id: string) => {
	const timer = timers.get(id);
	if (timer) {
		clearTimeout(timer);
		timers.delete(id);
	}
};

const scheduleDismiss = (toast: ToastMessage) => {
	cleanupTimer(toast.id);
	if (!Number.isFinite(toast.duration) || toast.duration <= 0) return;

	const timer = setTimeout(() => dismiss(toast.id), toast.duration);
	timers.set(toast.id, timer);
};

const show = (options: ToastOptions) => {
	const toast: ToastMessage = {
		id: resolveId(options.id),
		title: options.title || 'Notification',
		description: options.description,
		intent: options.intent ?? 'info',
		duration: options.duration ?? DEFAULT_DURATION,
		dismissible: options.dismissible ?? true,
		action: options.action
	};

	store.update((list) => [...list.filter((item) => item.id !== toast.id), toast]);
	scheduleDismiss(toast);

	return toast.id;
};

const dismiss = (id: string) => {
	cleanupTimer(id);
	store.update((list) => list.filter((toast) => toast.id !== id));
};

const clear = () => {
	timers.forEach((timer) => clearTimeout(timer));
	timers.clear();
	store.set([]);
};

const variant =
	(intent: ToastIntent) =>
	(
		title: string,
		description?: string,
		options?: Omit<ToastOptions, 'title' | 'description' | 'intent'>
	) =>
		show({ ...options, title, description, intent });

export const toast = {
	subscribe: store.subscribe,
	show,
	dismiss,
	clear,
	success: variant('success'),
	info: variant('info'),
	warning: variant('warning'),
	error: variant('error')
};
