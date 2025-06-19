# Specification Review Instructions

## 1. Overview
This form is used to review all unstaged changes in the repository. The review process must follow the rules defined in `./.rules/spec_rules.md`. If any violations are found, they should be fixed before proceeding.

## 2. Goals
- Ensure all changes comply with the specification rules.
- Maintain code quality and consistency.

## 3. Non-Goals
- This process does not cover staged or committed changes.
- Does not address issues outside the scope of `spec_rules.md`.

## 4. Requirements
- All unstaged changes must be reviewed.
- All violations of `spec_rules.md` must be identified and fixed.

## 5. Proposed Solution
- Use automated and manual review to check unstaged changes against `spec_rules.md`.
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
- `changes` for listing unstaged changes.
- `editFiles` for applying fixes.
- Reference file: `./.rules/spec_rules.md`.

## 10. Review Checklist
- [ ] All unstaged changes are reviewed
- [ ] All violations of `spec_rules.md` are fixed
- [ ] Tools used: `changes`, `editFiles`
- [ ] Reference to `spec_rules.md` is clear
- [ ] Open questions are documented

---

*Complete all sections before submitting for review.*
