# CHANGELOG


## Untagged


## 


### 21 Jun 2024

- ([`8ef3f15`](https://github.com/russmatney/blox/commit/8ef3f15)) feat: drop in crtv shader

  > from: https://godotshaders.com/shader/vhs-and-crt-monitor-effect/
  > 
  > nice effect! will have to study this code!


### 20 Jun 2024

- ([`1f58a5d`](https://github.com/russmatney/blox/commit/1f58a5d)) fix: bigger cell size, non-resizable window

  > and a proper movie_writer file

- ([`1cd521a`](https://github.com/russmatney/blox/commit/1cd521a)) fix: misc clean up/log noise reduction

  > Recorded a great playthrough with no bugs!!

- ([`af390d8`](https://github.com/russmatney/blox/commit/af390d8)) feat: ticking and effects in lock step!

  > Finally gets a handle on the flow - waiting for animations to complete
  > before going to the next step. Huzzah!
  > 
  > A bit of a mess, and difficult to test - should refactor to separate
  > determining the next step() action separate from performing it.
  > 
  > the action_queue was a nice fix here, and a few things can be cleaned
  > up (e.g. the extra set of on_blah_complete signals).

- ([`ba4acdd`](https://github.com/russmatney/blox/commit/ba4acdd)) feat: score, restart, wip more tick control

  > The pace/state is a mess right now - need to get a better handle on the
  > timing of it. probably moving to an explicit state machine would help -
  > we need to move back and forth between split/clear/fall with arbitrary animations.

- ([`955d266`](https://github.com/russmatney/blox/commit/955d266)) wip: node instead of node2d, color rect bg
- ([`1c7860e`](https://github.com/russmatney/blox/commit/1c7860e)) wip: rough hud outline and dynamic sizing

  > Adds a bloxTheme and some basic containers to the BloxGame's ui layer.

- ([`8eeef8b`](https://github.com/russmatney/blox/commit/8eeef8b)) feat: game scene with camera centering the grid
- ([`2465509`](https://github.com/russmatney/blox/commit/2465509)) refactor: read puyo_group_size from grid_rules

  > maybe should be setting grid_rules on the grid directly, rather than
  > passing it through these funcs? eh, nice to use different ones in misc situations.

- ([`cb3beec`](https://github.com/russmatney/blox/commit/cb3beec)) feat: smooth falling via basic position tween
- ([`80699c6`](https://github.com/russmatney/blox/commit/80699c6)) readme: add misc social links

  > Including some commented out workflow statuses and itch links (coming
  > soon!)


### 19 Jun 2024

- ([`6164d4f`](https://github.com/russmatney/blox/commit/6164d4f)) wip: very rough group/row clear animation

  > Need to stop the action while this anims run... but then it's all FX
  > time.

- ([`37137ae`](https://github.com/russmatney/blox/commit/37137ae)) test: coverage for instance_ids

  > Making sure this actually works!

- ([`367a518`](https://github.com/russmatney/blox/commit/367a518)) feat: refactor to maintain BloxCell objects

  > Rather than create new cells in a few places (splitting, rotation,
  > adjusting coords), this maintains the cell objects. Ought to cover this
  > in unit tests!
  > 
  > I'm hopeful this makes tracking the cell-rect per cell across renders
  > reasonable.

- ([`6a375ff`](https://github.com/russmatney/blox/commit/6a375ff)) feat: introduce GridRules object

  > A potential base object for codifying the rules applied per grid.step()

- ([`3150de1`](https://github.com/russmatney/blox/commit/3150de1)) wip: towards animated group clearing

  > Not working yet - i'd hoped the signal emits would be blocking - maybe
  > they are, but the next tick already fires? probably better to use an
  > explicit state check before the next render wipes the current state.

- ([`dbd12fd`](https://github.com/russmatney/blox/commit/dbd12fd)) fix: remove empty pieces from initial bloxBucket

  > tool script backfiring yet again. Game working again!

- ([`7a0c4b0`](https://github.com/russmatney/blox/commit/7a0c4b0)) wip: refactors bloxCell to use grid_coord (not local_coord)

  > Removes local_cells and root_coord from piece in favor of maintaining
  > grid_cells instead. This lets cells be independent rather than needing
  > to deal with some relative root coord. otherwise passing around
  > BloxCells is pretty useless.
  > 
  > Still an issue - we never seem to leave the 'falling' state in grid.step()

- ([`e3097fe`](https://github.com/russmatney/blox/commit/e3097fe)) feat: clear current_piece, skip ticks/renders when no current_piece

  > Bucket now clears the current_piece whenever settled, splitting, or
  > clearing - the prevents inputs from moving the split pieces around.
  > 
  > We also require a current_piece when delaying the next tick - now the
  > pieces 'fall' immediately, which feels better. Hopefully the signals
  > will be able to animate nicely as well.

- ([`974c2a6`](https://github.com/russmatney/blox/commit/974c2a6)) feat: first feature flags in use

  > Adds opts conditionals for grid.step(). This will break the bucket test,
  > and grid.step() should get some basic test coverage for each of these.
  > 
  > This opts dict should grow into a resource/object/entity of some kind -
  > ideally something composable like map_defs, and likely bringing piece
  > shapes, cell-colors, and other mechanics/feats.
  > 
  > Still seeing tetris pieces fall further than expected in some cases - do
  > they get locked to the row they are first set in? Right now gravity
  > pulls them down. probablly need to set a row when they land and adjust
  > it as rows are cleared.

- ([`f5d8456`](https://github.com/russmatney/blox/commit/f5d8456)) refactor: pull bucket tick into grid step logic

  > Makes more sense for the grid to own this step(opts) function - it's
  > important to get the order right, and it'll help the consumers handle
  > various game modes correctly.
  > 
  > the bucket/grid tests are a bit duped right now, but it's nice to have
  > both 'tick' and 'step' unit tested at least, so i'm leaving the bucket
  > tests for now.


### 18 Jun 2024

- ([`f6129d3`](https://github.com/russmatney/blox/commit/f6129d3)) chore: drop some noisey logs

  > don't log when we're just hitting the bottom.

- ([`c75468b`](https://github.com/russmatney/blox/commit/c75468b)) misc: bucket cell color by 3s
- ([`ad68c9a`](https://github.com/russmatney/blox/commit/ad68c9a)) fix: maintain cell color across puyo split

  > Gameplay making alot more sense now! Tetris and puyo clears.

- ([`210641d`](https://github.com/russmatney/blox/commit/210641d)) fix: render the cell color, not piece color

  > Good news! It was working, just rendering the wrong colors, which was
  > VERY confusing.

- ([`d1b6300`](https://github.com/russmatney/blox/commit/d1b6300)) test: more complex bucket piece clearing

  > still not catching the bug i saw... did the tweaks fix it?

- ([`d36ec07`](https://github.com/russmatney/blox/commit/d36ec07)) refactor: basic bloxBucket tick() test

  > setting up some bucket-level tests to debug the current behavior

- ([`e85f894`](https://github.com/russmatney/blox/commit/e85f894)) wip: ugh this game is buggy!

  > Ought to target BloxBucket's tick() with some tests next - going to be
  > complicated and that might be a better target for mechanic flags.

- ([`170aafe`](https://github.com/russmatney/blox/commit/170aafe)) chore: default coord and color in bloxCell
- ([`a9dee8c`](https://github.com/russmatney/blox/commit/a9dee8c)) fix: prevent double-moves

  > moving the root_coord AND the local_cell is not right! fortunately this
  > was a no-op before (the array of vector2is wasn't updating at all.)

- ([`5582b4d`](https://github.com/russmatney/blox/commit/5582b4d)) fix: couple more BloxCell local_cells fixes

  > A few more places to maybe complete this refactor - tho other tests are
  > failing now - the rotate is weird and the tetris rules are failing now
  > that puyo split/groups have been introduced


### 17 Jun 2024

- ([`2d1f358`](https://github.com/russmatney/blox/commit/2d1f358)) wip: some BloxCell structure

  > Moving the BloxPiece's local_cells from Vector2i to a new resource. Not
  > sure I like it - interesting to see where it complicates things a it.
  > 
  > Tests and probably the game still crashing rn.


### 16 Jun 2024

- ([`2af14bf`](https://github.com/russmatney/blox/commit/2af14bf)) fix: don't multiply collected dots so much

### 15 Jun 2024

- ([`300008a`](https://github.com/russmatney/blox/commit/300008a)) wip: puyo group clear unit test and some fixes

  > Nearly correct - not redundantly removing pieces nearly as many times as
  > before. Now to get the recursive neighbor walk to skip already visited
  > cells.

- ([`d146800`](https://github.com/russmatney/blox/commit/d146800)) wip: puyo group clear structure

  > A few things to work through: a BloxCell data type to hold a coord and
  > color, and refactoring into a reduce with an accumulator to prevent the
  > 'collected/visited' dupe-blow-up.

- ([`3afa4b5`](https://github.com/russmatney/blox/commit/3afa4b5)) feat: puyo split test coverage, improved naming, bug fix

  > Couple issues - we now skip the bottom row completely in this check (to
  > avoid having to care if 'below' the bottom is empty/off-the-grid). we
  > also correct the `if p_below: continue` logic, which was backwards - we
  > skip when there is already a piece below us.
  > 
  > Also improves some to_pretty() to help with debugging.

- ([`50299aa`](https://github.com/russmatney/blox/commit/50299aa)) wip: incomplete puyo split impled

  > Not working correctly, but a bunch of structure. Going to write some
  > unit tests for the bugs i'm seeing next.

- ([`13aa4e5`](https://github.com/russmatney/blox/commit/13aa4e5)) fix: rerender after move/rotate

  > duh! dramatic improvement in player feedback, missed this on the first impl.

- ([`1ed9558`](https://github.com/russmatney/blox/commit/1ed9558)) refactor: empty/piece cells use size-factor instead of fixed size_diff

  > A factor is much better than a fixed value here, so everything can stay
  > in terms of the cell_size.

- ([`07cbbc7`](https://github.com/russmatney/blox/commit/07cbbc7)) wip: resource_saved doesn't seem to fire when an external script is changed

  > well damn, can't quite get a scene-reload on file-save.

- ([`86bab5a`](https://github.com/russmatney/blox/commit/86bab5a)) feat: reload the scene whenever a resource is saved

  > Nice if you have an editor visual you want to update from the code.
  > 
  > From: https://github.com/godotengine/godot/issues/28580#issuecomment-2170959586

- ([`52224b1`](https://github.com/russmatney/blox/commit/52224b1)) feat: add actual tetris shapes, adjust rotation

  > Rotation feels a bit more normal now - tho it is possible to 'telegraph'
  > the shape across would-be diagonal blockers. Not 100% about this
  > ensure_top_left feat, but i like the reusable function.

- ([`0e1fc29`](https://github.com/russmatney/blox/commit/0e1fc29)) feat: basic piece rotation 'bumping'

  > Rotations with horizontal conflicts will attempt to 'bump' away from the
  > conflict one cell. We probably want to try to bump more than one cell
  > for certain piece shapes - i.e. this still won't allow a 4-tall piece to
  > rotate if you're next to the wall.

- ([`aed85af`](https://github.com/russmatney/blox/commit/aed85af)) refactor: more move/rotate logic dry up
- ([`ac5bdb6`](https://github.com/russmatney/blox/commit/ac5bdb6)) refactor: cleaner can-move/rotate logic impl
- ([`6f93026`](https://github.com/russmatney/blox/commit/6f93026)) feat: basic piece rotation and test
- ([`9fa1b82`](https://github.com/russmatney/blox/commit/9fa1b82)) feat: tetris rows clearing
- ([`7fbb957`](https://github.com/russmatney/blox/commit/7fbb957)) feat: blocks queuing, moving, and falling

  > Building up to a basic tetris game - helpers for generating pieces from
  > a list of shapes, consistent piece colors, moving pieces (if they can
  > move), and firing a tick/timer as a 'current' piece falls.

- ([`65a269b`](https://github.com/russmatney/blox/commit/65a269b)) feat: pull in basic static Trolls helpers

  > and adds wasd to ui_* movement.


### 14 Jun 2024

- ([`f075c45`](https://github.com/russmatney/blox/commit/f075c45)) feat: rendering and tetris-dropping pieces on click
- ([`30b7828`](https://github.com/russmatney/blox/commit/30b7828)) feat: basic tetris falling block logic
- ([`db929e2`](https://github.com/russmatney/blox/commit/db929e2)) feat: basic BloxPiece and BloxGrid add_piece() support
- ([`5724026`](https://github.com/russmatney/blox/commit/5724026)) wip: basic BloxGrid and BloxBucket, initial gdunit test

  > also adds a blox-addon to provide some editor interface features

- ([`42b16c3`](https://github.com/russmatney/blox/commit/42b16c3)) docs: link to gwj70
- ([`7d7d8ba`](https://github.com/russmatney/blox/commit/7d7d8ba)) deps: add initial addson

  > - asepriteWizard
  > - gdunit
  > - pandora
  > - input/sound helper/manager
  > - gdfxr
  > - gdplug
  > - log.gd
  > 
  > All specified by `plug.gd`
