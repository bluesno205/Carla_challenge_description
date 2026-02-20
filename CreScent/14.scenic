""" 
Scenario Description 14.
The ego-vehicle encounters a slow moving hazard blocking part of the lane. The ego-vehicle 
must brake or maneuver next to a lane of traffic moving in the same direction to avoid it.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

lead = Car on road,
	with blueprint bicycles,
        with constraint:
        follow_lane (duration = [1~23]):
		Position(ahead_of = ego, at = 'start')
                Speed(1)

lead1 = Car on road,
	with blueprint bicycles,
        with constraint:
        follow_lane (duration = [1~23]):
		Position(ahead_of = lead, at = 'all')
		Lane(same_as = lead, at = 'all')
                Speed(1)

lead2 = Car on road,
	with blueprint bicycles,
        with constraint:
        follow_lane (duration = [1~23]):
		Position(ahead_of = lead1, at = 'all')
		Lane(same_as = lead, at = 'all')
                Speed(1)

ego = Car on lead.lane.centerline,
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
           
leftCar = Car on road,
        with constraint:
        get_ahead (duration = [8~23]):
		Position(ahead_of = ego, at = 'all')
		Lane(left_of = ego, at = 'start')
                Speed(10)

leftCar1 = Car on road,
        with constraint:
        follow_lane (duration = [1~23]):
		Position(ahead_of = leftCar, at = 'all')
		Lane(same_as = leftCar, at = 'all')
                Speed(10)

leftCar2 = Car on road,
        with constraint:
        follow_lane (duration = [1~23]):
		Position(behind = ego, at = 'start')
		Lane(same_as = leftCar, at = 'all')
                Speed(10)