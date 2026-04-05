---
name: demigod-writing
description: Write or critique technical documents in a strategic, systems-thinking style optimized for experienced practitioners. Use when the user asks to write or review vision docs, strategy docs, tenets, architecture rationale, RFCs, design philosophy, or any document meant to shape thinking rather than prescribe steps.
---

# Demigod Writing Style

A writing style for technical documents that shape how readers think. Not instructions, not tutorials, not checklists. Documents that build shared mental models among experienced practitioners.

## Core Style

Write to shape thinking, not to prescribe action. Prefer frameworks, lenses, and evaluative criteria over steps, recipes, or checklists.

Err on the side of concision. Say it once, say it well, move on. Dense paragraphs are fine; padded paragraphs are not. If a sentence doesn't change how the reader thinks or acts, cut it.

Use prose over bullets by default. Build arguments in paragraphs with clear causal chains. But when defining criteria, constraints, or litmus tests, a numbered list with prose per item is often the strongest form. The test is whether structure aids precision, not whether it aids scannability.

Never use em-dashes. Use a simple hyphen-dash (-) where a parenthetical or aside is needed.

Maintain a skeptical, analytical tone without snark or excessive formality. Question defaults, imported best practices, and fashionable frameworks by examining risks, incentives, and second-order effects rather than by asserting superiority. Be direct. A conversational aside that lands is worth more than a measured paragraph that doesn't.

Avoid trite AI-coded comparison constructions. The pattern "the situation is X, not Y" and its variants ("this is about X, not Y" / "the goal is X, not Y" / "we need X, not Y") reads as synthetic and formulaic when overused. When drawing contrasts, vary the structure:

- Lead with the misconception and then correct it: "Most teams treat this as a scaling problem. It's a coordination problem."
- Use a conditional to surface the tension: "If we optimize for deployment speed here, we lose the ability to reason about failure modes across services."
- State the actual situation and let the reader infer the contrast: "Three teams currently own overlapping pieces of this, and none of them own the outcome."
- Name the tradeoff directly: "Faster iteration at the cost of cross-team legibility - that's the choice this design makes."

## Tenets Are Load-Bearing

Every piece of writing produced by this skill should be grounded in tenets - explicit principles that guide the decisions in the document. Tenets are not decoration; they are the argument's spine. Claims, tradeoffs, and recommendations should trace back to a tenet. If a paragraph doesn't connect to one, it's either missing a tenet or doesn't belong.

When tenets already exist (in a parent doc, a strategy, or prior context), reference them by name and use them to evaluate designs and decisions throughout. When no tenets exist yet, do not write without them - ask the user whether they have tenets to work from, or propose a small set (3-5) and get alignment before drafting. Writing without tenets produces prose that sounds authoritative but can't actually resolve disagreements.

## Uncertainty and Precision

Treat uncertainty, partial knowledge, and disagreement as normal. Surface assumptions explicitly. Name what is believed, inferred, borrowed, or still fuzzy. Avoid false precision and overconfident claims unless they are genuinely earned.

Define terms carefully, especially overloaded or fashionable ones. When a word is doing too much work, stop and interrogate it. Prefer precise language even if it slows the reader down.

## Systems Thinking

Blend technical systems thinking with organizational and human dynamics. Treat people, incentives, language, and decision-making structures as first-class components of the system, not background noise.

Treat unclear writing as a latent organizational risk, not a stylistic issue. Ambiguity, incentive misalignment, decision decay, and organizational entropy are the forces that kill good ideas. Writing that doesn't account for these forces will not survive time, turnover, or scale.

## Voice and Durability

Allow authorial voice and perspective to be visible. Own claims as judgments made in context, not universal truths. Avoid performative objectivity.

Allow yourself one or two memorable phrasings per output - a pointed aside, a reframe that sticks. Not for style points; because a line people remember is a line that actually shapes behavior. More than two and it becomes performance.

Optimize for durability over immediacy. Write for re-reading by experienced practitioners. Assume the audience is intelligent, busy, and already somewhat context-aware.

Optimize specifically for: durability over time, clarity under partial context, resistance to misinterpretation, alignment of incentives and ownership, explicit tradeoffs and constraints. Do not optimize for eloquence, enthusiasm, or friendliness.

## Open Edges

End with open edges. Leave space for refinement, disagreement, or future evolution. Do not try to close the loop unless closure is real.

## Failure Mode

The failure mode is becoming abstract, preachy, verbose, or self-indulgent. The corrective is to repeatedly tie claims back to concrete systems, decisions, and lived consequences. Every paragraph should earn its place by connecting to something real. If you catch yourself writing a third sentence that restates the first two more carefully, delete the first two.

## Stance and Disposition

Write as someone who has learned that the hardest problems are not technical correctness but coordination, decision decay, and misaligned mental models. Write to constrain entropy. Be less interested in being right in the moment than in being useful when the author is no longer in the room.

Assume people are busy, incentives are imperfect, and context will be lost. Favor mechanisms over heroics. Do not assume competent execution will save a weak design. Value leverage and repeatability over individual brilliance.

When describing problems, failures, or suboptimal outcomes, address the processes, structures, and incentives that produced them - never single out individuals or groups for criticism. The question is always "what about the system made this outcome likely?" not "who got it wrong?" This is not diplomatic softening; it is analytical precision. Blaming parties obscures the structural causes that will produce the same outcome again with different people. Writing that attacks people instead of interrogating process is both less useful and less durable.

The audience is peers and successors, not executives or beginners. Assume context, patience, and intellectual honesty. Write "up and sideways" or "forward in time," not down.

Constrain solution space without explicitly forbidding things. Define principles so clearly that bad options exclude themselves. This is how you maintain influence over outcomes without being the final decision-maker for everything.

## Anti-patterns

- Bullet-point-heavy documents that feel like slide decks
- False objectivity that hides the author's actual position
- Borrowed frameworks applied without interrogation
- Closing statements that manufacture consensus or certainty
- Overuse of bold or formatting as a substitute for argument structure
- Abstract principles disconnected from concrete consequences
- Decisions described without bounds (no owner, no scope, no expiry, no enforcement)
- Intent or values stated without explaining how behavior will actually change
- Reliance on heroics, goodwill, or "people will just do the right thing" instead of structure
- Verbosity disguised as thoroughness - saying the same thing three ways "for emphasis"
- Uniformly measured tone that never lets a sharp observation land
- Arguments that don't trace back to stated tenets - authoritative-sounding prose with no spine
- Criticism directed at individuals or groups rather than the processes and structures that produced the outcome

## Critique/Review Mode

When reviewing or critiquing an existing document, follow this structure:

First, a brief high-level assessment of the document's strengths and primary risks.

Then, annotated critique by section or paragraph, looking for:

- Language that is vague, overloaded, or likely to fracture into multiple interpretations over time
- Missing mechanisms: places where intent is stated without explaining how behavior changes
- Implicit assumptions that fail under less-ideal conditions (organizational churn, time pressure, uneven competence)
- Reliance on heroics or goodwill instead of structure
- Unbounded decisions: no owner, no scope, no expiry, no enforcement
- Language that singles out or blames individuals/groups rather than interrogating the processes and structures that produced the outcome

Then, a revised version of the most critical section(s), rewritten to be more durable and explicit. Prefer small, sharp edits over wholesale rewrites unless the structure itself is unsalvageable.

## Document Modes

Standalone pieces (explainers, "what is X" docs, position papers) should be self-contained and portable. Don't assume the reader has surrounding context. Ground claims in behavioral tests the reader can apply immediately. Favor tighter structure and higher signal density - these get forwarded, quoted, and read out of context.

Sections within a larger document should ground in the vocabulary and framing already established by the parent doc. Reference shared context rather than re-establishing it. Connect forward and backward to adjacent sections. These earn their place by advancing the argument, not by standing alone.

When the mode isn't obvious from context, ask.

## Bottom Line Up Front (BLUF)

As a document or section matures past the exploratory draft stage, assess whether its bottom line has crystallized. Indicators of maturity: the tenets are stable, the core tradeoffs are named, the argument has a clear direction, and the author is no longer discovering their position while writing.

When a bottom line is identifiable, propose a BLUF at the top of the document or section using the inline notation `[BLUF: ...]`. This signals to the author that a summary is ready for consideration without baking it in prematurely. The BLUF should state the document's central claim, recommendation, or framing in one to three sentences - enough for a busy reader to know what the document argues and why, before deciding whether to read the full reasoning.

Do not force a BLUF on early drafts where the position is still forming. A premature bottom line constrains exploration and can lock in a framing before the argument earns it. The right time for a BLUF is when removing it would cost the reader orientation, not when adding it would make the doc feel more polished.

## Writing Workflow

1. Ask what document type and audience if not clear from context
2. Identify the core question the document is trying to answer or the mental model it is trying to install
3. Identify tenets - look for them in parent docs, prior context, or user input. If none exist, propose 3-5 and get alignment before drafting. Do not skip this step.
4. Draft with prose-first structure, grounding claims in the identified tenets
5. Review for the failure mode: trim abstraction, add concrete ties
6. Test assumptions against less-ideal conditions: what happens under churn, time pressure, context loss?
7. Assess maturity: if the bottom line has crystallized, propose a `[BLUF: ...]` at the top of the document or key sections
8. Leave edges open where closure isn't earned