# Classic Ludo — default ruleset (release 1)

The engine (`lib/features/games/ludo/engine/ludo_engine.dart`) implements these
rules. Every switch below lives in `LudoRuleset`
(`lib/features/games/ludo/models/ludo_ruleset.dart`); the setup screen exposes
the "House rules" ones.

## Board

- Standard four-seat board, 15 × 15 grid. Red top-left, green top-right,
  yellow bottom-right, blue bottom-left. Turns go clockwise in that order.
- Shared track of 52 squares. Each colour starts on its own start square and
  travels once around (51 squares), then turns into its private home column of
  5 squares, then the centre. From the start square, exactly 56 steps reach the
  centre.
- Two or three seats use a subset of colours. With two seats, players sit
  opposite each other.

## Default rules

| Rule | Default | Configurable |
|---|---|---|
| Rolls that bring a token out of base | 6 | Yes: 6, or 1 and 6 |
| A six earns another roll | On | Yes (`extraTurnOnSix`) |
| Three sixes in a row end the turn; the third six cannot be used | On (limit 3) | Yes: any limit, or 0 for none |
| Capturing earns another roll | On | Yes |
| Bringing a token to the centre earns another roll | On | Yes (`extraTurnOnFinish`) |
| Start and star squares are safe | On | Yes |
| Exact roll needed to reach the centre | Always | No |
| Match end | Play on until one seat remains | Yes: end when the first seat finishes |
| Computer-only remainder | Ranked by progress once every person has finished | Yes |

## Details

- **Entering.** A token leaving base lands on its start square. It does not
  move further with the same roll.
- **Moving.** A token moves exactly the number rolled. A move that would pass
  the centre is not legal.
- **Captures.** Landing on a non-safe square occupied by opponent tokens sends
  all of them back to their bases. Your own tokens can share any square.
- **Safe squares.** The four start squares and the four star squares (8 steps
  after each start). Any number of colours can share them. Tokens in a home
  column can never be captured.
- **No legal move.** The turn passes, except that a six still earns another
  roll (and counts toward the three-sixes limit).
- **Moves made with earlier sixes stand** when the three-sixes limit is hit.
- **Finishing.** When a seat brings its fourth token home it is placed (1st,
  2nd, …) and skipped from then on. When one seat remains, it takes last
  place and the match ends.
- **Ranking by progress** (used by the "end when the first player finishes"
  option and for computer-only remainders): total squares travelled by all
  four tokens; ties go to the earlier seat in turn order.

## Not in this ruleset

- Blockades (two tokens forming a wall) are not used.
- A literal five-player game needs a different board and is not part of
  standard Ludo.
