# 🛡️ Code Review Report
**Scope**: {TARGET_FILES_OR_DIFF}
**Overall Health Score**: {SCORE}/100 ({GRADE})

> **How the score is computed (deterministic rubric):**
> Start at **100**, then subtract per finding:
> - 🚨 Blocker: **−20** each
> - ⚠️ Warning: **−8** each
> - 💡 Suggestion: **−2** each
> - ✅ Commendation: **0** (no effect on score)
>
> Clamp the result to the range **0–100**.
> **Grade mapping:** `A+` = 97–100, `A` = 90–96, `B` = 80–89, `C` = 70–79, `D` = 60–69, `F` = 0–59.

---

## 📊 Summary of Findings
| Severity | Count | Status |
| :--- | :--- | :--- |
| 🚨 **Blockers** | {BLOCKERS_COUNT} | {BLOCKERS_STATUS} |
| ⚠️ **Warnings** | {WARNINGS_COUNT} | {WARNINGS_STATUS} |
| 💡 **Suggestions** | {SUGGESTIONS_COUNT} | Optional improvements |
| ✅ **Commendations** | {COMMENDATIONS_COUNT} | Clean Architecture patterns |

---

## 🚨 Blockers (Must Fix)
{BLOCKERS_LIST}

---

## ⚠️ Warnings (Potential Bugs / Edge Cases)
{WARNINGS_LIST}

---

## 💡 Suggestions & Minor Optimizations
{SUGGESTIONS_LIST}

---

## ✅ Commendations & Best Practices
{COMMENDATIONS_LIST}

---

## 🛠️ Verification Commands
```bash
flutter analyze
flutter test
```
