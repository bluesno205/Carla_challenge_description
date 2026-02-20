""" 
Scenario Description 21.
The ego-vehicle must exit a parallel parking bay into a flow of traffic.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

ego = Car on road,
        with constraint:
            change_to_left (duration = [1~8]):
		Lane(same_as = npc, at = 'end')
                Speed(10)

npc = Car on lead.lane.centerline,
        with constraint:
            follow_lane (duration = [1~8]):
                Speed(5)
		Position([0~5], ahead_of = ego, at = 'start')
                Lane(left_of = ego, at = 'start')

npc1 = Car on lead.lane.centerline,
        with constraint:
            follow_lane (duration = [1~8]):
                Speed(5)
		Position([0~5], ahead_of = npc, at = 'start')
                Lane(same_as = npc, at = 'all')

npc2 = Car on lead.lane.centerline,
        with constraint:
            follow_lane (duration = [1~8]):
                Speed(5)
		Position([0~5], ahead_of = npc1, at = 'start')
                Lane(same_as = npc1, at = 'all')

park = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([10~20], ahead_of = ego, at = 'start')
		Lane(same_as = ego, at = 'start')

park2 = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([10~20], behind = ego, at = 'all')
		Lane(same_as = park, at = 'all')