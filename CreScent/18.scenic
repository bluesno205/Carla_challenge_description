""" 
Scenario Description 18.
The ego-vehicle encounters an pedestrian emerging from behind a parked vehicle
and advancing into the lane. The ego-vehicle must brake or maneuver to avoid it.
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

npc = Pedestrian on road,
        with regionContainedIn None,
        with constraint:
            change_to_left (duration = [1~8]):
                Position([5~10], ahead_of = ego, at = 'all')
		Lane(right_of = ego, at = 'start')
		Lane(same_as = ego, at = 'end')
                Speed(1)
           
park1 = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([20~30], ahead_of = npc, at = 'all')
		Lane(same_as = lead, at = 'start')

park2 = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([10~20], behind = lead, at = 'all')
		Lane(same_as = park1, at = 'all')

park3 = Car on road,
        with constraint:
            keep_position (duration = [1~8]):
                Position([10~20], behind = park2, at = 'all')
		Lane(same_as = park2, at = 'all')