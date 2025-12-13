import { browser } from '$app/environment';
import { storageState } from '$lib/runes/storage.svelte';
import { STORAGE_KEYS } from '$lib/types/storage';

export enum THEME {
	LIGHT = 'light',
	DARK = 'dark'
}

export class AppState {
	#themeStorage = storageState<THEME>(STORAGE_KEYS.THEME, THEME.DARK);
	theme = $state<THEME>(this.#themeStorage.value);

	constructor() {
		if (!browser) return;

		this._applyTheme(this.theme);

		$effect(() => {
			if (this.#themeStorage.value !== this.theme) {
				this.#themeStorage.value = this.theme;
			}
			this._applyTheme(this.theme);
		});

		$effect(() => {
			const stored = this.#themeStorage.value;
			if (stored !== this.theme) {
				this.theme = stored;
			}
		});
	}

	toggleTheme() {
		this.theme = this.theme === THEME.DARK ? THEME.LIGHT : THEME.DARK;
	}

	private _applyTheme(theme: THEME) {
		const root = document.documentElement;
		root.dataset.theme = theme;
		root.style.colorScheme = theme;
	}
}
