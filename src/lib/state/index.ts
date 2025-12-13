import { setContext, getContext } from 'svelte';
import { AppState } from './app.svelte.ts';

const APP_KEY = Symbol('APP_STATE');

export function initAppState() {
	return setContext(APP_KEY, new AppState());
}

export function useApp() {
	return getContext<AppState>(APP_KEY);
}
