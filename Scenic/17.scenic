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

EGO_MODEL = "vehicle.lincoln.mkz2017"
EGO_SPEED = 10
SAFETY_DISTANCE = 10
BRAKE_INTENSITY = 1.0

PEDESTRIAN_MIN_SPEED = 1.0
THRESHOLD = 20

behavior EgoBehavior(speed=10):
    try:
        do FollowLaneBehavior(target_speed=speed)
    interrupt when withinDistanceToObjsInLane(self, SAFETY_DISTANCE):
        take SetBrakeAction(BRAKE_INTENSITY)

behavior PedestrianBehavior(min_speed=1, threshold=10):
    do CrossingBehavior(ego, min_speed, threshold)

lane = Uniform(*network.lanes)

spot = OrientedPoint on lane.centerline
vending_spot = OrientedPoint following roadDirection from spot for -3

pedestrian = Pedestrian right of spot by 3,
    with heading 90 deg relative to spot.heading,
    with regionContainedIn None,
    with behavior PedestrianBehavior(PEDESTRIAN_MIN_SPEED, THRESHOLD)

vending_machine = VendingMachine right of vending_spot by 3,
    with heading -90 deg relative to vending_spot.heading,
    with regionContainedIn None

ego = Car following roadDirection from spot for Range(-30, -20),
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED)

require (distance to intersection) > 75
require (ego.laneSection._slowerLane is None)
terminate when (distance to spot) > 50