"""
Scenario Description 17.
The ego-vehicle encounters an obstacle/unexpected entity on the road and must
perform an emergency brake or an avoidance maneuver.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

npc = Pedestrian on road,
            with regionContainedIn None,
            with constraint:
                follow_lane (duration = [1~5]):
                    Speed(0)
                brake (duration = [1~5]):
                    Speed(0)

ego = Car on road,
        with constraint:
            follow_lane (duration = [1~5]):
                Speed([5~10])
                Lane(same_as = npc)
                Position([15~20], behind = npc, at = 'start')
            brake (duration = [1~5]):
                Position([5~7], behind = npc, at = 'end')