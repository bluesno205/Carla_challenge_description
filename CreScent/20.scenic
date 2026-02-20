"""
Scenario Description 20.
The ego-vehicle must slow down or brake to allow a parked vehicle exiting a
parallel parking bay to cut in front.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

ego = Car on lead.lane.centerline,
        with constraint:
            follow_lane (duration = [1~5]):
                Speed(10)
            brake (duration = [1~3]):
                Position([5~15], behind = lead, at = 'end')

lead = Car on road,
        with constraint:
            change_to_left (duration = [1~5]):
                Position([5~10], ahead_of = ego, at = 'all')
		Lane(left_of = ego, at = 'start')
		Lane(same_as = ego, at = 'end')
                Speed(10)
            get_ahead (duration = [1~3]):
		Position([5~10], ahead_of = ego, at = 'all')
		Lane(same_as = ego, at = 'all')
                Speed(5)

park1 = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([20~30], ahead_of = lead, at = 'all')
		Lane(same_as = lead, at = 'start')

park2 = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([10~20], behind = lead, at = 'all')
		Lane(same_as = lead, at = 'start')