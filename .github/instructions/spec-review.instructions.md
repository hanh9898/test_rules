---
applyTo: '**'
---
# Specification Review Instructions

## 1. Overview
This form is used to review all staged changes in the repository. The review process must follow the rules defined in `./.rules/spec_rules.md`. If any violations are found, they should be fixed before proceeding.

## 2. Goals
- Ensure all staged changes comply with the specification rules.
- Maintain code quality and consistency.

## 3. Non-Goals
- This process does not cover unstaged or committed changes.
- Does not address issues outside the scope of `spec_rules.md`.

## 4. Requirements
- All staged changes must be reviewed.
- All violations of `spec_rules.md` must be identified and fixed.

## 5. Proposed Solution
- Use automated and manual review to check staged changes against `spec_rules.md`.
- Apply fixes as needed to resolve any rule violations.

## 6. Alternatives Considered
- Manual review without reference to `spec_rules.md` (not recommended).
- Automated tools only, without manual verification.

## 7. Impact
- Ensures repository remains compliant with specification rules.
- Reduces risk of introducing errors or inconsistencies.

## 8. Open Questions
- Are there edge cases not covered by `spec_rules.md`?
- Should additional tools be integrated for automated checking?

## 9. Tools to Be Used
- `changes` for listing staged changes.
- `editFiles` for applying fixes.
- Reference file: `./.rules/spec_rules.md`.

---

*Complete all sections before submitting for review.*

