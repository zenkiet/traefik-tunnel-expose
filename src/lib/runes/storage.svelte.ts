import { browser } from '$app/environment';

export class StorageState<T> {
	#value = $state() as T;
	key = '';

	constructor(key: string, initialValue: T) {
		this.key = key;

		if (browser) {
			const stored = localStorage.getItem(key);
			this.#value = stored ? JSON.parse(stored) : initialValue;
		} else {
			this.#value = initialValue;
		}

		if (browser) {
			$effect.root(() => {
				$effect(() => {
					localStorage.setItem(this.key, JSON.stringify(this.#value));
				});

				const handleStorage = (e: StorageEvent) => {
					if (e.key === this.key && e.newValue) {
						this.#value = JSON.parse(e.newValue);
					}
				};
				window.addEventListener('storage', handleStorage);

				return () => window.removeEventListener('storage', handleStorage);
			});
		}
	}

	get value() {
		return this.#value;
	}

	set value(v: T) {
		this.#value = v;
	}
}

export function storageState<T>(key: string, initialValue: T) {
	return new StorageState<T>(key, initialValue);
}
