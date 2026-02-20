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

EGO_MODEL = "vehicle.lincoln.mkz2017"
EGO_SPEED = 10

behavior EgoBehavior(speed=10):
    do FollowLaneBehavior(speed)

lane = Uniform(*network.lanes)

start = OrientedPoint on lane.centerline
ego = Car at start,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED)

debris1 = Debris following roadDirection for Range(10, 20)
debris2 = Debris following roadDirection from debris1 for Range(5, 10)
debris3 = Debris following roadDirection from debris2 for Range(5, 10)

require (distance to intersection) > 50
terminate when (distance from debris3 to ego) > 10 and (distance to start) > 50
