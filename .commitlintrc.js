module.exports = {
  extends: ['@commitlint/config-conventional'],
  parserPreset: {
    name: 'conventional-changelog-conventionalcommits',
    parserOpts: {
      // RegEx: type[scope]: subject
      // Use [^\]]+ to allow hyphens and special chars inside brackets
      headerPattern: /^(\w+)\[([^\]]+)\]:\s*(.*)$/,
      headerCorrespondence: ['type', 'scope', 'subject'],
    },
  },
  rules: {
    // Sentence Case for the subject
    // [Level, Applicability, Case]
    // 'sentence-case' ensures the first letter is capitalized, rest is lower
    'subject-case': [2, 'always', 'sentence-case'],

    //  Warn if the whole header is longer than 50 chars
    // [Level 1 = Warning, Applicability, Length]
    'header-max-length': [1, 'always', 50],

    // Block (Error) if the subject itself is longer than 72 chars
    // [Level 2 = Error, Applicability, Length]
    'subject-max-length': [2, 'always', 72],
    'type-enum': [2, 'always', ['feat', 'fix', 'chore', 'docs', 'ci', 'refactor']],
    'scope-enum': [2, 'always', ['pre-commit', 'commit-msg']],
    'scope-empty': [2, 'never'],
    'subject-empty': [2, 'never'],
  },
};
