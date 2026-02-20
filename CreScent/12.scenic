""" 
Scenario Description 12.
The ego-vehicle encounters an obstacle blocking the lane and must perform a lane
change into traffic moving in the same direction to avoid it. The obstacle may be
a construction site, an accident or a parked vehicle.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

ego = Car on road,
        with constraint:
	    follow_lane(duration = [1~3]):
		Speed (5)
            change_to_left (duration = [1~5]):
                Speed(10)
                Lane(same_as = lead, at = 'start')
                Lane(left_of = lead, at = 'end')
            get_ahead (duration = [3~5]):
                Speed([5~10])
                Position([5~15], ahead_of = lead, at = 'end')
            change_to_right (duration = [3~10]):
                Lane(same_as = lead, at = 'end')
                Speed(10)

lead = Car on road,
        with constraint:
        keep_position (duration = [1~23]):
		Lane(same_as = ego, at = 'start')
		Position(ahead_of = ego, at = 'start')

leftCar = Car on road,
        with constraint:
        get_ahead (duration = [1~23]):
		Position(ahead_of = ego, at = 'start')
		Lane(left_of = ego, at = 'start')
                Speed(10)

leftCar1 = Car on road,
        with constraint:
        get_ahead (duration = [1~23]):
		Position(behind = ego, at = 'start')
		Lane(same_as = leftCar, at = 'all')
                Speed(10)

leftCar2 = Car on road,
        with constraint:
        follow_lane (duration = [1~23]):
		Position(ahead_of = leftCar, at = 'all')
		Lane(same_as = leftCar, at = 'all')
                Speed(10)