extends GdUnitTestSuite

## grid coords ############################################

func test_all_coords():
	var grid = BloxGrid.new({width=3, height=4})
	var coords = grid.all_coords()
	assert_int(len(coords)).is_equal(3*4)
	assert_array(coords).contains([Vector2i(0, 0)])

func test_all_coords_as_dict():
	var grid = BloxGrid.new({width=3, height=4})
	var dict = grid.all_coords_as_dict()
	assert_int(len(dict.keys())).is_equal(3*4)
	assert_that(dict[Vector2i(0, 0)]).is_false()
	assert_that(dict[Vector2i(0, 3)]).is_false()
	assert_that(dict[Vector2i(2, 0)]).is_false()
	assert_that(dict[Vector2i(2, 3)]).is_false()
	assert_that(Vector2i(3, 4) in dict).is_false()
	assert_that(Vector2i(3, 3) in dict).is_false()
	assert_that(Vector2i(2, 4) in dict).is_false()

## pieces ##################################################

func test_add_piece_and_piece_coords():
	var grid = BloxGrid.new({width=2, height=3})

	var crds = grid.piece_coords()
	assert_array(crds).is_empty()

	var p = BloxPiece.new({
		cells=[Vector2i()],
		coord=Vector2i(),
		})

	var ret = grid.add_piece(p)
	assert_bool(ret).is_true()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i()])

func test_can_add_piece():
	var grid = BloxGrid.new({width=2, height=3})

	var p = BloxPiece.new({
		cells=[Vector2i()],
		coord=Vector2i(),
		})

	var ret = grid.add_piece(p)
	assert_bool(ret).is_true()

	ret = grid.add_piece(p)
	assert_bool(ret).is_false()

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i()])


## tetris fall ##################################################

func test_can_piece_fall_tetris_style():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[Vector2i()], coord=Vector2i()})

	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i()])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(0, 1)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(0, 1)])


func test_can_piece_fall_tetris_style_tall():
	var grid = BloxGrid.new({width=2, height=4})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i.DOWN], coord=Vector2i()})

	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(), Vector2i(0, 1)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(0, 1), Vector2i(0, 2)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(0, 2), Vector2i(0, 3)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(2)
	assert_array(crds).contains([Vector2i(0, 2), Vector2i(0, 3)])

## tetris row clear ##################################################

func test_tetris_clear_rows():
	var grid = BloxGrid.new({width=2, height=2})
	grid.add_piece(BloxPiece.new({cells=[Vector2i()], coord=Vector2i()}))
	grid.add_piece(BloxPiece.new({cells=[Vector2i(), Vector2i(0, -1)], coord=Vector2i(1, 0)}))

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([Vector2i(), Vector2i(1, 0), Vector2i(1, -1)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0)])

	var cleared_count = grid.clear_rows()
	assert_int(cleared_count).is_equal(1)

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(1, 0)])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(1)
	assert_array(crds).contains([Vector2i(1, 1)])

## piece rotation ##################################################

func test_rotate_piece():
	var grid = BloxGrid.new({width=3, height=3})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i(1, 0)],
		coord=Vector2i(1, 1)})
	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_array(crds).contains([Vector2i(1, 1), Vector2i(2, 1)])

	# rotate once right (clockwise)
	grid.rotate_piece(p, Vector2i.RIGHT)
	assert_array(p.local_cells).contains([Vector2i(), Vector2i(0, 1)])
	crds = grid.piece_coords()
	assert_array(crds).contains([Vector2i(1, 1), Vector2i(1, 2)])

	# rotate back
	grid.rotate_piece(p, Vector2i.LEFT)
	assert_array(p.local_cells).contains([Vector2i(), Vector2i(1, 0)])
	crds = grid.piece_coords()
	assert_array(crds).contains([Vector2i(1, 1), Vector2i(2, 1)])

	# rotate once left (counter-clockwise)
	grid.rotate_piece(p, Vector2i.LEFT)
	assert_array(p.local_cells).contains([Vector2i(), Vector2i(0, -1)])
	crds = grid.piece_coords()
	assert_array(crds).contains([Vector2i(1, 1), Vector2i(1, 0)])

func test_rotate_piece_bump():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[Vector2i(), Vector2i(0, 1)],
		coord=Vector2i()})
	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_array(crds).contains([Vector2i(), Vector2i(0, 1)])

	# rotate clockwise, should bump to right
	grid.rotate_piece(p, Vector2i.RIGHT)
	assert_array(p.local_cells).contains([Vector2i(), Vector2i(-1, 0)])
	crds = grid.piece_coords()
	assert_array(crds).contains([Vector2i(), Vector2i(1, 0)])


## puyo split/fall ##################################################

func test_puyo_piece_split():
	var grid = BloxGrid.new({width=2, height=2})
	var p = BloxPiece.new({cells=[
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
		], coord=Vector2i()})
	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
		])

	grid.apply_split_puyo()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1),
	])

	grid.apply_step_tetris()

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(2)
	assert_int(len(crds)).is_equal(3)
	assert_array(crds).contains([
		Vector2i(),
		Vector2i(0, 1), Vector2i(1, 1),
	])


## puyo group clear ##################################################

func test_puyo_group_clear():
	var grid = BloxGrid.new({width=2, height=2})
	# TODO specify same color for cells
	var p = BloxPiece.new({cells=[
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		], coord=Vector2i()})
	grid.add_piece(p)

	var crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(1)
	assert_int(len(crds)).is_equal(4)
	assert_array(crds).contains([
		Vector2i(), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1),
		])

	var ret = grid.clear_groups()

	# should remove 4 cells
	assert_array(ret).contains([4])

	crds = grid.piece_coords()
	assert_int(len(grid.pieces)).is_equal(0)
	assert_int(len(crds)).is_equal(0)
