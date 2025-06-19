---
applyTo: '**'
---
# Pull Request Code Review Instructions

## 0. Quick Checklist for Reviewers
- [ ] Đã xác định phạm vi thay đổi (model, controller, test...)?
- [ ] Đã kiểm tra các rule MUST/SHOULD/TIPS trong `.rules/spec_rules.md`?
- [ ] Đã kiểm tra test coverage và chất lượng test?
- [ ] Đã kiểm tra comment cũ để tránh lặp lại feedback?
- [ ] Đã dùng đúng tool MCP để lấy thông tin PR, file, nội dung file?

---

## 1. Overview
This instruction is used to review Pull Request code changes using the coding standards and rules defined in the `.rules/` folder. When a PR link is provided, analyze the code changes against all applicable rules to ensure code quality and consistency.

## 2. Goals
- Review PR code changes against established coding rules
- Identify violations of coding standards and best practices
- Provide actionable feedback for code improvements
- Ensure test coverage and quality standards are met

## 3. Non-Goals
- This does not cover deployment or infrastructure changes
- Does not address issues outside the scope of defined rules
- Does not perform functional testing of the application

## 4. Requirements
- All PR code changes must be reviewed against rules in `.rules/` folder
- Identify and report all rule violations with specific examples
- Provide clear recommendations for fixing violations
- Check test coverage and test quality according to testing standards

## 5. Review Process

### Step 1: Analyze PR Changes
When provided with a PR link:
1. Extract and analyze all code changes in the PR
2. Identify the types of changes (models, controllers, tests, etc.)
3. Categorize changes by file type and functionality

### Step 2: Apply Coding Rules
**Các rule quan trọng cần chú ý:**
- FactoryBot phải dùng giá trị random (ví dụ: `Faker::Name.name`)
- Không dùng let cho data cần tạo, phải dùng let!
- Không tạo record không cần thiết (tránh create_list lớn nếu không cần)
- Test date/time phải dùng travel_to, tránh hardcode date
- Subject đặt tên rõ ràng, context không lồng quá sâu
- Không dùng allow_any_instance_of trừ khi thực sự cần thiết
- Sử dụng shoulda-matchers cho validation phức tạp

**Ví dụ tốt/xấu:**
```ruby
# BAD
let(:user) { create(:user) }
# GOOD
let!(:user) { create(:user) }

# BAD
factory :user do
  name { "Taro Yamada" }
end
# GOOD
factory :user do
  name { Faker::Name.name }
end
```

Review changes against all rules in `.rules/` folder:
1. **Testing Standards** - Check if appropriate tests are written
   - RequestSpec, WorkerSpec, ModelSpec, MailerSpec, DecoratorSpec, HelperSpec
   - Verify business logic testing in ModelSpec
   - Check for shoulda-matchers usage for complex validations
   
2. **Code Quality Standards**
   - Verify proper use of FactoryBot with random default values
   - Check for proper date/time handling and boundary value analysis
   - Ensure proper use of `let!` vs `let` in tests
   - Verify no unnecessary record creation

3. **Best Practices**
   - Check for proper subject naming in tests
   - Verify context and describe structure
   - Ensure proper data setup in test scopes
   - Check for avoid_any_instance_of usage

### Step 3: Generate Review Report
Create a comprehensive review report including:
1. **Summary** - Overall assessment of the PR
2. **Rule Violations** - Specific violations found with file/line references
3. **Recommendations** - Actionable steps to fix violations
4. **Test Coverage Analysis** - Assessment of test completeness
5. **Code Quality Score** - Overall quality rating

## 6. Review Template

```markdown
# PR Review Report

## Summary
- **PR Title**: [Title]
- **Files Changed**: [Number] files
- **Lines Added/Removed**: +[X]/-[Y]
- **Overall Status**: ✅ APPROVED / ⚠️ NEEDS CHANGES / ❌ REJECTED

## Rule Violations Found

### MUST Fix Issues
- [ ] **[Rule Category]**: [Description]
  - **File**: `[filename]:[line]`
  - **Issue**: [Specific violation]
  - **Fix**: [Recommended solution]

### SHOULD Fix Issues
- [ ] **[Rule Category]**: [Description]
  - **File**: `[filename]:[line]`
  - **Issue**: [Specific violation]
  - **Fix**: [Recommended solution]

## Test Coverage Analysis
- **Test Files Added/Modified**: [List]
- **Coverage Assessment**: [Analysis]
- **Missing Tests**: [List if any]

## Recommendations
1. [Priority 1 recommendations]
2. [Priority 2 recommendations]
3. [Priority 3 recommendations]

## Code Quality Score: [X]/10
**Breakdown**:
- Testing: [X]/10
- Code Structure: [X]/10
- Best Practices: [X]/10
- Documentation: [X]/10
```

## 6.1. Example Review (Tham khảo)
```markdown
# PR Review Report

## Summary
- **PR Title**: Fix user validation logic
- **Files Changed**: 2 files
- **Lines Added/Removed**: +30/-10
- **Overall Status**: ⚠️ NEEDS CHANGES

## Rule Violations Found

### MUST Fix Issues
- [ ] **Testing Standards**: Không dùng shoulda-matchers cho validation phức tạp
  - **File**: `spec/models/user_spec.rb:15`
  - **Issue**: Test validation thủ công thay vì shoulda-matchers
  - **Fix**: Sử dụng `it { should validate_presence_of(:name) }`

### SHOULD Fix Issues
- [ ] **Best Practices**: Context lồng quá sâu
  - **File**: `spec/models/user_spec.rb:40`
  - **Issue**: 3 cấp context lồng nhau
  - **Fix**: Gộp context hoặc viết lại cho rõ ràng hơn

## Test Coverage Analysis
- **Test Files Added/Modified**: `spec/models/user_spec.rb`
- **Coverage Assessment**: Đã test đủ các nhánh logic chính, thiếu test cho trường hợp user guest
- **Missing Tests**: Test cho user guest

## Recommendations
1. Thêm test cho user guest
2. Refactor context lồng nhau
3. Sử dụng shoulda-matchers cho validation

## Code Quality Score: 7/10
**Breakdown**:
- Testing: 7/10
- Code Structure: 7/10
- Best Practices: 6/10
- Documentation: 8/10
```

## 7. Tools and References

### GitHub MCP Server Tools
Use these specific tools for PR analysis:

1. **get_pull_request_Github** - Get PR details and metadata
   - Parameters: `owner`, `repo`, `pullNumber`
   - Returns: PR title, description, status, author info

2. **get_pull_request_files_Github** - Get list of changed files
   - Parameters: `owner`, `repo`, `pullNumber`
   - Returns: Files changed with additions/deletions count

3. **get_pull_request_comments_Github** - Get existing PR comments
   - Parameters: `owner`, `repo`, `pullNumber`
   - Returns: All comments on the PR

4. **get_file_contents_Github** - Get content of specific files
   - Parameters: `owner`, `repo`, `path`, `branch`
   - Use to examine changed files in detail

5. **get_pull_request_comments_Github** - Get existing PR comments
   - Parameters: `owner`, `repo`, `pullNumber`
   - Returns: All comments on the PR

6. **add_issue_comment_Github** - Add review comments to PR
   - Parameters: `owner`, `repo`, `issue_number`, `body`
   - Use to post comprehensive review feedback
   - Note: PR number is used as issue_number

### Primary References
- `.rules/spec_rules.md` - Main coding standards and testing rules
- Any additional rule files in `.rules/` folder

### Review Categories
1. **MUST** - Critical violations that must be fixed
2. **SHOULD** - Important improvements that should be addressed
3. **TIPS** - Suggestions for better practices
4. **CONSIDER** - Items for future consideration

## 8. Usage Instructions

To use this instruction for PR review:

1. **Extract PR Information**: Parse GitHub PR URL to get `owner`, `repo`, `pullNumber`
2. **Fetch PR Details**: Use `get_pull_request_Github` to get PR metadata
3. **Get Changed Files**: Use `get_pull_request_files_Github` to list all changed files
4. **Analyze File Contents**: Use `get_file_contents_Github` for each changed file
5. **Apply Rules**: Check each file against rules in `.rules/` folder
6. **Generate Report**: Create comprehensive review report
7. **Post Review Comment**: Use `add_issue_comment_Github` to post detailed review feedback
8. **Check Existing Comments**: Use `get_pull_request_comments_Github` to avoid duplicate feedback

## 9. Example Usage

```
Please review this PR: https://github.com/user/repo/pull/123
```

**Step-by-step process:**
1. Parse URL: `owner="user"`, `repo="repo"`, `pullNumber=123`
2. Call `get_pull_request_Github(owner="user", repo="repo", pullNumber=123)`
3. Call `get_pull_request_files_Github(owner="user", repo="repo", pullNumber=123)`
4. For each changed file, call `get_file_contents_Github(owner="user", repo="repo", path="file_path")`
5. Apply all rules from `.rules/spec_rules.md` to the file contents
6. Generate detailed review report with violations and recommendations

## 10. GitHub MCP Tools Workflow

### Workflow Implementation:

```javascript
// 1. Parse PR URL
const prUrl = "https://github.com/user/repo/pull/123";
const [owner, repo, pullNumber] = parsePRUrl(prUrl);

// 2. Get PR details
const prDetails = await get_pull_request_Github({
  owner: owner,
  repo: repo,
  pullNumber: pullNumber
});

// 3. Get changed files
const changedFiles = await get_pull_request_files_Github({
  owner: owner,
  repo: repo,
  pullNumber: pullNumber
});

// 4. Analyze each file
for (const file of changedFiles) {
  const fileContent = await get_file_contents_Github({
    owner: owner,
    repo: repo,
    path: file.filename,
    mode: "full"
  });

  // Apply rules from .rules/spec_rules.md
  const violations = analyzeAgainstRules(fileContent, file.filename);
  // Add to review report
}

// 5. Check existing comments to avoid duplicates
const existingComments = await get_pull_request_comments_Github({
  owner: owner,
  repo: repo,
  pullNumber: pullNumber
});

// 6. Generate final review report
const reviewReport = generateReviewReport(violations, prDetails);

// 7. Post review comment to PR
const reviewComment = await add_issue_comment_Github({
  owner: owner,
  repo: repo,
  issue_number: pullNumber, // PR number is used as issue_number
  body: reviewReport
});
```

### Error Handling:
- Nếu gặp lỗi không lấy được file/PR, kiểm tra quyền truy cập repo và xác thực GitHub.
- Nếu file quá lớn hoặc binary, chỉ review phần code text.
- Luôn kiểm tra comment cũ để tránh lặp lại feedback.

## 10. Comment Templates and Best Practices

### Review Comment Template:
```markdown
## 🔍 Code Review Report

**PR Summary**: [Brief description]
**Files Reviewed**: [X] files
**Status**: ✅ APPROVED / ⚠️ NEEDS CHANGES / ❌ REJECTED

### 🚨 Critical Issues (MUST Fix)
- **File**: `path/to/file.rb:line`
  **Rule**: [Rule from spec_rules.md]
  **Issue**: [Specific violation]
  **Fix**: [Recommended solution]

### ⚠️ Important Issues (SHOULD Fix)
- **File**: `path/to/file.rb:line`
  **Rule**: [Rule from spec_rules.md]
  **Issue**: [Specific violation]
  **Fix**: [Recommended solution]

### 💡 Suggestions (TIPS)
- [Improvement suggestions]

### ✅ Good Practices Found
- [Highlight positive aspects]

### 📊 Test Coverage Analysis
- **Test Files**: [List of test files]
- **Coverage**: [Assessment]
- **Missing Tests**: [If any]

---
*Review generated using rules from `.rules/spec_rules.md`*
```

### Comment Best Practices:
1. **Be Constructive**: Focus on improvement, not criticism
2. **Be Specific**: Reference exact files and line numbers
3. **Provide Context**: Explain why the rule exists
4. **Offer Solutions**: Don't just point out problems, suggest fixes
5. **Acknowledge Good Work**: Highlight positive aspects
6. **Use Emojis**: Make comments more readable and friendly

## 11. Quality Gates

Before approving a PR, ensure:
- [ ] All MUST violations are fixed
- [ ] Test coverage meets standards
- [ ] Code follows established patterns
- [ ] Documentation is updated if needed
- [ ] No regression risks identified

## 12. GitHub MCP Tools Reference

### Required Tools:
- `get_pull_request_Github` - Fetch PR metadata
- `get_pull_request_files_Github` - Get list of changed files
- `get_file_contents_Github` - Read file contents for analysis
- `add_issue_comment_Github` - Post comprehensive review feedback

### Recommended Tools:
- `get_pull_request_comments_Github` - Read existing comments (avoid duplicates)
- `get_pull_request_status_Github` - Check PR status

### Comment Tools Usage:
```javascript
// Check existing comments first
const existingComments = await get_pull_request_comments_Github({
  owner: "user",
  repo: "repo",
  pullNumber: 123
});

// Post review comment
const comment = await add_issue_comment_Github({
  owner: "user",
  repo: "repo",
  issue_number: 123, // PR number
  body: reviewReportMarkdown
});
```

### Authentication:
- Ensure GitHub authentication is properly configured
- Handle rate limiting appropriately
- Respect repository access permissions

---

*Hướng dẫn này giúp đảm bảo review PR nhất quán, bám sát rule và tăng chất lượng codebase.*

# END OF FILE
