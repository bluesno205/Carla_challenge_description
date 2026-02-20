""" 
Scenario Description 12a.
The ego-vehicle encounters an obstacle blocking the lane and must perform a lane
change into traffic moving in the opposite direction to avoid it. The obstacle may be
a construction site, an accident or a parked vehicle.
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
                Position([0, path_length/3], at = 'start')
            get_ahead (duration = [3~5]):
                Speed(10)
            change_to_right (duration = [3~10]):
                Speed(10)
                Lane(right_of = oncomingCar, at = 'end')

blockingCar = Car on ego_lane_sec.centerline,
	with constraint:
	    keep_position(duration = [1~20]):
		Position([10, 20], ahead_of = ego, at = 'start')
		Lane(same_as = ego, at = 'start')

oncomingCar = Car on opp_lane_sec.centerline,
        with constraint:
             follow_lane (duration = [1~20]):
                Speed(10)
		Position([path_lengh/3, path_length/2], at = 'start')

oncomingCar1 = Car on opp_lane_sec.centerline,
        with constraint:
             follow_lane (duration = [1~20]):
                Speed(10)
		Position([10, 20], behind = oncomingCar, at = 'all')
		Lane(same_as = oncomingCar, at = 'all')

oncomingCar2 = Car on opp_lane_sec.centerline,
        with constraint:
             follow_lane (duration = [1~20]):
                Speed(10)
		Position([10, 20], ahead_of = oncomingCar, at = 'all')
		Lane(same_as = oncomingCar, at = 'all')