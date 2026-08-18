# 🛡️ Code Review Report
**Scope**: {TARGET_FILES_OR_DIFF}
**Overall Health Score**: {SCORE}/100 ({GRADE})

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
