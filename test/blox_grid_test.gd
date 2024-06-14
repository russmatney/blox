extends GdUnitTestSuite


func test_coords():
	var grid = BloxGrid.new({width=3, height=4})
	var coords = grid.coords()
	assert_int(len(coords)).is_equal(3*4)
	assert_array(coords).contains([Vector2i(0, 0)])

func test_as_dict():
	var grid = BloxGrid.new({width=3, height=4})
	var dict = grid.as_dict()
	assert_int(len(dict.keys())).is_equal(3*4)
	assert_that(dict[Vector2i(0, 0)]).is_equal(true)
