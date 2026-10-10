# Session Plan & Instructional Materials — {{PROJECT_NAME}}

> Canonical document establishing the session lesson plan structure, learning materials inventory, facilitator delivery guidelines, and technical environment readiness for `{{PROJECT_NAME}}`.

---

## 1. Delivery Configuration & Context

| Parameter | Value |
|---|---|
| **Instructional Delivery Model** | `{{TRAINING_TYPE}}` |
| **Participant Demographics** | `{{TARGET_LEARNER}}` |
| **Curriculum Scope** | `{{CURRICULUM_SCOPE}}` |
| **Delivery Medium / Platform** | Dedicated LMS, Virtual Classroom / Physical Lab |
| **Program Lead** | `{{DECISION_OWNER}}` |

---

## 2. Session Lesson Plan Architecture

Every learning session follows an intentional pedagogical cadence:

| Time Allocation | Session Block | Learning Activities | Pedagogical Tooling |
|---|---|---|---|
| **10% (10–15 mins)** | Opening & Alignment | Welcome greeting, attendance verification, session objective briefing, recap | Interactive warmup Q&A |
| **30% (30–45 mins)** | Conceptual Lecture & Live Demo | Core theory presentation, case exposition, instructor-led walkthrough | Slide deck, live coding/demo |
| **45% (45–60 mins)** | Hands-on Lab & Active Build | Learners solve workbook exercises or implement challenge tasks | Self-paced lab, breakout room coaching |
| **15% (15–20 mins)** | Assessment, Q&A, & Wrap-up | Common blockers debrief, instant concept check, peer feedback, reading assignment | Quick poll / quiz form |

---

## 3. Instructional Materials Inventory

| Material Item | Description & Format | Storage Location / Link | Readiness Status |
|---|---|---|---|
| **Slide Decks** | Standardized presentation decks (PDF / Slides) | `docs/assets/slides/` | [ ] Verified |
| **Lab Manuals** | Step-by-step exercise guides with edge case notes | `docs/labs/exercise-guide.md` | [ ] Verified |
| **Starter Code / Data** | Seed repositories or benchmark datasets | `src/exercises/` or Shared Drive | [ ] Verified |
| **Quick Reference Sheet** | 1–2 page cheat sheet summarizing syntax and concepts | `docs/assets/cheatsheet.pdf` | [ ] Verified |
| **Session Recordings** | Archived session video streams for asynchronous review | `{{PROJECT_NAME}}` LMS Portal | [ ] Post-Session |

---

## 4. Facilitator & Instructor Guidelines

1. **Pre-Session Readiness Checklist (T-30 Minutes):**
   - [ ] Test audio, video, microphone clarity, and screen sharing permissions.
   - [ ] Verify that cloud sandbox instances, lab repos, and learner accounts are operational.
   - [ ] Stage attendance verification links and digital exercise handouts.
2. **Interactive Facilitation Strategies:**
   - Prompt participants every 15 minutes to ensure cognitive engagement.
   - Apply the *Show, Tell, and Do* sequence prior to unguided practical drills.
   - Delegate individualized troubleshooting to teaching assistants (TAs) to maintain group pace.

---

## 5. Technical Infrastructure & Environment

- **Workstation Requirements:** Learner laptops meeting hardware specs with minimum 10 Mbps connectivity.
- **Software Tooling:** Pre-installed software dependencies verified via installation smoke test prior to Day 1.
- **Support Channels:** Dedicated instant messaging channels (*Slack / Discord / Teams*) for real-time technical escalations.
