module.exports = {
	extends: ['@commitlint/config-conventional'],
	rules: {
		'body-max-line-length': [2, 'always', 300],
		'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
		'subject-empty': [2, 'never'],
		'subject-full-stop': [2, 'never', '.'],
		'type-case': [2, 'always', 'lower-case'],
		'type-empty': [2, 'never'],
		'scope-case': [2, 'always', 'lower-case'],
		'header-max-length': [2, 'always', 72],
		'footer-leading-blank': [1, 'always'],
		'body-leading-blank': [1, 'always'],
		'type-enum': [
			2,
			'always',
			[
				'build', // Changes that affect the build system or external dependencies
				'chore', // Other changes that don't modify src or test files
				'ci', // Changes to our CI configuration files and scripts
				'docs', // Documentation only changes
				'feat', // A new feature
				'fix', // A bug fix
				'wip', // Work in progress
				'perf', // A code change that improves performance
				'refactor', // A code change that neither fixes a bug nor adds a feature
				'revert', // Reverts a previous commit
				'style', // Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
				'test', // Adding missing tests or correcting existing tests
				'init' // Initialize the project
			]
		]
	},
	prompt: {
		settings: {
			enableMultipleScopes: true,
			scopeEnumSeparator: ',',
			skipQuestions: ['breaking', 'footer'],
			upperCaseSubject: false
		},
		messages: {
			skip: ':skip',
			max: 'maximum %d characters',
			min: 'minimum %d characters',
			emptyWarning: 'cannot be empty',
			upperLimitWarning: 'over limit',
			lowerLimitWarning: 'below limit'
		},
		questions: {
			type: {
				description: "Select the type of change you're committing:",
				enum: {
					feat: {
						description: 'A new feature',
						title: 'Features',
						emoji: '✨'
					},
					fix: {
						description: 'A bug fix',
						title: 'Bug Fixes',
						emoji: '🐛'
					},
					wip: {
						description: 'Work in progress',
						title: 'WIP',
						emoji: '🚧'
					},
					docs: {
						description: 'Documentation only changes',
						title: 'Documentation',
						emoji: '📚'
					},
					style: {
						description:
							'Changes that do not affect the meaning of the code (formatting, semicolons, etc)',
						title: 'Styles',
						emoji: '💄'
					},
					refactor: {
						description: 'A code change that neither fixes a bug nor adds a feature',
						title: 'Code Refactoring',
						emoji: '📦'
					},
					perf: {
						description: 'A code change that improves performance',
						title: 'Performance',
						emoji: '🚀'
					},
					test: {
						description: 'Adding or correcting tests',
						title: 'Tests',
						emoji: '🚨'
					},
					build: {
						description: 'Changes that affect the build system or external dependencies',
						title: 'Builds',
						emoji: '🏗️'
					},
					ci: {
						description: 'Changes to CI/CD configuration',
						title: 'CI/CD',
						emoji: '⚙️'
					},
					chore: {
						description: "Changes that don't modify src or test files",
						title: 'Chores',
						emoji: '♻️'
					},
					revert: {
						description: 'Revert a previous commit',
						title: 'Reverts',
						emoji: '🗑'
					},
					init: {
						description: 'Initialize the project',
						title: 'Init',
						emoji: '🎉'
					}
				}
			},
			scope: {
				description: 'What is the scope of this change (component, file, etc)'
			},
			subject: {
				description: 'Write a short, imperative description of the change',
				minLength: 5,
				maxLength: 50
			},
			body: {
				description: 'Provide a longer description of the change'
			},
			isBreaking: {
				description: 'Are there any breaking changes?'
			},
			breaking: {
				description: 'Describe the breaking changes',
				minLength: 5
			},
			isIssueAffected: {
				description: 'Does this change affect any open issues?'
			},
			issues: {
				description: 'Add issue references (e.g. "fix #123", "re #123")',
				pattern: /^(fix|re|resolve|close)\s#\d+$/,
				patternError: 'Issue references must follow the pattern "fix #123", "re #123"'
			},
			confirmCommit: {
				description: 'Are you sure you want to proceed with the commit above?'
			}
		}
	}
};
