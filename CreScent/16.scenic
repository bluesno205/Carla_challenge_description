""" 
Scenario Description 16.
The leading vehicle decelerates suddenly due to an obstacle and the ego-vehicle
must perform an emergency brake or an avoidance maneuver.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

lane = Uniform(*network.lanes)

leadCar = Car on road,
            with constraint:
                follow_lane (duration = [1~5]):
                    Speed(10)
                brake (duration = [1~5]):
                    Speed(0, at = 'end')

ego = Car on road,
        with constraint:
            follow_lane (duration = [1~5]):
                Speed(10)
                Lane(same_as = leadCar)
                Position([5~20], behind = leadCar, at = 'start')
            brake (duration = [1~5]):
                Position([5~7], behind = leadCar, at = 'end')