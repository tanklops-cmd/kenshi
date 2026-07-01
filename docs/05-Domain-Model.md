# 05 - Domain Model

The domain model should remain small and stable.

## Core Objects

### User

Stores user preferences, grade, dojo, theme, and optional sync/account settings.

### Session

A training event.

Examples:

- Club Keiko
- Seminar
- Shiai
- Grading
- Home Suburi

Contains date, type, location, reflection, guidance, moments, and next intention.

### Reflection

The user's own thinking about training.

Reflections may grow over time. Later thoughts should be added rather than overwriting the original reflection.

### Guidance

One coaching point from Sensei, senpai, seminar, or another trusted source.

Guidance is independent, linkable, and archivable. It should not be deleted casually.

### PracticeTopic

A unified object for both techniques and fundamentals.

Types:

- Technique
- Fundamental

Examples:

- Debana-men
- Kaeshi-do
- Seme
- Maai
- Tenouchi
- Footwork

### Moment

A short visual learning item, usually 5-10 seconds.

Can be a GIF, video clip, photo, or YouTube timestamp.

### MentalCue

Short, distilled reminders.

Examples:

- Wait
- Commit
- Relax right hand
- Win centre

Mental cues may be global or linked to specific Practice Topics.

### CurrentIntention

One active deliberate practice focus.

Example:

> Win centre before attacking.

Only one Current Intention should be active at a time.

### Knowledge

Curated reference content used in Learn.

Never personal. Never mixed with user reflections.

Each article is represented as a `LearnTopic` with a required category, title, summary,
and body. Optional fields reserved for future use:

- `difficulty` — a string label such as 'Beginner', 'Intermediate', or 'Advanced'.
- `relatedTopics` — a list of related topic IDs for cross-linking within the library.
- `references` — a list of source attributions (books, instructors, videos).

These fields are defined on the model but not populated in the initial seed content.
