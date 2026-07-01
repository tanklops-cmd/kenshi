# 14 - Decision Log

## DEC-001

Product is a deliberate practice companion, not a generic kendo app.

## DEC-002

Primary user is the committed kendoka, approximately 1 Kyu to 3 Dan.

## DEC-003

Reflection is the core workflow.

## DEC-004

The application optimises for the next keiko, not yesterday's statistics.

## DEC-005

AI is optional and not part of Version 1 foundations.

## DEC-006

Offline-first is mandatory.

## DEC-007

Flutter is the selected framework.

## DEC-008

SQLite is the selected local database.

## DEC-009

No account is required to start using the app.

## DEC-010

GitHub is the single source of truth for docs, issues, project management, and code.

## DEC-011

Version 1 navigation is Today, Reflect, Practice, Learn, Prepare.

## DEC-012

Practice Topics are unified. Techniques and Fundamentals share one page model.

## DEC-013

Moments are 5-10 seconds and represent one lesson.

## DEC-014

Guidance is stored as individual coaching notes.

## DEC-015

No gamification, streaks, social feeds, or achievement spam in Version 1.

## DEC-016

Product freeze applies until Version 1. New ideas go to backlog unless critical.

## DEC-017

Learn Library uses twenty categories reflecting the full scope of kendo study.
Empty categories remain visible to communicate encyclopedic intent.
Categories are defined as a Dart enum; article counts are displayed at the category list level.
Optional fields (difficulty, relatedTopics, references) are defined on LearnTopic for future use but not populated in seed content.

## DEC-018

Visual identity is calm, quiet, and Japanese-influenced.
The design language evokes a premium kendo journal, not a productivity utility.
A refined splash screen shows before the main application using the host theme;
the application under test constructs KendoCompanionApp directly and is unaffected.
The atmospheric background (AtmosphericBackground widget) uses extremely faint
enso-inspired arcs at ~4% gold opacity and is available for per-screen adoption.
Reduced-motion preferences are respected in both the splash and page transitions.
Navigation icon for Practice changed from fitness_center to sports_martial_arts.

## DEC-019

Visual identity follows the principle of Ma (間) — intentional space and silence.
Dark palette deepened: surface 0xFF161514, containers in the 0xFF1B–0xFF26 range,
providing richer charcoal depth consistent with a premium dojo journal aesthetic.
EnsoDecoration (open-circle motif) established as a branding / loading element.
KoiMotif (abstract koi silhouette) established as a recurring quiet signature;
appears in splash screen, empty states (FeaturePlaceholder), and the atmospheric
background. Opacity kept ≤ 0.20 throughout — the koi should feel discovered,
not displayed. ProgressIndicatorTheme set to gold primary colour. ListTile
vertical padding increased from 4 to 6 px to honour Ma spacing principles.
enso-inspired arcs at ~4% gold opacity and is available for per-screen adoption.
Reduced-motion preferences are respected in both the splash and page transitions.
Navigation icon for Practice changed from fitness_center to sports_martial_arts.
