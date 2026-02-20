""" Scenario Description
Traffic Scenario 01.
The ego-vehicle loses control due to bad conditions on the road and it must recover,
coming back to its original lane
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

lane = Uniform(*network.lanes)

EGO_MODEL = "vehicle.lincoln.mkz_2017"

ego = Car on lane.centerline,
        with blueprint EGO_MODEL,
        with constraint:
            follow_lane (duration = 5):
                Speed(10)

debris1 = Debris following roadDirection from ego for Range(10, 20)
debris2 = Debris following roadDirection from debris1 for Range(5, 10)
debris3 = Debris following roadDirection from debris2 for Range(5, 10)