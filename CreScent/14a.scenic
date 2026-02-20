""" 
Scenario Description 14a.
The ego-vehicle encounters a slow moving hazard blocking part of the lane. The ego-vehicle 
must brake or maneuver next to a lane of traffic moving in the opposite direction to avoid it.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town07.xodr')
param carla_map = 'Town07'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

lanes_with_left_lane = filter(lambda s: s._laneToLeft is not None, network.laneSections)
ego_lane_sec = random.choice(list(lanes_with_left_lane))
opp_lane_sec = ego_lane_sec._laneToLeft
path_length = ego_lane_sec.lane.centerline.length

ego = Car on ego_lane_sec.centerline,
        with constraint:
            change_to_left (duration = [1~5]):
                Speed(10)
                Position([0 ~ path_length/3], at = 'start')
		Lane(right_of = oncomingCar, at = 'start')
		Lane(same_as = oncomingCar, at = 'end')
            get_ahead (duration = [3~5]):
                Speed(10)
            change_to_right (duration = [3~10]):
                Speed(10)
                Lane(right_of = oncomingCar, at = 'end')

cyclist = Car on ego_lane_sec.centerline,
	with blueprint bicycles,
	with constraint:
	    follow_lane(duration = [1~20]):
		Position(10, ahead_of = ego, at = 'start')
		Lane(same_as = ego, at = 'start')

cyclist1 = Car on ego_lane_sec.centerline,
	with blueprint bicycles,
	with constraint:
	    follow_lane(duration = [1~20]):
		Position(10, ahead_of = cyclist, at = 'all')
		Lane(same_as = cyclist, at = 'all')

cyclist2 = Car on ego_lane_sec.centerline,
	with blueprint bicycles,
	with constraint:
	    follow_lane(duration = [1~20]):
		Position(10, ahead_of = cyclist1, at = 'all')
		Lane(same_as = cyclist1, at = 'all')

oncomingCar = Car on opp_lane_sec.centerline,
        with constraint:
             follow_lane (duration = [1~20]):
                Speed(10)
		Position([path_lengh/3, path_length/2], at = 'start')

oncomingCar1 = Car on opp_lane_sec.centerline,
        with constraint:
             follow_lane (duration = [1~20]):
                Speed(10)
		Position(20, behind = oncomingCar, at = 'all')
		Lane(same_as = oncomingCar, at = 'all')

oncomingCar2 = Car on opp_lane_sec.centerline,
        with constraint:
             follow_lane (duration = [1~20]):
                Speed(10)
		Position(20, ahead_of = oncomingCar, at = 'all')
		Lane(same_as = oncomingCar, at = 'all')