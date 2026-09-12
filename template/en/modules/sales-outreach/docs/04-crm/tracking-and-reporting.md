# CRM Tracking & Sales Reporting — {{PROJECT_NAME}}

> Specifications for lead logging, CRM status properties, weekly pipeline cadence, and metrics tracking for `{{PROJECT_NAME}}`.

---

## 1. CRM Lead Schema

Every lead logged in CRM or tracking sheet must include:
- `lead_id`: Unique identifier
- `company_name`: Target organization
- `contact_name`: Full name of prospect
- `contact_title`: Job title (must match `{{ICP_PROFILE}}`)
- `channel`: Outreach channel from `{{OUTREACH_CHANNELS}}`
- `status`: One of `Identified`, `Contacted`, `Engaged`, `Demo`, `Proposal`, `Won`, `Lost`
- `last_touch_date`: Timestamp of most recent communication
- `next_action_date`: Scheduled date for next follow-up
- `deal_value`: Estimated value towards `{{SALES_TARGET}}`

---

## 2. Weekly Sales Pipeline Review Cadence

Held weekly by the team and agent:
1. **Activity Review:** Number of new contacts added vs touchpoints sent.
2. **Pipeline Flow:** Deals moved from Engaged ➔ Qualified ➔ Proposal.
3. **Stalled Deals:** Any deal without activity for > 5 days flagged for re-engagement or disqualify.
4. **Target Tracking:** Current closed revenue against `{{SALES_TARGET}}`.

---

## 3. Key Conversion Metrics & KPIs

- **Positive Reply Rate:** Target `≥ 8%`
- **Meeting Booked Rate:** Target `≥ 3%` of total reached
- **Demo-to-Close Rate:** Target `≥ 25%`
